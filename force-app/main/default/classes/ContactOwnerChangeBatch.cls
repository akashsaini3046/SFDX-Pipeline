/*
 * Name: ContactOwnerChangeBatch
 * Purpose: Batch class for updating contact owners after owner Change of Accounts
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class ContactOwnerChangeBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();
  Map<Id, Id> mapOpportunitiesToAccountId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public ContactOwnerChangeBatch(
    Map<Id, Id> mapAllAccountIdOldOwnerId,
    Map<Id, Id> mapOpportunitiesToAccountId,
    DateTime objActionStartTime
  ) {
    this.mapAllAccountIdOldOwnerId = mapAllAccountIdOldOwnerId;
    this.mapOpportunitiesToAccountId = mapOpportunitiesToAccountId;
    this.objActionStartTime = objActionStartTime;
  }

  public Database.QueryLocator start(Database.BatchableContext objContext) {
    return Database.getQueryLocator(
      [
        SELECT Id, OwnerId, AccountId, Account.OwnerId
        FROM Contact
        WHERE AccountId IN :mapAllAccountIdOldOwnerId.keySet()
      ]
    );
  }

  public void execute(
    Database.BatchableContext objContext,
    List<Contact> lstScope
  ) {
    List<Contact> lstContactsToUpdate = new List<Contact>();
    List<Database.SaveResult> lstUpdateResult = new List<Database.SaveResult>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
    Map<Id, Contact> mapContactIdToContact = new Map<Id, Contact>();

    for (Contact objContact : lstScope) {
      mapContactToAccountId.put(objContact.Id, objContact.AccountId);
      if (objContact.Account.OwnerId != null) {
        if (
          mapAllAccountIdOldOwnerId.containsKey(objContact.AccountId) &&
          mapAllAccountIdOldOwnerId.get(objContact.AccountId) ==
          objContact.OwnerId
        ) {
          lstContactsToUpdate.add(
            new Contact(
              Id = objContact.Id,
              OwnerId = objContact.Account.OwnerId
            )
          );
          mapContactIdToContact.put(objContact.Id, objContact);
        }
      }
    }

    if (lstContactsToUpdate.size() > 0) {
      lstUpdateResult = Database.update(lstContactsToUpdate, false);
    }

    // Iterate through each returned result
    if (lstUpdateResult != null && lstUpdateResult.size() > 0) {
      Integer intIndex = 0;
      for (Database.SaveResult objSaveResult : lstUpdateResult) {
        if (objSaveResult.isSuccess()) {
          // Operation was successful, so log it
          lstOwnerChangeLogger.add(
            OwnerChangeLoggerUtility.createLogger(
              objActionStartTime,
              objSaveResult.getId(),
              UserInfo.getUserId(),
              'Success',
              null,
              null,
              objSaveResult.getId(),
              null,
              mapAllAccountIdOldOwnerId.get(
                mapContactIdToContact.get(objSaveResult.getId()).AccountId
              ),
              mapContactIdToContact.get(objSaveResult.getId()).Account.OwnerId,
              'Contact',
              null
            )
          );
          System.debug(
            'Successfully updated record. Record Id: ' + objSaveResult.getId()
          );
        } else {
          Id objRecId = null;
          if (intIndex < lstContactsToUpdate.size()) {
            objRecId = lstContactsToUpdate[intIndex].Id;
          }
          for (Database.Error objErr : objSaveResult.getErrors()) {
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                objRecId,
                UserInfo.getUserId(),
                'Failed',
                null,
                null,
                objRecId,
                null,
                null,
                null,
                'Contact',
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
    Database.executeBatch(
      new BusinessLocationOwnerChangeBatch(
        mapAllAccountIdOldOwnerId,
        mapContactToAccountId,
        mapOpportunitiesToAccountId,
        this.objActionStartTime
      ),
      200
    );
  }
}
