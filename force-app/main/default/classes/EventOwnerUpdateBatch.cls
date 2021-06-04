/*
 * Name: EventOwnerUpdateBatch
 * Purpose: Batch class for updating event owners after Owner Change on Accounts
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class EventOwnerUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();
  Map<Id, Id> mapOpportunitiesToAccountId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public EventOwnerUpdateBatch(
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
        FROM Event
        WHERE
          (WhatId IN :mapAllAccountIdOldOwnerId.keySet()
          OR WhatId IN :mapOpportunitiesToAccountId.keySet()
          OR WhoId IN :mapContactToAccountId.keySet())
          AND StartDateTime >= :System.now()
      ]
    );
  }

  public void execute(
    Database.BatchableContext objContext,
    List<Event> lstScope
  ) {
    List<Event> lstEventsToUpdate = new List<Event>();
    List<Database.SaveResult> lstUpdateResult = new List<Database.SaveResult>();
    Set<Id> setWhatIds = new Set<Id>();
    Set<Id> setWhoIds = new Set<Id>();
    Map<Id, Opportunity> mapOpporunities = new Map<Id, Opportunity>();
    Map<Id, Contact> mapContacts = new Map<Id, Contact>();
    Map<Id, Account> mapAccounts = new Map<Id, Account>();
    Map<Id, Id> mapEventToNewOwner = new Map<Id, Id>();
    Map<Id, Id> mapEventToOldOwner = new Map<Id, Id>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();

    for (Event objEvent : lstScope) {
      if (objEvent.WhatId != null) {
        setWhatIds.add(objEvent.WhatId);
      } else if (objEvent.WhoId != null) {
        setWhoIds.add(objEvent.WhoId);
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

    for (Event objEvent : lstScope) {
      String relatedId = '';
      if (objEvent.WhatId != null) {
        relatedId = objEvent.WhatId;
        if (relatedId.startsWith('001')) {
          //What id is account
          if (
            mapAllAccountIdOldOwnerId.containsKey(relatedId) &&
            mapAllAccountIdOldOwnerId.get(relatedId) == objEvent.OwnerId
          ) {
            if (mapAccounts.containsKey(relatedId)) {
              mapEventToOldOwner.put(objEvent.Id, objEvent.OwnerId);
              lstEventsToUpdate.add(
                new Event(
                  Id = objEvent.Id,
                  OwnerId = mapAccounts.get(relatedId).OwnerId
                )
              );
              mapEventToNewOwner.put(
                objEvent.Id,
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
              ) == objEvent.OwnerId
            ) {
              mapEventToOldOwner.put(objEvent.Id, objEvent.OwnerId);
              lstEventsToUpdate.add(
                new Event(
                  Id = objEvent.Id,
                  OwnerId = mapOpporunities.get(relatedId).Account.OwnerId
                )
              );
              mapEventToNewOwner.put(
                objEvent.Id,
                mapOpporunities.get(relatedId).Account.OwnerId
              );
            }
          }
        }
      } else if (objEvent.WhoId != null) {
        relatedId = objEvent.WhoId;
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
              ) == objEvent.OwnerId
            ) {
              mapEventToOldOwner.put(objEvent.Id, objEvent.OwnerId);
              lstEventsToUpdate.add(
                new Event(
                  Id = objEvent.Id,
                  OwnerId = mapContacts.get(relatedId).Account.OwnerId
                )
              );
              mapEventToNewOwner.put(
                objEvent.Id,
                mapContacts.get(relatedId).Account.OwnerId
              );
            }
          }
        }
      }
    }

    if (lstEventsToUpdate.size() > 0) {
      lstUpdateResult = Database.update(lstEventsToUpdate, false);
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
              mapEventToOldOwner.get(objSaveResult.getId()),
              mapEventToNewOwner.get(objSaveResult.getId()),
              'Event',
              null
            )
          );
          System.debug(
            'Successfully updated record. Record Id: ' + objSaveResult.getId()
          );
        } else {
          Id objRecId = null;
          if (intIndex < lstEventsToUpdate.size()) {
            objRecId = lstEventsToUpdate[intIndex].Id;
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
                'Event',
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
    String emailId = UserInfo.getUserEmail();
    String notificationMessage = Label.CONFIRMATION_EMAIL_ON_FULL_TRANSFER;
    List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();

    if (!String.isBlank(emailId)) {
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(new List<String>{ emailId });
      mail.setHTMLBody(notificationMessage);
      mail.setSubject('Mass Owner Transfer Process Completed');
      list_singleEmails.add(mail);
    }
    if (!list_singleEmails.isEmpty()) {
      Messaging.sendEmail(list_singleEmails);
    }

    MassOwnerChangeErrorEmail.sendErrorEmai(
      objActionStartTime,
      UserInfo.getUserId()
    );
  }
}
