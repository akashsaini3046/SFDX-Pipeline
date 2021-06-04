/*
 * Name: SynChildAccountTeamBatch
 * Purpose: Batch class for syncing child account teams with parent accounts after owner change on parent accounts
 * Test Class: AccountOwnerChange_v2_test
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class SynChildAccountTeamBatch implements Database.Batchable<SObject>, Database.Stateful {
  public List<Id> parentAccountList = new List<Id>();
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  public Map<Id, List<AccountTeamMember>> insertedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  public Map<Id, List<AccountTeamMember>> updatedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  public Map<Id, List<AccountTeamMember>> deletedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  DateTime objActionStartTime;

  public SynChildAccountTeamBatch(
    List<Id> parentIds,
    Map<Id, List<AccountTeamMember>> insAccMemberMap,
    Map<Id, List<AccountTeamMember>> updAccMemberMap,
    Map<Id, List<AccountTeamMember>> delAccMemberMap,
    Map<Id, Id> mapAllAccountIdOldOwnerId,
    DateTime objActionStartTime
  ) {
    parentAccountList = parentIds;
    insertedAccMemberMap = insAccMemberMap;
    updatedAccMemberMap = updAccMemberMap;
    deletedAccMemberMap = delAccMemberMap;
    this.mapAllAccountIdOldOwnerId = mapAllAccountIdOldOwnerId;
    this.objActionStartTime = objActionStartTime;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [SELECT Id, ParentId FROM Account WHERE ParentId IN :parentAccountList]
    );
  }

  public void execute(Database.BatchableContext bc, List<Account> scope) {
    Map<Id, Set<Id>> parentIdToChildMap = new Map<Id, Set<Id>>();
    Set<Id> childIdSet = new Set<Id>();
    Set<Id> parentIdSet = new Set<Id>();
    AccountTeamMember objTmpExtremeAccoutTeamMember;
    AccountTeamMember objNewAccoutTeamMember;
    List<AccountTeamMember> childAccTeamMembers = new List<AccountTeamMember>();
    List<AccountTeamMember> accTeamParentList = new List<AccountTeamMember>();
    List<AccountTeamMember> lstNewAccountTeamMember = new List<AccountTeamMember>();
    Map<String, AccountTeamMember> mapAccountAndUserToATM = new Map<String, AccountTeamMember>();
    Map<Id, Set<String>> mapAccountIdtoATMUserKeys = new Map<Id, Set<String>>();
    Map<String, AccountTeamMember> mapExtremeParentAccountAndUserToATM = new Map<String, AccountTeamMember>();
    Map<Id, Set<String>> mapExtremeAccountIdtoATMUserKeys = new Map<Id, Set<String>>();
    List<Database.SaveResult> lstDBSaveResult = new List<Database.SaveResult>();
    List<Database.SaveResult> lstDBUpdateResult = new List<Database.SaveResult>();
    List<Database.DeleteResult> lstDeleteResult = new List<Database.DeleteResult>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();

    if (scope != null && !scope.isEmpty()) {
      for (Account acc : scope) {
        if (!parentIdToChildMap.containsKey(acc.ParentId)) {
          parentIdToChildMap.put(acc.ParentId, new Set<Id>());
        }
        parentIdToChildMap.get(acc.ParentId).add(acc.Id);

        childIdSet.add(acc.Id);

        parentIdSet.add(acc.ParentId);
      }
      childAccTeamMembers = WithoutSharingUtility.queryAccountTeamMember(
        childIdSet
      );

      if (childAccTeamMembers != null) {
        TriggerHandler.bypass('AccountTeamTriggerHandler');
        AccountTeamTriggerHandler.validationCheck = false;
        WithoutSharingUtility.deleteAccountTeamMembers(childAccTeamMembers);
        TriggerHandler.clearbypass('AccountTeamTriggerHandler');
      }

      accTeamParentList = WithoutSharingUtility.queryAccountTeamMember(
        parentIdSet
      );

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

        for (Id idParentItr : parentIdToChildMap.keySet()) {
          System.debug(
            'idExtremeParentItr ' + parentIdToChildMap.get(idParentItr)
          );
          if (parentIdToChildMap.get(idParentItr) != null) {
            for (Id idChildAccountId : parentIdToChildMap.get(idParentItr)) {
              System.debug(
                'idFamilyAccountId ' +
                mapAccountIdtoATMUserKeys.get(idParentItr)
              );
              if (mapAccountIdtoATMUserKeys.get(idParentItr) != null) {
                for (
                  String strATMUserKey : mapAccountIdtoATMUserKeys.get(
                    idParentItr
                  )
                ) {
                  System.debug(
                    'strATMUserKey ' +
                    mapAccountIdtoATMUserKeys.get(idParentItr)
                  );
                  objTmpExtremeAccoutTeamMember = mapAccountAndUserToATM.get(
                    idParentItr +
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
                    objNewAccoutTeamMember.AccountId = idChildAccountId;
                    lstNewAccountTeamMember.add(objNewAccoutTeamMember);
                  }
                }
              }
            }
          }
        }
      }
    }
    System.debug('Neew Account Team ' + lstNewAccountTeamMember);
    if (lstNewAccountTeamMember.size() > 0) {
      TriggerHandler.bypass('AccountTeamTriggerHandler');
      lstDBSaveResult = Database.insert(lstNewAccountTeamMember, false);
      TriggerHandler.clearbypass('AccountTeamTriggerHandler');
      Integer intIndex = 0;
      for (Database.SaveResult objSvRslt : lstDBSaveResult) {
        if (objSvRslt.isSuccess() == false) {
          Id objRecId = null;
          if (intIndex < lstNewAccountTeamMember.size()) {
            objRecId = lstNewAccountTeamMember[intIndex].Id;
          }
          for (Database.Error objErr : objSvRslt.getErrors()) {
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                objRecId,
                UserInfo.getUserId(),
                'Failed',
                null,
                null,
                null,
                null,
                null,
                null,
                'Account Team',
                '' +
                objErr.getFields() +
                ': ' +
                objErr.getMessage()
              )
            );
            System.debug(
              'Error occured in AccountTeamTriggerHandler->syncAccountTeam ' +
              objErr.getMessage() +
              '  ' +
              objErr.getFields()
            );
          }
        }
        intIndex++;
      }
    }

    if (lstOwnerChangeLogger.size() > 0) {
      Database.insert(lstOwnerChangeLogger, false);
    }
  }

  public void finish(Database.BatchableContext bc) {
    Mass_Account_Transfer__mdt objMeta = [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
      WHERE DeveloperName = 'AccountTeamChangeCaptureBatch'
    ];
    Database.executeBatch(
      new AccountTeamChangeCaptureBatch(
        insertedAccMemberMap,
        updatedAccMemberMap,
        deletedAccMemberMap,
        mapAllAccountIdOldOwnerId,
        this.objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
    Database.executeBatch(new UpdateNegAccOwnerBatch(parentAccountList));
  }
}
