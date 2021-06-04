/*
 * Name: AccountTeamTriggerHandler
 * Purpose: Handler class for AccountTeam trigger.
 * Author: Nagarro
 * Created Date: 18-Nov-2019
 *
 *  Modification History
 *  Description                              #Story/Defect#      Modified By         Date
 *  1.Logic added to prevent addition        #CROSA-1201         Nagarro             18-Mar-2020
 *    of Sales Agent on account teams.
 *
 */
public with sharing class AccountTeamTriggerHandler extends TriggerHandler {
  public static Boolean validationCheck = true;
  public static Boolean roleCheck = true;
  public static Boolean isRecursion = false;
  public static Integer count = 0;
  List<AccountTeamMember> lstAccountTeamMemberInScope = new List<AccountTeamMember>();
  Boolean boolInsertTrigger = false,
    boolUpdateTrigger = false,
    boolDeleteTrigger = false;
  List<AccountTeamMember> newATMList = new List<AccountTeamMember>();
  List<AccountTeamMember> oldATMList = new List<AccountTeamMember>();
  Map<Id, AccountTeamMember> oldATMMap = new Map<Id, AccountTeamMember>();
  Map<Id, AccountTeamMember> newATMMap = new Map<Id, AccountTeamMember>();
  Set<String> accountErrorIds = new Set<String>();

  //Constructor
  public AccountTeamTriggerHandler() {
    //System.debug('+++**** '+Trigger.isInsert);
    //System.debug('@@!!___'+Trigger.isUpdate);
    //System.debug('@@@888--'+Trigger.new);
    //System.debug('@@@--- '+Trigger.old);
    this.newATMList = (List<AccountTeamMember>) Trigger.new;
    this.oldATMList = (List<AccountTeamMember>) Trigger.old;
    this.oldATMMap = (Map<Id, AccountTeamMember>) Trigger.oldMap;
    this.newATMMap = (Map<Id, AccountTeamMember>) Trigger.newMap;
  }

  //Override the after insert
  public override void afterInsert() {
    System.debug('afterInsert invoked');
    System.debug('afterInsert account team: ' + newATMList);
    lstAccountTeamMemberInScope = this.newATMList;
    boolInsertTrigger = true;

    //if(isRecursion == false) {
    //    isRecursion = true;
    syncAccountTeam();
    captureInsertedRecord(newATMList);
    sendEmailToAccountTeamMembers(newATMList, oldATMList, oldATMMap);
    //updateContractsRepFieldOnAccount(newAtmList);
    // }
  }

  //Override the after update
  public override void afterUpdate() {
    lstAccountTeamMemberInScope = this.newATMList;
    boolUpdateTrigger = true;

    // if(isRecursion == false) {
    //     isRecursion = true;
    syncAccountTeam();
    //}
    captureUpdatedRecord(newATMList);
    sendEmailToAccountTeamMembers(newATMList, oldATMList, oldATMMap);
    //updateContractsRepFieldOnAccount(newAtmList);
  }

  //Override the after delete
  public override void afterDelete() {
    lstAccountTeamMemberInScope = this.oldATMList;
    boolDeleteTrigger = true;
    syncAccountTeam();
  }

  public override void beforeDelete() {
    try {
      preventSelfDelete(oldATMList);
    } catch (Exception objEx) {
      System.debug('AccountTeamTriggerHandler > before delete');
    }

    if (validationCheck == true) {
      preventChildAccountTeamDeletion(oldATMList);
    }
    sendEmailToAccountTeamMembers(newATMList, oldATMList, oldATMMap);
    captureDeletedRecord(oldATMList);
    if (roleCheck == true) {
      roleAssignmentAndUserValidation(newATMList, oldATMList, oldATMMap);
    }
  }
  public override void beforeInsert() {
    //lstAccountTeamMemberInScope = this.newATMList;
    boolInsertTrigger = true;

    if (validationCheck) {
      preventChildAccountTeamInsertAndUpdate(newAtmList);
    }
    preventInsertionAndUpdationOfSameRole(newAtmList, oldATMMap);

    if (roleCheck == true) {
      roleAssignmentAndUserValidation(newATMList, oldATMList, oldATMMap);
    }

    //preventAdditionOfSalesAgentsOnAccountTeam(newAtmList);
    preventRoleMismatchForSalesAgent(newAtmList);
  }

  public override void beforeUpdate() {
    //lstAccountTeamMemberInScope = this.newATMList;

    //  preventChildAccountTeamInsertAndUpdate();
    if (validationCheck == true) {
      preventChildAccountTeamInsertAndUpdate(newAtmList);
    }
    preventInsertionAndUpdationOfSameRole(newAtmList, oldATMMap);

    if (roleCheck == true || Test.isRunningTest()) {
      roleAssignmentAndUserValidation(newATMList, oldATMList, oldATMMap);
    }

    //preventAdditionOfSalesAgentsOnAccountTeam(newAtmList);
    preventRoleMismatchForSalesAgent(newAtmList);
  }

  /*
   * Method Name: syncAccountTeam
   * Input Parameters:
   * Return value:
   * Purpose: This method syncs account team member across accout hierarchy
   */
  private void syncAccountTeam() {
    Set<Id> setAccountIdInScope = new Set<Id>();
    //This holds accout to extream parent account
    Map<Id, Id> mapAccountToExtremeParent = new Map<Id, Id>();
    //This holds parent account to parent accounts
    Map<Id, Set<Id>> mapParentAccountIdToChildrenAccounts = new Map<Id, Set<Id>>();
    Id idExtremeParent;
    List<AccountTeamMember> lstNewAccountTeamMember = new List<AccountTeamMember>();
    List<AccountTeamMember> lstUpdatableAccountTeamMember = new List<AccountTeamMember>();
    AccountTeamMember objTmpExtremeAccoutTeamMember;
    AccountTeamMember objNewAccoutTeamMember;
    AccountTeamMember objTmpCurrentAccoutTeamMember;
    Boolean isUpdated;
    Set<Id> setFamilyAccountIdinTheScope = new Set<Id>();
    List<AccountTeamMember> lstAtmInFamily;
    Map<String, AccountTeamMember> mapAccountAndUserToATM = new Map<String, AccountTeamMember>();
    Map<Id, Set<String>> mapAccountIdtoATMUserKeys = new Map<Id, Set<String>>();
    Map<String, AccountTeamMember> mapExtremeParentAccountAndUserToATM = new Map<String, AccountTeamMember>();
    Map<Id, Set<String>> mapExtremeAccountIdtoATMUserKeys = new Map<Id, Set<String>>();
    List<Database.SaveResult> lstDBSaveResult = new List<Database.SaveResult>();
    List<Database.SaveResult> lstDBUpdateResult = new List<Database.SaveResult>();
    List<Database.DeleteResult> lstDeleteResult = new List<Database.DeleteResult>();

    //Check if sync is active
    Account_Team_Sync_Constant__mdt objAccountTeamSyncConstantMeta = [
      SELECT Run_Sync__c
      FROM Account_Team_Sync_Constant__mdt
      WHERE DeveloperName = 'Account_Team_Sync_Constant'
    ];
    if (objAccountTeamSyncConstantMeta.Run_Sync__c == false) {
      return;
    }

    for (AccountTeamMember objATM : lstAccountTeamMemberInScope) {
      setAccountIdInScope.add(objATM.AccountId);
    }

    validationCheck = false;
    List<Account> childAccList = new List<Account>();
    Set<Id> childAccIdSet = new Set<Id>();

    childAccList = [
      SELECT Id, ParentId
      FROM Account
      WHERE ParentId IN :setAccountIdInScope
    ];
    if (childAccList != null) {
      for (Account acc : childAccList) {
        if (!mapParentAccountIdToChildrenAccounts.containsKey(acc.ParentId)) {
          mapParentAccountIdToChildrenAccounts.put(acc.ParentId, new Set<Id>());
        }
        mapParentAccountIdToChildrenAccounts.get(acc.ParentId).add(acc.Id);

        mapAccountToExtremeParent.put(acc.Id, acc.ParentId);
        childAccIdSet.add(acc.Id);
      }
    }
    System.debug('Child Acc Id ' + childAccIdSet);
    System.debug(
      'mapParentAccountIdToChildrenAccounts ' +
      mapParentAccountIdToChildrenAccounts
    );
    if (boolInsertTrigger || boolUpdateTrigger || boolDeleteTrigger) {
      List<AccountTeamMember> childAccTeamMembers = new List<AccountTeamMember>();

      childAccTeamMembers = WithoutSharingUtility.queryAccountTeamMember(
        childAccIdSet
      );

      if (childAccTeamMembers != null) {
        WithoutSharingUtility.deleteAccountTeamMembers(childAccTeamMembers);
      }
      List<AccountTeamMember> accTeamParentList = new List<AccountTeamMember>();

      accTeamParentList = WithoutSharingUtility.queryAccountTeamMember(
        setAccountIdInScope
      );

      System.debug('Acc Team Parent ' + accTeamParentList);
      if (accTeamParentList != null) {
        for (AccountTeamMember objATM : accTeamParentList) {
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
        System.debug('mapAccountAndUserToATM ' + mapAccountAndUserToATM);
        System.debug('mapAccountIdtoATMUserKeys ' + mapAccountIdtoATMUserKeys);

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
      System.debug('Neew Account Team ' + lstNewAccountTeamMember);
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
  }

  /****Account Team Member Info Addition/Updation/Deletion******/
  private void captureInsertedRecord(
    List<AccountTeamMember> newAccountTeamList
  ) {
    List<Account_Team_Member_Info__c> accTeamInfoInsertList = new List<Account_Team_Member_Info__c>();
    newAccountTeamList = [
      SELECT
        Id,
        AccountId,
        Account.ParentId,
        Account.CVIF__c,
        TeamMemberRole,
        UserId
      FROM AccountTeamMember
      WHERE Id IN :newAccountTeamList
    ];

    List<Id> listOfParentAccountId = new List<Id>();
    Set<Id> childAccIdSet = new Set<Id>();
    List<Account> childAccList = new List<Account>();
    Map<Id, List<Account>> parentTochildMap = new Map<Id, List<Account>>();

    for (AccountTeamMember accMem : newAccountTeamList) {
      childAccIdSet.add(accMem.AccountId);
    }
    if (childAccIdSet != null && !childAccIdSet.isEmpty())
      childAccList = [
        SELECT id, ParentId, CVIF__c
        FROM Account
        WHERE ParentId IN :childAccIdSet
      ];

    if (childAccList != null && !childAccList.isEmpty()) {
      for (Account acc : childAccList) {
        if (!parentTochildMap.containsKey(acc.ParentId)) {
          parentTochildMap.put(acc.ParentId, new List<Account>());
        }
        parentTochildMap.get(acc.ParentId).add(acc);
      }
    }

    System.debug('newAccountTeamList insertion: ' + newAccountTeamList);

    for (AccountTeamMember accMem : newAccountTeamList) {
      Account_Team_Member_Info__c obj = new Account_Team_Member_Info__c();

      if (accMem.Account.ParentId == null) {
        obj.User__c = accMem.UserId;
        obj.Account__c = accMem.AccountId;
        obj.Team_Role__c = accMem.TeamMemberRole;
        obj.Status__c = 'Inserted';
        obj.CVIF_Id__c = accMem.Account.CVIF__c;
        obj.Parent_Account__c = accMem.Account.ParentId;
        obj.Unique__c =
          accMem.UserId +
          ' ' +
          accMem.AccountId +
          ' ' +
          DateTime.Now().day() +
          DateTime.Now().month();
        accTeamInfoInsertList.add(obj);

        if (
          parentTochildMap.containsKey(accMem.AccountId) &&
          !parentTochildMap.get(accMem.AccountId).isEmpty()
        ) {
          System.debug('Entry in child insert');
          for (Account childAcc : parentTochildMap.get(accMem.AccountId)) {
            Account_Team_Member_Info__c obj2 = new Account_Team_Member_Info__c();
            obj2.User__c = accMem.UserId;
            obj2.Account__c = childAcc.Id;
            obj2.Team_Role__c = accMem.TeamMemberRole;
            obj2.Status__c = 'Inserted';
            obj2.CVIF_Id__c = childAcc.CVIF__c;
            obj2.Parent_Account__c = childAcc.ParentId;
            obj2.Unique__c =
              accMem.UserId +
              ' ' +
              childAcc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj2);
          }
        }
      }
    }

    System.debug('accTeamInfoInsertList insertion: ' + accTeamInfoInsertList);

    if (accTeamInfoInsertList != null && !accTeamInfoInsertList.isEmpty()) {
      Schema.SObjectField ftoken = Account_Team_Member_Info__c.Unique__c;
      Database.UpsertResult[] srList = Database.upsert(
        accTeamInfoInsertList,
        ftoken,
        false
      );
      System.debug('srList insertion: ' + srList);
    }
  }

  private void captureUpdatedRecord(
    List<AccountTeamMember> newAccountTeamList
  ) {
    List<Account_Team_Member_Info__c> accTeamInfoUpdateList = new List<Account_Team_Member_Info__c>();

    newAccountTeamList = [
      SELECT
        Id,
        AccountId,
        Account.ParentId,
        Account.CVIF__c,
        TeamMemberRole,
        UserId
      FROM AccountTeamMember
      WHERE Id IN :newAccountTeamList
    ];

    Set<Id> childAccIdSet = new Set<Id>();
    List<Account> childAccList = new List<Account>();
    Map<Id, List<Account>> parentTochildMap = new Map<Id, List<Account>>();

    for (AccountTeamMember accMem : newAccountTeamList) {
      childAccIdSet.add(accMem.AccountId);
    }
    System.debug('Child Id Set ' + childAccIdSet);

    if (childAccIdSet != null && !childAccIdSet.isEmpty())
      childAccList = [
        SELECT id, ParentId, CVIF__c
        FROM Account
        WHERE ParentId IN :childAccIdSet
      ];

    System.debug('Child Acc list ' + childAccList);
    if (childAccList != null && !childAccList.isEmpty()) {
      for (Account acc : childAccList) {
        if (!parentTochildMap.containsKey(acc.ParentId)) {
          parentTochildMap.put(acc.ParentId, new List<Account>());
        }
        parentTochildMap.get(acc.ParentId).add(acc);
      }
    }
    System.debug('Parent to child update map: ' + parentTochildMap);
    for (AccountTeamMember accMem : newAccountTeamList) {
      if (accMem.Account.ParentId == null) {
        Account_Team_Member_Info__c obj = new Account_Team_Member_Info__c();
        obj.User__c = accMem.UserId;
        obj.Account__c = accMem.AccountId;
        obj.Team_Role__c = accMem.TeamMemberRole;
        obj.Status__c = 'Updated';
        obj.CVIF_Id__c = accMem.Account.CVIF__c;
        obj.Parent_Account__c = accMem.Account.ParentId;
        obj.Unique__c =
          accMem.UserId +
          ' ' +
          accMem.AccountId +
          ' ' +
          DateTime.Now().day() +
          DateTime.Now().month();
        accTeamInfoUpdateList.add(obj);

        System.debug(
          'Check before enter ' + parentTochildMap.get(accMem.AccountId)
        );
        if (
          parentTochildMap.containsKey(accMem.AccountId) &&
          !parentTochildMap.get(accMem.AccountId).isEmpty()
        ) {
          System.debug('Entry in child update');
          for (Account childAcc : parentTochildMap.get(accMem.AccountId)) {
            Account_Team_Member_Info__c obj2 = new Account_Team_Member_Info__c();
            obj2.User__c = accMem.UserId;
            obj2.Account__c = childAcc.Id;
            obj2.Team_Role__c = accMem.TeamMemberRole;
            obj2.Status__c = 'Updated';
            obj2.CVIF_Id__c = childAcc.CVIF__c;
            obj2.Parent_Account__c = childAcc.ParentId;
            obj2.Unique__c =
              accMem.UserId +
              ' ' +
              childAcc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoUpdateList.add(obj2);
          }
        }
      }
    }
    if (accTeamInfoUpdateList != null && !accTeamInfoUpdateList.isEmpty()) {
      //NULL CHECK

      Schema.SObjectField ftoken = Account_Team_Member_Info__c.Unique__c;
      Database.UpsertResult[] srList = Database.upsert(
        accTeamInfoUpdateList,
        ftoken,
        false
      );
    }
  }
  /*
   * Method Name: updateContractsRepFieldOnAccount.
   * Input Parameters: List of new opportunity team members.
   * Return value: None.
   * Purpose: Update Contracts Rep Team Member field on Account.
   */
  /*    
    private void updateContractsRepFieldOnAccount(List<AccountTeamMember> newAccountTeamMemberList){
        list<AccountTeamMember> atmWithAccList = new list<AccountTeamMember>();
        list<Account> accountsToUpdate = new list<Account>();
        atmWithAccList = [Select Id, AccountId, User.Name, UserId, TeamMemberRole from AccountTeamMember Where TeamMemberRole = 'Contracts Rep' AND Id IN :newAccountTeamMemberList];
        map<Id,String> mAccountUserName = new map<Id,String>();
        for(AccountTeamMember atm : atmWithAccList) {
            mAccountUserName.put(atm.AccountId,atm.User.Name);
        }
        
        for(Id a : mAccountUserName.keyset()) {
            if(mAccountUserName.containsKey(a)) {
                Account acc = new Account();
                acc.Id = a;
                acc.Contracts_Rep_Team_Member__c = mAccountUserName.get(a);
                accountsToUpdate.add(acc);
            }
        }
        if(accountsToUpdate.size()>0) {
            TriggerHandler.bypass('AccountTriggerHandler');
            update accountsToUpdate;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    */
  private void captureDeletedRecord(
    List<AccountTeamMember> oldAccountTeamList
  ) {
    List<Account_Team_Member_Info__c> accTeamInfoDeleteList = new List<Account_Team_Member_Info__c>();

    oldAccountTeamList = [
      SELECT
        Id,
        AccountId,
        Account.ParentId,
        Account.CVIF__c,
        TeamMemberRole,
        UserId
      FROM AccountTeamMember
      WHERE Id IN :oldAccountTeamList
    ];

    Set<Id> childAccIdSet = new Set<Id>();
    List<Account> childAccList = new List<Account>();
    Map<Id, List<Account>> parentTochildMap = new Map<Id, List<Account>>();

    for (AccountTeamMember accMem : oldAccountTeamList) {
      childAccIdSet.add(accMem.AccountId);
    }
    if (childAccIdSet != null && !childAccIdSet.isEmpty())
      childAccList = [
        SELECT id, ParentId, CVIF__c
        FROM Account
        WHERE ParentId IN :childAccIdSet
      ];

    if (childAccList != null && !childAccList.isEmpty()) {
      for (Account acc : childAccList) {
        if (!parentTochildMap.containsKey(acc.ParentId)) {
          parentTochildMap.put(acc.ParentId, new List<Account>());
        }
        parentTochildMap.get(acc.ParentId).add(acc);
      }
    }
    System.debug('Parent to child delete map: ' + parentTochildMap);
    System.debug('oldAccountTeamList deletion: ' + oldAccountTeamList);

    for (AccountTeamMember accMem : oldAccountTeamList) {
      if (accMem.Account.ParentId == null) {
        Account_Team_Member_Info__c obj = new Account_Team_Member_Info__c();
        obj.User__c = accMem.UserId;
        obj.Account__c = accMem.AccountId;
        obj.Team_Role__c = accMem.TeamMemberRole;
        obj.Status__c = 'Deleted';
        obj.CVIF_Id__c = accMem.Account.CVIF__c;
        obj.Parent_Account__c = accMem.Account.ParentId;
        obj.Unique__c =
          accMem.UserId +
          ' ' +
          accMem.AccountId +
          ' ' +
          DateTime.Now().day() +
          DateTime.Now().month();
        accTeamInfoDeleteList.add(obj);

        if (
          parentTochildMap.containsKey(accMem.AccountId) &&
          !parentTochildMap.get(accMem.AccountId).isEmpty()
        ) {
          System.debug('Entry in child delete');
          for (Account childAcc : parentTochildMap.get(accMem.AccountId)) {
            Account_Team_Member_Info__c obj2 = new Account_Team_Member_Info__c();
            obj2.User__c = accMem.UserId;
            obj2.Account__c = childAcc.Id;
            obj2.Team_Role__c = accMem.TeamMemberRole;
            obj2.Status__c = 'Deleted';
            obj2.CVIF_Id__c = childAcc.CVIF__c;
            obj2.Parent_Account__c = childAcc.ParentId;
            obj2.Unique__c =
              accMem.UserId +
              ' ' +
              childAcc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoDeleteList.add(obj2);
          }
        }
      }
    }
    if (accTeamInfoDeleteList != null && !accTeamInfoDeleteList.isEmpty()) {
      //null check

      System.debug('accTeamInfoDeleteList deletion: ' + accTeamInfoDeleteList);
      Schema.SObjectField ftoken = Account_Team_Member_Info__c.Unique__c;
      Database.UpsertResult[] srList = Database.upsert(
        accTeamInfoDeleteList,
        ftoken,
        false
      );
      System.debug('srList deletion: ' + srList);
    }
  }

  /************************************************************/

  private void sendEmailToAccountTeamMembers(
    List<AccountTeamMember> newAccountTeamList,
    List<AccountTeamMember> oldAccountTeamList,
    Map<Id, AccountTeamMember> oldAccountTeamMap
  ) {
    List<Id> userIdList = new List<Id>();
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accList = new List<Account>();
    List<User> memberUserList = new List<User>();
    Map<Id, String> userToEmailMap = new Map<Id, String>();
    List<String> sendToAddress = new List<String>();
    List<AccountTeamMember> accMemList = new List<AccountTeamMember>();
    List<Task> taskToAdd = new List<Task>();
    EmailTemplate emailTemplate;
    EmailTemplate emailTemplateIns;
    EmailTemplate eamilTemplateUpd;
    List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();
    Id userId = UserInfo.getUserId();

    if (Trigger.isInsert || Trigger.isUpdate) {
      accountTeamList.addAll(newAccountTeamList);
    }
    if (Trigger.isDelete) {
      accountTeamList.addAll(oldAccountTeamList);
    }

    for (AccountTeamMember accMem : accountTeamList) {
      userIdList.add(accMem.UserId);
    }

    System.debug('&&&*** userList' + userIdList);
    if (!userIdList.isEmpty()) {
      memberUserList = [SELECT Id, Email FROM User WHERE Id IN :userIdList];
    }
    System.debug('&&&*** userDetailList' + memberUserList);
    if (!memberUserList.isEmpty()) {
      for (User u : memberUserList) {
        if (!userToEmailMap.containsKey(u.Id))
          userToEmailMap.put(u.Id, u.Email);
      }
    }
    System.debug('&&&*** userToEmail ' + userToEmailMap);
    List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
    Set<Messaging.SingleEmailMessage> set_singleEmails = new Set<Messaging.SingleEmailMessage>();
    String emailTemplateName;
    if (Trigger.isInsert)
      emailTemplateName = 'Account Team Addition';

    if (Trigger.isUpdate)
      emailTemplateName = 'Account Team Update';

    if (Trigger.isDelete)
      emailTemplateName = 'Account Team Member Deletion';

    emailTemplate = [
      SELECT id, Name
      FROM EmailTemplate
      WHERE Name = :emailTemplateName
      LIMIT 1
    ];
    List<Contact> contactList = new List<Contact>();
    contactList = [SELECT id, Email FROM Contact WHERE email != NULL LIMIT 1];

    accMemList = [
      SELECT
        Id,
        UserId,
        AccountId,
        Account.ParentId,
        User.Name,
        Account.Name,
        TeamMemberRole,
        AccountAccessLevel,
        OpportunityAccessLevel
      FROM AccountTeamMember
      WHERE Id IN :accountTeamList
    ];
    System.debug('&&&&**** ' + emailTemplate);
    System.debug('&&&&**** ' + accMemList);
    for (AccountTeamMember accMem : accMemList) {
      System.debug('&&&**** ' + accMem.UserId);
      sendToAddress.clear();
      if (userToEmailMap.containsKey(accMem.UserId) && userId != accMem.UserId)
        sendToAddress.add(userToEmailMap.get(accMem.UserId));

      if (
        sendToAddress != null &&
        !sendToAddress.isEmpty() &&
        accMem.Account.ParentId == null
      ) {
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setWhatId(accMem.Id);
        singleEmail.setTemplateID(emailTemplate.Id);
        singleEmail.setToAddresses(sendToAddress);
        singleEmail.setTargetObjectId(contactList[0].Id);
        singleEmail.saveAsActivity = false;
        singleEmail.setTreatTargetObjectAsRecipient(false);
        set_singleEmails.add(singleEmail);
      }
    }
    list_singleEmails.addAll(set_singleEmails);

    if (!list_singleEmails.isEmpty()) {
      Messaging.sendEmail(list_singleEmails);
    }
  }

  private void roleAssignmentAndUserValidation(
    List<AccountTeamMember> newAccountTeamList,
    List<AccountTeamMember> oldAccountTeamList,
    Map<Id, AccountTeamMember> oldAccountTeamMap
  ) {
    Id profileId = UserInfo.getProfileId();
    Id userId = UserInfo.getUserId();
    Map<String, User_Region_to_Opp_Role__c> regionToRoleMap = new Map<String, User_Region_to_Opp_Role__c>();
    Map<Id, String> userToRegionMap = new Map<Id, String>();
    Map<Id, String> userToProfileMap = new Map<Id, String>();
    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> userIdSet = new Set<Id>();
    List<User> relatedUserList = new List<User>();
    List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();
    List<Account> relatedAccountList = new List<Account>();
    Map<Id, Id> accountToOwnerIdMap = new Map<Id, Id>();
    Map<Id, Id> accountToManagerIdMap = new Map<Id, Id>();
    Set<String> saleProfiles = new Set<String>();
    Set<String> saleRoles = new Set<String>();
    Set<String> adminProfiles = new Set<String>();

    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;

    saleProfiles.addAll(Label.Sales_Profiles.split(','));
    saleRoles.addAll(Label.Sales_Roles.split(','));
    adminProfiles.addAll(
      Label.Profiles_with_Account_Team_Permission.split(',')
    );
    regionToRoleMap = User_Region_to_Opp_Role__c.getAll();

    if (Trigger.isInsert || Trigger.isUpdate) {
      accountTeamList.addAll(newAccountTeamList);
    }
    if (Trigger.isDelete) {
      accountTeamList.addAll(oldAccountTeamList);
    }

    for (AccountTeamMember accMem : accountTeamList) {
      userIdSet.add(accMem.UserId);
      accountIdSet.add(accMem.AccountId);
    }

    relatedUserList = [
      SELECT Id, Region__c, Profile.Name
      FROM User
      WHERE Id IN :userIdSet
    ];
    relatedAccountList = [
      SELECT Id, OwnerId, Owner.Name, Owner.ManagerId
      FROM Account
      WHERE Id IN :accountIdSet
    ];

    for (Account acc : relatedAccountList) {
      accountToOwnerIdMap.put(acc.Id, acc.OwnerId);
      accountToManagerIdMap.put(acc.Id, acc.Owner.ManagerId);
    }
    for (User use : relatedUserList) {
      userToRegionMap.put(use.Id, use.Region__c);
      userToProfileMap.put(use.Id, use.Profile.Name);
    }
    Map<String, String> roleToProfileMap = new Map<String, String>();
    for (
      Account_team_Roles_Profiles__c rolesWithProfile : Account_team_Roles_Profiles__c.getAll()
        .values()
    ) {
      roleToProfileMap.put(
        rolesWithProfile.name,
        rolesWithProfile.Team_Member_Role_Name__c
      );
    }

    System.debug('user to region &&& ' + userToRegionMap);
    for (AccountTeamMember accMem : accountTeamList) {
      if (
        Trigger.isInsert ||
        (oldAccountTeamMap != null &&
        oldAccountTeamMap.containsKey(accMem.Id) &&
        oldAccountTeamMap.get(accMem.Id).TeamMemberRole !=
        accMem.TeamMemberRole)
      ) {
        System.debug('profiles' + saleProfiles);
        System.debug('roles' + saleRoles);
        System.debug('userToProfileMap:' + userToProfileMap);
        System.debug('accMem.UserId:' + accMem.UserId);
        if (saleProfiles.contains(userToProfileMap.get(accMem.UserId))) {
          if (
            userToRegionMap.get(accMem.UserId) != null &&
            accMem.TeamMemberRole !=
            regionToRoleMap.get(userToRegionMap.get(accMem.UserId))
              .Opp_Role__c &&
            !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
          ) {
            accMem.addError(
              'The role of a member with sales profile should be aligned with his/her sales region '
            );
          } else if (
            userToRegionMap.get(accMem.UserId) == null &&
            accMem.TeamMemberRole != ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN &&
            !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
          ) {
            accMem.addError(
              'The users with sales profile that are not assigned any region cannot be a part of any account team. Please contact your system admin to assign a region to the user Or please save this user with Admin role.'
            );
          }
        } else {
          if (
            saleRoles.contains(accMem.TeamMemberRole) &&
            !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
          ) {
            accMem.addError(
              'Users having non-sales profile can only be assigned to the roles of ' +
              ConstantClass.NON_SALES_ROLE
            );
          } else if (
            roleToProfileMap.containsKey(userToProfileMap.get(accMem.UserId)) &&
            accMem.TeamMemberRole !=
            roleToProfileMap.get(userToProfileMap.get(accMem.UserId)) &&
            roleToProfileMap.get(userToProfileMap.get(accMem.UserId)) != null &&
            !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
          ) {
            accMem.addError(
              'Users not having ' +
              userToProfileMap.get(accMem.UserId) +
              ' profile cannot be assigned to ' +
              roleToProfileMap.get(userToProfileMap.get(accMem.UserId)) +
              ' role'
            );
          }
        }
        if (
          !adminProfiles.contains(profileName) &&
          userId != accMem.UserId &&
          userId != accountToOwnerIdMap.get(accMem.AccountId) &&
          userId != accountToManagerIdMap.get(accMem.AccountId) &&
          !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
        ) {
          accMem.addError(
            'Users can only add/modify themselves on the account team.  Please contact the account owner for other changes.'
          );
        }
        if (
          (roleToProfileMap.containsKey(userToProfileMap.get(accMem.UserId)) &&
          accMem.TeamMemberRole !=
          roleToProfileMap.get(userToProfileMap.get(accMem.UserId)) &&
          roleToProfileMap.get(userToProfileMap.get(accMem.UserId)) != null &&
          !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId))
        ) {
          accMem.addError(
            'Users with ' +
            userToProfileMap.get(accMem.UserId) +
            ' profile can only be assigned to ' +
            roleToProfileMap.get(userToProfileMap.get(accMem.UserId)) +
            ' role'
          );
        }
      }
      if (Trigger.isDelete) {
        if (
          !adminProfiles.contains(profileName) &&
          userId != accMem.UserId &&
          userId != accountToOwnerIdMap.get(accMem.AccountId) &&
          userId != accountToManagerIdMap.get(accMem.AccountId) &&
          !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
        ) {
          accMem.addError(
            'Users can only add/modify themselves on the account team.  Please contact the account owner for other changes.'
          );
        }
      }
    }
  }

  private void preventChildAccountTeamDeletion(
    List<AccountTeamMember> accountTeamList
  ) {
    Account_Team_Sync_Constant__mdt objAccountTeamSyncConstantMeta = [
      SELECT Validation_on_child__c
      FROM Account_Team_Sync_Constant__mdt
      WHERE DeveloperName = 'Account_Team_Sync_Constant'
    ];
    if (objAccountTeamSyncConstantMeta.Validation_on_child__c == false) {
      return;
    }

    if (accountTeamList != null && !accountTeamList.isEmpty()) {
      accountTeamList = [
        SELECT Id, AccountId, UserId, Account.ParentId
        FROM AccountTeamMember
        WHERE Id IN :accountTeamList
      ];

      for (AccountTeamMember accMem : accountTeamList) {
        System.debug('AccountId ' + accMem.AccountId);
        System.debug('ParentId ' + accMem.Account.ParentId);
        if (accMem.Account.ParentId != null) {
          accountErrorIds.add(accMem.UserId + ' ' + accMem.AccountId);
          oldATMMap.get(accMem.Id)
            .addError(
              'Account Team member can not be deleted at child account level. Please go to the corresponding parent account and delete the account team member from there.'
            );
          //accMem.addError('Account Team member can not be deleted at child account level. Please go to the corresponding parent account and delete the account team member from there.');
        }
      }
    }
  }

  private void preventChildAccountTeamInsertAndUpdate(
    List<AccountTeamMember> lstAccountTeamMemberInScope
  ) {
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accList = new List<Account>();
    Map<Id, Id> accIdToParentIdMap = new Map<Id, Id>();

    // if(lstAccountTeamMemberInScope != Null && !lstAccountTeamMemberInScope.isEmpty()){

    //lstAccountTeamMemberInScope = [SELECT Id, AccountId, Account.ParentId from AccountTeamMember Where Id In: lstAccountTeamMemberInScope];

    Account_Team_Sync_Constant__mdt objAccountTeamSyncConstantMeta = [
      SELECT Validation_on_child__c
      FROM Account_Team_Sync_Constant__mdt
      WHERE DeveloperName = 'Account_Team_Sync_Constant'
    ];
    if (objAccountTeamSyncConstantMeta.Validation_on_child__c == false) {
      return;
    }
    for (AccountTeamMember accMem : lstAccountTeamMemberInScope) {
      accIdSet.add(accMem.AccountId);

      //if(accMem.Account.ParentId != Null )
      //  newATMMap.get(accMem.Id).addError('Account team member modification not allowed at child account level. Please go to the corresponding parent account and add/update a team member from there.');
    }
    //   }
    accList = [SELECT Id, ParentId FROM Account WHERE Id IN :accIdSet];

    for (Account acc : accList) {
      accIdToParentIdMap.put(acc.Id, acc.ParentId);
    }

    for (AccountTeamMember accMemL : lstAccountTeamMemberInScope) {
      if (accIdToParentIdMap.get(accMemL.AccountId) != null) {
        accountErrorIds.add(accMemL.UserId + ' ' + accMemL.AccountId);

        accMemL.addError(
          'Account team member modification not allowed at child account level. Please go to the corresponding parent account and add/update a team member from there.'
        );
      }
    }
  }

  private void preventInsertionAndUpdationOfSameRole(
    List<AccountTeamMember> newAccountTeamList,
    Map<Id, AccountTeamMember> oldAccountTeamMemberMap
  ) {
    Map<Id, Set<String>> accIdToRoleMap = new Map<Id, Set<String>>();
    List<AccountTeamMember> accMemList = new List<AccountTeamMember>();
    Map<Id, List<String>> accIdtoRoleTempMap = new Map<Id, List<String>>();
    Map<Id, Set<String>> accIdToRole = new Map<Id, Set<String>>();
    Set<Id> accId = new Set<Id>();
    Set<String> saleProfiles = new Set<String>();
    Set<Id> userId = new Set<Id>();
    List<User> userList = new List<User>();
    Map<Id, String> userIdToProfileMap = new Map<Id, String>();

    saleProfiles.addAll(Label.Sales_Profiles.split(','));

    for (AccountTeamMember accMemU : newAccountTeamList) {
      userId.add(accMemU.UserId);
    }
    userList = [SELECT Id, Profile.Name FROM User WHERE Id IN :userId];

    for (User use : userList) {
      userIdToProfileMap.put(use.Id, use.Profile.Name);
    }

    for (AccountTeamMember accMem : newAccountTeamList) {
      System.debug('accMem------------' + accMem);
      System.debug('Bool Insert ' + boolInsertTrigger);

      if (
        saleProfiles.contains(userIdToProfileMap.get(accMem.UserId)) &&
        !accountErrorIds.contains(accMem.UserId + ' ' + accMem.AccountId)
      ) {
        if (
          boolInsertTrigger ||
          (oldAccountTeamMemberMap != null &&
          oldAccountTeamMemberMap.containsKey(accMem.Id) &&
          oldAccountTeamMemberMap.get(accMem.Id).TeamMemberRole !=
          accMem.TeamMemberRole)
        ) {
          accId.add(accMem.AccountId);

          System.debug(
            'accIdtoRoleTempMap-----------------' + accIdtoRoleTempMap
          );
          if (!accIdtoRoleTempMap.containskey(accMem.AccountId)) {
            accIdtoRoleTempMap.put(accMem.AccountId, new List<String>());
          }
          if (
            accIdtoRoleTempMap.get(accMem.AccountId).size() == 0 ||
            (accIdtoRoleTempMap.get(accMem.AccountId).size() > 0 &&
            !accIdtoRoleTempMap.get(accMem.AccountId)
              .contains(accMem.TeamMemberRole))
          ) {
            accIdtoRoleTempMap.get(accMem.AccountId).add(accMem.TeamMemberRole);
          } else {
            System.debug('Enter ELSE +++');
            accMem.addError(
              'Two people cannot have the same role in an account team. Please select a different role for every new member.'
            );
          }
          //System.debug('Role '+roles);
        }
      }
    }

    System.debug('accId ' + accId);
    accMemList = [
      SELECT Id, TeamMemberRole, AccountId
      FROM AccountTeamMember
      WHERE AccountId IN :accId
    ];

    System.debug('Account Mem List ' + accMemList);
    if (accMemList != null) {
      for (AccountTeamMember accMemR : accMemList) {
        if (!accIdToRole.containsKey(accMemR.AccountId)) {
          accIdToRole.put(accMemR.AccountId, new Set<String>());
        }

        accIdToRole.get(accMemR.AccountId).add(accMemR.TeamMemberRole);
      }

      for (AccountTeamMember accMemT : newAccountTeamList) {
        if (
          saleProfiles.contains(userIdToProfileMap.get(accMemT.UserId)) &&
          !accountErrorIds.contains(accMemT.UserId + ' ' + accMemT.AccountId)
        ) {
          if (accIdToRole.containsKey(accMemT.AccountId)) {
            if (
              accIdToRole.get(accMemT.AccountId)
                .contains(accMemT.TeamMemberRole)
            ) {
              //  for(String role: accIdToRole.get(accMemT.AccountId)){

              //      if(accMemT.TeamMemberRole == role){

              System.debug('Entry @@@@---> ');
              accMemT.addError(
                'This role is already assigned to an existing team member. Adding two users with the same role is not allowed.'
              );
            }
          }
        }
      }
    }
  }

  /*
   * Method Name: preventRoleMismatchForSalesAgent.
   * Input Parameters: List of new opportunity team members.
   * Return value: None.
   * Purpose: Prevent role mismatch for Sales agent addition on opportunity team.
   * Comment: preventRoleMismatchForSalesAgent method should be called before
   * preventAdditionMoreThanOneSalesAgent in beforeInsert and beforeUpdate trigger.
   */
  private void preventRoleMismatchForSalesAgent(
    List<AccountTeamMember> newAccountTeamMemberList
  ) {
    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> accountTeamUserIdSet = new Set<Id>();
    Map<Id, String> userIdToProfileNameMap = new Map<Id, String>();
    Map<Id, Profile> profileIdToNameMap = new Map<Id, Profile>(
      [SELECT Id, Name FROM Profile]
    );
    for (AccountTeamMember accTeamMem : newAccountTeamMemberList) {
      accountIdSet.add(accTeamMem.AccountId);
      accountTeamUserIdSet.add(accTeamMem.UserId);
    }

    List<User> accTeamUserList = [
      SELECT Id, Profile.Id
      FROM User
      WHERE Id = :accountTeamUserIdSet
    ];

    if (accTeamUserList.size() > 0) {
      for (User accTeamUser : accTeamUserList) {
        userIdToProfileNameMap.put(
          accTeamUser.Id,
          profileIdToNameMap.get(accTeamUser.ProfileId).Name
        );
      }
    }
    for (AccountTeamMember accTeamMem : newAccountTeamMemberList) {
      if (
        accTeamMem.TeamMemberRole !=
        ConstantClass.TEAM_MEMBER_ROLE_AS_SALES_AGENT &&
        userIdToProfileNameMap.get(accTeamMem.UserId) ==
        ConstantClass.SALES_AGENT_PROFILE
      ) {
        accTeamMem.addError(
          System.label.Error_Opportunity_Team_Member_Sales_Agent_Role
        );
      }
    }
  }

  /*
   * Method Name: preventSelfDelete.
   * Input Parameters: List of new account team members.
   * Return value: None.
   * Purpose: Prevent self delete from team.
   * Comment: None
   *
   */
  private void preventSelfDelete(List<AccountTeamMember> lstOldATM) {
    Id profileId = UserInfo.getProfileId();
    Map<String, String> roleToProfileMap = new Map<String, String>();
    for (
      Account_team_Roles_Profiles__c rolesWithProfile : Account_team_Roles_Profiles__c.getAll()
        .values()
    ) {
      roleToProfileMap.put(
        rolesWithProfile.name,
        rolesWithProfile.Team_Member_Role_Name__c
      );
    }
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;
    Account_Team_Self_Delete__mdt objAccTeamSelfDel = [
      SELECT Run_Self_Delete_Validation__c
      FROM Account_Team_Self_Delete__mdt
      WHERE DeveloperName = 'Account_Team_Self_Delete'
    ];
    if (objAccTeamSelfDel.Run_Self_Delete_Validation__c) {
      Map<Id, AccountTeamMember> mapOldAccTeam = new Map<Id, AccountTeamMember>(
        [
          SELECT Id, AccountId, Account.Primary_Account__c
          FROM AccountTeamMember
          WHERE Id IN :lstOldATM
        ]
      );
      for (AccountTeamMember objMember : lstOldATM) {
        //Check if primary account team is deleted by the member and delete is not happening after account trigger
        if (
          !roleToProfileMap.containsKey(profileName) &&
          UserInfo.getUserId() == objMember.UserId &&
          mapOldAccTeam != null &&
          mapOldAccTeam.containsKey(objMember.Id) &&
          mapOldAccTeam.get(objMember.Id).Account.Primary_Account__c == true &&
          AccountTeamDeleteStatic.setAccountNotConsideredForThisValidation.contains(
            objMember.AccountId
          ) == false
        ) {
          objMember.addError('You can not delete yourself from the team');
        }
      }
    }
  }
}
