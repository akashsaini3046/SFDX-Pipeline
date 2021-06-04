/*Purpose:  This class is to handle Case realted actions
===========================================================================================================================================

History 
----------------------- 
VERSION     AUTHOR    DATE        DETAIL 
1.0         Nagarro   3/12/2019   Handler Class
===========================================================================================================================================
*/
public with sharing class CaseTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterDelete = true;
  private static Boolean Flag = true;
  private static String subjectstr;
  private static Boolean recflag;
  List<Case> newCaseList;
  List<Case> oldCaseList;
  Map<Id, Case> newCaseMap;
  Map<Id, Case> oldCaseMap;

  //public static Map<Id, Id> duplicateCaseMap = new Map<Id, Id>();
  //Test Comment
  /*Create the constructor*/
  public CaseTriggerHandler() {
    this.newCaseList = (List<Case>) Trigger.new;
    this.oldCaseList = (List<Case>) Trigger.old;
    this.newCaseMap = (Map<Id, Case>) Trigger.newMap;
    this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;
  }

  public static void reset() {
    recursionVarBeforeInsert = true;
    recursionVarAfterInsert = true;
    recursionVarBeforeUpdate = true;
    recursionVarAfterUpdate = true;
    recursionVarBeforeDelete = true;
    recursionVarAfterDelete = true;
  }

  /*Override the before insert method from the parent class*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      recursionVarBeforeInsert = false;
      clearXtraFields();
      setDueDate(newCaseList);
      setParentAccount(newCaseList, oldCaseMap);
      updateEntitlementId(newCaseList);
      updateChildFieldsFromParent(newCaseList);
      AllCaseHandler.updateParentCaseStatus(newCaseList, null);
      PopulateSummary(newCaseList, null);
      markCaseAsDuplicate(newCaseList);
      updateFieldsIfInternalContact(newCaseList, null);
    }
  }

  /*Override the after insert method from the parent class*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      checkDuplicateCase(newCaseList);
      addrelatedCaseAttachment(newCaseList);
      recursionVarAfterInsert = false;
      // DeleteCustomerinquiryCase(newCaseList);
    }
  }

  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      recursionVarBeforeUpdate = false;
      checkModifiedFields();
      setParentAccount(newCaseList, oldCaseMap);
      updateEntitlementId(newCaseList);
      parentCaseClosed(newCaseList, oldCaseMap);
      AllCaseHandler.updateParentCaseStatus(newCaseList, oldCaseMap);
      SetTimeTakenToResolve(newCaseList, oldCaseMap);
      PopulateSummary(newCaseList, oldCaseMap);
      updatePricingStatus(newCaseList, oldCaseMap);
      showPopupOnCase(newCaseList, oldCaseMap);
      UpdateCaseTypeOnRecordTypeChange(newCaseList);
      CasesClosedCustomerInquirySLA(newCaseList, oldCaseMap);
      UpdateBookingQueueBeforeUpdate(newCaseList);
      updateFieldsIfInternalContact(newCaseList, oldCaseMap);
    }
    uncheckDuplicate(newCaseList, oldCaseMap);
  }

  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;
      UpdateCaseContactEmail(newCaseList, oldCaseMap);
    }
  }

  /*Override before delete method*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      recursionVarBeforeDelete = false;
    }
  }

  /*Override after delete method*/
  public override void afterDelete() {
    if (recursionVarAfterDelete) {
      recursionVarAfterDelete = false;
    }
  }
  /*public class queueUpdate{
        string caseId;
        string accountId;
        string ownerId;
        string ownerName;
        queueUpdate(string c,string a,string oi,string own){
            caseId = c;
            accountId = a;
            ownerId = oi;
            ownerName = own;
        }
    } */
  public static void UpdateBookingQueueBeforeUpdate(List<Case> newCases) {
    system.debug('UpdateBookingQueue');
    map<string, List<string>> caseAccountMap = new Map<string, List<string>>();
    List<string> caseIds = new List<string>();
    system.debug(newCases);
    for (Case cs : newCases) {
      try {
        cs.Description__c = cs.Description.substring(0, 500);
      } catch (exception e) {
        cs.Description__c = cs.Description;
      }
      if (
        cs.RecordTypeId == System.Label.Booking_Request_Record_Type ||
        cs.RecordTypeId == System.Label.Create_Booking_Request_Record_type
      ) {
        if (cs.AccountId != null) {
          list<string> existingMapping = caseAccountMap.get(cs.AccountId);
          if (existingMapping != null && !existingMapping.isEmpty()) {
            existingMapping.add(cs.Id);
          } else {
            existingMapping = new List<string>{ cs.Id };
          }
          caseAccountMap.put(cs.AccountId, existingMapping);
          caseIds.add(cs.Id);
        }
      }
    }
    system.debug('caseAccountMap');
    system.debug(caseAccountMap);
    map<string, List<string>> caseOwnerMap = new Map<string, list<string>>();
    List<account> acc = [
      SELECT id, Queue__c
      FROM Account
      WHERE Id IN :caseAccountMap.keySet()
    ];

    for (account a : acc) {
      list<string> existingAccountMapping = caseAccountMap.get(a.id);
      system.debug('existingMapping');
      system.debug(existingAccountMapping);
      for (string s : existingAccountMapping) {
        system.debug(s);
        list<string> existingMapping = caseOwnerMap.get(a.Queue__c);
        if (existingMapping != null && !existingMapping.isEmpty()) {
          existingMapping.add(s);
        } else {
          existingMapping = new List<string>{ s };
        }
        caseOwnerMap.put(a.Queue__c, existingMapping);
      }
    }
    system.debug('caseOwnerMap');
    system.debug(caseOwnerMap);
    map<string, string> caseOwnerIdMap = new Map<string, string>();
    list<group> queId = [
      SELECT Id, Name
      FROM Group
      WHERE Type = 'Queue' AND Name IN :caseOwnerMap.keySet()
    ];
    system.debug(queId);
    for (group g : queId) {
      //caseOwnerIdMap.put(caseOwnerMap.get(g.Name),g.id);
      system.debug(queId);
      system.debug(caseOwnerMap.get(g.Name));
      list<string> existingOwnerMapping = caseOwnerMap.get(g.Name);
      for (string s : existingOwnerMapping) {
        caseOwnerIdMap.put(s, g.Id);
      }
    }
    system.debug('caseOwnerIdMap');
    system.debug(caseOwnerIdMap);
    for (Case cs : newCases) {
      system.debug('cs.Update_Count__c');
      system.debug(cs.Update_Count__c);
      if (
        cs.RecordTypeId == System.Label.Booking_Request_Recrd_Type ||
        cs.RecordTypeId == System.Label.Create_Booking_Request_Record_type
      ) {
        if (cs.Update_Count__c >= 1 && cs.origin != 'EDI/GT NEXUS') {
          if (
            string.valueOf(cs.OwnerId).startsWith('00G') &&
            cs.Status != 'Closed- Disqualified'
          ) {
            if (cs.AccountId != null) {
              cs.OwnerId = caseOwnerIdMap.get(cs.Id);
            } else {
              cs.OwnerId = System.Label.Booking_Request_Queue_Id;
            }
          }
        } else {
          cs.Update_Count__c += 1;
          if (string.valueOf(cs.OwnerId).startsWith('00G')) {
            // && cs.OwnerId!=System.Label.Booking_Request_Queue_Id
            cs.OwnerId = system.label.Booking_Inbox_Queue;
          }
        }
        if (
          cs.origin == 'EDI/GT NEXUS' &&
          string.valueOf(cs.OwnerId).startsWith('00G')
        ) {
          cs.OwnerId = System.Label.Booking_Speciality_Queue_2;
        }
        system.debug('newCases');
        system.debug(cs.OwnerId);
        system.debug(cs.Id);
      }
    }

    system.debug('UpdateBookingQueue');
  }
  public static void UpdateCaseTypeOnRecordTypeChange(List<Case> newCases) {
    for (Case cs : newCases) {
      if (cs.RecordTypeId != null) {
        if (
          cs.RecordTypeId == System.Label.B_L_Revision_record_type ||
          cs.RecordTypeId == System.Label.BL_Revision_Read_Only_18 ||
          cs.RecordTypeId == System.Label.Create_BL_Revision_Record_Type
        ) {
          cs.Case_Type__c = 'BL Revision';
        } else if (
          cs.RecordTypeId == System.Label.Pricing_Rating_Issue_Record_Type ||
          cs.RecordTypeId == System.Label.Create_Pricing_Rate_Issue
        ) {
          cs.Case_Type__c = 'Pricing Rate Issue';
        } else if (
          cs.RecordTypeId == System.Label.Customer_Inquiry_Record_type_18 ||
          cs.RecordTypeId ==
          System.Label.Customer_Inquiry_Case_Record_Type_Id ||
          cs.RecordTypeId == System.Label.Create_Customer_Inquiry_Record_Type
        ) {
          cs.Case_Type__c = 'Customer Inquiry';
        } else if (
          cs.RecordTypeId == System.Label.Booking_Request_Recrd_Type ||
          cs.RecordTypeId == System.Label.Create_Booking_Request_Record_type
        ) {
          cs.Case_Type__c = 'Booking Request';
        }
      }
    }
  }

  public static void updateFieldsIfInternalContact(
    List<Case> newCases,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case cs : newCases) {
      if (
        cs.Internal_Contact__c == true &&
        (oldCaseMap == null ||
        cs.Internal_Contact__c != oldCaseMap.get(cs.Id).Internal_Contact__c)
      ) {
        cs.AccountId = null;
        cs.ContactId = null;
      }
    }
  }

  public static void CasesClosedCustomerInquirySLA(
    List<Case> newCases,
    Map<Id, Case> oldCaseMap
  ) {
    System.debug('ClosedCISLA');
    for (Case cs : newCases) {
      if (
        cs.status.Contains('Closed') &&
        cs.status != oldCaseMap.get(cs.Id).status
      ) {
        Long milisecs = BusinessHours.diff(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          DateTime.now()
        );
        Integer min = Integer.valueOf(milisecs / 60000);
        system.debug('min->' + min);
        if (cs.RecordTypeId == System.Label.Customer_Inquiry_Record_Type) {
          if (min <= 120 && min >= 0) {
            cs.Closed_within_2_Business_Hours__c = true;
            System.debug('Closed_within_2_Business_Hours__c SLA');
          }
          if (min >= 0 && min < 30) {
            cs.Service_Level_CI__c = 'Within 0.5 Hour';
          } else if (min >= 30 && min < 60) {
            cs.Service_Level_CI__c = 'Within 1 Hour';
          } else if (min >= 60 && min < 120) {
            cs.Service_Level_CI__c = 'Within 2 Hours';
          } else if (min >= 120 && min < 180) {
            cs.Service_Level_CI__c = 'Within 3 Hours';
          } else if (min >= 180) {
            cs.Service_Level_CI__c = 'Over 3 Hours';
          }
          if (cs.Date_Time_Assigned__c != null) {
            Long Assignedmilisecs = BusinessHours.diff(
              System.Label.Service_Cloud_Business_hours_Id,
              cs.Date_Time_Assigned__c,
              DateTime.now()
            );
            Integer mins = Integer.valueOf(Assignedmilisecs / 60000);
            cs.Case_Handle_Time__c = mins;
          }
        }
        if (
          cs.RecordTypeId == System.Label.Booking_Request_Recrd_Type ||
          cs.RecordTypeId == System.Label.Create_Booking_Request_Record_type
        ) {
          if (min <= 120 && min >= 0) {
            if (cs.Tier__c == 'Tier 1' && min < 30) {
              cs.Closed_within_Business_Hours_BK__c = true;
            } else if (cs.Tier__c == 'Tier 2' && min < 60) {
              cs.Closed_within_Business_Hours_BK__c = true;
            } else if (cs.Tier__c == 'Tier 3' && min < 120) {
              cs.Closed_within_Business_Hours_BK__c = true;
            }
          }
          if (min >= 0 && min < 15) {
            cs.Service_Level_CI__c = 'Within 15 Minutes';
          } else if (min >= 15 && min < 30) {
            cs.Service_Level_CI__c = 'Within 30 Minutes';
          } else if (min >= 30 && min < 60) {
            cs.Service_Level_CI__c = 'Within 1 Hour';
          } else if (min >= 60 && min < 120) {
            cs.Service_Level_CI__c = 'Within 2 Hours';
          } else if (min >= 120 && min < 180) {
            cs.Service_Level_CI__c = 'Within 3 Hours';
          } else if (min >= 180) {
            cs.Service_Level_CI__c = 'Over 3 Hours';
          }
          if (cs.Date_Time_Assigned__c != null) {
            Long Assignedmilisecs = BusinessHours.diff(
              System.Label.Service_Cloud_Business_hours_Id,
              cs.Date_Time_Assigned__c,
              DateTime.now()
            );
            Integer mins = Integer.valueOf(Assignedmilisecs / 60000);
            cs.Case_Handle_Time__c = mins;
          }
          if (cs.Tier__c == 'Tier 1') {
            if (min >= 0 && min < 10) {
              cs.Service_Level_Tier__c = 'Within 10 Minutes';
            } else if (min >= 10 && min < 20) {
              cs.Service_Level_Tier__c = 'Within 20 Minutes';
            } else if (min >= 20 && min < 30) {
              cs.Service_Level_Tier__c = 'Within 30 Minutes';
            } else if (min >= 30 && min < 60) {
              cs.Service_Level_Tier__c = 'Within 1 Hour';
            } else if (min >= 60) {
              cs.Service_Level_Tier__c = 'Over 1 Hour';
            }
          } else if (cs.Tier__c == 'Tier 2') {
            if (min >= 0 && min < 15) {
              cs.Service_Level_Tier__c = 'Within 15 Minutes';
            } else if (min >= 15 && min < 30) {
              cs.Service_Level_Tier__c = 'Within 30 Minutes';
            } else if (min >= 30 && min < 60) {
              cs.Service_Level_Tier__c = 'Within 1 Hour';
            } else if (min >= 60 && min < 120) {
              cs.Service_Level_Tier__c = 'Within 2 Hours';
            } else if (min >= 120) {
              cs.Service_Level_Tier__c = 'Over 2 Hours';
            }
          } else if (cs.Tier__c == 'Tier 3') {
            if (min >= 0 && min < 30) {
              cs.Service_Level_Tier__c = 'Within 30 Minutes';
            } else if (min >= 30 && min < 60) {
              cs.Service_Level_Tier__c = 'Within 1 Hour';
            } else if (min >= 60 && min < 120) {
              cs.Service_Level_Tier__c = 'Within 2 Hours';
            } else if (min >= 120 && min < 180) {
              cs.Service_Level_Tier__c = 'Within 3 Hours';
            } else if (min >= 180) {
              cs.Service_Level_Tier__c = 'Over 3 Hours';
            }
          }
        }
      }
      if (cs.RecordTypeId == System.Label.Customer_Inquiry_Record_Type) {
        cs.Due_Date__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          2 * 3600000
        );
        cs.Reminder_Date_after_1_5_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          90 * 60000
        );
        cs.Reminder_Date_after_2_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          2 * 3600000
        );
      }
      cs.Reminder_Date_After_6_hrs__c = BusinessHours.add(
        System.Label.Service_Cloud_Business_hours_Id,
        cs.LastModifiedDate,
        6 * 3600000
      );
      if (
        cs.RecordTypeId == System.Label.Booking_Request_Recrd_Type ||
        cs.RecordTypeId == System.Label.Create_Booking_Request_Record_type
      ) {
        cs.Reminder_Date_after_3_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.LastModifiedDate,
          3 * 3600000
        );
        cs.Reminder_Date_after_1_5_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          90 * 60000
        );
        cs.Reminder_Date_after_2_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          2 * 3600000
        );
        cs.Reminder_Date_after_0_25_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          15 * 60000
        );
        cs.Reminder_Date_after_0_5_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          30 * 60000
        );
        cs.Reminder_Date_after_1_0_hrs__c = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          cs.CreatedDate,
          60 * 60000
        );
        if (cs.Tier__c == 'Tier 1') {
          cs.Due_Date__c = BusinessHours.add(
            System.Label.Service_Cloud_Business_hours_Id,
            cs.CreatedDate,
            30 * 60000
          );
        } else if (cs.Tier__c == 'Tier 2') {
          cs.Due_Date__c = BusinessHours.add(
            System.Label.Service_Cloud_Business_hours_Id,
            cs.CreatedDate,
            1 * 3600000
          );
        } else if (cs.Tier__c == 'Tier 3') {
          cs.Due_Date__c = BusinessHours.add(
            System.Label.Service_Cloud_Business_hours_Id,
            cs.CreatedDate,
            2 * 3600000
          );
        }
      }
    }
    System.debug('ClosedCISLA');
  }

  /**
   * @dscription if case is being created
   */
  public static void setParentAccount(
    List<Case> newCases,
    Map<Id, Case> oldCaseMap
  ) {
    Set<Id> accIds = new Set<Id>();
    Set<Id> contIds = new Set<Id>();
    Set<Id> filteredCaseIds = new Set<Id>();
    for (Case cs : newCases) {
      system.debug('cs.Description');
      try {
        cs.Description__c = cs.Description.substring(0, 500);
      } catch (exception e) {
        cs.Description__c = cs.Description;
      }

      if (oldCaseMap == null) {
        // If case is being ceated
        System.debug('Case is being created -> ' + cs.AccountId);
        if (cs.AccountId != null) {
          accIds.add(cs.AccountId);
          filteredCaseIds.add(cs.Id);
        } else {
          cs.Parent_Account__c = null;
        }
      } else if (
        oldCaseMap.containsKey(cs.Id) &&
        cs.AccountId != oldCaseMap.get(cs.Id).AccountId
      ) {
        System.debug('account Id changes on case');
        // if account Id changes on case
        if (cs.AccountId != null) {
          accIds.add(cs.AccountId);
          filteredCaseIds.add(cs.Id);
        } else {
          cs.Parent_Account__c = null;
        }
      } else if (
        oldCaseMap.containsKey(cs.Id) &&
        cs.AccountId == null &&
        cs.ContactId != oldCaseMap.get(cs.Id).ContactId
      ) {
        System.debug('contact Id changes on cases');
        if (cs.ContactId != null) {
          contIds.add(cs.ContactId);
          filteredCaseIds.add(cs.Id);
        } else {
          cs.Parent_Account__c = null;
        }
      }
    }
    Map<Id, Id> contactAccIdMap = new Map<Id, Id>();
    if (contIds.size() > 0) {
      for (Contact ct : [
        SELECT Id, AccountId
        FROM Contact
        WHERE Id IN :contIds
      ]) {
        accIds.add(ct.AccountId);
        contactAccIdMap.put(ct.Id, ct.AccountId);
      }
    }
    Map<Id, Id> accParentMap = new Map<Id, Id>();
    if (accIds.size() > 0) {
      for (Account acc : [
        SELECT Id, ParentId
        FROM Account
        WHERE Id IN :accIds
      ]) {
        accParentMap.put(acc.Id, acc.ParentId);
      }
    }
    for (Case cs : newCases) {
      if (filteredCaseIds.contains(cs.Id)) {
        if (accParentMap.containsKey(cs.AccountId)) {
          cs.Parent_Account__c = accParentMap.get(cs.AccountId);
        } else if (
          oldCaseMap.containsKey(cs.Id) &&
          cs.AccountId == null &&
          cs.ContactId != oldCaseMap.get(cs.Id).ContactId
        ) {
          cs.Parent_Account__c = contactAccIdMap.containsKey(cs.ContactId)
            ? accParentMap.get(contactAccIdMap.get(cs.ContactId))
            : null;
        }
      }
    }
  }

  private void clearXtraFields() {
    System.debug('Clearing extra fields');
    List<RecordType> rts = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Create_B_L_Revision'
    ];
    if (!rts.isEmpty()) {
      Id recordTypeId = rts[0].Id;
      for (Case cs : newCaseList) {
        if (cs.RecordTypeId == recordTypeId) {
          cs.Resolution__c = null;
          cs.Resolution_Category__c = null;
          cs.Resolution_Sub_category__c = null;
          cs.BL_Resolution_Category__c = null;
          cs.Department_Responsible_for_Error__c = null;
          cs.URE__c = null;
          cs.New_BOL__c = null;
          cs.Number_of_Bill_Revisions__c = null;
          cs.Bill_change_fee_applicable__c = null;
          cs.Audit__c = false;
          cs.Issue_Type__c = null;
          cs.Comments_on_Pricing_Rating_Issue__c = null;
          cs.Final_Resolution_Comments__c = null;
          cs.Publishing_Owner__c = null;
          cs.Customers_Approval__c = null;
          cs.Status = 'Open';
        }
      }
    }
  }

  private static void addrelatedCaseAttachment(List<Case> newCaseList) {
    Set<Id> caseIds = (new Map<Id, SObject>(newCaseList)).keySet();
    set<string> str = new Set<string>();
    for (Id i : caseIds) {
      str.add(string.valueOf(i));
    }
    list<string> parentcaseIds = new List<string>();
    map<string, string> parentCaseMap = new Map<string, string>();
    for (case c : newCaseList) {
      if (c.ParentId != null) {
        parentcaseIds.add(string.valueOf(c.ParentId));
        parentCaseMap.put(c.ParentId, c.Id);
      }
    }
    if (!parentcaseIds.isEmpty()) {
      system.debug(parentcaseIds);
      List<contentDocumentLink> cdLink = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM contentDocumentLink
        WHERE LinkedEntityId IN :parentcaseIds
      ];
      system.debug(cdLink);
      ContentDocumentLinkTriggerHandler.shareDocumentWithRelatedUsers(
        JSON.serialize(cdLink),
        JSON.serialize(parentCaseMap)
      );
    }
  }
  private static void checkModifiedFields() {
    System.debug('checking modified fields');
    Map<string, Schema.SObjectField> fdMap = Case.getSobjectType()
      .getDescribe()
      .fields.getMap();
    List<string> modifiedfields = new List<string>();
    for (Case newcs : (List<Case>) Trigger.new) {
      if (Trigger.oldMap.containsKey(newcs.Id)) {
        for (string keyfd : fdMap.keySet()) {
          if (
            fdMap.get(keyfd).getDescribe().isAccessible() &&
            fdMap.get(keyfd).getDescribe().isUpdateable() &&
            newcs.get(keyfd) != Trigger.oldMap.get(newcs.Id).get(keyfd)
          ) {
            modifiedfields.add(keyfd);
          }
        }
      }
    }
    System.debug('modifield fields -> ' + String.join(modifiedFields, ', '));
  }
  /*
   * @ Description: This method update Entitlement ID
   * @ Args       : List<Case>
   * @ Return     : None
   */
  private static void updateEntitlementId(List<Case> newCaseList) {
    if (recursionVarBeforeInsert) {
      for (Case objCase : newCaseList) {
        System.debug(
          'objCase.RecordTypeId==System.Label.B_L_Revision_record_type -> ' +
          objCase.RecordTypeId == System.Label.B_L_Revision_record_type
        );
        if (objCase.RecordTypeId == System.Label.B_L_Revision_record_type) {
          objCase.EntitlementId = System.Label.BL_Revision_Entitlements;
        } else if (
          objCase.RecordTypeId == System.Label.Rating_Issue_record_type
        ) {
          objCase.EntitlementId = System.Label.Pricing_Rate_Issue_Process;
        } else if (
          objCase.RecordTypeId == System.Label.Booking_Request_Record_Type
        ) {
          objCase.EntitlementId = System.Label.Booking_Request_Entitlement;
        } else if (
          objCase.RecordTypeId == System.Label.Customer_Inquiry_Record_Type
        ) {
          objCase.EntitlementId = System.Label.Customer_Inquiry_Entitlement_Process;
        }
        /*else if(objCase.RecordTypeId==System.Label.Rate_Proposal_Record_Type){
                    objCase.EntitlementId = System.Label.Rate_Proposal_Entitlement_Process;
                }*/
      }
    }
  }

  private static string cleanSubject(string subject) {
    if (subject.startsWith('RE: ')) {
      return subject.substringAfter('RE: ');
    } else if (subject.startsWith('FW: ')) {
      return subject.substringAfter('FW: ');
    } else if (subject.startsWith('Fw: ')) {
      return subject.substringAfter('Fw: ');
    } else if (subject.startsWith('Re: ')) {
      return subject.substringAfter('Re: ');
    } else if (subject.startsWith('Fwd: ')) {
      return subject.substringAfter('Fwd: ');
    } else {
      return subject;
    }
  }

  private static void uncheckDuplicate(
    List<Case> newCaseList,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case cs : newCaseList) {
      if (
        oldCaseMap.get(cs.Id).Status != cs.Status &&
        cs.Original_Case__c != null &&
        cs.Status == 'Closed Duplicate'
      ) {
        cs.Original_Case__c = null;
      }
    }
  }
  /**
   * Check if the case is a duplicate case.
   * If yes, set the original as
   * */
  private static void markCaseAsDuplicate(List<Case> newCaseList) {
    set<string> caseSubject = new Set<string>();
    set<Id> newCaseIds = new Set<Id>();
    for (case c : newCaseList) {
      if (c.Subject != null) {
        caseSubject.add(cleanSubject(c.Subject));
        newCaseIds.add(c.Id);
        if (!caseSubject.contains(c.Subject)) {
          caseSubject.add(c.Subject);
        }
      }
    }
    Map<Id, Case> afterCasesMap = new Map<Id, Case>(
      [SELECT Id, RecordTypeId FROM Case WHERE Id IN :newCaseIds]
    );
    List<case> caselist = [
      SELECT
        id,
        CaseNumber,
        recordTypeId,
        IsClosed,
        status,
        ContactId,
        accountid,
        Description,
        subject,
        SuppliedEmail
      FROM case
      WHERE
        subject IN :caseSubject
        AND Id NOT IN :newCaseIds
        AND IsClosed = FALSE
      LIMIT 50000
    ];
    System.debug('case list -> ' + caseList);
    Map<Id, RecordType> rctMap = new Map<Id, RecordType>(
      [
        SELECT Id, Name, SobjectType, IsActive
        FROM RecordType
        WHERE SobjectType = 'Case'
      ]
    );
    List<CaseComment> csComments = new List<CaseComment>();
    List<Case> dupCases = new List<Case>();
    Set<Id> dupCaseIds = new Set<Id>();
    if (caselist != null) {
      for (case c : newCaseList) {
        for (case cList : caseList) {
          system.debug('checking criterias for duplicate cases');
          string cleanedOldCaseSubject = cleanSubject(cList.Subject);

          // if a person send email to 4 email address create only once case.
          // But if a Person send two different emails at different times with same subject then create both cases.
          // (Ex: A package got delayed. Ordered new package that also got delayed.)

          if (
            // if cusotmer sent an email, we did not yet replied and he replied on that email again to us
            c.Subject != null &&
            (c.Subject == cList.Subject ||
            c.Subject.equalsIgnoreCase('RE: ' + cleanedOldCaseSubject) ||
            c.Subject.equalsIgnoreCase('FW: ' + cleanedOldCaseSubject) ||
            c.Subject.equalsIgnoreCase('Fwd: ' + cleanedOldCaseSubject)) &&
            ((c.contactId != null && c.contactId == cList.ContactId) ||
            c.SuppliedEmail == cList.SuppliedEmail) &&
            (rctMap.get(c.RecordTypeId).Name ==
            rctMap.get(cList.RecordTypeId).Name ||
            rctMap.get(c.RecordTypeId).Name ==
            'Create ' + rctMap.get(cList.RecordTypeId).Name)
          ) {
            System.debug('**** original case');
            c.Original_Case__c = cList.Id;
          }
        }
      }
    }
  }

  /*
   * @ Description: This method is for check duplicate dase based on case subject
   * @ Args       : List<Case>
   * @ Return     : None
   */
  private static void checkDuplicateCase(List<Case> newCaseList) {
    // Since the function is called within after insert, we don't need to compare old/new values of Original Case field.
    Set<Id> dupCaseIds = new Set<Id>();
    for (Case cs : newCaseList) {
      if (cs.Original_Case__c != null) {
        dupCaseIds.add(cs.Id);
      }
    }
    if (!dupCaseIds.isEmpty()) {
      /*if(userInfo.getUserId() != System.Label.Email_to_Case_User){
for(Id csId: dupCaseIds){
if(Trigger.newMap.containsKey(csId)){
Trigger.newMap.get(csId).addError(System.Label.Case_Duplicate_Record_Error_Msg);
}
}
}*/
    }
  }

  @future
  public static void deleteDupCases(Set<Id> dupCaseIds) {
    List<Case> dupCases = [
      SELECT id, OwnerId
      FROM Case
      WHERE Id IN :dupCaseIds
    ];
    for (case cs : dupCases) {
      cs.OwnerId = UserInfo.getUserId();
    }

    System.debug('duplicate cases to be deleted -> ' + dupCases);
    update dupCases;
    delete dupCases;
  }

  private static void updatePricingStatus(
    List<Case> newCaseList,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case caseRec : newCaseList) {
      String s1 = String.valueOf(CaseRec.OwnerId);
      if (
        caseRec.RecordTypeId == System.Label.Pricing_Rating_Issue_Record_Type &&
        caseRec.Status == 'Publishing' &&
        (caseRec.Customers_Approval__c == 'Yes' ||
        caseRec.Customers_Approval__c == 'Not Required') &&
        s1.StartsWith('005')
      ) {
        caseRec.Status = 'Resolving Case';
      }
    }
  }
  /*
   * @ Description: This method stops the record from getting saved unless all child records are closed.
   * @ Args       : List<Case>
   * @ Return     : None
   */
  private static void parentCaseClosed(
    List<Case> newCaseList,
    Map<Id, Case> oldCaseMap
  ) {
    Set<Id> parentCaseIdSet = new Set<Id>();
    for (Case caseRec : newCaseList) {
      if (
        caseRec.Parent == null &&
        caseRec.Status.contains('Closed') &&
        !oldCaseMap.get(caseRec.Id).Status.contains('Closed')
      ) {
        parentCaseIdSet.add(caseRec.Id);
      }
    }

    if (parentCaseIdSet != null && !parentCaseIdSet.isEmpty()) {
      List<Case> childCaseList = [
        SELECT Id, ParentId, RecordTypeId, Parent.RecordTypeId
        FROM Case
        WHERE ParentId IN :parentCaseIdSet AND IsClosed = FALSE
      ];
      if (childCaseList != null && !childCaseList.isEmpty()) {
        Map<Id, Boolean> parentCaseOpenChildCaseMap = new Map<Id, Boolean>();
        for (Case caseRec : childCaseList) {
          if (
            caseRec.RecordTypeId == System.Label.Rating_Issue_record_type &&
            caseRec.Parent.RecordTypeId == System.Label.B_L_Revision_record_type
          )
            parentCaseOpenChildCaseMap.put(caseRec.ParentId, true);
        }
        if (!parentCaseOpenChildCaseMap.keySet().isEmpty()) {
          for (Case caseRec : newCaseList) {
            if (parentCaseOpenChildCaseMap.keySet().contains(caseRec.Id)) {
              caseRec.addError(System.Label.Case_Child_Cases_Open_Error_Msg);
            }
          }
        }
      }
    }
  }

  /*
   * @ Description: This method updates all child records from the parent records before getting saved.
   * @ Args       : List<Case>
   * @ Return     : None
   */
  private static void updateChildFieldsFromParent(List<Case> newCaseList) {
    set<ID> cases = new Set<ID>();
    set<ID> users = new Set<ID>();
    set<ID> Accs = new Set<ID>();
    for (Case c : newCaseList) {
      if (c.AccountId != null) {
        Accs.add(c.AccountId);
      }
      if (c.ParentId != null) {
        cases.add(c.ParentId);
      }
    }
    if (!Accs.isEmpty()) {
      List<Account> acclist = new List<Account>(
        [SELECT Id, Primary_Account_Manager__c FROM Account WHERE Id = :Accs]
      );
      if (!(acclist.isEmpty())) {
        for (Account acc : acclist) {
          if (acc.Primary_Account_Manager__c != null) {
            users.add(acc.Primary_Account_Manager__c);
          }
        }
      }
      if (!users.isEmpty()) {
        List<User> userlist = new List<User>(
          [SELECT Id, SenderEmail FROM User WHERE Id = :users]
        );
        for (case c : newCaseList) {
          for (Account acc : accList) {
            if (c.AccountId == acc.Id) {
              if (!(userlist.isEmpty())) {
                for (User u : userlist) {
                  if (acc.Primary_Account_Manager__c == u.ID) {
                    c.Account_Manager__c = u.SenderEmail;
                  }
                }
              }
            }
          }
        }
      }
    }
    if (!cases.isEmpty()) {
      //List<Case> parentcases=new List<Case>([SELECT Id,Service__c,Type,Origin,ContactId,Origin_City__c,Origin_Zipcode__c,Destination_City__c,Destination_State__c,Destination_Country__c,Destination_Zipcode__c,RecordTypeId,Reporter_s_Department__c,Comments__c,Origin_State__c,Origin_Country__c,Feedback_Received__c,Market_Segment__c,Assignee_Pricing_Location__c,Assignee_Pricing_SubLocation__c,Bill_of_lading__c, Priority, Summary__c,Reporter__c,Contract_Number__c,Cargo_Type__c,Additional_Services_Required__c,Cargo_Details__c,Commodity__c,Move_Type__c,Service_Type__c,Direction__c,Load_Port__c,Discharge_Port__c FROM Case where RecordTypeId=:system.Label.Existing_Customer_Rate_Request AND Id =:cases LIMIT 50000]);
      List<Case> BLallCases = new List<Case>(
        [
          SELECT
            id,
            Consignee_Name__c,
            Equipment_Type_Size__c,
            Contract_Number__c,
            Shipper_Name__c,
            Assignee_Pricing_Location__c,
            RecordTypeId,
            ContactId,
            Priority,
            BOL_Number__c,
            Voyage__c,
            Origin,
            Booking__c,
            Bill_to_Party__c,
            Move_Type__c
          FROM Case
          WHERE
            Id = :cases
            AND RecordTypeId = :system.Label.B_L_Revision_record_type
          LIMIT 50000
        ]
      );
      for (case c : newCaseList) {
        for (case pcs : BLallCases) {
          if (c.ParentId == pcs.Id) {
            if (String.isNotEmpty(pcs.ContactId)) {
              c.ContactId = pcs.ContactId;
            }
            if (String.isNotEmpty(pcs.Origin)) {
              c.Origin = pcs.Origin;
            }
            if (String.isNotEmpty(pcs.Bill_to_Party__c)) {
              c.Bill_to_Party__c = pcs.Bill_to_Party__c;
            }
            if (String.isNotEmpty(pcs.Move_Type__c)) {
              c.Move_Type__c = pcs.Move_Type__c;
            }
            if (String.isNotEmpty(pcs.Assignee_Pricing_Location__c)) {
              c.Assignee_Pricing_Location__c = pcs.Assignee_Pricing_Location__c;
            }
            if (String.isNotEmpty(pcs.Priority)) {
              c.Priority = pcs.Priority;
            }
            if (String.isNotEmpty(pcs.Booking__c)) {
              c.Booking__c = pcs.Booking__c;
            }
            if (String.isNotEmpty(pcs.BOL_Number__c)) {
              c.BOL_Number__c = pcs.BOL_Number__c.subString(0, 12);
            }
            if (String.isNotEmpty(pcs.Voyage__c)) {
              c.Voyage__c = pcs.Voyage__c;
            }
            if (String.isNotEmpty(pcs.Shipper_Name__c)) {
              c.Shipper_Name__c = pcs.Shipper_Name__c;
            }
            if (String.isNotEmpty(pcs.Consignee_Name__c)) {
              c.Consignee_Name__c = pcs.Consignee_Name__c;
            }
            if (String.isNotEmpty(pcs.Equipment_Type_Size__c)) {
              c.Equipment_Type_Size__c = pcs.Equipment_Type_Size__c;
            }
            if (String.isNotEmpty(pcs.Contract_Number__c)) {
              c.Contract_Number__c = pcs.Contract_Number__c;
            }
          }
        }
      }
    }
  }

  private static void SetTimeTakenToResolve(
    List<Case> newCaseList,
    Map<Id, Case> oldCaseMap
  ) {
    Boolean hasSessionTimer = Schema.getGlobalDescribe()
      .containsKey('casetimer19__session_time__c');

    Set<string> closedStatuses = new Set<string>();
    for (CaseStatus c : [
      SELECT Id, MasterLabel, APIName
      FROM CaseStatus
      WHERE IsClosed = TRUE
    ]) {
      closedStatuses.add(c.APIName);
    }
    for (Case cs : newCaseList) {
      if (
        oldCaseMap != null &&
        oldCaseMap.get(cs.Id).Status != cs.Status &&
        closedStatuses.contains(cs.Status)
      ) {
        if (cs.Time_Taken_To_Resolve__c == null) {
          Datetime startDate = cs.CreatedDate; // Start date

          Datetime endDate = cs.ClosedDate == null
            ? System.now()
            : cs.ClosedDate; //End Date

          Integer minutes = Integer.valueOf(
            Math.floor(
              ((endDate.getTime()) / 1000 / 60) -
              ((startDate.getTime()) /
              1000 /
              60)
            )
          );
          Integer decHours = Integer.valueOf(Math.floor(minutes / 60));
          Integer decMinutes = Integer.valueOf(
            Math.floor(minutes - decHours * 60)
          );
          cs.Time_Taken_To_Resolve__c =
            decHours +
            ' Hours ' +
            decMinutes +
            ' Minutes ';
        }
      }
    }
  }

  private static void PopulateSummary(
    List<Case> newCaseList,
    Map<Id, Case> newCaseMap
  ) {
    List<Case> allCases = new List<Case>();
    List<ID> accountIds = new List<ID>();
    List<ID> contactIds = new List<ID>();
    for (Case c : newCaseList) {
      if (c.AccountId != null) {
        accountIds.add(c.AccountId);
      }
      if (c.Shipper_Name__c != null) {
        accountIds.add(c.Shipper_Name__c);
      }
      if (c.ContactId != null) {
        contactIds.add(c.ContactId);
      }
    }
    Map<ID, String> AccInfo = new Map<ID, String>();
    for (Account a : [
      SELECT Name
      FROM Account
      WHERE Id = :accountIds
      LIMIT 1000
    ]) {
      AccInfo.put(a.Id, a.Name);
    }
    Map<ID, String> ContactInfo = new Map<ID, String>();
    for (Contact con : [
      SELECT Name
      FROM Contact
      WHERE Id = :contactIds
      LIMIT 1000
    ]) {
      ContactInfo.put(con.Id, con.Name);
    }
    String bolnumber;
    for (Case c : newCaseList) {
      if (c.RecordTypeId == System.Label.B_L_Revision_record_type) {
        if (c.BOL_Number__c == null || c.BOL_Number__c.length() < 12) {
          bolnumber = '';
        } else {
          bolnumber = c.BOL_Number__c.subString(0, 12);
        }
        c.Summary_BR__c =
          c.CaseNumber +
          ' / ' +
          bolnumber +
          ' / ' +
          (AccInfo.containsKey(c.Shipper_Name__c)
            ? AccInfo.get(c.Shipper_Name__c)
            : '');
      }
      if (c.RecordTypeId == System.Label.Rating_Issue_record_type) {
        c.Summary_BR__c =
          c.CaseNumber +
          ' / ' +
          (AccInfo.containsKey(c.AccountId) ? AccInfo.get(c.AccountId) : '');
      }
      if (c.RecordTypeId == System.Label.Booking_Request_Record_Type) {
        if (c.Booking__c == null) {
          c.Booking__c = '';
        }
        c.Summary_BR__c =
          c.CaseNumber +
          ' / ' +
          c.Booking__c +
          ' / ' +
          (AccInfo.containsKey(c.AccountId) ? AccInfo.get(c.AccountId) : '');
      }
      if (c.RecordTypeId == System.Label.Customer_Inquiry_Record_Type) {
        if (c.Request_Type__c == null) {
          c.Request_Type__c = '';
        }
        if (c.Subject == null || c.Subject == '' || c.Origin != 'Email') {
          c.Subject =
            c.CaseNumber +
            ' / ' +
            c.Request_Type__c +
            ' / ' +
            (ContactInfo.containsKey(c.ContactId)
              ? ContactInfo.get(c.ContactId)
              : '');
        }
        c.Summary_BR__c =
          c.CaseNumber +
          ' / ' +
          c.Request_Type__c +
          ' / ' +
          (ContactInfo.containsKey(c.ContactId)
            ? ContactInfo.get(c.ContactId)
            : '');
      }
      /*if(c.RecordTypeId==System.Label.Rate_Proposal_Record_Type){
                if(c.Booking__c==null){
                    c.Booking__c='';
                }
                if(c.Customers_Approval__c==null){
                    c.Customers_Approval__c='';
                }
                c.Summary_BR__c=c.CaseNumber+' / '+c.Booking__c+' / '+c.Customers_Approval__c;
            }*/
    }
  }

  /****
   * Method Name: UpdateCaseContactEmail
   * Purpose: To update email if not existing on service contact from case web email.
   *
   * */

  private static Void UpdateCaseContactEmail(
    List<Case> newCaseList,
    Map<Id, Case> newCaseMap
  ) {
    system.debug('in the method');
    List<Contact> UpdateContacts = new List<Contact>();
    Map<Id, Contact> contactmap;
    Set<Id> contactlist = new Set<Id>();
    for (Case cs : newCaseList) {
      system.debug(
        '$$$-->' +
        (String.isNotBlank(cs.ContactId) &&
        String.isNotBlank(cs.SuppliedEmail) &&
        String.isBlank(cs.ContactEmail))
      );
      system.debug('email-->' + cs.ContactEmail);
      if (
        String.isNotBlank(cs.ContactId) &&
        String.isNotBlank(cs.SuppliedEmail) &&
        cs.ContactEmail == null
      ) {
        system.debug('added to list');
        Contactlist.add(cs.ContactId);
      }
    }
    if (!Contactlist.isEmpty()) {
      system.debug('got record type');
      contactmap = new Map<Id, Contact>(
        [
          SELECT Id, RecordType.Id, RecordType.Name, Email
          FROM Contact
          WHERE id = :Contactlist
        ]
      );
    }
    for (Case cs : newCaseList) {
      system.debug(
        '$$$-->' +
        (contactlist.Contains(cs.ContactId) &&
        contactmap.get(cs.ContactId).RecordTypeId ==
        System.Label.Service_Contact_Record_Type)
      );
      if (
        contactlist.Contains(cs.ContactId) &&
        contactmap.get(cs.ContactId).RecordTypeId ==
        System.Label.Service_Contact_Record_Type &&
        contactmap.get(cs.ContactId).Email == null
      ) {
        system.debug('adding update');
        Contact con = new Contact();
        con.Id = cs.ContactId;
        con.Email = cs.SuppliedEmail;
        UpdateContacts.add(con);
      }
    }
    if (!UpdateContacts.isEmpty()) {
      system.debug('updating');
      update UpdateContacts;
    }
  }

  public static List<Case> setDueDate(List<Case> newCases) {
    Datetime nowdt = Datetime.now();
    for (Case cs : newCases) {
      String dayOfWeek = nowdt.format('E');
      if (dayOfWeek == 'Fri') {
        if (
          cs.RecordTypeId == System.Label.B_L_Revision_record_type ||
          cs.RecordTypeId == System.Label.Pricing_Rating_Issue_Record_Type
        ) {
          cs.Due_Date__c = nowdt.addDays(3);
        }
        cs.Reminder_Date__c = nowdt.addHours(20);
        cs.Reminder_Date_after_7_hrs__c = nowdt.addHours(7);
        cs.Reminder_Date_after_9_hrs__c = nowdt.addHours(9);
        if (cs.Reminder_Date__c.format('E') == 'Sat') {
          cs.Reminder_Date__c = cs.Reminder_Date__c.addDays(2);
        }
        if (cs.Reminder_Date_after_7_hrs__c.format('E') == 'Sat') {
          cs.Reminder_Date_after_7_hrs__c = cs.Reminder_Date_after_7_hrs__c.addDays(
            2
          );
          cs.Reminder_Date_after_9_hrs__c = cs.Reminder_Date_after_9_hrs__c.addDays(
            2
          );
        }
      } else if (dayOfWeek == 'Sat') {
        Datetime dt = nowdt.addDays(3);
        if (
          cs.RecordTypeId == System.Label.B_L_Revision_record_type ||
          cs.RecordTypeId == System.Label.Pricing_Rating_Issue_Record_Type
        ) {
          cs.Due_Date__c = Datetime.newInstance(
            dt.year(),
            dt.month(),
            dt.day(),
            0,
            0,
            0
          );
        }
        dt = nowdt.addDays(2);
        cs.Reminder_Date__c = Datetime.newInstance(
          dt.year(),
          dt.month(),
          dt.day(),
          20,
          0,
          0
        );
        cs.Reminder_Date_after_7_hrs__c = Datetime.newInstance(
          dt.year(),
          dt.month(),
          dt.day(),
          15,
          0,
          0
        );
        cs.Reminder_Date_after_9_hrs__c = Datetime.newInstance(
          dt.year(),
          dt.month(),
          dt.day(),
          17,
          0,
          0
        );
      } else if (dayOfWeek == 'Sun') {
        Datetime dt = nowdt.addDays(2);
        if (
          cs.RecordTypeId == System.Label.B_L_Revision_record_type ||
          cs.RecordTypeId == System.Label.Pricing_Rating_Issue_Record_Type
        ) {
          cs.Due_Date__c = Datetime.newInstance(
            dt.year(),
            dt.month(),
            dt.day(),
            0,
            0,
            0
          );
        }
        dt = nowdt.addDays(1);
        cs.Reminder_Date__c = Datetime.newInstance(
          dt.year(),
          dt.month(),
          dt.day(),
          20,
          0,
          0
        );
        cs.Reminder_Date_after_7_hrs__c = Datetime.newInstance(
          dt.year(),
          dt.month(),
          dt.day(),
          15,
          0,
          0
        );
        cs.Reminder_Date_after_9_hrs__c = Datetime.newInstance(
          dt.year(),
          dt.month(),
          dt.day(),
          17,
          0,
          0
        );
      } else {
        if (
          cs.RecordTypeId == System.Label.B_L_Revision_record_type ||
          cs.RecordTypeId == System.Label.Pricing_Rating_Issue_Record_Type
        ) {
          cs.Due_Date__c = nowdt.addDays(1);
        }
        cs.Reminder_Date__c = nowdt.addHours(20);
        cs.Reminder_Date_after_7_hrs__c = nowdt.addHours(7);
        cs.Reminder_Date_after_9_hrs__c = nowdt.addHours(9);
      }
    }
    return newCases;
  }

  public static void showPopupOnCase(
    List<Case> newCaseList,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case cs : newCaseList) {
      if (cs.Audit__c && !oldCaseMap.get(cs.Id).Audit__c) {
        cs.Show_Popup__c = true;
      }
    }
  }
}
