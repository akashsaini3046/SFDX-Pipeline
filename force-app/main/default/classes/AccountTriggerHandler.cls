/*
 * Name: AccountTriggerHandler
 * Purpose: Handler class for Account Trigger
 * Author: Nagarro
 * Created Date: 10/09/2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public with sharing class AccountTriggerHandler extends TriggerHandler {
  private static Boolean byPassMrktSgmntValidation = true;
  private static Boolean byPassQueueValidation = true;
  private static Boolean byPassAccountTierValidation = true;
  @TestVisible
  private static Boolean recursionVarBeforeInsert = true;
  @TestVisible
  private static Boolean recursionVarBeforeUpdate = true;
  @TestVisible
  private static Boolean recursionVarBeforeDelete = true;
  @TestVisible
  private static Boolean recursionVarAfterInsert = true;
  @TestVisible
  private static Boolean recursionVarAfterUpdate = true;
  @TestVisible
  private static Boolean recursionVarAfterDelete = true;
  List<Account> newAccountList;
  List<Account> oldAccountList;
  Map<Id, Account> newAccountMap;
  Map<Id, Account> oldAccountMap;
  String profileName;

  /*Create the constructor*/
  public AccountTriggerHandler() {
    this.newAccountList = (List<Account>) Trigger.new;
    this.oldAccountList = (List<Account>) Trigger.old;
    this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
    this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
  }

  /*Override the before insert method from the parent class*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      ConvertUpperCase.convertToUpperCase('Account', newAccountList);
      assignUSASystemAdminAsOwner(newAccountList);
      updateSecAssignmentOnParentChange(newAccountList, oldAccountMap);
      //toTitleCase(newAccountList);
      updateAccountParent(newAccountList);
      copyAccountName(newAccountList, oldAccountMap);
      validatePhoneFormat(newAccountList, oldAccountMap);
      populateAccountType(newAccountList);
      setParentOwnerAsAccOwner(newAccountList, oldAccountMap);
      if (byPassMrktSgmntValidation == true)
        byPassMrktSgmntValidation(newAccountList, oldAccountMap);
      if (byPassQueueValidation == true)
        queueValidation(newAccountList, oldAccountMap);
      if (byPassAccountTierValidation == true)
        accountTierValidation(newAccountList, oldAccountMap);
      copyMktSegFromParent(newAccountList, oldAccountMap);
      copyQueueFromParent(newAccountList, oldAccountMap);
      copyAccountTierFromParent(newAccountList, oldAccountMap);
      setAccountOwnerToUSASYSAdmin(newAccountList);
      setLeadConverted(newAccountList);
      recursionVarBeforeInsert = false;
    }
  }

  /*Override before delete method*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      preventAccDeletion(oldAccountList);
      recursionVarBeforeDelete = false;
    }
  }

  /*Override after delete method*/
  public override void afterDelete() {
    if (recursionVarAfterDelete) {
      recursionVarAfterDelete = false;
    }
  }

  public override void beforeUpdate() {
    //Add accounts to set where acc team self delete will be allowed.

    for (Account objAccount : newAccountList) {
      AccountTeamDeleteStatic.setAccountNotConsideredForThisValidation.add(
        objAccount.Id
      );
    }
    if (recursionVarBeforeUpdate) {
      ConvertUpperCase.convertToUpperCase('Account', newAccountList);
      secAccValidation(newAccountList, oldAccountMap);
      updateSecAssignmentOnParentChange(newAccountList, oldAccountMap);
      //toTitleCase(newAccountList);
      setUserWhoProposedNewOwner(oldAccountMap, newAccountMap);
      setProposedAccountOwnerManager(newAccountList);
      updatePreviousAccountOwnerAndManager(oldAccountMap, newAccountMap);
      copyAccountName(newAccountList, oldAccountMap);
      validatePhoneFormat(newAccountList, oldAccountMap);
      setParentOwnerAsAccOwner(newAccountList, oldAccountMap);
      if (byPassMrktSgmntValidation == true)
        byPassMrktSgmntValidation(newAccountList, oldAccountMap);
      if (byPassQueueValidation == true)
        queueValidation(newAccountList, oldAccountMap);
      if (byPassAccountTierValidation == true)
        accountTierValidation(newAccountList, oldAccountMap);
      copyMktSegFromParent(newAccountList, oldAccountMap);
      copyQueueFromParent(newAccountList, oldAccountMap);
      copyAccountTierFromParent(newAccountList, oldAccountMap);
      setLeadConverted(newAccountList);
      recursionVarBeforeUpdate = false;
    }
    AccountOwnerChangeHelper_V2.handleOwnerUpdateBeforeUpdate(
      newAccountList,
      oldAccountMap
    );
  }

  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;
      updateChildSecAssignments(newAccountList, oldAccountMap);
      updateBusinessLocation(newAccountMap, oldAccountMap);

      //AccountOwnerChangeHelper.transferOwners(newAccountMap, oldAccountMap);
      createTrackHistoryRecord(
        newAccountList,
        newAccountMap,
        oldAccountList,
        oldAccountMap,
        Label.GTR_OPERATION_MODIFIED
      );
      updateParentAccountonSubsidiaryContacts(newAccountList, oldAccountMap);

      createAccountTeamForChild(newAccountList, oldAccountMap);
      populateMktSmtOnChild(newAccountList, oldAccountMap);
      populateAccountTierOnChild(newAccountList, oldAccountMap);
      populateQueueOnChild(newAccountList, oldAccountMap);
      callNeglectedDeletionMethod(newAccountMap, oldAccountMap);
      //NeglectedAccountReport.deleteNeglectedAccountRecord(newAccountMap.keyset());
      setParentAccountOnCase(newAccountList, oldAccountMap);
    }
    if (AccountOwnerChangeHelper_V2.boolOwnerChangeRan == false) {
      Map<String, Map<Id, Account>> mapParentAccountWithOwnerChange = getParentAccountWithOwnerChange(
        newAccountMap,
        oldAccountMap
      );
      if (
        mapParentAccountWithOwnerChange.containsKey('NEW_MAP') &&
        mapParentAccountWithOwnerChange.get('NEW_MAP').size() > 0
      ) {
        AccountOwnerChangeHelper_V2.transferOwners(
          mapParentAccountWithOwnerChange.get('NEW_MAP'),
          mapParentAccountWithOwnerChange.get('OLD_MAP')
        );
      }
    }
  }

  /*Override the after insert method from the parent class*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      //This method will create a record in the Track History object whenever an Account is created.
      createTrackHistoryRecord(
        newAccountList,
        newAccountMap,
        new List<Account>(),
        new Map<Id, Account>(),
        Label.GTR_OPERATION_TYPE_CREATED
      );
      createBusinessLocation(newAccountList);
      createAccountTeamForChild(newAccountList, oldAccountMap);
      createAccountTeamForParent(newAccountList);
      recursionVarAfterInsert = false;
    }
  }

  /*Method Name: callNeglectedDeletionMethod
   * Purpose: This method will call deleteNeglectedAccountRecord based on owner change.
   * Created By:  Nagarro(10th Feb, 2021)
   * Last Modified By:
   */
  public static void callNeglectedDeletionMethod(
    Map<Id, Account> newAccountMap,
    Map<Id, Account> oldAccountMap
  ) {
    for (Account acc : newAccountMap.values()) {
      if (acc.Proposed_Account_Owner__c == oldAccountMap.get(acc.Id).OwnerId) {
        NeglectedAccountReport.deleteNeglectedAccountRecord(
          newAccountMap.keyset()
        );
      }
    }
  }

  /*Method Name: createBusinessLocation
   * Purpose: This method will create a record of Address whenever a new Account is being created.
   * Created By:  Karan Dhir(26th Aug, 2019)
   * Last Modified By: Karan Dhir(26th Aug, 2019),
   */
  private void createBusinessLocation(List<Account> accountList) {
    List<Address__c> businessLocationList = new List<Address__c>();
    for (Account accountObj : accountList) {
      if (
        !accountObj.Created_from_Lead_Conversion__c &&
        accountObj.Address_Line_1__c != null
      ) {
        Address__c newaddress = new Address__c(
          Address_Line_1__c = accountObj.Address_Line_1__c,
          Address_Line_2__c = accountObj.Address_Line_2__c,
          Address_Line_3__c = accountObj.Address_Line_3__c,
          City__c = accountObj.City__c,
          Country__c = accountObj.Country__c,
          State_Picklist__c = accountObj.State__c,
          Postal_Code__c = accountObj.Postal_Code__c,
          LocationType__c = accountObj.Location_Type__c,
          Account__c = accountObj.Id
        );
        businessLocationList.add(newaddress);
      }
    }
    try {
      if (!businessLocationList.isEmpty() && businessLocationList != null) {
        insert businessLocationList;
      }
    } catch (Exception objEx) {
      System.debug(
        'AccountTriggerHandler >> createBusinessLocation ' + objEx.getMessage()
      );
    }
  }

  /*Method Name: setParentOwnerAsAccOwner
   * Purpose: This method will set owner of child account same as that of Parent Account
   * Created By:  Dhruv Raisinghani(28th Aug, 2019)
   * Modified By: Dhruv Raisinghani(16th Oct, 2019)
   */

  private static void setParentOwnerAsAccOwner(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> accountParentIdSet = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    List<Opportunity> oppList = new List<Opportunity>();
    List<Contact> contactList = new List<Contact>();
    List<Address__c> businessLocationList = new List<Address__c>();
    Map<Id, Id> accIdNewOwnerIdMap = new Map<Id, Id>();
    Map<Id, Id> accIdOldOwnerIdMap = new Map<Id, Id>();
    Set<Id> accIdSet = new Set<Id>();

    if (newAccountList != null && !newAccountList.isEmpty()) {
      for (Account acc : newAccountList) {
        if (Trigger.isInsert && acc.ParentId != null)
          accIdSet.add(acc.Id);
        else if (Trigger.isUpdate) {
          if (
            acc.ParentId != null &&
            oldAccountMap.get(acc.Id).ParentId != acc.ParentId
          )
            accIdSet.add(acc.Id);
        }
      }

      if (accIdSet != null && !accIdSet.isEmpty()) {
        Map<Id, String> map_AccId_AccOwner = new Map<Id, String>();

        for (Account acc : newAccountList) {
          accountParentIdSet.add(acc.ParentId);
          accountIdSet.add(acc.Id);
        }

        if (oldAccountMap != null) {
          for (Account oldacc : oldAccountMap.values()) {
            accountParentIdSet.add(oldacc.ParentId);
            accountIdSet.add(oldacc.Id);
          }
        }

        List<Account> accList = new List<Account>();
        if (accountParentIdSet != null && !accountParentIdSet.isEmpty()) {
          accList = [
            SELECT Id, OwnerId
            FROM Account
            WHERE Id IN :accountParentIdSet
          ];
        }

        if (accList != null) {
          for (Account acc : accList) {
            map_AccId_AccOwner.put(acc.Id, acc.OwnerId);
          }
        }
        System.debug('map_AccId_AccOwner ' + map_AccId_AccOwner);
        for (Account acc : newAccountList) {
          if (
            oldAccountMap != null &&
            oldAccountMap.get(acc.Id).ParentId != acc.ParentId
          ) {
            accIdNewOwnerIdMap.put(
              acc.Id,
              map_AccId_AccOwner.get(acc.ParentId)
            );

            accIdOldOwnerIdMap.put(acc.Id, oldAccountMap.get(acc.Id).OwnerId);
          }
        }

        System.debug('accIdNewOwnerIdMap ' + accIdNewOwnerIdMap);
        System.debug('accIdOldOwnerIdMap ' + accIdOldOwnerIdMap);

        System.debug('ACC LIST ' + accList);

        if (oldAccountMap != null) {
          oppList = AccountOwnerChangeHelper.getOpportunityList(accountIdSet);
          contactList = AccountOwnerChangeHelper.getContactList(accountIdSet);
          businessLocationList = AccountOwnerChangeHelper.getBusinessLocationList(
            accountIdSet
          );
        }
        System.debug('Opp List ' + oppList);
        System.debug('Contact List ' + contactList);
        System.debug('BL List ' + businessLocationList);

        for (Account acc : newAccountList) {
          if (map_AccId_AccOwner.containsKey(acc.ParentId)) {
            acc.OwnerId = map_AccId_AccOwner.get(acc.ParentId);
          }
        }
        if (
          accIdNewOwnerIdMap != null &&
          !accIdNewOwnerIdMap.isEmpty() &&
          accIdOldOwnerIdMap != null &&
          !accIdOldOwnerIdMap.isEmpty()
        ) {
          AccountOwnerChangeHelper.transferContactOwner(
            oldAccountMap,
            accIdOldOwnerIdMap,
            accIdNewOwnerIdMap,
            contactList
          );
          AccountOwnerChangeHelper.transferOpenOppsOwnedByAccountOwner(
            accountIdSet,
            oldAccountMap,
            accIdOldOwnerIdMap,
            accIdNewOwnerIdMap,
            oppList
          );
          AccountOwnerChangeHelper.transferBusinessLocationOwner(
            accIdOldOwnerIdMap,
            accIdNewOwnerIdMap,
            businessLocationList
          );
          AccountOwnerChangeHelper.keepAccountTeams(
            accountIdSet,
            accIdOldOwnerIdMap,
            accIdNewOwnerIdMap,
            accIdSet
          );
          AccountOwnerChangeHelper_V2.transferActivityOwner(
            accountIdSet,
            oppList,
            contactList,
            accIdNewOwnerIdMap,
            oldAccountMap
          );
        }
      }
    }
  }

  /* Method Name: byPassMrktSgmntValidation
   * Purpose: This method will thrown an error if market segment is being modified on child account
   * Created By : Nagarro(14th Aug, 2020)
   * Modified By: Nagarro(14th Aug, 2020)
   */

  private static void byPassMrktSgmntValidation(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    for (Account accObj : newAccountList) {
      if (
        oldAccountMap != null &&
        accObj.Industry != oldAccountMap.get(accObj.Id).Industry &&
        !accObj.Primary_Account__c
      )
        accObj.addError('You can update Market Segment only on Parent Account');
    }
  }

  /* Method Name: populateMktSmtOnChild
   * Purpose : This method will populate market segment field on child account similar to that of parent account
   * Created By : Nagarro(14th Aug, 2020)
   * Modified By : Nagarro(14th Aug, 2020)
   */

  private static void populateMktSmtOnChild(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    List<Account> accList = new List<Account>();
    List<Account> accountstoUpdateList = new List<Account>();
    for (Account accObj : newAccountList) {
      if (
        accObj.Industry != oldAccountMap.get(accObj.Id).Industry &&
        accObj.Industry != null &&
        accObj.ParentId == null
      ) {
        byPassMrktSgmntValidation = false;
        accList.add(accObj);
      }
    }
    for (Account a : [
      SELECT Id, ParentId, Industry, Parent.Industry
      FROM Account
      WHERE ParentId IN :accList
    ]) {
      a.Industry = a.Parent.Industry;
      accountstoUpdateList.add(a);
    }
    TriggerHandler.bypass('AccountTriggerHandler');
    update accountstoUpdateList;
    TriggerHandler.clearBypass('AccountTriggerHandler');
  }

  /* Method Name: copyMktSegFromParent
   * Purpose : This method will populate market segment field on child account similar to that of parent account in case of reparenting
   * Created By : Nagarro(14th Aug, 2020)
   * Modified By : Nagarro(14th Aug, 2020)
   */

  private static void copyMktSegFromParent(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> setOfParentIds = new Set<Id>();
    List<Account> accountList = new List<Account>();
    for (Account accObj : newAccountList) {
      byPassMrktSgmntValidation = false;
      if (Trigger.IsInsert && accObj.ParentId != null) {
        accountList.add(accObj);
        setOfParentIds.add(accObj.ParentId);
      } else if (
        Trigger.IsUpdate &&
        !oldAccountMap.isEmpty() &&
        accObj.ParentId != null &&
        oldAccountMap.get(accObj.Id).ParentId != accObj.ParentId
      ) {
        accountList.add(accObj);
        setOfParentIds.add(accObj.ParentId);
      }
    }

    List<Account> accnts = new List<Account>();
    if (setOfParentIds != null)
      accnts = [SELECT Id, Industry FROM Account WHERE Id IN :setOfParentIds];
    Map<Id, String> mapofParentIdtoSgmnt = new Map<Id, String>();
    for (Account a : accnts) {
      mapofParentIdtoSgmnt.put(a.Id, a.Industry);
    }

    for (Account acc : accountList) {
      if (mapofParentIdtoSgmnt.containsKey(acc.ParentId)) {
        acc.Industry = mapofParentIdtoSgmnt.get(acc.ParentId);
      }
    }
  }

  /*Method Name: setAccountOwnerToUSASYSAdmin
   * Purpose: This method will set owner to USA SYSTEM ADMIN if the account is primary and it is created by 'Integration User' Profile User
   * Created By:  Dhruv Raisinghani(27th Sep, 2019)
   */
  private void setAccountOwnerToUSASYSAdmin(List<Account> newAccountList) {
    Set<Id> intUserIdSet = new Set<Id>();
    String sysAdminOwnerId;

    List<User> sysAdmin = [
      SELECT Id
      FROM User
      WHERE Name = 'USA SYSTEM ADMIN'
      LIMIT 1
    ];

    if (sysAdmin.size() > 0) {
      sysAdminOwnerId = sysAdmin[0].Id;
    }
    List<User> intUserList = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'Integration User'
    ];

    for (User u : intUserList) {
      intUserIdSet.add(u.Id);
    }

    if (newAccountlist != null) {
      for (Account acc : newAccountlist) {
        if (
          acc.ParentId == null &&
          intUserIdSet.contains(acc.OwnerId) &&
          sysAdmin.size() > 0
        ) {
          acc.OwnerId = sysAdminOwnerId;
        }
      }
    }
  }

  /*Method Name: createTrackHistoryRecord
   * Purpose: This method will create a record in the Track History object whenever an Account is created/modified/deleted.
   * Created By:  Anuj Garg(06th Aug, 2019)
   * Last Modified By: Anuj Garg(06th Aug, 2019),
   */
  private void createTrackHistoryRecord(
    List<Account> accountList1,
    Map<Id, Account> accountMap1,
    List<Account> accountList2,
    Map<Id, Account> accountMap2,
    String operation
  ) {
    Map<Id, String> mapRecordIdToName = new Map<Id, String>();
    List<Track_History__c> listTrackHistory = new List<Track_History__c>();
    Set<Id> setLookupRecordIds = new Set<Id>();
    Map<String, Governance_Team_Fields__c> allFields = Governance_Team_Fields__c.getAll();
    List<List<sObject>> lstObjResults = new List<List<sObject>>();
    profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()]
    .Name;

    if (
      !profileName.equals(Label.GTR_PROFILE_DATA_STEWARD) &&
      !profileName.equals(Label.GTR_PROFILE_INTEGRATION_USER)
    ) {
      if (accountMap1.keySet() != null && !accountMap1.keySet().isEmpty()) {
        if (operation == Label.GTR_OPERATION_MODIFIED) {
          for (Governance_Team_Fields__c fld : allFields.values()) {
            if (
              fld.Object_Name__c == Label.GTR_OBJECT_NAME_ACCOUNT &&
              (fld.Data_Type__c == Label.GTR_DATA_TYPE_LOOKUP ||
              fld.Data_Type__c == Label.GTR_DATA_TYPE_LOOK_UP)
            ) {
              for (Account acc : accountList1) {
                if (
                  accountMap1.get(acc.Id).get(fld.Field_API_Name__c) !=
                  accountMap2.get(acc.Id).get(fld.Field_API_Name__c)
                ) {
                  setLookupRecordIds.add(
                    String.valueOf(
                      accountMap1.get(acc.Id).get(fld.Field_API_Name__c)
                    )
                  );
                  setLookupRecordIds.add(
                    String.valueOf(
                      accountMap2.get(acc.Id).get(fld.Field_API_Name__c)
                    )
                  );
                }
              }
            }
          }

          if (setLookupRecordIds.size() > 0) {
            lstObjResults = new List<List<sObject>>{
              [SELECT Id, Name FROM Account WHERE Id IN :setLookupRecordIds],
              [SELECT Id, Name FROM Address__c WHERE Id IN :setLookupRecordIds],
              [SELECT Id, Name FROM Contact WHERE Id IN :setLookupRecordIds],
              [
                SELECT Id, Name
                FROM Opportunity
                WHERE Id IN :setLookupRecordIds
              ],
              [SELECT Id, Name FROM Lead WHERE Id IN :setLookupRecordIds]
            };
            for (List<sObject> lstObj : lstObjResults) {
              for (sObject objItr : lstObj) {
                mapRecordIdToName.put(
                  String.valueOf(objItr.get('Id')),
                  String.valueOf(objItr.get('Name'))
                );
              }
            }
          }
        }

        for (Account acc : accountList1) {
          if (acc.Type != Label.GTR_ACCOUT_TYPE_PROSPECT) {
            //If Account created or deleted
            if (
              (operation == Label.GTR_OPERATION_TYPE_CREATED &&
              !acc.Created_from_Lead_Conversion__c) ||
              operation == Label.GTR_OPERATION_TYPE_DELETED
            ) {
              Track_History__c objTrackHistory = new Track_History__c();
              objTrackHistory.Object_Name__c = Label.GTR_OBJECT_NAME_ACCOUNT;
              objTrackHistory.Operation__c = operation;
              objTrackHistory.Attribute_Name__c = '';
              objTrackHistory.New_Value__c = '';
              objTrackHistory.Previous_Value__c = '';
              objTrackHistory.Operator_Name__c = UserInfo.getName();
              objTrackHistory.Record_Name__c = acc.Name;
              objTrackHistory.Salesforce_Record_Id__c = acc.Id;
              objTrackHistory.Operation_Time__c = System.now();
              objTrackHistory.CVIF_Id__c = acc.CVIF__c;
              listTrackHistory.add(objTrackHistory);
            } else if (Trigger.isUpdate) {
              //If Account is updated
              if (allFields.keySet() != null && !allFields.isEmpty()) {
                for (Governance_Team_Fields__c fld : allFields.values()) {
                  if (fld.Object_Name__c == Label.GTR_OBJECT_NAME_ACCOUNT) {
                    if (
                      accountMap1.get(acc.Id).get(fld.Field_API_Name__c) !=
                      accountMap2.get(acc.Id).get(fld.Field_API_Name__c)
                    ) {
                      Track_History__c objTrackHistory = new Track_History__c();
                      objTrackHistory.Object_Name__c = fld.Object_Name__c;
                      objTrackHistory.Operation__c = operation;
                      objTrackHistory.Attribute_Name__c = fld.Field_Label_Name__c;
                      objTrackHistory.New_Value__c = ((fld.Data_Type__c ==
                        Label.GTR_DATA_TYPE_LOOKUP ||
                        fld.Data_Type__c == Label.GTR_DATA_TYPE_LOOK_UP) &&
                        mapRecordIdToName.containsKey(
                          String.valueOf(
                            (accountMap1.get(acc.Id)).get(fld.Field_API_Name__c)
                          )
                        ))
                        ? mapRecordIdToName.get(
                            String.valueOf(
                              (accountMap1.get(acc.Id))
                                .get(fld.Field_API_Name__c)
                            )
                          )
                        : String.valueOf(
                            (accountMap1.get(acc.Id)).get(fld.Field_API_Name__c)
                          );
                      objTrackHistory.Previous_Value__c = ((fld.Data_Type__c ==
                        Label.GTR_DATA_TYPE_LOOKUP ||
                        fld.Data_Type__c == Label.GTR_DATA_TYPE_LOOK_UP) &&
                        mapRecordIdToName.containsKey(
                          String.valueOf(
                            (accountMap2.get(acc.Id)).get(fld.Field_API_Name__c)
                          )
                        ))
                        ? mapRecordIdToName.get(
                            String.valueOf(
                              (accountMap2.get(acc.Id))
                                .get(fld.Field_API_Name__c)
                            )
                          )
                        : String.valueOf(
                            (accountMap2.get(acc.Id)).get(fld.Field_API_Name__c)
                          );
                      objTrackHistory.Operator_Name__c = UserInfo.getName();
                      objTrackHistory.Record_Name__c = String.valueOf(
                        (accountMap2.get(acc.Id)).get('Name')
                      );
                      objTrackHistory.Salesforce_Record_Id__c = acc.Id;
                      objTrackHistory.Operation_Time__c = System.now();
                      objTrackHistory.CVIF_Id__c = acc.CVIF__c;
                      listTrackHistory.add(objTrackHistory);
                    }
                  }
                }
              }
            }
          }
        }

        if (listTrackHistory != null && !listTrackHistory.isEmpty()) {
          try {
            insert listTrackHistory;
          } catch (Exception objEx) {
            System.debug(
              'AccountTriggerHandler >> createTrackHistoryRecord ' +
              objEx.getMessage()
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: updateBusinessLocation
   * Input Parameters: Map<Id, Account>, Map<Id,Account>
   * Return value: void
   * Purpose: Update the Account_Type__c and the Account Name field on all related business locations
   * Created By:
   * Last Modified By:
   */

  private void updateBusinessLocation(
    Map<Id, Account> newAccountMap,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> accIdSet = new Set<Id>();
    Map<Id, List<Address__c>> accAddressMap = new Map<Id, List<Address__c>>();
    List<Address__c> businessLocationList = new List<Address__c>();
    Map<Id, Account> accountMap = new Map<Id, Account>();

    if (oldAccountMap != null && !oldAccountMap.isEmpty()) {
      for (Account add : newAccountMap.values()) {
        if (
          oldAccountMap.get(add.Id) != null &&
          (newAccountMap.get(add.Id).Type != oldAccountMap.get(add.Id).Type) ||
          (newAccountMap.get(add.Id).Name != oldAccountMap.get(add.Id).Name)
        ) {
          accountMap.put(add.Id, add);
        }
      }
    }

    businessLocationList = [
      SELECT Id, Account__c, Account_Type__c, Account_Name__c
      FROM Address__c
      WHERE Account__c IN :accountMap.keySet()
    ];

    if (businessLocationList != null && !businessLocationList.isEmpty()) {
      for (Address__c add : businessLocationList) {
        add.Account_Type__c = accountMap.get(add.Account__c).Type;
        add.Account_Name__c = accountMap.get(add.Account__c).Name;
      }
      Database.update(businessLocationList, true);
    }
  }

  /*
   * Method Name: updateAccountParent
   * Input Parameters: Map<Id, Account>
   * Return value: void
   * Purpose: This method is used to insert the records in webdata object by copying the information from Account record at the time of record creation
   */

  private void updateAccountParent(List<Account> newAccountList) {
    if (newAccountList != null && !newAccountList.isEmpty()) {
      for (Account acc : newAccountList) {
        if (acc.parent_party_id__c != null && acc.parentId == null) {
          acc.parentId = acc.parent_party_id__c;
        }
      }
    }
  }

  /*
   * Method Name: populateAccountType
   * Purpose: This method populates the Type of Account created from lead to prospect on Lead conversion
   * Created By:
   * Last Modified By:
   */

  public void populateAccountType(List<Account> newAccountList) {
    if (newAccountList != null && !newAccountList.isEmpty()) {
      for (Account acc : newAccountList) {
        if (acc.Created_from_Lead_Conversion__c) {
          acc.Type = ConstantClass.ACCOUNT_TYPE;
        }
      }
    }
  }

  /*
   * Method Name: createMapOfUserIdManagerId
   * Input Parameters: -
   * Purpose: This method returns map of user id and their manager. Used in multiple functions to get the manager of the user
   * Created By:  Himani Tanwar
   */
  private static Map<Id, Id> createMapOfUserIdManagerId() {
    List<User> userList = new List<User>();
    userList = [SELECT Id, ManagerId, Email, Manager.Email FROM User];
    Map<Id, Id> mapUserIdManagerId = new Map<Id, Id>();
    if (userList != null && !userList.isEmpty()) {
      for (User u : userList) {
        if (!String.isBlank(u.ManagerId)) {
          mapUserIdManagerId.put(u.Id, u.ManagerId);
        }
      }
    }
    return mapUserIdManagerId;
  }

  /*
   * Method Name: updatePreviousAccountOwnerAndManager
   * Input Parameters: Map<Id, Account>, Map<Id, Account>
   * Purpose: This method is used in Approval Process-Account Owner Change functionality. Method to update the current owner in the PreviousOwner field and current owner's manager in PreviousOwnersManager field
   * Created By:  Himani Tanwar
   */
  private void updatePreviousAccountOwnerAndManager(
    Map<Id, Account> oldAccountMap,
    Map<Id, Account> newAccountMap
  ) {
    Map<Id, Id> mapUserIdManagerId = new Map<Id, Id>();
    mapUserIdManagerId = createMapOfUserIdManagerId();

    if (newAccountMap != null && !newAccountMap.isEmpty()) {
      for (Account newAcc : newAccountMap.values()) {
        if (oldAccountMap != null && !oldAccountMap.isEmpty()) {
          if (
            oldAccountMap.get(newAcc.Id).OwnerId !=
            newAccountMap.get(newAcc.Id).Proposed_Account_Owner__c
          ) {
            if (
              oldAccountMap.containsKey(newAcc.Id) &&
              !AccountOwnerChangeHelper.preventPreviousOwnerUpdate
            ) {
              newAcc.PreviousOwner__c = oldAccountMap.get(newAcc.Id).OwnerId;

              if (mapUserIdManagerId.containsKey(newAcc.PreviousOwner__c))
                newAcc.PreviousOwnersManager__c = mapUserIdManagerId.get(
                  newAcc.PreviousOwner__c
                );
            }
          }
        }
      }
    }
  }

  /*
   * Method Name: setUserWhoProposedNewOwner
   * Input Parameters: Map<Id, Account>, Map<Id, Account>
   * Purpose: This method is used to update the field userWhoProposedNewOwner__c with the current user who proposed new owner for the account record
   * Created By:  Himani Tanwar
   */
  //Update the field userWhoProposedNewOwner__c with the current user who proposed new owner for the account record
  private static void setUserWhoProposedNewOwner(
    Map<Id, Account> oldAccountMap,
    map<Id, Account> newAccountMap
  ) {
    if (newAccountMap != null && !newAccountMap.isEmpty()) {
      for (Account acc : newAccountMap.values()) {
        if (Approval.isLocked(acc.Id) == false) {
          if (
            newAccountMap.get(acc.Id).Proposed_Account_Owner__c !=
            oldAccountMap.get(acc.Id).OwnerId
          ) {
            acc.userWhoProposedNewOwner__c = UserInfo.getUserId();
            acc.userWhoProposedNewOwnerCopy__c = UserInfo.getUserId();
          }
        }
      }
    }
  }

  //This method is used in Approval Process-Account Owner Change functionality.
  //This Method is used to update Proposed_Owners_Manager field with the Proposed Account Owner's manager.
  private static void setProposedAccountOwnerManager(
    List<Account> newAccountList
  ) {
    Map<Id, Id> mapUserIdManagerId = new Map<Id, Id>();
    mapUserIdManagerId = createMapOfUserIdManagerId();

    if (newAccountList != null && !newAccountList.isEmpty()) {
      for (Account acc : newAccountList) {
        if (mapUserIdManagerId.containsKey(acc.Proposed_Account_Owner__c)) {
          acc.ProposedAccountOwnerCopy__c = acc.Proposed_Account_Owner__c;
          acc.Proposed_Owners_Manager__c = mapUserIdManagerId.get(
            acc.Proposed_Account_Owner__c
          );
          acc.Proposed_Owners_Manager_Copy__c = mapUserIdManagerId.get(
            acc.Proposed_Account_Owner__c
          );
        }
      }
    }
  }

  //Prevent account from deletion if
  // -> opportunity or business location is linked with it
  // -> user profile is not Sales Manager or Sales Leader
  // -> user is not the account owner

  private void preventAccDeletion(List<Account> accountList) {
    Set<Id> accountIdSet = new Set<Id>();
    if (accountList != null && !accountList.isEmpty()) {
      for (Account acc : accountList) {
        accountIdSet.add(acc.Id);
      }
    }
    List<Address__c> allbusinessLocationList = new List<Address__c>();
    List<Opportunity> allOppList = new List<Opportunity>();
    List<Contact> allConList = new List<Contact>();

    if (accountIdSet != null && accountIdSet.size() > 0) {
      allbusinessLocationList = [
        SELECT Id, Account__c
        FROM Address__c
        WHERE Account__c IN :accountIdSet
      ];
      allOppList = [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE AccountId IN :accountIdSet
      ];
      allConList = [
        SELECT Id, AccountId
        FROM Contact
        WHERE AccountId IN :accountIdSet
      ];
    }

    Map<Id, integer> mapAccIdBusinessLocationSize = new Map<Id, integer>();
    if (allbusinessLocationList != null && !allbusinessLocationList.isEmpty()) {
      for (Address__c add : allbusinessLocationList) {
        integer businessLocationSize = mapAccIdBusinessLocationSize.get(
          add.Account__c
        );
        if (businessLocationSize == null) {
          businessLocationSize = 0;
        }
        businessLocationSize++;
        mapAccIdBusinessLocationSize.put(add.Account__c, businessLocationSize);
      }
    }

    Map<Id, integer> mapAccIdOppCount = new Map<Id, integer>();
    if (allOppList != null && !allOppList.isEmpty()) {
      for (Opportunity opp : allOppList) {
        integer oppList = mapAccIdOppCount.get(opp.AccountId);
        if (oppList == null) {
          oppList = 0;
        }
        oppList++;
        mapAccIdOppCount.put(opp.AccountId, oppList);
      }
    }

    Map<Id, integer> mapAccIdContactCount = new Map<Id, integer>();
    if (allConList != null && !allConList.isEmpty()) {
      for (Contact con : allConList) {
        integer conList = mapAccIdContactCount.get(con.AccountId);
        if (conList == null) {
          conList = 0;
        }
        conList++;
        mapAccIdContactCount.put(con.AccountId, conList);
      }
    }
    Set<Messaging.SingleEmailMessage> set_singleEmails = new Set<Messaging.SingleEmailMessage>();
    List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
    List<String> sendTo = new List<String>();
    sendTo.addAll(GovernanceTeamEmail__c.getAll().keySet());
    EmailTemplate emailTemplate = [
      SELECT id
      FROM EmailTemplate
      WHERE name = :Label.EMAIL_TEMPLATE_NOTIFICATION_ACC_DELETED
      LIMIT 1
    ];

    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;

    Map<String, ProfileNames__c> profileNames = ProfileNames__c.getall();
    if (accountList != null && !accountList.isEmpty()) {
      for (Account acc : accountList) {
        if (!Label.SYSTEM_ADMINISTRATOR.contains(profileName)) {
          if (
            !String.ISBLANK(acc.CDM_Org_Id__c) || !String.ISBLANK(acc.CVIF__c)
          ) {
            acc.addError(Label.RECORD_ALREADY_SYNCHED_WITH_CDM);
          } else {
            integer countbusinessLocation = 0, countOpp = 0, countCon = 0;
            if (mapAccIdBusinessLocationSize.containsKey(acc.Id))
              countbusinessLocation = mapAccIdBusinessLocationSize.get(acc.Id);
            if (mapAccIdOppCount.containsKey(acc.Id))
              countOpp = mapAccIdOppCount.get(acc.Id);
            if (mapAccIdContactCount.containsKey(acc.Id))
              countCon = mapAccIdContactCount.get(acc.Id);

            if (
              UserInfo.getUserId() != acc.OwnerId &&
              !profileNames.containsKey(profileName)
            ) {
              acc.addError(Label.DELETION_NOT_ALLOWED_PLEASE_CONTACT_MANAGER);
            }
            if (countOpp > 0) {
              acc.addError(
                Label.YOUR_ATTEMPT_TO_DELETE +
                ' ' +
                acc.name +
                ' ' +
                Label.ACCOUNT_HAS_ASSOCIATED_OPPORTUNITIES
              );
            } else if (countbusinessLocation > 0 && countCon > 0) {
              acc.addError(
                Label.YOUR_ATTEMPT_TO_DELETE +
                ' ' +
                acc.name +
                ' ' +
                Label.ACCOUNT_HAS_ASSOCIATED_BUSINESS_LOCATION_AND_CONTACT
              );
            } else if (countbusinessLocation > 0) {
              acc.addError(
                Label.YOUR_ATTEMPT_TO_DELETE +
                ' ' +
                acc.name +
                ' ' +
                Label.ACCOUNT_HAS_ASSOCIATED_BUSINESS_LOCATION
              );
            } else if (countCon > 0) {
              acc.addError(
                Label.YOUR_ATTEMPT_TO_DELETE +
                ' ' +
                acc.name +
                ' ' +
                Label.ACCOUNT_HAS_ASSOCIATED_CONTACTS
              );
            } else {
              if (
                emailTemplate != null &&
                !profileName.contains(Label.PROFILE_DATA_STEWARD) &&
                !profileName.contains(Label.INTEGRATION_USER) &&
                acc.Type != 'Prospect'
              ) {
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setWhatId(acc.Id);
                singleEmail.setTemplateID(emailTemplate.Id);
                singleEmail.setToAddresses(sendTo);
                singleEmail.setTargetObjectId(UserInfo.getUserId());
                singleEmail.saveAsActivity = false;
                if (singleEmail != null) {
                  list_singleEmails.add(singleEmail);
                }
              }
            }
          } //end of else condition
        } //end of if condition(checking System Administrator profile)
      } // end of for loop
    }
    if (!list_singleEmails.isEmpty()) {
      //This method will create a record in the Track History object whenever an Account is deleted from SF.
      createTrackHistoryRecord(
        oldAccountList,
        oldAccountMap,
        new List<Account>(),
        new Map<Id, Account>(),
        Label.GTR_OPERATION_TYPE_DELETED
      );
      Messaging.sendEmail(list_singleEmails);
    }
  }

  /*
   * Method Name: validatePhoneFormat
   * Input Parameters: List<Account> Map<Id, Account>
   * Return value: void
   * Purpose: Validation rule for phone field
   */

  public static void validatePhoneFormat(
    List<Account> AccountList,
    Map<Id, Account> AccountToIdMap
  ) {
    for (Account objAccount : AccountList) {
      if (objAccount.Phone != null || String.isNotBlank(objAccount.Phone)) {
        //if(Trigger.isInsert || (AccountToIdMap != NULL && objAccount.Phone != AccountToIdMap.get(objAccount.Id).Phone))
        if (Trigger.isInsert || Trigger.isBefore) {
          String phoneString = objAccount.Phone;
          if (
            String.isNotBlank(phoneString) && phoneString.containsAny('()-+1')
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
              objAccount.addError(System.Label.Phone_Validation);
            } else {
              if (
                phoneString.length() == 10 ||
                (phoneString.length() == 11 && phoneString.startsWith('1'))
              ) {
                objAccount.Phone = phoneString;
              }
            }
          } else if (!phoneString.isNumeric()) {
            objAccount.addError(System.Label.Phone_Validation);
          } else if (phoneString.length() < 7 || phoneString.length() > 15) {
            objAccount.addError(System.Label.Phone_Validation);
          }
        }
      }
    }
  }

  /*
   * Method Name: copyAccountName
   * Input Parameters: List<Account> Map<Id, Account>
   * Return value: void
   * Purpose: Copy the Account Name value on new field.
   */
  private void copyAccountName(
    List<Account> newAccList,
    Map<Id, Account> oldAccMap
  ) {
    for (Account objAccount : newAccList) {
      if (
        (objAccount.Id == null) ||
        (oldAccMap != null &&
        oldAccMap.get(objAccount.Id) != null &&
        objAccount.Name != oldAccMap.get(objAccount.Id).Name)
      ) {
        objAccount.Account_Name_Copy__c = objAccount.Name;
      }
    }
  }

  /*
   * Method Name: updateParentAccountonSubsidiaryContacts
   * Input Parameters:
   * List<Account> lstNewAccount : This holds new account list
   * Map<Id, Account> mapOldAccount : This holds old account map
   * Return value: void
   * Purpose: pupulates parent account in the contact to maintain subsidiary contact.
   */
  private void updateParentAccountonSubsidiaryContacts(
    List<Account> lstNewAccount,
    Map<Id, Account> mapOldAccount
  ) {
    Set<Id> setAccountIds = new Set<Id>();
    List<Contact> lstContactsToUpdate = new List<Contact>();
    List<Database.SaveResult> lstDBSaveResult = new List<Database.SaveResult>();
    List<Account> lstAccounts = new List<Account>();
    Map<Id, Account> mapAccountWithContacts = new Map<Id, Account>();
    Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata;

    for (Account objAccount : lstNewAccount) {
      setAccountIds.add(objAccount.Id);
      lstAccounts.add(
        new Account(Id = objAccount.Id, Bypass_Contact_Validation__c = true)
      );
    }

    mapAccountWithContacts = new Map<Id, Account>(
      [
        SELECT Id, ParentId, (SELECT Id, Parent_Account__c FROM Contacts)
        FROM Account
        WHERE Id IN :setAccountIds
      ]
    );
    for (Account objAccount : lstNewAccount) {
      if (
        mapOldAccount != null &&
        mapOldAccount.containsKey(objAccount.Id) &&
        objAccount.ParentId != mapOldAccount.get(objAccount.Id).ParentId
      ) {
        for (
          Contact objContact : mapAccountWithContacts.get(objAccount.Id)
            .Contacts
        ) {
          objContact.Parent_Account__c = objAccount.ParentId;
          lstContactsToUpdate.add(objContact);
        }
      }
    }

    if (lstContactsToUpdate.size() > 0) {
      try {
        //Upate account to by pass associated contact stadard validation.
        //Bypass trigger handlers from execution becuse only contact validation controller field is required to pudate where trigger execution is not required.
        //Get the handlers to bypass.
        objOpportunitySplitCustomMetadata = [
          SELECT Trigger_Handlers__c
          FROM Opportunity_Split_Constant__mdt
          WHERE DeveloperName = 'Bypass_Handlers'
          LIMIT 1
        ];
        for (
          String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
            ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
          )
        ) {
          TriggerHandler.bypass(strHandlerToBypass);
        }
        if (lstAccounts.size() > 0) {
          try {
            update lstAccounts;
          } catch (Exception objEx) {
            System.debug(
              'Exception occured in AccountTriggerHandler->updateParentAccountonSubsidiaryContacts' +
              objEx.getMessage()
            );
          }
        }
        lstDBSaveResult = Database.update(lstContactsToUpdate, false);
        for (Database.SaveResult objSvRslt : lstDBSaveResult) {
          if (objSvRslt.isSuccess() == false) {
            for (Database.Error objErr : objSvRslt.getErrors()) {
              System.debug(
                'Error occured in AccountTriggerHandler->updateParentAccountonSubsidiaryContacts ' +
                objErr.getMessage() +
                '  ' +
                objErr.getFields()
              );
            }
          }
        }
      } catch (Exception objEx) {
        System.debug(
          'Exception occured in AccountTriggerHandler->updateParentAccountonSubsidiaryContacts' +
          objEx.getMessage()
        );
      }

      //Reset contact validation controller
      lstAccounts.clear();
      for (Account objAccount : lstNewAccount) {
        lstAccounts.add(
          new Account(Id = objAccount.Id, Bypass_Contact_Validation__c = false)
        );
      }
      if (lstAccounts.size() > 0) {
        try {
          update lstAccounts;
        } catch (Exception objEx) {
          System.debug(
            'Exception occured in AccountTriggerHandler->updateParentAccountonSubsidiaryContacts' +
            objEx.getMessage()
          );
        }
      }
      //Reset trigger handlers bypass
      for (
        String strHandlerToBypass : objOpportunitySplitCustomMetadata.Trigger_Handlers__c.split(
          ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
        )
      ) {
        TriggerHandler.clearBypass(strHandlerToBypass);
      }
    }
  }
  /*
   * Method Name: createAccountTeamForChild
   * Input Parameters:
   * List<Account> lstNewAccount : This holds new account list
   * Map<Id, Account> mapOldAccount : This holds old account map
   * Return value: void
   * Purpose: This method populates the account team for a children accounts in case of Re-Parenting
   */
  private void createAccountTeamForChild(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> accParentIdSet = new Set<Id>();
    Set<Id> childIdSet = new Set<Id>();
    List<AccountTeamMember> parentAccMemList = new List<AccountTeamMember>();
    List<AccountTeamMember> childAccMemList = new List<AccountTeamMember>();
    Map<String, AccountTeamMember> mapAccountAndUserToATM = new Map<String, AccountTeamMember>();
    Map<Id, Set<String>> mapAccountIdtoATMUserKeys = new Map<Id, Set<String>>();
    Map<Id, Set<Id>> mapParentAccountIdToChildrenAccounts = new Map<Id, Set<Id>>();
    AccountTeamMember objTmpExtremeAccoutTeamMember;
    List<AccountTeamMember> lstNewAccountTeamMember = new List<AccountTeamMember>();
    AccountTeamMember objNewAccoutTeamMember;
    List<Database.SaveResult> lstDBSaveResult = new List<Database.SaveResult>();

    for (Account acc : newAccountList) {
      if (Trigger.isInsert && acc.ParentId != null) {
        accParentIdSet.add(acc.ParentId);

        if (!mapParentAccountIdToChildrenAccounts.containsKey(acc.ParentId)) {
          mapParentAccountIdToChildrenAccounts.put(acc.ParentId, new Set<Id>());
        }

        mapParentAccountIdToChildrenAccounts.get(acc.ParentId).add(acc.Id);
      } else if (Trigger.isUpdate) {
        if (
          acc.ParentId != null &&
          oldAccountMap.get(acc.Id).ParentId != acc.ParentId
        ) {
          childIdSet.add(acc.Id);
          accParentIdSet.add(acc.ParentId);
          if (!mapParentAccountIdToChildrenAccounts.containsKey(acc.ParentId)) {
            mapParentAccountIdToChildrenAccounts.put(
              acc.ParentId,
              new Set<Id>()
            );
          }

          mapParentAccountIdToChildrenAccounts.get(acc.ParentId).add(acc.Id);
        }
      }
    }
    System.debug('Parent Id Set ' + accParentIdSet);
    System.debug('Map Parent Child ' + mapParentAccountIdToChildrenAccounts);
    if (accParentIdSet != null && !accParentIdSet.isEmpty())
      parentAccMemList = [
        SELECT Id, TeamMemberRole, UserId, AccountId
        FROM AccountTeamMember
        WHERE AccountId IN :accParentIdSet
      ];

    if (childIdSet != null && !childIdSet.isEmpty())
      childAccMemList = [
        SELECT id, AccountId
        FROM AccountTeamMember
        WHERE AccountId IN :childIdSet
      ];

    if (childAccMemList != null && !childAccMemList.isEmpty()) {
      AccountTeamTriggerHandler.validationCheck = false;
      WithoutSharingUtility.deleteAccountTeamMembers(childAccMemList);
    }
    if (parentAccMemList != null && !parentAccMemList.isEmpty()) {
      for (AccountTeamMember objATM : parentAccMemList) {
        mapAccountAndUserToATM.put(
          objATM.AccountId +
          ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER +
          objATM.UserId,
          objATM
        );
        if (mapAccountIdtoATMUserKeys.containsKey(objATM.AccountId)) {
          mapAccountIdtoATMUserKeys.get(objATM.AccountId).add(objATM.UserId);
        } else {
          mapAccountIdtoATMUserKeys.put(
            objATM.AccountId,
            new Set<String>{ objATM.UserId }
          );
        }
      }

      for (
        Id idExtremeParentItr : mapParentAccountIdToChildrenAccounts.keySet()
      ) {
        System.debug(
          'idExtremeParentItr ' +
          mapParentAccountIdToChildrenAccounts.get(idExtremeParentItr)
        );
        if (
          mapParentAccountIdToChildrenAccounts.get(idExtremeParentItr) != null
        ) {
          for (
            Id idFamilyAccountId : mapParentAccountIdToChildrenAccounts.get(
              idExtremeParentItr
            )
          ) {
            System.debug(
              'idFamilyAccountId ' +
              mapAccountIdtoATMUserKeys.get(idExtremeParentItr)
            );
            if (mapAccountIdtoATMUserKeys.get(idExtremeParentItr) != null) {
              for (
                String strATMUserKey : mapAccountIdtoATMUserKeys.get(
                  idExtremeParentItr
                )
              ) {
                System.debug(
                  'strATMUserKey ' +
                  mapAccountIdtoATMUserKeys.get(idExtremeParentItr)
                );
                objTmpExtremeAccoutTeamMember = mapAccountAndUserToATM.get(
                  idExtremeParentItr +
                  ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER +
                  strATMUserKey
                );

                System.debug(
                  'objTmpExtremeAccoutTeamMember ' +
                  objTmpExtremeAccoutTeamMember
                );
                if (objTmpExtremeAccoutTeamMember != null) {
                  objNewAccoutTeamMember = objTmpExtremeAccoutTeamMember.clone(
                    false,
                    false,
                    false,
                    false
                  );
                  objNewAccoutTeamMember.AccountId = idFamilyAccountId;
                  lstNewAccountTeamMember.add(objNewAccoutTeamMember);
                }
              }
            }
          }
        }
      }
    }
    if (lstNewAccountTeamMember.size() > 0) {
      lstDBSaveResult = Database.insert(lstNewAccountTeamMember, false);
      for (Database.SaveResult objSvRslt : lstDBSaveResult) {
        if (objSvRslt.isSuccess() == false) {
          for (Database.Error objErr : objSvRslt.getErrors()) {
            System.debug(
              'Error occured in AccountTeamTriggerHandler->syncAccountTeam ' +
              objErr.getMessage() +
              '  ' +
              objErr.getFields()
            );
          }
        }
      }
    }
  }
  /*
   * Method Name: createAccountTeamForParent
   * Input Parameters:
   * List<Account> lstNewAccount : This holds new account list
   * Map<Id, Account> mapOldAccount : This holds old account map
   * Return value: void
   * Purpose: This method adds the person who creates the parent account to the account team.
   */
  private void createAccountTeamForParent(List<Account> newAccountList) {
    Map<String, User_Region_to_Opp_Role__c> regionToRoleMap = new Map<String, User_Region_to_Opp_Role__c>();
    Map<Id, String> userToRegionMap = new Map<Id, String>();
    Map<Id, String> userIdToNameMap = new Map<Id, String>();
    Set<Id> userIdSet = new Set<Id>();
    List<User> relatedUserList = new List<User>();
    List<AccountTeamMember> accTeamMemberListToInsert = new List<AccountTeamMember>();
    Set<String> adminUsers = new Set<String>();
    map<String, Boolean> profileNamesWithATMMap = new Map<String, Boolean>();

    regionToRoleMap = User_Region_to_Opp_Role__c.getAll();

    adminUsers.addAll(Label.System_Admin_User.split(','));

    for (Account acc : newAccountList) {
      userIdSet.add(acc.CreatedById);
    }
    if (!userIdSet.isEmpty())
      relatedUserList = [
        SELECT Id, Region__c, Name, Profile.Name
        FROM User
        WHERE Id IN :userIdSet
      ];

    if (!relatedUserList.isEmpty()) {
      for (User use : relatedUserList) {
        userToRegionMap.put(use.Id, use.Region__c);
        userIdToNameMap.put(use.Id, use.Profile.Name);
      }
    }
    for (
      Sales_Profiles__c profileNameObj : Sales_Profiles__c.getAll().Values()
    ) {
      profileNamesWithATMMap.put(
        profileNameObj.Name,
        profileNameObj.Create_Account_Team_Member__c
      );
    }
    for (Account acc : newAccountList) {
      System.debug('acc owner &%^%^ ' + userIdToNameMap.get(acc.OwnerId));
      if (
        acc.ParentId == null &&
        userIdToNameMap.get(acc.CreatedById) != 'Integration User' &&
        profileNamesWithATMMap.containsKey(
          userIdToNameMap.get(acc.CreatedById)
        ) &&
        profileNamesWithATMMap.get(userIdToNameMap.get(acc.CreatedById))
      ) {
        AccountTeamMember accMem = new AccountTeamMember();

        if (
          userToRegionMap.containsKey(acc.CreatedById) &&
          userToRegionMap.get(acc.CreatedById) != null &&
          regionToRoleMap.containsKey(userToRegionMap.get(acc.CreatedById))
        ) {
          accMem.TeamMemberRole = regionToRoleMap.get(
              userToRegionMap.get(acc.CreatedById)
            )
            .Opp_Role__c;
        } else {
          accMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
        }
        accMem.AccountAccessLevel = ConstantClass.EDIT_PERMISSION;
        accMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
        accMem.CaseAccessLevel = ConstantClass.EDIT_PERMISSION;
        accMem.ContactAccessLevel = ConstantClass.EDIT_PERMISSION;
        accMem.UserId = acc.CreatedById;
        accMem.AccountId = acc.Id;
        accTeamMemberListToInsert.add(accMem);
      }
    }
    if (!accTeamMemberListToInsert.isEmpty()) {
      WithoutSharingUtility.insertAccountTeamMemberRecords(
        accTeamMemberListToInsert
      );
    }
  }

  /*
   * Method Name: setLeadConverted
   * Input Parameters:
   * List<Lead> lstNewAccount: This holds new Account list.
   * Return value:
   * Purpose: set the static veriable that says lead is converted.
   */
  private void setLeadConverted(List<Account> lstNewAccount) {
    for (Account objAccount : lstNewAccount) {
      if (objAccount.Created_from_Lead_Conversion__c) {
        LeadConversionIdentifier.boolCalledAfterLeadConverted = true;
        break;
      }
    }
  }

  /*
   * Method Name: getParentAccountWithOwnerChange
   * Input Parameters:
   * Map<Id, Account> mapNewAccount : Holds new account map.
   * Map<Id, Account> mapOldAccount : Holds old account map.
   * Return value: Map<String, Map<Id, Account>>
   * Purpose: Filters parent accounts where owner is changed.
   */
  private Map<String, Map<Id, Account>> getParentAccountWithOwnerChange(
    Map<Id, Account> mapNewAccount,
    Map<Id, Account> mapOldAccount
  ) {
    Map<String, Map<Id, Account>> mapParentAccountWithOwnerChange = new Map<String, Map<Id, Account>>();
    mapParentAccountWithOwnerChange.put('NEW_MAP', new Map<Id, Account>());
    mapParentAccountWithOwnerChange.put('OLD_MAP', new Map<Id, Account>());

    if (mapNewAccount != null && mapNewAccount.values() != null) {
      for (Id objId : mapNewAccount.keySet()) {
        if (
          mapOldAccount != null &&
          mapOldAccount.containsKey(objId) &&
          mapOldAccount.get(objId).OwnerId !=
          mapNewAccount.get(objId).OwnerId &&
          mapNewAccount.get(objId).Primary_Account__c == true
        ) {
          mapParentAccountWithOwnerChange.get('OLD_MAP')
            .put(objId, mapOldAccount.get(objId));
          mapParentAccountWithOwnerChange.get('NEW_MAP')
            .put(objId, mapNewAccount.get(objId));
        }
      }
    }

    return mapParentAccountWithOwnerChange;
  }

  /*
* Method Name: setParentAccountOnCase
* Input Parameters: 
* List<Account> newAccounts : Holds new accounts list.
* Map<Id, Account> mapOldAccount : Holds old account map.
* Return value: void
* Purpose: Filters all account which has their parent account changed. 
Invokes a batch to set the updated Parent account on child cases of these filtered accounts. 
*/
  private void setParentAccountOnCase(
    List<Account> newAccounts,
    Map<Id, Account> oldAccountsMap
  ) {
    System.debug('oldAccountsMap -> ' + oldAccountsMap);
    List<Cache__c> accCaches = new List<Cache__c>();
    for (Account acc : newAccounts) {
      System.debug(
        'new parent id on account ' +
        acc.Id +
        ' is ' +
        acc.ParentId +
        ' from ' +
        oldAccountsMap.get(acc.Id).ParentId
      );
      if (
        oldAccountsMap != null &&
        oldAccountsMap.containsKey(acc.Id) &&
        acc.ParentId != oldAccountsMap.get(acc.Id).ParentId
      ) {
        accCaches.add(
          new Cache__c(
            Type__c = SetParentAccountOnCaseBatch.SetParentAccountOnCaseType,
            Data__c = acc.Id
          )
        );
      }
    }
    if (accCaches.size() > 0) {
      insert accCaches;
      SetParentAccountOnCaseBatch.start();
    }
  }

  @TestVisible
  private static void clearRecursionVar() {
    recursionVarBeforeInsert = true;
    recursionVarBeforeUpdate = true;
    recursionVarBeforeDelete = true;
    recursionVarAfterInsert = true;
    recursionVarAfterUpdate = true;
    recursionVarAfterDelete = true;
  }

  /*
   * Method Name: toTitleCase
   * Input Parameters:
   * String
   * Return value: void
   * Purpose: set the static veriable that says lead is converted.
   */

  /*   public void toTitleCase(List<Account> newAccountList){
        
        for(Account accObj: newAccountList){
            String phrase = accObj.Name;
            String titlePhrase = '';
            //a set of words that should always (or at least, almost always) be in lower case when in Title Case
            //eg The Day of the Jackal.  First and last word of a phrase should always be Capped though.
            Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};
            
            if(phrase != null && phrase.length() > 0){
                String[] splitPhrase = phrase.trim().split(' ');
                System.debug('splitPhrase----------'+splitPhrase);            
                for(integer i = 0; i < splitPhrase.size(); i++){
                    if(!forceLower.contains(splitPhrase[i].toLowerCase()) || i == 0 || i <= (splitPhrase.size()-1) ){
                        titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase())+(splitPhrase[i].substring(1).toLowerCase())+' ';
                    }
                    
                }
            }
            System.debug('titlePhrase-----------'+titlePhrase);
            accObj.Account_Name_Title_Case__c = titlePhrase;
        }
    }*/

  /*
   * Method Name: getParentAccountWithOwnerChange
   * Input Parameters:
   * Map<Id, Account> mapNewAccount : Holds new account map.
   * Map<Id, Account> mapOldAccount : Holds old account map.
   * Return value: Map<String, Map<Id, Account>>
   * Purpose: Filters parent accounts where owner is changed.
   */

  private void updateChildSecAssignments(
    List<Account> newAccList,
    Map<Id, Account> oldAccMap
  ) {
    Set<Account> accSet = new Set<Account>();
    for (Account accObj : newAccList) {
      if (
        (oldAccMap.get(accObj.Id).Secondary_Assignments__c != null &&
        accObj.Secondary_Assignments__c == null) ||
        (accObj.Secondary_Assignments__c != null &&
        accObj.Secondary_Assignments__c !=
        oldAccMap.get(accObj.Id).Secondary_Assignments__c)
      ) {
        accSet.add(accObj);
      }
    }

    List<Account> childAccountList = [
      SELECT Id, Secondary_Assignments__c, Parent.Secondary_Assignments__c
      FROM Account
      WHERE ParentId IN :accSet
    ];
    for (Account accObj : childAccountList) {
      accobj.Secondary_Assignments__c = accObj.Parent.Secondary_Assignments__c;
    }

    TriggerHandler.bypass('AccountTriggerHandler');
    update childAccountList;
    TriggerHandler.clearBypass('AccountTriggerHandler');
  }

  private void updateSecAssignmentOnParentChange(
    List<Account> newAccList,
    Map<Id, Account> oldAccMap
  ) {
    Set<Account> accSet = new Set<Account>();
    Set<Id> parentAccIdSet = new Set<Id>();
    Map<Id, String> parentIdToSecAssignmentMap = new Map<Id, String>();

    for (Account accObj : newAccList) {
      if (Trigger.isUpdate) {
        if (accObj.ParentId != oldAccMap.get(accObj.Id).ParentId) {
          accSet.add(accObj);
          parentAccIdSet.add(accObj.ParentId);
        }
      } else {
        accSet.add(accObj);
        parentAccIdSet.add(accObj.ParentId);
      }
    }
    for (Account accObj : [
      SELECT Id, Secondary_Assignments__c
      FROM Account
      WHERE Id IN :parentAccIdSet
    ]) {
      parentIdToSecAssignmentMap.put(
        accobj.Id,
        accObj.Secondary_Assignments__c
      );
    }

    for (Account accObj : accSet) {
      accObj.Secondary_Assignments__c = parentIdToSecAssignmentMap.get(
        accObj.ParentId
      );
    }
  }

  private void secAccValidation(
    List<Account> newAccList,
    Map<Id, Account> oldAccMap
  ) {
    for (Account accObj : newAccountList) {
      if (
        accObj.ParentId != null &&
        ((oldAccMap.get(accObj.Id).Secondary_Assignments__c != null &&
        accObj.Secondary_Assignments__c == null) ||
        (accObj.Secondary_Assignments__c != null &&
        accObj.Secondary_Assignments__c !=
        oldAccMap.get(accObj.Id).Secondary_Assignments__c))
      ) {
        accObj.addError(
          'Secondary Assignments can only be set up at parent account level.'
        );
      }
    }
  }

  /*   private void deleteNeglectedAccountRecord(List<Account> newAccList){
        Set<Id> accListToDel = new Set<Id>();
        Set<Id> parentIdSet = new Set<Id>();
        
        for(Account accObj: newAccList){
           
            accListToDel.add(accObj.Id);
            if(accObj.ParentId!=null){
                accListToDel.add(accObj.ParentId);
            }
        }
        if(accListToDel != Null){
            
            NeglectedAccountReport.deleteNeglectedAccountRecord(accListToDel);
        }
    }*/

  private void assignUSASystemAdminAsOwner(List<Account> newAccountList) {
    Map<Id, Id> accIdtoUserIdMap = new Map<Id, Id>();
    Map<Id, String> userIdtoProfileNameMap = new Map<Id, String>();

    Set<String> profileNameSet = new Set<String>();

    for (
      Sales_Profiles__c profileNameObj : Sales_Profiles__c.getAll().Values()
    ) {
      profileNameSet.add(profileNameObj.Name);
    }
    System.debug('profileNameSet----------' + profileNameSet);
    for (Account accObj : newAccountList) {
      accIdtoUserIdMap.put(accObj.Id, accObj.OwnerId);
    }

    for (User userObj : [
      SELECT Id, ProfileId, Profile.Name
      FROM User
      WHERE Id IN :accIdtoUserIdMap.values()
    ]) {
      userIdtoProfileNameMap.put(userObj.Id, userObj.Profile.Name);
    }

    for (Account accObj : newAccountList) {
      System.debug(
        'userIdtoProfileNameMap.get(accObj.OwnerId)------------' +
        userIdtoProfileNameMap.get(accObj.OwnerId)
      );
      if (
        !profileNameSet.contains(userIdtoProfileNameMap.get(accObj.OwnerId))
      ) {
        accObj.OwnerId = Label.USA_System_Admin_Id;
      }
    }
  }

  private static void queueValidation(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    for (Account accObj : newAccountList) {
      if (
        oldAccountMap != null &&
        accObj.Queue__c != oldAccountMap.get(accObj.Id).Queue__c &&
        !accObj.Primary_Account__c
      )
        accObj.addError('You can update Queue only on Parent Account');
    }
  }

  private static void accountTierValidation(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    for (Account accObj : newAccountList) {
      if (
        oldAccountMap != null &&
        accObj.Account_Tier__c !=
        oldAccountMap.get(accObj.Id).Account_Tier__c &&
        !accObj.Primary_Account__c
      )
        accObj.addError('You can update Account Tier only on Parent Account');
    }
  }

  private static void populateQueueOnChild(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    List<Account> accList = new List<Account>();
    List<Account> accountstoUpdateList = new List<Account>();
    List<Id> accIdList = new List<Id>();
    for (Account accObj : newAccountList) {
      accIdList.add(accObj.Id);
      if (
        accObj.Queue__c != oldAccountMap.get(accObj.Id).Queue__c &&
        accObj.Queue__c != null &&
        accObj.ParentId == null
      ) {
        byPassQueueValidation = false;
        accList.add(accObj);
      }
    }
    for (Account a : [
      SELECT Id, ParentId, Queue__c, Parent.Queue__c
      FROM Account
      WHERE ParentId IN :accList
    ]) {
      if (!accIdList.contains(a.Id)) {
        Account accObj = new Account();
        accObj.Id = a.Id;
        accObj.Queue__c = a.Parent.Queue__c;
        accountstoUpdateList.add(accObj);
      }
    }
    TriggerHandler.bypass('AccountTriggerHandler');
    update accountstoUpdateList;
    TriggerHandler.clearBypass('AccountTriggerHandler');
  }

  private static void populateAccountTierOnChild(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    List<Account> accList = new List<Account>();
    List<Account> accountstoUpdateList = new List<Account>();
    List<Id> accIdList = new List<Id>();
    for (Account accObj : newAccountList) {
      accIdList.add(accObj.Id);
      if (
        accObj.Account_Tier__c !=
        oldAccountMap.get(accObj.Id).Account_Tier__c &&
        accObj.Account_Tier__c != null &&
        accObj.ParentId == null
      ) {
        byPassAccountTierValidation = false;
        accList.add(accObj);
      }
    }

    for (Account a : [
      SELECT Id, ParentId, Account_Tier__c, Parent.Account_Tier__c
      FROM Account
      WHERE ParentId IN :accList
    ]) {
      System.debug('accIdList.contains(a.Id)------' + accIdList.contains(a.Id));
      if (!accIdList.contains(a.Id)) {
        Account accObj = new Account();
        accObj.Id = a.Id;
        accObj.Account_Tier__c = a.Parent.Account_Tier__c;
        accountstoUpdateList.add(accObj);
      }
    }
    TriggerHandler.bypass('AccountTriggerHandler');
    update accountstoUpdateList;
    TriggerHandler.clearBypass('AccountTriggerHandler');
  }

  private static void copyQueueFromParent(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> setOfParentIds = new Set<Id>();
    List<Account> accountList = new List<Account>();
    for (Account accObj : newAccountList) {
      byPassQueueValidation = false;
      if (Trigger.IsInsert && accObj.ParentId != null) {
        accountList.add(accObj);
        setOfParentIds.add(accObj.ParentId);
      } else if (
        Trigger.IsUpdate &&
        !oldAccountMap.isEmpty() &&
        accObj.ParentId != null &&
        oldAccountMap.get(accObj.Id).ParentId != accObj.ParentId
      ) {
        accountList.add(accObj);
        setOfParentIds.add(accObj.ParentId);
      }
    }

    List<Account> accnts = new List<Account>();
    if (setOfParentIds != null)
      accnts = [SELECT Id, Queue__c FROM Account WHERE Id IN :setOfParentIds];
    Map<Id, String> mapofParentIdtoSgmnt = new Map<Id, String>();
    for (Account a : accnts) {
      mapofParentIdtoSgmnt.put(a.Id, a.Queue__c);
    }
    //System.debug('mapofParentIdtoSgmnt' + mapofParentIdtoSgmnt.values());
    for (Account acc : accountList) {
      if (mapofParentIdtoSgmnt.containsKey(acc.ParentId)) {
        //System.debug('mapofParentIdtoSgmnt' + mapofParentIdtoSgmnt.get(acc.Parent.Industry));
        acc.Queue__c = mapofParentIdtoSgmnt.get(acc.ParentId);
        //System.debug('mapofParentIdtoSgmnt' + acc.Industry);
      }
    }
  }

  private static void copyAccountTierFromParent(
    List<Account> newAccountList,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> setOfParentIds = new Set<Id>();
    List<Account> accountList = new List<Account>();
    for (Account accObj : newAccountList) {
      byPassQueueValidation = false;
      if (Trigger.IsInsert && accObj.ParentId != null) {
        accountList.add(accObj);
        setOfParentIds.add(accObj.ParentId);
      } else if (
        Trigger.IsUpdate &&
        !oldAccountMap.isEmpty() &&
        accObj.ParentId != null &&
        oldAccountMap.get(accObj.Id).ParentId != accObj.ParentId
      ) {
        accountList.add(accObj);
        setOfParentIds.add(accObj.ParentId);
      }
    }

    List<Account> accnts = new List<Account>();
    if (setOfParentIds != null)
      accnts = [
        SELECT Id, Account_Tier__c
        FROM Account
        WHERE Id IN :setOfParentIds
      ];
    Map<Id, String> mapofParentIdtoSgmnt = new Map<Id, String>();
    for (Account a : accnts) {
      mapofParentIdtoSgmnt.put(a.Id, a.Account_Tier__c);
    }
    //System.debug('mapofParentIdtoSgmnt' + mapofParentIdtoSgmnt.values());
    for (Account acc : accountList) {
      if (mapofParentIdtoSgmnt.containsKey(acc.ParentId)) {
        //System.debug('mapofParentIdtoSgmnt' + mapofParentIdtoSgmnt.get(acc.Parent.Industry));
        acc.Account_Tier__c = mapofParentIdtoSgmnt.get(acc.ParentId);
        //System.debug('mapofParentIdtoSgmnt' + acc.Industry);
      }
    }
  }
}
