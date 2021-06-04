/*
 * Name: AccountOwnerChangeHelper_V2
 * Purpose: Helper class for Account Owner Change Process. It is called from AccountTriggerHandler class.
 * Author: Nagarro
 *
 */

public without sharing class AccountOwnerChangeHelper_V2 {
  public static Boolean preventPreviousOwnerUpdate = false;
  public static Boolean boolOwnerChangeRan = false;
  public static Map<Id, List<AccountTeamMember>> insertedAccMemberMap = new Map<Id, List<AccountTeamMember>>();

  public static Map<Id, List<AccountTeamMember>> updatedAccMemberMap = new Map<Id, List<AccountTeamMember>>();

  public static Map<Id, List<AccountTeamMember>> deletedAccMemberMap = new Map<Id, List<AccountTeamMember>>();

  public static Map<Id, Id> mapAccountToOldOwnerId = new Map<Id, Id>();

  /*
   * Method Name : handleOwnerUpdateBeforeUpdate
   * Description: This method is called before update and it will change the account owner if record is approved.
   */
  public static void handleOwnerUpdateBeforeUpdate(
    List<Account> lstNewAccount,
    Map<Id, Account> mapOldAccount
  ) {
    for (Account objAccount : lstNewAccount) {
      //Save previous owner manager and notes in a field
      objAccount.PreviousOwnersManagerCopy__c = objAccount.PreviousOwnersManager__c;
      objAccount.Requester_Notes_Copy__c = objAccount.Requester_Notes__c;
      if (
        objAccount.Approval_Process_Action__c ==
        ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED
      ) {
        if (
          objAccount.Proposed_Account_Owner__c != null &&
          objAccount.OwnerId != objAccount.Proposed_Account_Owner__c &&
          String.isNotBlank(objAccount.Proposed_Account_Owner__c)
        ) {
          objAccount.OwnerId = objAccount.Proposed_Account_Owner__c;
          if (mapOldAccount.containsKey(objAccount.Id)) {
            mapAccountToOldOwnerId.put(
              objAccount.Id,
              mapOldAccount.get(objAccount.Id).OwnerId
            );
          }
        }
      } else if (
        objAccount.Approval_Process_Action__c ==
        ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED
      ) {
        objAccount.Approval_Process_Action__c = null;
        objAccount.ProposedAccountOwnerCopy__c = objAccount.Proposed_Account_Owner__c;
        objAccount.Proposed_Account_Owner__c = null;
        objAccount.Transfer_Closed_Opportunities__c = false;
        objAccount.Transfer_Not_Owned_Opportunities__c = false;
        objAccount.Transfer_Open_Cases__c = false;
        objAccount.Transfer_Closed_Cases__c = false;
        objAccount.Keep_Account_Team__c = false;
        objAccount.Keep_Opportunity_Team__c = false;
        objAccount.TimeofStep1Approval__c = null;
        objAccount.TimeofStep2Approval__c = null;
        objAccount.TimeofStep3Approval__c = null;
        objAccount.Requester_Notes_Copy__c = objAccount.Requester_Notes__c;
        objAccount.Requester_Notes__c = null;
        objAccount.ApprovalProcessInitiatedOn__c = null;
        objAccount.userWhoProposedNewOwner__c = null;
        objAccount.PreviousOwnersManagerCopy__c = objAccount.PreviousOwnersManager__c;
        objAccount.PreviousOwnersManager__c = null;
        objAccount.Proposed_Owners_Manager__c = null;
      }
    }
  }

  /*
   * Method Name: transferOwners
   * Purpose: This method is called from afterUpdate method of AccountTriggerHandler. It include methods which are called when the owner change request is either approved or declined.
   * Created By:  Nagarro
   */
  public static void transferOwners(
    Map<Id, Account> newAccountMap,
    Map<Id, Account> oldAccountMap
  ) {
    Set<Id> accIdSetTransferClosedOpps = new Set<Id>();
    Set<Id> accIdSetTransferNotOwnedOpps = new Set<Id>();
    Set<Id> accIdSetTransferAccountOwnerOpenCases = new Set<Id>();
    Set<Id> accIdSetTransferAccountOwnerCases = new Set<Id>();
    Set<Id> accIdSetKeepAccountTeam = new Set<Id>();
    Set<Id> accIdSetKeepOppTeam = new Set<Id>();
    Set<Id> accIdSet = new Set<Id>();
    Set<Id> childAccIdSet = new Set<Id>(); //for id's of child Accounts
    Set<Id> allAccountsIdSet = new Set<Id>(); //for id's of parent and their child accounts
    Map<Id, Account> childToParent = new Map<Id, Account>(); //child To parent Map
    Boolean isAccRecordApproved = false;

    List<Account> accListToUpdate = new List<Account>();
    List<Account> listForEmailUpdate = new List<Account>();
    List<Account> listForReset = new List<Account>();
    List<Account> rejectedAccListToUpdate = new List<Account>();
    List<Id> accountIdList = new List<Id>();

    Map<Id, String> mapUserIdProfileName = new Map<Id, String>();
    Map<Id, List<Account>> accId_childAcc_Map = new Map<Id, List<Account>>();
    mapUserIdProfileName = fetchMapUserIdProfileName();
    Map<String, ProfilesHavingCheckboxAccess__c> mapProfileHavingChkbxAccessObj = ProfilesHavingCheckboxAccess__c.getAll();
    if (newAccountMap != null && !newAccountMap.isEmpty()) {
      //accId_childAcc_Map = getMapAccIdChildAccList(newAccountMap);

      for (Account acc : newAccountMap.values()) {
        if (oldAccountMap.containsKey(acc.Id)) {
          mapAccountToOldOwnerId.put(acc.Id, oldAccountMap.get(acc.Id).OwnerId);
        }
        accountIdList.add(acc.Id);
        //When the record is locked and user tries to change the owner on visualforce page
        if (
          Approval.isLocked(acc.Id) &&
          newAccountMap.get(acc.Id).Proposed_Account_Owner__c !=
          oldAccountMap.get(acc.Id).Proposed_Account_Owner__c
        ) {
        }

        if (
          acc.Approval_Process_Action__c ==
          ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED ||
          (oldAccountMap != null &&
          oldAccountMap.containsKey(acc.Id) &&
          acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId)
        ) {
          isAccRecordApproved = true;
          accIdSet.add(acc.Id);

          allAccountsIdSet.add(acc.Id);

          String profileName;
          if (mapUserIdProfileName.containskey(acc.userWhoProposedNewOwner__c))
            profileName = mapUserIdProfileName.get(
              acc.userWhoProposedNewOwner__c
            );

          if (mapProfileHavingChkbxAccessObj.containsKey(profileName)) {
            if (acc.Keep_Account_Team__c == true) {
              // If the checkbox is unchecked, Account Team Members will be deleted from the account
              accIdSetKeepAccountTeam.add(acc.Id);
              accIdSetKeepAccountTeam.addall(childAccIdSet);
            } else if (
              acc.Keep_Account_Team__c == false &&
              (acc.Approval_Process_Action__c !=
              ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED &&
              (oldAccountMap != null &&
              oldAccountMap.containsKey(acc.Id) &&
              acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId))
            ) {
              accIdSetKeepAccountTeam.add(acc.Id);
              accIdSetKeepAccountTeam.addall(childAccIdSet);
            } else if (
              acc.Keep_Account_Team__c == false &&
              (String.isBlank(acc.Approval_Process_Action__c) &&
              (oldAccountMap != null &&
              oldAccountMap.containsKey(acc.Id) &&
              acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId))
            ) {
              System.debug('Test entry in if *&%%$%*&');
              accIdSetKeepAccountTeam.add(acc.Id);
              accIdSetKeepAccountTeam.addall(childAccIdSet);
            }
            if (acc.Keep_Opportunity_Team__c == true) {
              accIdSetKeepOppTeam.add(acc.Id);
              accIdSetKeepOppTeam.addall(childAccIdSet);
            }
          } else {
            accIdSetKeepAccountTeam.add(acc.Id);
            accIdSetKeepAccountTeam.addall(childAccIdSet);
            accIdSetKeepOppTeam.add(acc.Id);
            accIdSetKeepOppTeam.addall(childAccIdSet);
          }
        }

        // In case the account is REJECTED/ APPROVED, certain fields will be reset
        if (
          acc.Approval_Process_Action__c ==
          ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED ||
          acc.Approval_Process_Action__c ==
          ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED
        ) {
          //IN CASE OF APPROVED - To set the Approval Process Action to NULL after all the methods are processed.
          //IN CASE OF APPROVED - Process builder is setting the field value to APPROVED.
          //IN CASE OF APPROVED - In case the value is already APPROVED, and the owner is changed again then this trigger will fire(owner will be changed) without the approval process.

          if (acc.TimeofStep3Approval__c != null) {
            //sendEmailToNewAndOldAccountOwner(acc);
          }
        }

        Account a = resetAccountFields(acc);
        accListToUpdate.add(a);
      }
    }

    Map<Id, Id> mapAccIdCurrentOwnerId = new Map<Id, Id>();
    Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();

    List<Opportunity> opportunityList = new List<Opportunity>();
    List<Contact> contactList = new List<Contact>();
    List<Case> caseList = new List<Case>();
    List<Account> childAccountsList = new List<Account>();
    List<Address__c> businessLocationList = new List<Address__c>();

    //Used as future method parameters
    String mapAccIdCurrentOwnerIdJsonString = '';
    String mapAccIdNewOwnerIdJsonString = '';

    if (newAccountMap != null && !newAccountMap.isEmpty()) {
      //   childToParent = getchildToParentMap(newAccountMap, accId_childAcc_Map);
      for (Account acc : newAccountMap.values()) {
        //Map of account id and the current owner
        if (oldAccountMap != null && oldAccountMap.containsKey(acc.Id)) {
          mapAccIdCurrentOwnerId.put(acc.Id, oldAccountMap.get(acc.Id).OwnerId);
          mapAccIdCurrentOwnerIdJsonString =
            mapAccIdCurrentOwnerIdJsonString +
            acc.Id +
            ' ' +
            oldAccountMap.get(acc.Id).OwnerId +
            ' ';
        }
        //Map of account id and the changed owner
        if (!String.isBlank(acc.OwnerId)) {
          mapAccIdNewOwnerId.put(acc.Id, acc.OwnerId);
          mapAccIdNewOwnerIdJsonString =
            mapAccIdNewOwnerIdJsonString +
            acc.Id +
            ' ' +
            acc.OwnerId +
            ' ';
        }
      }
    }

    if (
      mapAccIdCurrentOwnerId != null &&
      !mapAccIdCurrentOwnerId.isEmpty() &&
      mapAccIdNewOwnerId != null &&
      !mapAccIdNewOwnerId.isEmpty() &&
      isAccRecordApproved == true
    ) {
      if (
        accIdSetKeepAccountTeam != null && !accIdSetKeepAccountTeam.isEmpty()
      ) {
        TriggerHandler.bypass('AccountTeamTriggerHandler');
        keepAccountTeams(
          accIdSetKeepAccountTeam,
          mapAccIdCurrentOwnerId,
          mapAccIdNewOwnerId,
          accIdSet
        );
        TriggerHandler.clearBypass('AccountTeamTriggerHandler');
      }
      //updateStandardOwnerOnAccount(newAccountMap);
      //changeChildAccountOwner(mapAccIdCurrentOwnerId, mapAccIdNewOwnerId, childAccountsList);
      //transferBusinessLocationOwner(mapAccIdCurrentOwnerId,mapAccIdNewOwnerId,businessLocationList);
    }
    if (accListToUpdate != null && !accListToUpdate.isEmpty()) {
      boolOwnerChangeRan = true;
      Database.DMLOptions objDml = new Database.DMLOptions();
      objDml.DuplicateRuleHeader.AllowSave = true;
      Database.update(accListToUpdate, objDml);
      updateOppOwners(accListToUpdate);
    }
    BulkEmailAccountTransfer obj = new BulkEmailAccountTransfer();
    obj.sendEmail(newAccountMap, oldAccountMap);
    changeNeglectedChildAccOwner(newAccountMap, oldAccountMap);
    //Create parent account success log
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
    if (newAccountMap != null && newAccountMap.size() > 0) {
      for (Id objAccountId : newAccountMap.keySet()) {
        if (
          newAccountMap.containsKey(objAccountId) &&
          oldAccountMap != null &&
          oldAccountMap.containsKey(objAccountId)
        ) {
          lstOwnerChangeLogger.add(
            OwnerChangeLoggerUtility.createLogger(
              System.now(),
              objAccountId,
              UserInfo.getUserId(),
              'Success',
              objAccountId,
              null,
              null,
              null,
              oldAccountMap.get(objAccountId).OwnerId,
              newAccountMap.get(objAccountId).OwnerId,
              'Account',
              null
            )
          );
        }
      }
      Database.insert(lstOwnerChangeLogger, false);
      //Seaction of code - Not allow neww owner change batch if any of the batch from chain is running.
      Integer intChildAccountsOwnerChangeBatchSize = 0;
      List<String> lstOwnerChangeApexBatchClasses = new List<String>();
      for (Mass_Account_Transfer__mdt objMeta : [
        SELECT DeveloperName, Label, Batch_Size__c
        FROM Mass_Account_Transfer__mdt
      ]) {
        lstOwnerChangeApexBatchClasses.add(objMeta.DeveloperName);
        if (objMeta.DeveloperName == 'ChildAccountsOwnerChangeBatch') {
          intChildAccountsOwnerChangeBatchSize = Integer.valueOf(
            objMeta.Batch_Size__c
          );
        }
      }
      String strOwnerChnageBatchError = Label.OWNER_CHANGE_BATCH_JOB_ERROR;
      List<AsyncApexJob> lstAsyncApexJob = new List<AsyncApexJob>();
      List<String> lstCompletedBatchStatus = new List<String>{
        'Aborted',
        'Completed',
        'Failed'
      };
      lstAsyncApexJob = [
        SELECT Id
        FROM AsyncApexJob
        WHERE
          ApexClass.Name IN :lstOwnerChangeApexBatchClasses
          AND JobType = 'BatchApex'
          AND Status NOT IN :lstCompletedBatchStatus
      ];
      if (
        newAccountMap != null &&
        newAccountMap.size() > 0 &&
        lstAsyncApexJob != null &&
        lstAsyncApexJob.size() > 0
      ) {
        for (Account objAccount : newAccountMap.values()) {
          objAccount.addError(strOwnerChnageBatchError);
        }
      }

      Database.executeBatch(
        new ChildAccountsOwnerChangeBatch(
          mapAccountToOldOwnerId,
          insertedAccMemberMap,
          updatedAccMemberMap,
          deletedAccMemberMap,
          System.now()
        ),
        intChildAccountsOwnerChangeBatchSize
      );
    }
  }

  public static void changeNeglectedChildAccOwner(
    Map<Id, Account> newAccountMap,
    Map<Id, Account> oldAccountMap
  ) {
    List<Neglected_Account_Data__c> relatedNegChildAccs = new List<Neglected_Account_Data__c>();
    List<Neglected_Account_Data__c> negAccsToUpdate = new List<Neglected_Account_Data__c>();
    map<Id, Account> mapAcc = new Map<Id, Account>();
    if (newAccountMap != null && !newAccountMap.isEmpty()) {
      relatedNegChildAccs = [
        SELECT Id, Account__c, Owner_Name__c
        FROM Neglected_Account_Data__c
        WHERE Account__c IN :newAccountMap.keySet()
      ];
      for (Account acc : newAccountMap.values()) {
        if (
          !String.isBlank(acc.OwnerId) &&
          acc.OwnerId != oldAccountMap.get(acc.Id).OwnerId
        ) {
          mapAcc.put(acc.Id, acc);
        }
      }
    }
    for (Neglected_Account_Data__c childAcc : relatedNegChildAccs) {
      if (mapAcc.containsKey(childAcc.Account__c)) {
        childAcc.Owner_Name__c = mapAcc.get(childAcc.Account__c).Owner_Name__c;
        negAccsToUpdate.add(childAcc);
      }
    }
    if (negAccsToUpdate != null && !negAccsToUpdate.isEmpty())
      update negAccsToUpdate;
  }

  /*
   * Method Name: fetchMapUserIdProfileName
   * Purpose: Used to populate map of user id and profile name
   * Created By:  Nagarro
   */
  private static Map<Id, String> fetchMapUserIdProfileName() {
    List<User> userList = new List<User>();
    userList = [SELECT Id, Profile.Name FROM User];
    Map<Id, String> mapUserIdProfileName = new Map<Id, String>();
    if (userList != null && !userList.isEmpty()) {
      for (User u : userList) {
        mapUserIdProfileName.put(u.Id, u.Profile.Name);
      }
    }
    return mapUserIdProfileName;
  }

  public static void updateOppOwners(List<Account> accList) {
    List<Opportunity> oppListToUpdate = new List<Opportunity>();

    for (Opportunity oppObj : [
      SELECT Id, Name, Account.OwnerId, OwnerId
      FROM Opportunity
      WHERE AccountId IN :accList AND IsClosed = FALSE
    ]) {
      oppObj.OwnerId = oppObj.Account.OwnerId;
      oppListToUpdate.add(oppObj);
    }

    TriggerHandler.bypass('OpportunityTriggerHandler');
    update oppListToUpdate;
    TriggerHandler.clearBypass('OpportunityTriggerHandler');
  }

  /*
   * Method Name: resetAccountFields
   * Input Parameters: Account
   * Purpose: Used to reset the account field back to blank fields once the record comes out of approval process
   * Created By:  Nagarro
   */
  public static Account resetAccountFields(Account acc) {
    AccountOwnerChangeHelper.preventPreviousOwnerUpdate = true;
    Account objAcc = new Account();
    objAcc.Id = acc.Id;
    objAcc.Approval_Process_Action__c = null;
    objAcc.Proposed_Account_Owner__c = null;
    objAcc.Transfer_Closed_Opportunities__c = false;
    objAcc.Transfer_Not_Owned_Opportunities__c = false;
    objAcc.Transfer_Open_Cases__c = false;
    objAcc.Transfer_Closed_Cases__c = false;
    objAcc.Keep_Account_Team__c = false;
    objAcc.Keep_Opportunity_Team__c = false;
    objAcc.TimeofStep1Approval__c = null;
    objAcc.TimeofStep2Approval__c = null;
    objAcc.TimeofStep3Approval__c = null;
    objAcc.Requester_Notes__c = null;
    objAcc.ApprovalProcessInitiatedOn__c = null;
    objAcc.userWhoProposedNewOwner__c = null;
    objAcc.PreviousOwnersManager__c = null;
    objAcc.Proposed_Owners_Manager__c = null;

    return objAcc;
  }

  /*
   * Method Name: transferActivityOwner
   * Input Parameters: Map<Id, Account>, List<Opportunity>, List<Contact>
   * Purpose: This method calls methods that are used to transfer the activities owned by current account owner
   * Created By:  Nagarro
   */

  public static void transferActivityOwner(
    Set<Id> allAccountsIdSet,
    List<Opportunity> opportunityList,
    List<Contact> contactList,
    Map<Id, Id> mapAccIdNewOwnerId,
    Map<Id, Account> oldAccountMap
  ) {
    transferTasksOwner(
      allAccountsIdSet,
      opportunityList,
      contactList,
      mapAccIdNewOwnerId,
      oldAccountMap
    );
    transferEventsOwner(
      allAccountsIdSet,
      opportunityList,
      contactList,
      mapAccIdNewOwnerId,
      oldAccountMap
    );
  }

  /*
   * Method Name: transferTasksOwner
   * Input Parameters: Set<Id>, List<Opportunity>, List<Contact>, Map<Id, Account>
   * Purpose: This method is used to transfer the tasks owned by current account owner
   * Created By:  Nagarro
   */
  private static void transferTasksOwner(
    Set<Id> allAccountsIdSet,
    List<Opportunity> opportunityList,
    List<Contact> contactList,
    Map<Id, Id> mapAccIdNewOwnerId,
    Map<Id, Account> oldAccountMap
  ) {
    //Get all open tasks related to account and opportunity
    List<Task> openTaskList = new List<Task>();
    openTaskList = [
      SELECT Id, Status, WhoId, WhatId, OwnerId
      FROM Task
      WHERE
        (WhatId IN :allAccountsIdSet
        OR WhatId IN :opportunityList
        OR WhoId IN :contactList)
        AND Status != 'Completed'
    ];

    Map<Id, Id> mapOppIdAccId = new Map<Id, Id>();
    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (!String.isBlank(opp.AccountId))
          mapOppIdAccId.put(opp.Id, opp.AccountId);
      }
    }

    Map<Id, Id> mapConIdAccId = new Map<Id, Id>();
    if (contactList != null && !contactList.isEmpty()) {
      for (Contact con : contactList) {
        if (!String.isBlank(con.AccountId))
          mapConIdAccId.put(con.Id, con.AccountId);
      }
    }

    //Create map with key as the account and value as list of open tasks
    //If task is associated with account's opportunity(WhatId is Opportunity), key would be opportunity's account and value as the task list
    //If task is associated with account's contact(WhoId is Contact), key would be contact's account and value as the task list
    Map<Id, List<Task>> mapAccIdTaskList = new Map<Id, List<Task>>();
    if (openTaskList != null && !openTaskList.isEmpty()) {
      for (Task t : openTaskList) {
        String accId;

        if (t.WhatId != null) {
          accId = t.WhatId;
          if (mapOppIdAccId.containsKey(t.WhatId)) {
            accId = mapOppIdAccId.get(t.WhatId);
          }
          List<Task> tempTaskList = mapAccIdTaskList.get(accId);
          if (tempTaskList == null)
            tempTaskList = new List<Task>();
          tempTaskList.add(t);
          if (
            accId.startsWith('001') //The key of the map must be account
          )
            mapAccIdTaskList.put(accId, tempTaskList);
        } else if (t.WhoId != null && t.WhatId == null) {
          accId = t.WhoId;
          if (mapConIdAccId.containsKey(t.WhoId)) {
            accId = mapConIdAccId.get(t.WhoId);
          }
          List<Task> tempTaskList = mapAccIdTaskList.get(accId);
          if (tempTaskList == null)
            tempTaskList = new List<Task>();
          tempTaskList.add(t);
          if (
            accId.startsWith('001') //The key of the map must be account
          )
            mapAccIdTaskList.put(accId, tempTaskList);
        }
      }
    }

    List<Task> taskListToUpdate = new List<Task>();
    if (allAccountsIdSet != null && !allAccountsIdSet.isEmpty()) {
      for (Id accId : allAccountsIdSet) {
        List<Task> taskListRelatedToAcc = new List<Task>();
        if (mapAccIdTaskList.containsKey(accId))
          taskListRelatedToAcc = mapAccIdTaskList.get(accId);
        if (taskListRelatedToAcc != null && !taskListRelatedToAcc.isEmpty()) {
          for (Task t : taskListRelatedToAcc) {
            if (
              mapAccIdNewOwnerId.containsKey(accId) &&
              oldAccountMap.containsKey(accId) &&
              t.OwnerId == oldAccountMap.get(accId).OwnerId
            ) {
              t.OwnerId = mapAccIdNewOwnerId.get(accId);
              taskListToUpdate.add(t);
            }
          }
        }
      }
    }
    Database.SaveResult[] srList;
    if (taskListToUpdate != null && !taskListToUpdate.isEmpty())
      srList = Database.update(taskListToUpdate, false);

    handleInsertionUpdationResult(srList);
  }

  /*
   * Method Name: transferEventsOwner
   * Input Parameters: Map<Id, Account>, List<Opportunity>, List<Contact>
   * Purpose: This method is used to transfer the events owned by the current account owner
   * Created By:  Set<Id>
   */
  private static void transferEventsOwner(
    Set<Id> allAccountsIdSet,
    List<Opportunity> opportunityList,
    List<Contact> contactList,
    Map<Id, Id> mapAccIdNewOwnerId,
    Map<Id, Account> oldAccountMap
  ) {
    //Get all open Events related to account and opportunity
    List<Event> openEventList = new List<Event>();
    openEventList = [
      SELECT Id, WhoId, WhatId, OwnerId
      FROM Event
      WHERE
        (WhatId IN :allAccountsIdSet
        OR WhatId IN :opportunityList
        OR WhoId IN :contactList)
        AND StartDateTime >= :System.now()
    ];
    System.debug('openEventList' + openEventList);
    Map<Id, Id> mapOppIdAccId = new Map<Id, Id>();
    if (opportunityList != null && !opportunityList.isEmpty()) {
      for (Opportunity opp : opportunityList) {
        if (!String.isBlank(opp.AccountId))
          mapOppIdAccId.put(opp.Id, opp.AccountId);
      }
    }

    Map<Id, Id> mapConIdAccId = new Map<Id, Id>();
    if (contactList != null && !contactList.isEmpty()) {
      for (Contact con : contactList) {
        if (!String.isBlank(con.AccountId))
          mapConIdAccId.put(con.Id, con.AccountId);
      }
    }

    //Create map with key as the account and value as list of open Events
    //If Event is associated with account's opportunity(WhatId is Opportunity), key would be opportunity's account and value as the Event list
    //If Event is associated with account's contact(WhoId is Contact), key would be contact's account and value as the Event list
    Map<Id, List<Event>> mapAccIdEventList = new Map<Id, List<Event>>();
    if (openEventList != null && !openEventList.isEmpty()) {
      for (Event e : openEventList) {
        String accId;

        if (e.WhatId != null) {
          accId = e.WhatId;
          if (mapOppIdAccId.containsKey(e.WhatId)) {
            accId = mapOppIdAccId.get(e.WhatId);
          }
          List<Event> tempEventList = mapAccIdEventList.get(accId);
          if (tempEventList == null)
            tempEventList = new List<Event>();
          tempEventList.add(e);
          if (
            accId.startsWith('001') //The key of the map must be account
          )
            mapAccIdEventList.put(accId, tempEventList);
        } else if (e.WhoId != null && e.WhatId == null) {
          accId = e.WhoId;
          if (mapConIdAccId.containsKey(e.WhoId)) {
            accId = mapConIdAccId.get(e.WhoId);
          }
          List<Event> tempEventList = mapAccIdEventList.get(accId);
          if (tempEventList == null)
            tempEventList = new List<Event>();
          tempEventList.add(e);
          if (
            accId.startsWith('001') //The key of the map must be account
          )
            mapAccIdEventList.put(accId, tempEventList);
        }
      }
    }

    List<Event> eventListToUpdate = new List<Event>();
    if (allAccountsIdSet != null && !allAccountsIdSet.isEmpty()) {
      for (Id accId : allAccountsIdSet) {
        List<Event> eventListRelatedToAcc = new List<Event>();
        if (mapAccIdEventList.containsKey(accId))
          eventListRelatedToAcc = mapAccIdEventList.get(accId);
        if (eventListRelatedToAcc != null && !eventListRelatedToAcc.isEmpty()) {
          for (Event e : eventListRelatedToAcc) {
            if (
              mapAccIdNewOwnerId.containsKey(accId) &&
              oldAccountMap.containsKey(accId) &&
              e.OwnerId == oldAccountMap.get(accId).OwnerId
            ) {
              e.OwnerId = mapAccIdNewOwnerId.get(accId);
              eventListToUpdate.add(e);
            }
          }
        }
      }
    }
    Database.SaveResult[] srList; // = new Database.SaveResult[]();
    if (eventListToUpdate != null && !eventListToUpdate.isEmpty())
      srList = Database.update(eventListToUpdate, false);

    handleInsertionUpdationResult(srList);
  }

  /*
   * Method Name: keepAccountTeams
   * Input Parameters: Set<Id>, Map<Id, Id>, Map<Id, Id>, Set<Id>
   * Purpose: If the account owner is present in the Account Team, then he will be replaced with the new owner
   * Created By:  Nagarro
   */
  public static void keepAccountTeams(
    Set<Id> accIdSetKeepAccountTeam,
    Map<Id, Id> mapAccIdCurrentOwnerId,
    Map<Id, Id> mapAccIdNewOwnerId,
    Set<Id> accIdSet
  ) {
    List<AccountTeamMember> accTeamMemList = new List<AccountTeamMember>();
    Map<String, User_Region_to_Opp_Role__c> regionToRoleMap = new Map<String, User_Region_to_Opp_Role__c>();
    List<User> userdetail = new List<User>();
    //Id proposedOwner;
    List<Id> proposedOwnerIdList = new List<Id>();
    Map<Id, String> userToRegionMap = new Map<Id, String>();
    Map<Id, List<AccountTeamMember>> accIdToMemberMap = new Map<Id, List<AccountTeamMember>>();
    Map<String, AccountTeamMember> memberRoleToAccMem = new Map<String, AccountTeamMember>();
    Map<String, AccountTeamMember> memberIdToAccMem = new Map<String, AccountTeamMember>();
    Set<String> roleSet = new Set<String>();
    Set<String> saleProfiles = new Set<String>();
    Set<String> adminProfiles = new Set<String>();
    Set<Id> parentAccountIdSet = new Set<Id>();
    Map<Id, String> userToProfileMap = new Map<Id, String>();
    Map<Id, String> userToNameMap = new Map<Id, String>();
    List<AccountTeamMember> accTeamMemberListToUpdate = new List<AccountTeamMember>();
    List<AccountTeamMember> accTeamMemberListToInsert = new List<AccountTeamMember>();
    List<AccountTeamMember> accTeamMemberListToDelete = new List<AccountTeamMember>();

    regionToRoleMap = User_Region_to_Opp_Role__c.getAll();
    saleProfiles.addAll(Label.Sales_Profiles.split(','));
    adminProfiles.addAll(Label.System_Admin_User.split(','));
    System.debug('Sale profile ' + saleProfiles);
    List<Account> accList = [
      SELECT Id, ParentId, Name
      FROM Account
      WHERE Id IN :accIdSetKeepAccountTeam
    ];

    if (accList != null) {
      for (Account acc : accList) {
        if (acc.ParentId == null) {
          parentAccountIdSet.add(acc.Id);
          System.debug('parent acc name' + acc.Name);
        }
      }
    }

    System.debug('Parnt Account set ' + parentAccountIdSet);
    if (parentAccountIdSet != null && !parentAccountIdSet.isEmpty()) {
      System.debug('Parnt Account set^*&*& ' + parentAccountIdSet);
      accTeamMemList = [
        SELECT
          Id,
          AccountId,
          UserId,
          User.Region__c,
          User.Profile.Name,
          TeamMemberRole
        FROM AccountTeamMember
        WHERE AccountId IN :parentAccountIdSet
      ];
    }
    System.debug('Account team list ' + accTeamMemList);
    if (accTeamMemList != null && !accTeamMemList.isEmpty()) {
      for (AccountTeamMember accMemR : accTeamMemList) {
        //roleSet.add(accMemR.TeamMemberRole);

        memberRoleToAccMem.put(accMemR.TeamMemberRole, accMemR);
        System.debug(
          'Account memeber and account Id ' + accMemR.User.Profile.Name
        );
        if (saleProfiles.contains(accMemR.User.Profile.Name)) {
          memberIdToAccMem.put(
            accMemR.TeamMemberRole + accMemR.AccountId,
            accMemR
          );
        }
        if (!accIdToMemberMap.containsKey(accMemR.AccountId)) {
          accIdToMemberMap.put(
            accMemR.AccountId,
            new List<AccountTeamMember>()
          );
        }
        accIdToMemberMap.get(accMemR.AccountId).add(accMemR);
      }
    }
    System.debug('Account id to list member ' + accIdToMemberMap);
    System.debug('Role to meber ' + memberIdToAccMem);
    for (Id accId1 : parentAccountIdSet) {
      if (
        mapAccIdNewOwnerId.containsKey(accId1) &&
        mapAccIdNewOwnerId.get(accId1) != null
      ) {
        // proposedOwner = mapAccIdNewOwnerId.get(accId1);
        proposedOwnerIdList.add(mapAccIdNewOwnerId.get(accId1));
      }
    }
    userdetail = [
      SELECT Id, Region__c, Profile.Name, Name
      FROM User
      WHERE Id IN :proposedOwnerIdList
    ];

    System.debug('User details ' + userdetail);
    for (User u : userdetail) {
      userToRegionMap.put(u.Id, u.Region__c);
      userToProfileMap.put(u.Id, u.Profile.Name);
      userToNameMap.put(u.Id, u.Name);
    }
    System.debug('@^&@^ ' + userToProfileMap);

    for (Id accId : parentAccountIdSet) {
      if (
        accIdToMemberMap.containsKey(accId) &&
        !accIdToMemberMap.get(accId).isEmpty()
      ) {
        for (AccountTeamMember accTeamMember : accIdToMemberMap.get(accId)) {
          String currentOwnerId = mapAccIdCurrentOwnerId.get(
            accTeamMember.AccountId
          );
          String proposedOwnerId = mapAccIdNewOwnerId.get(
            accTeamMember.AccountId
          );

          if (currentOwnerId != proposedOwnerId) {
            //for reparenting case
            if (proposedOwnerId.contains(accTeamMember.UserId)) {
              if (
                userToRegionMap.get(accTeamMember.UserId) != null &&
                accTeamMember.TeamMemberRole !=
                regionToRoleMap.get(userToRegionMap.get(accTeamMember.UserId))
                  .Opp_Role__c &&
                saleProfiles.contains(userToProfileMap.get(proposedOwnerId))
              ) {
                if (
                  memberIdToAccMem.containsKey(
                    regionToRoleMap.get(
                        userToRegionMap.get(accTeamMember.UserId)
                      )
                      .Opp_Role__c + accTeamMember.AccountId
                  )
                ) {
                  accTeamMemberListToDelete.add(
                    memberIdToAccMem.get(
                      regionToRoleMap.get(
                          userToRegionMap.get(accTeamMember.UserId)
                        )
                        .Opp_Role__c + accTeamMember.AccountId
                    )
                  );

                  if (
                    !deletedAccMemberMap.containsKey(accTeamMember.AccountId)
                  ) {
                    deletedAccMemberMap.put(
                      accTeamMember.AccountId,
                      new List<AccountTeamMember>()
                    );
                  }
                  deletedAccMemberMap.get(accTeamMember.AccountId)
                    .add(
                      memberIdToAccMem.get(
                        regionToRoleMap.get(
                            userToRegionMap.get(accTeamMember.UserId)
                          )
                          .Opp_Role__c + accTeamMember.AccountId
                      )
                    );
                }

                accTeamMember.TeamMemberRole = regionToRoleMap.get(
                    userToRegionMap.get(accTeamMember.UserId)
                  )
                  .Opp_Role__c;
              } else if (
                userToRegionMap.get(accTeamMember.UserId) == null &&
                accTeamMember.TeamMemberRole !=
                ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN &&
                saleProfiles.contains(userToProfileMap.get(proposedOwnerId))
              ) {
                if (
                  memberIdToAccMem.containsKey(
                    ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN +
                    accTeamMember.AccountId
                  )
                ) {
                  accTeamMemberListToDelete.add(
                    memberIdToAccMem.get(
                      ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN +
                      accTeamMember.AccountId
                    )
                  );
                  if (
                    !deletedAccMemberMap.containsKey(accTeamMember.AccountId)
                  ) {
                    deletedAccMemberMap.put(
                      accTeamMember.AccountId,
                      new List<AccountTeamMember>()
                    );
                  }
                  deletedAccMemberMap.get(accTeamMember.AccountId)
                    .add(
                      memberIdToAccMem.get(
                        ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN +
                        accTeamMember.AccountId
                      )
                    );
                }
                accTeamMember.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
              }
              accTeamMemberListToUpdate.add(accTeamMember);
              if (!updatedAccMemberMap.containsKey(accTeamMember.AccountId)) {
                updatedAccMemberMap.put(
                  accTeamMember.AccountId,
                  new List<AccountTeamMember>()
                );
              }
              updatedAccMemberMap.get(accTeamMember.AccountId)
                .add(accTeamMember);
            }

            //The below code is kept inside the above if because the proposed owner will only be added in the AccountTeamMember if current owner is present.
            //If current owner is not present, it will not be replaced by the proposed owner.
            //  String proposedOwnerId = mapAccIdNewOwnerId.get(accTeamMember.AccountId);
            if (
              !proposedOwnerId.contains(accTeamMember.UserId) &&
              !adminProfiles.contains(userToNameMap.get(proposedOwnerId)) &&
              saleProfiles.contains(userToProfileMap.get(proposedOwnerId))
            ) {
              System.debug('Check the entry 1 $$%$$#$W$@');
              AccountTeamMember accTeamMem = new AccountTeamMember();
              //     if(regionToRoleMap.containsKey(accTeamMember.User.Region__c) && userToRegionMap.get(proposedOwnerId) != Null){
              if (
                userToRegionMap.get(proposedOwnerId) != null &&
                regionToRoleMap.containsKey(
                  userToRegionMap.get(proposedOwnerId)
                )
              ) {
                accTeamMem.TeamMemberRole = regionToRoleMap.get(
                    userToRegionMap.get(proposedOwnerId)
                  )
                  .Opp_Role__c;

                if (
                  accTeamMember.TeamMemberRole ==
                  regionToRoleMap.get(userToRegionMap.get(proposedOwnerId))
                    .Opp_Role__c
                ) {
                  accTeamMemberListToDelete.add(accTeamMember);
                  if (
                    !deletedAccMemberMap.containsKey(accTeamMember.AccountId)
                  ) {
                    deletedAccMemberMap.put(
                      accTeamMember.AccountId,
                      new List<AccountTeamMember>()
                    );
                  }
                  deletedAccMemberMap.get(accTeamMember.AccountId)
                    .add(accTeamMember);
                }
              } else {
                if (
                  accTeamMember.TeamMemberRole ==
                  ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN
                ) {
                  accTeamMemberListToDelete.add(accTeamMember);
                  if (
                    !deletedAccMemberMap.containsKey(accTeamMember.AccountId)
                  ) {
                    deletedAccMemberMap.put(
                      accTeamMember.AccountId,
                      new List<AccountTeamMember>()
                    );
                  }
                  deletedAccMemberMap.get(accTeamMember.AccountId)
                    .add(accTeamMember);
                }

                accTeamMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
              }
              accTeamMem.AccountAccessLevel = ConstantClass.EDIT_PERMISSION;
              accTeamMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
              accTeamMem.CaseAccessLevel = ConstantClass.EDIT_PERMISSION;
              accTeamMem.ContactAccessLevel = ConstantClass.EDIT_PERMISSION;
              accTeamMem.UserId = proposedOwnerId;
              accTeamMem.AccountId = accTeamMember.AccountId;
              accTeamMemberListToInsert.add(accTeamMem);

              if (!insertedAccMemberMap.containsKey(accTeamMem.AccountId)) {
                insertedAccMemberMap.put(
                  accTeamMem.AccountId,
                  new List<AccountTeamMember>()
                );
              }
              insertedAccMemberMap.get(accTeamMem.AccountId).add(accTeamMem);
            } else if (
              !proposedOwnerId.contains(accTeamMember.UserId) &&
              adminProfiles.contains(userToNameMap.get(proposedOwnerId)) &&
              currentOwnerId.contains(accTeamMember.UserId)
            ) {
              accTeamMemberListToDelete.add(accTeamMember);
              if (!deletedAccMemberMap.containsKey(accTeamMember.AccountId)) {
                deletedAccMemberMap.put(
                  accTeamMember.AccountId,
                  new List<AccountTeamMember>()
                );
              }
              deletedAccMemberMap.get(accTeamMember.AccountId)
                .add(accTeamMember);
            }
          }
        }
      } else {
        String currentOwnerId = mapAccIdCurrentOwnerId.get(accId);
        String proposedOwnerId = mapAccIdNewOwnerId.get(accId);

        if (
          currentOwnerId != proposedOwnerId &&
          !adminProfiles.contains(userToNameMap.get(proposedOwnerId)) &&
          saleProfiles.contains(userToProfileMap.get(proposedOwnerId))
        ) {
          AccountTeamMember accMem = new AccountTeamMember();
          if (userToRegionMap.get(proposedOwnerId) != null) {
            accMem.TeamMemberRole = regionToRoleMap.get(
                userToRegionMap.get(proposedOwnerId)
              )
              .Opp_Role__c;
          } else {
            accMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
          }

          accMem.AccountAccessLevel = ConstantClass.EDIT_PERMISSION;
          accMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
          accMem.CaseAccessLevel = ConstantClass.EDIT_PERMISSION;
          accMem.ContactAccessLevel = ConstantClass.EDIT_PERMISSION;
          accMem.UserId = proposedOwnerId;
          accMem.AccountId = accId;
          accTeamMemberListToInsert.add(accMem);
          if (!insertedAccMemberMap.containsKey(accMem.AccountId)) {
            insertedAccMemberMap.put(
              accMem.AccountId,
              new List<AccountTeamMember>()
            );
          }
          insertedAccMemberMap.get(accMem.AccountId).add(accMem);
        }
      }
    }
    Set<AccountTeamMember> accTeamMemSet = new Set<AccountTeamMember>();
    accTeamMemSet.addAll(accTeamMemberListToDelete);
    accTeamMemberListToDelete.clear();
    accTeamMemberListToDelete.addAll(accTeamMemSet);
    if (accTeamMemberListToDelete != null) {
      AccountTeamTriggerHandler.validationCheck = false;

      WithoutSharingUtility.deleteAccountTeamMembers(accTeamMemberListToDelete);
    }
    Database.SaveResult[] srListToInsert;
    if (
      accTeamMemberListToInsert != null && !accTeamMemberListToInsert.isEmpty()
    ) {
      AccountTeamTriggerHandler.roleCheck = false;
      srListToInsert = Database.insert(accTeamMemberListToInsert, false);
    }
    handleInsertionUpdationResult(srListToInsert);

    Database.SaveResult[] srListToUpdate;
    if (Schema.sObjectType.Account.isUpdateable() == true) {
      //Best Practice - Check if Updateable
      if (
        accTeamMemberListToUpdate != null &&
        !accTeamMemberListToUpdate.isEmpty()
      ) {
        AccountTeamTriggerHandler.roleCheck = false;
        srListToUpdate = Database.update(accTeamMemberListToUpdate, false);
      }
      handleInsertionUpdationResult(srListToUpdate);
    }
  }

  /*
   * Method Name: handleDeletionResult
   * Input Parameters: Database.DeleteResult[] srList
   * Purpose: This method is used to handle deletion result
   * Created By:  Nagarro
   */
  public static void handleDeletionResult(Database.DeleteResult[] srList) {
    // Iterate through each returned result
    if (srList != null && !srList.isEmpty()) {
      for (Database.DeleteResult sr : srList) {
        if (sr.isSuccess()) {
          // Operation was successful, so get the ID of the record that was processed
          System.debug('Successfully deleted records. ' + sr.getId());
        } else {
          // Operation failed, so get all errors
          for (Database.Error err : sr.getErrors()) {
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
          }
        }
      }
    }
  }

  /*
   * Method Name: handleInsertionUpdationResult
   * Input Parameters: Database.SaveResult[] srList
   * Purpose: This method is used to handle insertion and updation result
   * Created By:  Nagarro
   */
  public static void handleInsertionUpdationResult(
    Database.SaveResult[] srList
  ) {
    // Iterate through each returned result
    if (srList != null && !srList.isEmpty()) {
      for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
          // Operation was successful, so get the ID of the record that was processed
          System.debug(
            'Successfully inserted record. Record Id: ' + sr.getId()
          );
        } else {
          // Operation failed, so get all errors
          for (Database.Error err : sr.getErrors()) {
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
          }
        }
      }
    }
  }

  /*
   * Method Name: abortRunningJobsofOwnerChange
   * Input Parameters: None
   * Purpose: This is used to abort all the apex jobs running for owner change. It will only be used in cases where there could be owner update from 2 places.
   * Created By:  Nagarro
   */

  public static void abortRunningJobsofOwnerChange() {
    List<String> lstOwnerChangeApexBatchClasses = new List<String>();
    for (Mass_Account_Transfer__mdt objMeta : [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
    ]) {
      lstOwnerChangeApexBatchClasses.add(objMeta.DeveloperName);
    }

    List<String> lstCompletedBatchStatus = new List<String>{
      'Aborted',
      'Completed',
      'Failed'
    };
    for (AsyncApexJob asyncApexJobObj : [
      SELECT Id
      FROM AsyncApexJob
      WHERE
        ApexClass.Name IN :lstOwnerChangeApexBatchClasses
        AND JobType = 'BatchApex'
        AND Status NOT IN :lstCompletedBatchStatus
    ]) {
      System.debug('asyncApexJobObj---------' + asyncApexJobObj);
      System.abortJob(asyncApexJobObj.Id);
    }
  }
}
