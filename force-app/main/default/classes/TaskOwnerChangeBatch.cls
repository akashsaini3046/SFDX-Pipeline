/*
 * Name: TaskOwnerChangeBatch
 * Purpose: Batch class for updating task owners after Owner Change on Accounts
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class TaskOwnerChangeBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();
  Map<Id, Id> mapOpportunitiesToAccountId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public TaskOwnerChangeBatch(
    Map<Id, Id> mapAllAccountIdOldOwnerId,
    Map<Id, Id> mapContactToAccountId,
    Map<Id, Id> mapOpportunitiesToAccountId,
    DateTime objActionStartTime
  ) {
    this.mapAllAccountIdOldOwnerId = mapAllAccountIdOldOwnerId;
    this.mapContactToAccountId = mapContactToAccountId;
    this.mapOpportunitiesToAccountId = mapOpportunitiesToAccountId;
    this.objActionStartTime = objActionStartTime;
  }

  public Database.QueryLocator start(Database.BatchableContext objContext) {
    return Database.getQueryLocator(
      [
        SELECT Id, OwnerId, WhoId, WhatId
        FROM Task
        WHERE
          (WhatId IN :mapAllAccountIdOldOwnerId.keySet()
          OR WhatId IN :mapOpportunitiesToAccountId.keySet()
          OR WhoId IN :mapContactToAccountId.keySet())
          AND Status != 'Completed'
      ]
    );
  }

  public void execute(
    Database.BatchableContext objContext,
    List<Task> lstScope
  ) {
    List<Task> lstTasksToUpdate = new List<Task>();
    List<Database.SaveResult> lstUpdateResult = new List<Database.SaveResult>();
    Set<Id> setWhatIds = new Set<Id>();
    Set<Id> setWhoIds = new Set<Id>();
    Map<Id, Opportunity> mapOpporunities = new Map<Id, Opportunity>();
    Map<Id, Contact> mapContacts = new Map<Id, Contact>();
    Map<Id, Account> mapAccounts = new Map<Id, Account>();
    Map<Id, Id> mapTaskToNewOwner = new Map<Id, Id>();
    Map<Id, Id> mapTaskToOldOwner = new Map<Id, Id>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();

    for (Task objTask : lstScope) {
      if (objTask.WhatId != null) {
        setWhatIds.add(objTask.WhatId);
      } else if (objTask.WhoId != null) {
        setWhoIds.add(objTask.WhoId);
      }
    }

    mapOpporunities = new Map<Id, Opportunity>(
      [
        SELECT Id, AccountId, Account.OwnerId
        FROM Opportunity
        WHERE Id IN :setWhatIds
      ]
    );
    mapContacts = new Map<Id, Contact>(
      [
        SELECT Id, AccountId, Account.OwnerId
        FROM Contact
        WHERE Id IN :setWhoIds
      ]
    );
    mapAccounts = new Map<Id, Account>(
      [SELECT Id, OwnerId FROM Account WHERE Id IN :setWhatIds]
    );

    for (Task objTask : lstScope) {
      String relatedId = '';
      if (objTask.WhatId != null) {
        relatedId = objTask.WhatId;
        if (relatedId.startsWith('001')) {
          //What id is account
          if (
            mapAllAccountIdOldOwnerId.containsKey(relatedId) &&
            mapAllAccountIdOldOwnerId.get(relatedId) == objTask.OwnerId
          ) {
            if (mapAccounts.containsKey(relatedId)) {
              mapTaskToOldOwner.put(objTask.Id, objTask.OwnerId);
              lstTasksToUpdate.add(
                new Task(
                  Id = objTask.Id,
                  OwnerId = mapAccounts.get(relatedId).OwnerId
                )
              );
              mapTaskToNewOwner.put(
                objTask.Id,
                mapAccounts.get(relatedId).OwnerId
              );
            }
          }
        } else if (relatedId.startsWith('006')) {
          //What id is opportunity
          if (
            mapOpporunities.containsKey(relatedId) &&
            mapOpporunities.get(relatedId).Account.OwnerId != null
          ) {
            if (
              mapAllAccountIdOldOwnerId.containsKey(
                mapOpporunities.get(relatedId).AccountId
              ) &&
              mapAllAccountIdOldOwnerId.get(
                mapOpporunities.get(relatedId).AccountId
              ) == objTask.OwnerId
            ) {
              mapTaskToOldOwner.put(objTask.Id, objTask.OwnerId);
              lstTasksToUpdate.add(
                new Task(
                  Id = objTask.Id,
                  OwnerId = mapOpporunities.get(relatedId).Account.OwnerId
                )
              );
              mapTaskToNewOwner.put(
                objTask.Id,
                mapOpporunities.get(relatedId).Account.OwnerId
              );
            }
          }
        }
      } else if (objTask.WhoId != null) {
        relatedId = objTask.WhoId;
        if (relatedId.startsWith('003')) {
          //Who id is contact
          if (
            mapContacts.containsKey(relatedId) &&
            mapContacts.get(relatedId).Account.OwnerId != null
          ) {
            if (
              mapAllAccountIdOldOwnerId.containsKey(
                mapContacts.get(relatedId).AccountId
              ) &&
              mapAllAccountIdOldOwnerId.get(
                mapContacts.get(relatedId).AccountId
              ) == objTask.OwnerId
            ) {
              mapTaskToOldOwner.put(objTask.Id, objTask.OwnerId);
              lstTasksToUpdate.add(
                new Task(
                  Id = objTask.Id,
                  OwnerId = mapContacts.get(relatedId).Account.OwnerId
                )
              );
              mapTaskToNewOwner.put(
                objTask.Id,
                mapContacts.get(relatedId).Account.OwnerId
              );
            }
          }
        }
      }
    }

    if (lstTasksToUpdate.size() > 0) {
      lstUpdateResult = Database.update(lstTasksToUpdate, false);
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
              null,
              null,
              mapTaskToOldOwner.get(objSaveResult.getId()),
              mapTaskToNewOwner.get(objSaveResult.getId()),
              'Task',
              null
            )
          );
          System.debug(
            'Successfully updated record. Record Id: ' + objSaveResult.getId()
          );
        } else {
          Id objRecId = null;
          if (intIndex < lstTasksToUpdate.size()) {
            objRecId = lstTasksToUpdate[intIndex].Id;
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
                null,
                null,
                null,
                null,
                'Task',
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
    Mass_Account_Transfer__mdt objMeta = [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
      WHERE DeveloperName = 'EventOwnerUpdateBatch'
    ];
    Database.executeBatch(
      new EventOwnerUpdateBatch(
        mapAllAccountIdOldOwnerId,
        mapContactToAccountId,
        mapOpportunitiesToAccountId,
        objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
  }
}
