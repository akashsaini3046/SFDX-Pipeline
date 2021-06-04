/*
 * Name: ChildAccountsOwnerChangeBatch
 * Purpose: Batch class for updating child account owners after owner change on Parent Accounts
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class ChildAccountsOwnerChangeBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapParentAccountToOldOwnerId = new Map<Id, Id>();
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  public Map<Id, List<AccountTeamMember>> insertedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  public Map<Id, List<AccountTeamMember>> updatedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  public Map<Id, List<AccountTeamMember>> deletedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  DateTime objActionStartTime;

  public ChildAccountsOwnerChangeBatch(
    Map<Id, Id> mapParentAccountToOldOwnerId,
    Map<Id, List<AccountTeamMember>> insertedAccMemberMap,
    Map<Id, List<AccountTeamMember>> updatedAccMemberMap,
    Map<Id, List<AccountTeamMember>> deletedAccMemberMap,
    DateTime objActionStartTime
  ) {
    this.mapParentAccountToOldOwnerId = mapParentAccountToOldOwnerId;
    this.insertedAccMemberMap = insertedAccMemberMap;
    this.updatedAccMemberMap = updatedAccMemberMap;
    this.deletedAccMemberMap = deletedAccMemberMap;
    this.objActionStartTime = objActionStartTime;
  }

  public Database.QueryLocator start(Database.BatchableContext objContext) {
    return Database.getQueryLocator(
      [
        SELECT Id, OwnerId, Parent.OwnerId
        FROM Account
        WHERE ParentId IN :mapParentAccountToOldOwnerId.keySet()
      ]
    );
  }

  public void execute(
    Database.BatchableContext objContext,
    List<Account> lstScope
  ) {
    List<Account> lstAccountToUpdate = new List<Account>();
    List<Database.SaveResult> lstUpdateResult = new List<Database.SaveResult>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
    Map<Id, Id> mapAccountToNewOwner = new Map<Id, Id>();

    for (Account objAccount : lstScope) {
      if (objAccount.Parent.OwnerId != null) {
        mapAllAccountIdOldOwnerId.put(objAccount.Id, objAccount.OwnerId);
        lstAccountToUpdate.add(
          new Account(Id = objAccount.Id, OwnerId = objAccount.Parent.OwnerId)
        );
        mapAccountToNewOwner.put(objAccount.Id, objAccount.Parent.OwnerId);
      }
    }

    if (lstAccountToUpdate.size() > 0) {
      lstUpdateResult = Database.update(lstAccountToUpdate, false);
    }

    // Iterate through each returned result
    if (lstUpdateResult != null && !lstUpdateResult.isEmpty()) {
      Integer intIndex = 0;
      for (Database.SaveResult objSr : lstUpdateResult) {
        if (objSr.isSuccess()) {
          // Operation was successful, so log it
          lstOwnerChangeLogger.add(
            OwnerChangeLoggerUtility.createLogger(
              objActionStartTime,
              objSr.getId(),
              UserInfo.getUserId(),
              'Success',
              objSr.getId(),
              null,
              null,
              null,
              mapAllAccountIdOldOwnerId.get(objSr.getId()),
              mapAccountToNewOwner.get(objSr.getId()),
              'Account',
              null
            )
          );
          System.debug(
            'Successfully updated record. Record Id: ' + objSr.getId()
          );
        } else {
          Id objRecId = null;
          if (intIndex < lstAccountToUpdate.size()) {
            objRecId = lstAccountToUpdate[intIndex].Id;
          }
          // Operation failed, so get all errors
          for (Database.Error objErr : objSr.getErrors()) {
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                objRecId,
                UserInfo.getUserId(),
                'Failed',
                objRecId,
                null,
                null,
                null,
                null,
                null,
                'Account',
                '' +
                objErr.getFields() +
                ': ' +
                objErr.getMessage()
              )
            );
            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
          }
        }
        intIndex++;
      }
    }

    if (lstOwnerChangeLogger.size() > 0) {
      Database.insert(lstOwnerChangeLogger, false);
    }
  }

  public void finish(Database.BatchableContext objContext) {
    mapAllAccountIdOldOwnerId.putAll(mapParentAccountToOldOwnerId);
    Mass_Account_Transfer__mdt objMeta = [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
      WHERE DeveloperName = 'SynChildAccountTeamBatch'
    ];
    Database.executeBatch(
      new SynChildAccountTeamBatch(
        new List<Id>(mapParentAccountToOldOwnerId.keySet()),
        insertedAccMemberMap,
        updatedAccMemberMap,
        deletedAccMemberMap,
        mapAllAccountIdOldOwnerId,
        this.objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
  }
}
