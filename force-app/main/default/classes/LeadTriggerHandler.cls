/*
 * Name: LeadTriggerHandler
 * Purpose: Handler class for Lead Trigger
 * Author: Nagarro
 * Created Date: 11/09/2018
 *
 *  Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public with sharing class LeadTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarAfterDelete = true;
  List<Lead> newLeadList;
  List<Lead> oldLeadList;
  Map<Id, Lead> oldLeadMap = new Map<Id, Lead>();
  Map<Id, Lead> newLeadMap = new Map<Id, Lead>();

  //Constructor
  public LeadTriggerHandler() {
    this.newLeadList = (List<Lead>) Trigger.new;
    this.oldLeadList = (List<Lead>) Trigger.old;
    this.oldLeadMap = (Map<Id, Lead>) Trigger.oldMap;
    this.newLeadMap = (Map<Id, Lead>) Trigger.newMap;
  }
  //Override the before insert method
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      System.debug('beforeInsert: ' + newLeadList);
      recursionVarBeforeInsert = false;
      ConvertUpperCase.convertToUpperCase('Lead', newLeadList);
      validatePhoneFormat(newLeadList, oldLeadMap);
      validateMobileFormat(newLeadList, oldLeadMap);
      checkIfLeadIsConversionReady(newLeadList, newLeadMap, null, null);
    }
  }

  //Override the before update method
  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      recursionVarBeforeUpdate = false;
      ConvertUpperCase.convertToUpperCase('Lead', newLeadList);
      validatePhoneFormat(newLeadList, oldLeadMap);
      validateMobileFormat(newLeadList, oldLeadMap);
      checkIfLeadIsConversionReady(
        newLeadList,
        newLeadMap,
        oldLeadList,
        oldLeadMap
      );
      updatePreviousOwnerField(newLeadList, oldLeadMap);
      throwLeadConversionErrors(newLeadList, oldLeadMap);
    }
  }

  //Override the before delete method
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      recursionVarBeforeDelete = false;
      restrictLeadDeletion(oldLeadList);
    }
  }

  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      System.debug('afterInsert: ' + newLeadList);
      recursionVarAfterInsert = false;
      assignLeadsCreatedBySalesAgentToMarketManager(newLeadList);
      List<Id> leadIdList = new List<Id>();
      for (Lead l : newLeadList)
        leadIdList.add(l.Id);
      //createTask(leadIdList);
      //createInitiativeTaskForLeadOwner(newLeadList, oldLeadMap);
    }
  }

  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;
      List<Id> leadIdList = new List<Id>();
      for (Lead leadObj : newLeadList) {
        if (
          oldLeadMap.get(leadObj.Id).Followup__c !=
          newLeadMap.get(leadObj.Id).Followup__c ||
          oldLeadMap.get(leadObj.Id).OwnerId !=
          newLeadMap.get(leadObj.Id).OwnerId ||
          oldLeadMap.get(leadObj.Id).Hot_Lead__c !=
          newLeadMap.get(leadObj.Id).Hot_Lead__c
        ) {
          leadIdList.add(leadObj.Id);
        }
      }
      //createTask(leadIdList);
      //sendEmailToOldLeadQueueOwners(newLeadList, oldLeadMap);
      manageInitiativeOnConvert(newLeadList, oldLeadMap);
      //createInitiativeTaskForLeadOwner(newLeadList, oldLeadMap);

      addSalesAgentToAccountOpportunityTeam(newLeadList);
    }
  }

  public override void afterDelete() {
  }

  /*
   * Method Name: throwLeadConversionErrors
   * Input Parameters: List<Lead> newLeadList, Map<Id, Lead> oldLeadMap
   * Return value: void
   * Purpose: This method will throw errors upon Lead Conversion
   */
  private static void throwLeadConversionErrors(
    List<Lead> newLeadList,
    Map<Id, Lead> oldLeadMap
  ) {
    for (Lead ld : newLeadList) {
      if (ld.isConverted) {
        String errorMessage = 'Please fix the following: ';

        if (oldLeadMap.get(ld.Id).OwnerId != UserInfo.getUserId()) {
          ld.addError(System.Label.Owner_Lead_Error);
        } else {
          if (!ld.Conversion_Ready__c) {
            errorMessage +=
              System.Label.Lead_Conversion_Ready_Error +
              System.Label.Error_Separator;
          }
          if (!ld.Activities_Closed__c) {
            errorMessage +=
              +'\n' +
              System.Label.Activities_Not_Closed_Error +
              System.Label.Error_Separator;
          }
          if (
            errorMessage != '' &&
            errorMessage != 'Please fix the following: '
          ) {
            Integer separatorLength = System.Label.Error_Separator.length();
            String errorMessageSubString = errorMessage.substring(
              0,
              errorMessage.length() - separatorLength
            );
            ld.addError(errorMessageSubString);
          }
        }
      }
    }
  }

  /*
   * Method Name: updatePreviousOwnerField
   * Input Parameters: List<Lead> newLeadList, Map<Id, Lead> oldLeadMap
   * Return value: void
   * Purpose: Update the Previous Owner field on Lead with the Previous Owner when an owner is changed. This field will be
   *           used to send emails to the previous owner when the previous owner is a user.
   */
  private static void updatePreviousOwnerField(
    List<Lead> newLeadList,
    Map<Id, Lead> oldLeadMap
  ) {
    if (
      newLeadList != null &&
      !newLeadList.isEmpty() &&
      oldLeadMap.keySet() != null &&
      !oldLeadMap.keySet().isEmpty()
    ) {
      Set<Id> queueIdSet = new Set<Id>();
      for (Lead leadRec : newLeadList) {
        if (
          leadRec.OwnerId != null &&
          oldLeadMap.containsKey(leadRec.Id) &&
          leadRec.OwnerId != oldLeadMap.get(leadRec.Id).OwnerId
        ) {
          //If the previous owner was a user
          if (
            String.valueOf(oldLeadMap.get(leadRec.Id).OwnerId).startsWith('005')
          ) {
            leadRec.Previous_Owner__c = oldLeadMap.get(leadRec.Id).OwnerId;
            leadRec.Previous_Owner_Queue_Name__c = null;
          } else if (
            String.valueOf(oldLeadMap.get(leadRec.Id).OwnerId).startsWith('00G')
          ) {
            //If the previous owner was a queue
            leadRec.Previous_Owner__c = null;
            queueIdSet.add(oldLeadMap.get(leadRec.Id).OwnerId);
          }
        }
      }
      if (queueIdSet != null && !queueIdSet.isEmpty()) {
        Map<Id, Group> queueIdNameMap = new Map<Id, Group>(
          [SELECT Id, Name FROM Group WHERE Id IN :queueIdSet]
        );

        if (
          queueIdNameMap != null &&
          queueIdNameMap.keySet() != null &&
          !queueIdNameMap.isEmpty()
        ) {
          for (Lead leadRec : newLeadList) {
            if (
              leadRec.OwnerId != null &&
              oldLeadMap.containsKey(leadRec.Id) &&
              leadRec.OwnerId != oldLeadMap.get(leadRec.Id).OwnerId &&
              String.valueOf(oldLeadMap.get(leadRec.Id).OwnerId)
                .startsWith('00G')
            ) {
              leadRec.Previous_Owner_Queue_Name__c = queueIdNameMap.get(
                  oldLeadMap.get(leadRec.Id).OwnerId
                )
                .Name;
            }
          }
        }
      }
    }
  }

  /*
   * Method Name: sendEmailToOldLeadQueueOwners
   * Input Parameters: List<Lead> newLeadList, Map<Id, Lead> oldLeadMap
   * Return value: void
   * Purpose: Update the Previous Owner field on Lead with the Previous Owner when an owner is changed.
   */
  private static void sendEmailToOldLeadQueueOwners(
    List<Lead> newLeadList,
    Map<Id, Lead> oldLeadMap
  ) {
    if (
      newLeadList != null &&
      !newLeadList.isEmpty() &&
      oldLeadMap.keySet() != null &&
      !oldLeadMap.keySet().isEmpty()
    ) {
      Map<Id, Id> leadIdOwnerIdMap = new Map<Id, Id>();
      Set<Id> ownerIdSet = new Set<Id>();

      for (Lead leadRec : newLeadList) {
        if (
          leadRec.OwnerId != null &&
          oldLeadMap.containsKey(leadRec.Id) &&
          leadRec.OwnerId != oldLeadMap.get(leadRec.Id).OwnerId &&
          String.valueOf(oldLeadMap.get(leadRec.Id).OwnerId).startsWith('00G')
        ) {
          leadIdOwnerIdMap.put(leadRec.Id, oldLeadMap.get(leadRec.Id).OwnerId);
          ownerIdSet.add(oldLeadMap.get(leadRec.Id).OwnerId);
        }
      }

      if (ownerIdSet != null && !ownerIdSet.isEmpty()) {
        List<GroupMember> membersList = [
          SELECT UserOrGroupId, GroupId
          FROM GroupMember
          WHERE GroupId IN :ownerIdSet
          ORDER BY GroupId
        ];
        if (membersList != null && !membersList.isEmpty()) {
          Set<Id> userIdSet = new Set<Id>();
          for (GroupMember gMember : membersList) {
            if (String.valueOf(gMember.UserOrGroupId).startsWith('005')) {
              userIdSet.add(gMember.UserOrGroupId);
            }
          }

          if (userIdSet != null && !userIdSet.isEmpty()) {
            Map<Id, User> mapUserRecord = new Map<Id, User>(
              [SELECT Id, Email FROM User WHERE Id IN :userIdSet]
            );
            if (
              mapUserRecord != null &&
              mapUserRecord.keySet() != null &&
              !mapUserRecord.keySet().isEmpty()
            ) {
              Map<Id, List<String>> groupIdMembersListMap = new Map<Id, List<String>>();
              List<String> emailIdList;

              for (GroupMember gMember : membersList) {
                if (String.valueOf(gMember.UserOrGroupId).startsWith('005')) {
                  if (
                    groupIdMembersListMap != null &&
                    mapUserRecord.containsKey(gMember.UserOrGroupId)
                  ) {
                    if (groupIdMembersListMap.containsKey(gMember.GroupId)) {
                      emailIdList.add(
                        mapUserRecord.get(gMember.UserOrGroupId).Email
                      );
                    } else {
                      emailIdList = new List<String>();
                      emailIdList.add(
                        mapUserRecord.get(gMember.UserOrGroupId).Email
                      );
                    }
                    groupIdMembersListMap.put(gMember.GroupId, emailIdList);
                  }
                }
              }

              if (
                groupIdMembersListMap != null &&
                groupIdMembersListMap.keySet() != null &&
                !groupIdMembersListMap.isEmpty()
              ) {
                EmailTemplate emailTemplate = [
                  SELECT id
                  FROM EmailTemplate
                  WHERE name = :'Notify Old Lead Owner(Queue) On Owner Change'
                  LIMIT 1
                ];

                List<Messaging.SingleEmailMessage> listSingleEmails = new List<Messaging.SingleEmailMessage>();
                for (Lead leadRec : newLeadList) {
                  List<String> emailList = groupIdMembersListMap.get(
                    leadIdOwnerIdMap.get(leadRec.Id)
                  );

                  Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                  singleEmail.setTemplateID(emailTemplate.Id);
                  singleEmail.setToAddresses(emailList);
                  singleEmail.setTargetObjectId(leadRec.Id);
                  singleEmail.setTreatTargetObjectAsRecipient(false);
                  singleEmail.saveAsActivity = false;
                  if (singleEmail != null) {
                    listSingleEmails.add(singleEmail);
                  }
                }

                Messaging.SendEmailResult[] results;
                if (listSingleEmails != null && !listSingleEmails.isEmpty()) {
                  results = Messaging.sendEmail(listSingleEmails);
                }

                if (results != null && !results.isEmpty()) {
                  for (Messaging.SendEmailResult res : results) {
                    if (res.success) {
                      System.debug('Message Sent Successfully');
                    } else {
                      System.debug('Error ->  ' + res.getErrors());
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  public static void validatePhoneFormat(
    List<Lead> listLeads,
    Map<Id, Lead> mapIdToLeads
  ) {
    for (Lead objLead : listLeads) {
      if (objLead.Phone != null || String.isNotBlank(objLead.Phone)) {
        if (Trigger.isInsert || Trigger.isBefore) {
          String phoneString = objLead.Phone;
          if (
            String.isNotBlank(phoneString) && phoneString.containsAny('()-+')
          ) {
            phoneString = phoneString.replace('(', '');
            phoneString = phoneString.replace(')', '');
            phoneString = phoneString.replace('-', '');
            phoneString = phoneString.replace('+', '');
            if (
              !phoneString.isNumeric() ||
              phoneString.length() < 7 ||
              phoneString.length() > 15
            ) {
              objLead.addError(
                'Please enter 7 to 15 digits and also check no alphabets or special characters were entered and no space is added in Phone.'
              );
            } else {
              if (
                phoneString.length() == 10 ||
                (phoneString.length() == 11 && phoneString.startsWith('1'))
              ) {
                objLead.Phone = phoneString;
              }
            }
          } else if (!phoneString.isNumeric()) {
            objLead.addError(
              'Please enter 7 to 15 digits and also check no alphabets or special characters were entered and no space is added in Phone.'
            );
          } else if (phoneString.length() < 7 || phoneString.length() > 15) {
            objLead.addError(
              'Please enter 7 to 15 digits and also check no alphabets or special characters were entered and no space is added in Phone.'
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: checkIfLeadIsConversionReady
   * Input Parameters: List<Lead> newLeadList, Map<Id, Lead> newLeadMap, List<Lead> oldLeadList, Map<Id, Lead> oldLeadMap
   * Return value: void
   * Purpose: Marks the Conversion Ready checkbox on Lead to true if all the information necessary for conversion is populated on Lead.
   */
  private static void checkIfLeadIsConversionReady(
    List<Lead> newLeadList,
    Map<Id, Lead> newLeadMap,
    List<Lead> oldLeadList,
    Map<Id, Lead> oldLeadMap
  ) {
    if (newLeadList != null && !newLeadList.isEmpty()) {
      for (Lead leadRecord : newLeadList) {
        if (Trigger.isInsert) {
          if (
            (leadRecord.FirstName != null &&
            leadRecord.FirstName != '') && //Checks if the Lead First Name is empty or not.
            (leadRecord.Title != null &&
            leadRecord.Title != '') && //Checks if the Lead Title is empty or not.
            (leadRecord.Address_Line_1__c != null &&
            leadRecord.Address_Line_1__c != '') && //Checks if the Lead Address Line 1 is empty or not.
            (leadRecord.Service__c != null &&
            leadRecord.Service__c != '') && //Checks if any Service is selected on Lead or not.
            //Checks if any of the following is populated on Lead: Email, Phone or Mobile
            ((leadRecord.MobilePhone != null &&
            leadRecord.MobilePhone != '') ||
            (leadRecord.Phone != null &&
            leadRecord.Phone != '') ||
            (leadRecord.Email != null &&
            leadRecord.Email != ''))
          ) {
            leadRecord.Conversion_Ready__c = true;
          }
        } else if (Trigger.isUpdate) {
          if (
            ((newLeadMap.get(leadRecord.Id)).FirstName !=
            (oldLeadMap.get(leadRecord.Id)).FirstName) ||
            ((newLeadMap.get(leadRecord.Id)).Title !=
            (oldLeadMap.get(leadRecord.Id)).Title) ||
            ((newLeadMap.get(leadRecord.Id)).Address_Line_1__c !=
            (oldLeadMap.get(leadRecord.Id)).Address_Line_1__c) ||
            ((newLeadMap.get(leadRecord.Id)).Service__c !=
            (oldLeadMap.get(leadRecord.Id)).Service__c) ||
            ((newLeadMap.get(leadRecord.Id)).MobilePhone !=
            (oldLeadMap.get(leadRecord.Id)).MobilePhone) ||
            ((newLeadMap.get(leadRecord.Id)).Phone !=
            (oldLeadMap.get(leadRecord.Id)).Phone) ||
            ((newLeadMap.get(leadRecord.Id)).Email !=
            (oldLeadMap.get(leadRecord.Id)).Email)
          ) {
            if (
              (leadRecord.FirstName != null &&
              leadRecord.FirstName != '') && //Checks if the Lead First Name is empty or not.
              (leadRecord.Title != null &&
              leadRecord.Title != '') && //Checks if the Lead Title is empty or not.
              (leadRecord.Address_Line_1__c != null &&
              leadRecord.Address_Line_1__c != '') && //Checks if the Lead Address Line 1 is empty or not.
              (leadRecord.Service__c != null &&
              leadRecord.Service__c != '') && //Checks if any Service is selected on Lead or not.
              //Checks if any of the following is populated on Lead: Email, Phone or Mobile
              ((leadRecord.MobilePhone != null &&
              leadRecord.MobilePhone != '') ||
              (leadRecord.Phone != null &&
              leadRecord.Phone != '') ||
              (leadRecord.Email != null &&
              leadRecord.Email != ''))
            ) {
              leadRecord.Conversion_Ready__c = true;
            }
          }
        }
      }
    }
  }

  /*
   * Method Name: restrictLeadDeletion
   * Input Parameters: List<Lead> leadList
   * Return value: void
   * Purpose: Restricts users other than the record creator to delete the record.
   */
  public static void restrictLeadDeletion(List<Lead> leadList) {
    Id currentUserId = UserInfo.getUserId();
    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;
    List<Lead> recordsCannotBeDeletedList = new List<Lead>();
    if (leadList != null && !leadList.isEmpty()) {
      for (Lead leadObj : leadList) {
        if (
          leadObj.CreatedById != currentUserId &&
          !Label.SYSTEM_ADMINISTRATOR.contains(profileName)
        ) {
          try {
            leadObj.addError(Label.INSUFFICIENT_ACCESS_TO_DELETE_LEAD_RECORD);
          } catch (Exception e) {
            System.debug(
              logginglevel.ERROR,
              'MESSAGE:' +
              e.getMessage() +
              'STACK TRACE:' +
              e.getStackTraceString()
            );
          }
        }
      }
    }
  }

  public static void validateMobileFormat(
    List<Lead> listLeads,
    Map<Id, Lead> mapIdToLeads
  ) {
    for (Lead objLead : listLeads) {
      if (
        objLead.MobilePhone != null || String.isNotBlank(objLead.MobilePhone)
      ) {
        if (Trigger.isInsert || Trigger.isBefore) {
          String mobileString = objLead.MobilePhone;
          if (
            String.isNotBlank(mobileString) && mobileString.containsAny('()-+')
          ) {
            mobileString = mobileString.replace('(', '');
            mobileString = mobileString.replace(')', '');
            mobileString = mobileString.replace('-', '');
            mobileString = mobileString.replace('+', '');
            if (
              !mobileString.isNumeric() ||
              mobileString.length() < 7 ||
              mobileString.length() > 15
            ) {
              objLead.addError(
                'Please enter 7 to 15 digits and also check no alphabets or special characters were entered and no space is added in Phone.'
              );
            } else {
              if (
                mobileString.length() == 10 ||
                (mobileString.length() == 11 && mobileString.startsWith('1'))
              ) {
                objLead.MobilePhone = mobileString;
              }
            }
          } else if (!mobileString.isNumeric()) {
            objLead.addError(
              'Please enter 7 to 15 digits and also check no alphabets or special characters were entered and no space is added in Phone.'
            );
          } else if (mobileString.length() < 7 || mobileString.length() > 15) {
            objLead.addError(
              'Please enter 7 to 15 digits and also check no alphabets or special characters were entered and no space is added in Phone.'
            );
          }
        }
      }
    }
  }
  /* --------------------Code Commented for the request in Feedback-0026-------------------------
   * Method Name: createTask
   * Input Parameters: List<Lead>
   * Return value: void
   * Purpose: Creates task record attached to the lead record when followup is checked and record owner is a user.
   * //This is future method because the assignment date is populated using workflow and workflow is called after After Update
   */
  /*public static void createTask(List<Id> leadIdList){
        List<Lead> leadList = new List<Lead>();
        Set<Id> salesAgentUsers = (new Map<Id,User>([Select Id from user where profile.Name = :ConstantClass.SALES_AGENT_PROFILE and isActive = true])).keySet();
        leadList = [select id, Followup__c, OwnerId, AssignmentDate__c, Company, Hot_Lead__c,CreatedById from Lead where Id in: leadIdList];
        List<Task> tasksToCreateList = new List<Task>();
        if(leadList != NULL && !leadList.isEmpty())
        {
            for(Lead leadObj: leadList)
            {
                if(leadObj.Followup__c == TRUE && !String.valueOf(leadObj.OwnerId).startsWithIgnoreCase('00G') && leadObj.Company!='')
                {
                    if(!leadObj.Hot_Lead__c){
                        Task t = new Task();
                        t.Subject = System.Label.Automated_Follow_Up_Task_Prefix + ' Lead Follow Up - '+ leadObj.Company;
                        t.Priority = 'Normal';
                        t.Status = 'Open';
                        t.TaskSubtype = 'Task';
                        t.Type = 'Other';
                        t.WhoId = leadObj.Id;
                        t.ActivityDate = Date.today() +2;
                        if(salesAgentUsers.size()>0 && salesAgentUsers.contains(leadObj.CreatedById)){
                            t.OwnerId = leadObj.CreatedById;
                        }else{
                            t.OwnerId = leadObj.OwnerId;
                        }
                        tasksToCreateList.add(t);
                    }else if(leadObj.Hot_Lead__c){
                        Task t = new Task();
                        t.Subject = System.Label.Automated_Follow_Up_Task_Prefix + ' Lead Follow Up - '+ leadObj.Company;
                        t.Priority = 'Normal';
                        t.Status = 'Open';
                        t.TaskSubtype = 'Task';
                        t.Type = 'Other';
                        t.WhoId = leadObj.Id;
                        t.ActivityDate = Date.today();
                        if(salesAgentUsers.size()>0 && salesAgentUsers.contains(leadObj.CreatedById)){
                            t.OwnerId = leadObj.CreatedById;
                        }else{
                            t.OwnerId = leadObj.OwnerId;
                        }
                        tasksToCreateList.add(t);
                    }
                }
            }
        }
        if(tasksToCreateList != NULL && !tasksToCreateList.isEmpty())
        {
            insert tasksToCreateList;
        }
   }*/

  /*
   * Method Name: manageInitiativeOnConvert
   * Parameters:
   * List<Lead> lstNewLead : Holds new lead list
   * Map<Id, Lead> mapOld : Holds lead old map
   * Return value: void
   * Purpose: Syn lead initiative with account initiative after conversion.
   */
  private void manageInitiativeOnConvert(
    List<Lead> lstNewLead,
    Map<Id, Lead> mapOld
  ) {
    Boolean boolIsSuccess = true;
    List<Lead> lstConvertedLead = new List<Lead>();
    Set<Id> setInitiaitveId = new Set<Id>();
    Map<Id, Initiative__c> mapInitiaitve = new Map<Id, Initiative__c>();
    Map<Id, Id> mapLeadToConvertedAccId = new Map<Id, Id>();
    Map<Id, Id> mapLeadToConvertedConId = new Map<Id, Id>();
    Map<Id, Id> mapLeadToConvertedOppId = new Map<Id, Id>();
    Map<String, Goal_Initiative__c> mapAccountInitiative = new Map<String, Goal_Initiative__c>();
    List<Goal_Initiative__c> lstAccountInitiaitveUpdate = new List<Goal_Initiative__c>();
    List<Goal_Initiative__c> lstAccountInitiaitveAdd = new List<Goal_Initiative__c>();
    Map<Id, List<Goal_Initiative__c>> mapLeadToAccountInitiative = new Map<Id, List<Goal_Initiative__c>>();
    List<Opportunity> lstOppToLinkWithInitiative = new List<Opportunity>();

    for (Lead objLead : lstNewLead) {
      System.debug('>>>>>>>>>' + objLead.IsConverted);
      if (
        mapOld != null &&
        objLead.IsConverted == true &&
        mapOld.containsKey(objLead.Id) &&
        mapOld.get(objLead.Id).IsConverted != objLead.IsConverted
      ) {
        lstConvertedLead.add(objLead);
        if (objLead.Initiative__c != null) {
          setInitiaitveId.add(objLead.Initiative__c);
        }
        if (objLead.ConvertedAccountId != null) {
          mapLeadToConvertedAccId.put(objLead.Id, objLead.ConvertedAccountId);
        }
        if (objLead.ConvertedContactId != null) {
          mapLeadToConvertedConId.put(objLead.Id, objLead.ConvertedContactId);
        }
        if (objLead.ConvertedOpportunityId != null) {
          mapLeadToConvertedOppId.put(
            objLead.Id,
            objLead.ConvertedOpportunityId
          );
        }
      }
    }

    if (lstConvertedLead.size() == 0 || setInitiaitveId.size() == 0) {
      return;
    }

    mapInitiaitve = new Map<Id, Initiative__c>(
      [SELECT Id, IsActive__c FROM Initiative__c WHERE Id IN :setInitiaitveId]
    );

    for (Goal_Initiative__c objAccountInitiative : [
      SELECT Id, Account__c, Initiative__c, Active__c
      FROM Goal_Initiative__c
      WHERE Account__c IN :mapLeadToConvertedAccId.values()
    ]) {
      mapAccountInitiative.put(
        objAccountInitiative.Account__c +
        '' +
        objAccountInitiative.Initiative__c,
        objAccountInitiative
      );
    }

    for (Lead objLead : lstConvertedLead) {
      if (objLead.Initiative__c != null) {
        String strAccountInitiativeUniqueKey =
          objLead.ConvertedAccountId +
          '' +
          objLead.Initiative__c;
        //Check if account already contains the lead initiative
        if (mapAccountInitiative.containsKey(strAccountInitiativeUniqueKey)) {
          //If lead initiaitve is active then Account initiative will be as per lead inactive active state
          if (
            mapInitiaitve.containsKey(objLead.Initiative__c) &&
            mapInitiaitve.get(objLead.Initiative__c).IsActive__c
          ) {
            lstAccountInitiaitveUpdate.add(
              new Goal_Initiative__c(
                Id = mapAccountInitiative.get(strAccountInitiativeUniqueKey).Id,
                Active__c = true,
                Is_Converted_from_Lead__c = true
              )
            );
          }
        } else {
          //If account not contains the lead initiative then create new account initiative
          if (mapInitiaitve.containsKey(objLead.Initiative__c)) {
            lstAccountInitiaitveAdd.add(
              new Goal_Initiative__c(
                Account__c = objLead.ConvertedAccountId,
                Initiative__c = objLead.Initiative__c,
                Active__c = mapInitiaitve.get(objLead.Initiative__c)
                  .IsActive__c,
                Is_Converted_from_Lead__c = true
              )
            );
          }
        }
      }
      mapLeadToAccountInitiative.put(
        objLead.Id,
        new List<Goal_Initiative__c>()
      );
      mapLeadToAccountInitiative.get(objLead.Id)
        .addAll(lstAccountInitiaitveAdd);
      mapLeadToAccountInitiative.get(objLead.Id)
        .addAll(lstAccountInitiaitveUpdate);
    }

    if (lstAccountInitiaitveUpdate.size() > 0) {
      try {
        update lstAccountInitiaitveUpdate;
      } catch (Exception objEx) {
        boolIsSuccess = false;
        System.debug(
          'LeadTriggerHandler->manageInitiativeOnConvert ' +
          objEx.getMessage() +
          ' ' +
          objEx.getStackTraceString()
        );
      }
    }

    if (lstAccountInitiaitveAdd.size() > 0) {
      try {
        insert lstAccountInitiaitveAdd;
      } catch (Exception objEx) {
        boolIsSuccess = false;
        System.debug(
          'LeadTriggerHandler->manageInitiativeOnConvert ' +
          objEx.getMessage() +
          ' ' +
          objEx.getStackTraceString()
        );
      }
    }

    if (boolIsSuccess == false) {
      return;
    }

    for (Lead objLead : lstConvertedLead) {
      if (mapLeadToConvertedOppId.containsKey(objLead.Id)) {
        if (mapLeadToAccountInitiative.get(objLead.Id) != null) {
          for (
            Goal_Initiative__c objGoalInitiative : mapLeadToAccountInitiative.get(
              objLead.Id
            )
          ) {
            if (objGoalInitiative.Active__c) {
              lstOppToLinkWithInitiative.add(
                new Opportunity(
                  Id = mapLeadToConvertedOppId.get(objLead.Id),
                  Goal_Initiative__c = objGoalInitiative.Id
                )
              );
              break;
            }
          }
        }
      }
    }

    if (lstOppToLinkWithInitiative.size() > 0) {
      try {
        TriggerHandler.bypass('OpportunityTriggerHandler');
        update lstOppToLinkWithInitiative;
      } catch (Exception objEx) {
        System.debug(
          'LeadTriggerHandler->manageInitiativeOnConvert ' +
          objEx.getMessage() +
          ' ' +
          objEx.getStackTraceString()
        );
      }
      TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
  }

  /* --------------------Code Commented for the request in Feedback-0026-------------------------
   * Method Name: createInitiativeTaskForLeadOwner
   * Input Parameters:
   * List<Lead> lstNew: This holds new lead list.
   * Map<Id, Lead> mapOldLead : This holds old lead map.
   * Return value:
   * Purpose: Create task for lead owner.
   */
  /*private void createInitiativeTaskForLeadOwner(List<Lead> lstNew, Map<Id, Lead> mapOldLead) {
        List<Task> lstTask = new List<Task>();
        String strGoalInitiativeAutoTaskSubject = Label.Automated_Follow_Up_Task_Prefix + ' ' + Label.AINI_NEW_AUTO_TASK_SUBJECT + ' ';
        String strGoalInitiativeAutoTaskPriority = Label.AINI_NEW_AUTO_TASK_PRIORITY;
        String strGoalInitiativeAutoTaskStatus = Label.AINI_NEW_AUTO_TASK_STATUS;
        Integer intGoalInitiativeAutoTaskDueDate = Integer.valueOf(Label.AINI_NEW_AUTO_TASK_DUE_DATE);
        String strGoalInitiativeAutoTaskType = Label.AINI_NEW_AUTO_TASK_TYPE;
        String strTaskDescriptionPost = Label.AINI_TASK_DESCRIPTION_POST;
        String strTaskDescriptionPree = Label.AINI_TASK_DESCRIPTION_PREE;
        String strTaskDescriptionPreeThe = Label.AINI_TASK_DESCRIPTION_PREE_THE;
        Set<Id> setInitiaitveId = new Set<Id>();
        Map<Id, Initiative__c> mapInitiative = new Map<Id, Initiative__c>();
        
        for(Lead objLead : lstNew) {
            if(objLead.Initiative__c != null) {
                setInitiaitveId.add(objLead.Initiative__c);    
            }    
        }
        
        if(setInitiaitveId.size() == 0) {
            return;
        }
        
        mapInitiative = new Map<Id, Initiative__c>([SELECT Id, Name FROM Initiative__c WHERE Id IN :setInitiaitveId]);
        
        for(Lead objLead : lstNew) {
            String strLeadName = (objLead.FirstName != null? objLead.FirstName : '') + ' ' + (objLead.MiddleName != null? objLead.MiddleName : '') + ' ' + objLead.LastName;
            if(objLead.Initiative__c != null && (mapOldLead == null || (mapOldLead != null && mapOldLead.containsKey(objLead.Id) && objLead.Initiative__c != mapOldLead.get(objLead.Id).Initiative__c)) && mapInitiative.containsKey(objLead.Initiative__c)) {
                lstTask.add(new Task(
                    Subject = strGoalInitiativeAutoTaskSubject + mapInitiative.get(objLead.Initiative__c).Name,
                    Priority = strGoalInitiativeAutoTaskPriority,
                    Status = strGoalInitiativeAutoTaskStatus,
                    Type = strGoalInitiativeAutoTaskType,
                    OwnerId = objLead.OwnerId,
                    ActivityDate = Date.today() + intGoalInitiativeAutoTaskDueDate,
                    WhoId = objLead.Id,
                    Initiative__c = objLead.Initiative__c,
                    Description = strTaskDescriptionPreeThe + strLeadName + strTaskDescriptionPree + mapInitiative.get(objLead.Initiative__c).Name +'".'                    
                ));     
            }
        }
        
        if(lstTask.size() > 0) {
            List<Database.SaveResult> lstSaveResult = Database.insert(lstTask, false);
            for(Database.SaveResult objSaveResult : lstSaveResult) {
                if(objSaveResult.isSuccess() == false) {
                    for(Database.Error objError : objSaveResult.getErrors()) {
                        System.debug('InitiativeLeadTriggerHandler->createTaskFoLeadOwner ' + objError.getMessage());
                    }    
                }
            }
        }
    }*/

  /*
   * Method Name: assignLeadsCreatedBySalesAgentToMarketManager
   * Input Parameters: newLeadList
   * Return value: None
   * Purpose: To make Market Manager the lead owner for lead created by Sales Agent.
   */
  private void assignLeadsCreatedBySalesAgentToMarketManager(
    List<Lead> newLeadList
  ) {
    System.debug('inside assignLeadsCreatedBySalesAgentToMarketManager');

    Id currentUserId = UserInfo.getUserId();
    Id currentUserProfileId = UserInfo.getProfileId();
    Map<Id, Profile> profileIdToNameMap = new Map<Id, Profile>(
      [SELECT Id, Name FROM Profile]
    );
    //Map<Id,String> userIdToProfileNameMap =   new Map<Id,String>();
    List<Lead> leadlist = new List<Lead>();
    List<LeadShare> leadSharelist = new List<LeadShare>();
    Set<Id> leadIdSet = new Set<Id>();
    /**
        //Get userId,profileId,ManagerId of current user
        //List<User> userList       =   [SELECT Id,Profile.Id, ManagerId FROM User WHERE id  = :currentUserId];
        //System.debug('userList: ' +userList);
        //Create a Map of userId and User
        //Map<Id,User> userMap  =   new Map<Id,User>([SELECT Id,Profile.Id,ManagerId FROM User]);
        //System.debug('userMap: ' + userMap);
        
        //Create a map of userId To Profile name
        //for(User salesAgentuser: userList){
          // userIdToProfileNameMap.put(salesAgentuser.Id,profileIdToNameMap.get(salesAgentuser.ProfileId).Name);      
        //}
        **/
    //Get Manager Id of the Sales Agent
    Id managerId = getMarketManagerId(currentUserId);
    System.debug('managerId: ' + managerId);
    System.debug(
      'profileIdToNameMap.get(currentUserProfileId).Name: ' +
      profileIdToNameMap.get(currentUserProfileId).Name
    );
    //Check if the lead is created by Sales Agent
    if (
      (managerId != null) &&
      (profileIdToNameMap.get(currentUserProfileId).Name ==
      ConstantClass.SALES_AGENT_PROFILE)
    ) {
      System.debug('newLeadList: ' + newLeadList);
      for (Lead salesAgentLead : newLeadList) {
        Lead salesLead = new Lead(Id = salesAgentLead.Id);
        salesLead.OwnerId = managerId;
        leadlist.add(salesLead);
        leadIdSet.add(salesAgentLead.Id);
      }
      if (leadlist.size() > 0) {
        update leadlist;
      }

      //After lead owner is changed, share the lead with Sales Agent himself.
      if (leadIdSet.size() > 0) {
        WithoutSharingUtility.shareleadRecords(leadIdSet);
      }
    }
  }

  /*
   * Method Name: getMarketManagerId
   * Input Parameters: userId of Sales Agent
   * Return value: Id of Market Manager.
   * Purpose: To get Market Manager of Sales Agent creating Lead.
   *           Used in assignLeadsCreatedBySalesAgentToMarketManager method.
   */
  private Id getMarketManagerId(Id userId) {
    Map<Id, User> userMap = new Map<Id, User>(
      [SELECT Id, Profile.Id, ManagerId FROM User]
    );
    Set<Id> userIdWithPermissionSet = new Set<Id>();

    List<PermissionSetAssignment> permissionSetAssignmentList = [
      SELECT PermissionSetId, AssigneeId
      FROM PermissionSetAssignment
      WHERE
        PermissionSetId IN (
          SELECT Id
          FROM PermissionSet
          WHERE Name = :ConstantClass.Marketing_Manager_Permission_Set
        )
    ];
    for (PermissionSetAssignment PSA : permissionSetAssignmentList) {
      userIdWithPermissionSet.add(PSA.AssigneeId);
    }

    User usr = userMap.get(userId);
    while (usr.ManagerId != null) {
      if (userIdWithPermissionSet.contains(usr.ManagerId)) {
        return usr.ManagerId;
      } else {
        usr = userMap.get(usr.ManagerId);
      }
    }
    return null;
  }

  /*
   * Method Name: addSalesAgentToAccountOpportunityTeam
   * Input Parameters: newLeadList
   * Return value: None.
   * Purpose: Upon conversion of lead by Marketing Manager, sales agent should be added to the parent Account Team
   *           Opporutunity Team if lead has been created by Sales Agent.
   */
  private void addSalesAgentToAccountOpportunityTeam(List<Lead> newLeadList) {
    //Get all Marketing Managers
    List<PermissionSetAssignment> permissionSetAssignmentList = [
      SELECT PermissionSetId, AssigneeId
      FROM PermissionSetAssignment
      WHERE
        PermissionSetId IN (
          SELECT Id
          FROM PermissionSet
          WHERE Name = :ConstantClass.Marketing_Manager_Permission_Set
        )
    ];
    if (
      permissionSetAssignmentList.isEmpty() ||
      permissionSetAssignmentList == null
    ) {
      System.debug(
        'No User with Market Manager Permission present. - exiting....'
      );
      return;
    }

    Set<Id> permissionSetAssigneeIds = new Set<Id>();

    if (permissionSetAssignmentList.size() > 0) {
      for (PermissionSetAssignment PSA : permissionSetAssignmentList) {
        permissionSetAssigneeIds.add(PSA.AssigneeId);
      }
    }

    //Get all sales agent users
    List<Profile> profileList = new List<Profile>(
      [
        SELECT Id, Name
        FROM Profile
        WHERE Name = :ConstantClass.SALES_AGENT_PROFILE
      ]
    );
    if (profileList.isEmpty() || profileList == null) {
      System.debug('No Sales Agent Profile present. - exiting....');
      return;
    }

    List<User> salesAgentUserList = new List<User>();
    if (profileList.size() == 1) {
      Id salesAgentProfileId = profileList[0].Id;
      salesAgentUserList = [
        SELECT Id
        FROM User
        WHERE ProfileId = :salesAgentProfileId
      ];
    } else {
      System.debug('Multiple Sales Agent Profile present. - exiting....');
      return;
    }

    Set<Id> salesAgentUserIds = new Set<Id>();

    if (salesAgentUserList.size() > 0) {
      for (User salesAgentUser : salesAgentUserList) {
        salesAgentUserIds.add(salesAgentUser.Id);
      }
    }

    //Get custom setting values for Account and Opportunity access level for Marketing Manager and Sales Agent.
    Access_Level_MM_SA__c accessLevels = Access_Level_MM_SA__c.getInstance(
      UserInfo.getProfileId()
    );
    if (accessLevels == null) {
      System.debug(
        'Custom setting for access level is not present. - exiting....'
      );
      return;
    }

    //Execute below code if logged in user is a Marketing Manager
    System.debug('permissionSetAssigneeIds: ' + permissionSetAssigneeIds);
    System.debug('UserInfo.getUserId(): ' + UserInfo.getUserId());

    if (
      permissionSetAssigneeIds.size() > 0 &&
      permissionSetAssigneeIds.contains(UserInfo.getUserId())
    ) {
      System.debug('inside if in permisson');
      Set<Id> convertedAcccountIds = new Set<Id>();
      Set<Id> convertedOpportunityIds = new Set<Id>();
      System.debug('newLeadList: ' + newLeadList);
      for (Lead newLead : newLeadList) {
        System.debug(
          'newLead--------------' +
          newLead.Id +
          '    ' +
          newLead.IsConverted
        );
        if (newLead.IsConverted == true) {
          if (newLead.convertedAccountId != null) {
            convertedAcccountIds.add(newLead.convertedAccountId);
          }
          if (newLead.convertedOpportunityId != null) {
            convertedOpportunityIds.add(newLead.convertedOpportunityId);
          }
        }
      }

      List<AccountTeamMember> existingAccountTeamMember = [
        SELECT AccountId, UserId
        FROM AccountTeamMember
        WHERE AccountId = :convertedAcccountIds
      ];

      List<Account> existingAccounts = [
        SELECT Id, ParentId
        FROM Account
        WHERE Id = :convertedAcccountIds
      ];

      Map<Id, Id> mapOfParentIdToChild = new Map<Id, Id>();

      //Map of parent and child account
      if (existingAccounts.size() > 0) {
        for (Account acc : existingAccounts) {
          mapOfParentIdToChild.put(acc.Id, acc.ParentId);
        }
      }

      List<AccountTeamMember> accountTeamMemberToBeAdded = new List<AccountTeamMember>();

      Map<Id, Set<Id>> accountToTeamMemberMap = new Map<Id, Set<Id>>();
      Set<Id> accountTeamMemberIds = new Set<Id>();

      //Check for Converted account ids
      if (!convertedAcccountIds.isEmpty() && convertedAcccountIds != null) {
        for (Id accountId : convertedAcccountIds) {
          if (existingAccountTeamMember.size() > 0) {
            for (AccountTeamMember accTeamMem : existingAccountTeamMember) {
              if ((accountId == accTeamMem.AccountId)) {
                accountTeamMemberIds.add(accTeamMem.UserId);
              }
            }
          }
          for (Lead convertedLead : newLeadList) {
            if (convertedLead.ConvertedAccountId == accountId) {
              //Check if converted account already contains the sales agent
              if (
                !accountTeamMemberIds.contains(convertedLead.CreatedById) &&
                salesAgentUserIds.contains(convertedLead.CreatedById)
              ) {
                Id parentAccountId = mapOfParentIdToChild.get(
                  convertedLead.ConvertedAccountId
                );

                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountAccessLevel = accessLevels.SA_Account_Level__c;
                atm.CaseAccessLevel = accessLevels.SA_Case_Level__c;
                atm.OpportunityAccessLevel = accessLevels.SA_Opp_Level__c;
                atm.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_SALES_AGENT;
                atm.UserId = convertedLead.CreatedById;

                if (parentAccountId != null) {
                  atm.AccountId = parentAccountId;
                } else {
                  atm.AccountId = convertedLead.ConvertedAccountId;
                }

                accountTeamMemberToBeAdded.add(atm);
              }
              if (!accountTeamMemberIds.contains(convertedLead.OwnerId)) {
                Id parentAccountId = mapOfParentIdToChild.get(
                  convertedLead.ConvertedAccountId
                );

                AccountTeamMember atm = new AccountTeamMember();
                atm.AccountAccessLevel = accessLevels.MM_Account_Level__c;
                atm.CaseAccessLevel = accessLevels.MM_Case_Level__c;
                atm.OpportunityAccessLevel = accessLevels.MM_Opp_Level__c;
                atm.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_MARKETING_MANAGER;
                atm.UserId = convertedLead.OwnerId;

                if (parentAccountId != null) {
                  atm.AccountId = parentAccountId;
                } else {
                  atm.AccountId = convertedLead.ConvertedAccountId;
                }
                accountTeamMemberToBeAdded.add(atm);
              }
            }
          }
        }
      }

      if (accountTeamMemberToBeAdded.size() > 0) {
        WithoutSharingUtility.addTeamMembers(accountTeamMemberToBeAdded);
      }

      List<OpportunityTeamMember> existingOpportunityTeamMember = [
        SELECT OpportunityId, UserId
        FROM OpportunityTeamMember
        WHERE OpportunityId = :convertedOpportunityIds
      ];

      List<OpportunityTeamMember> oppTeamMemberToBeAdded = new List<OpportunityTeamMember>();
      Set<Id> opportunityTeamMemberIds = new Set<Id>();

      if (
        convertedOpportunityIds.size() > 0 &&
        !convertedOpportunityIds.isEmpty() &&
        convertedOpportunityIds != null
      ) {
        for (Id OpportunityId : convertedOpportunityIds) {
          if (existingOpportunityTeamMember.size() > 0) {
            for (
              OpportunityTeamMember oppTeamMem : existingOpportunityTeamMember
            ) {
              if ((OpportunityId == oppTeamMem.OpportunityId)) {
                opportunityTeamMemberIds.add(oppTeamMem.UserId);
              }
            }
          }
          for (Lead convertedLead : newLeadList) {
            if (convertedLead.ConvertedOpportunityId == OpportunityId) {
              //Check if existing opp team already contains sale agent.
              if (
                !opportunityTeamMemberIds.contains(convertedLead.CreatedById) &&
                salesAgentUserIds.contains(convertedLead.CreatedById)
              ) {
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.OpportunityId = OpportunityId;
                otm.UserId = convertedLead.CreatedById;
                otm.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_SALES_AGENT;
                otm.OpportunityAccessLevel = accessLevels.SA_Opp_Level__c;

                oppTeamMemberToBeAdded.add(otm);
              }
              //Check for market manager
              if (!opportunityTeamMemberIds.contains(convertedLead.OwnerId)) {
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.OpportunityAccessLevel = accessLevels.MM_Opp_Level__c;
                otm.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_MARKETING_MANAGER;
                otm.UserId = convertedLead.OwnerId;
                otm.OpportunityId = OpportunityId;

                oppTeamMemberToBeAdded.add(otm);
              }
            }
          }
        }
      }
      if (oppTeamMemberToBeAdded.size() > 0) {
        WithoutSharingUtility.addTeamMembers(oppTeamMemberToBeAdded);
      }
    }
  }
}
