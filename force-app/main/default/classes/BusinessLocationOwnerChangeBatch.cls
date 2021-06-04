public class BusinessLocationOwnerChangeBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  Map<Id, Id> mapContactToAccountId = new Map<Id, Id>();
  Map<Id, Id> mapOpportunitiesToAccountId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public BusinessLocationOwnerChangeBatch(
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
        SELECT Id, OwnerId, Account__r.OwnerId, Account__c
        FROM Address__c
        WHERE Account__c IN :mapAllAccountIdOldOwnerId.keySet()
      ]
    );
  }

  public void execute(
    Database.BatchableContext objContext,
    List<Address__c> lstScope
  ) {
    List<Address__c> lstAddressToUpdate = new List<Address__c>();
    List<Database.SaveResult> lstOwnerUpdateResult = new List<Database.SaveResult>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
    Map<Id, Address__c> mapAddressIdToAddress = new Map<Id, Address__c>();

    for (Address__c objAddress : lstScope) {
      if (objAddress.Account__r.OwnerId != null) {
        //Check if accouts old owner is same as address current owner then update address owner with new owner.
        if (
          mapAllAccountIdOldOwnerId.containsKey(objAddress.Account__c) &&
          mapAllAccountIdOldOwnerId.get(objAddress.Account__c) ==
          objAddress.OwnerId
        ) {
          lstAddressToUpdate.add(
            new Address__c(
              Id = objAddress.Id,
              OwnerId = objAddress.Account__r.OwnerId
            )
          );
          mapAddressIdToAddress.put(objAddress.Id, objAddress);
        }
      }
    }

    if (lstAddressToUpdate.size() > 0) {
      lstOwnerUpdateResult = Database.update(lstAddressToUpdate, false);
    }

    // Iterate through each returned result
    if (lstOwnerUpdateResult != null && lstOwnerUpdateResult.size() > 0) {
      Integer intIndex = 0;
      for (Database.SaveResult objSaveResult : lstOwnerUpdateResult) {
        if (objSaveResult.isSuccess()) {
          // Operation was successful, so log it
          lstOwnerChangeLogger.add(
            OwnerChangeLoggerUtility.createLogger(
              objActionStartTime,
              objSaveResult.getId(),
              UserInfo.getUserId(),
              'Success',
              null,
              objSaveResult.getId(),
              null,
              null,
              mapAllAccountIdOldOwnerId.get(
                mapAddressIdToAddress.get(objSaveResult.getId()).Account__c
              ),
              mapAddressIdToAddress.get(objSaveResult.getId())
                .Account__r.OwnerId,
              'Business Location',
              null
            )
          );
          System.debug(
            'Successfully updated record. Record Id: ' + objSaveResult.getId()
          );
        } else {
          Id objRecId = null;
          if (intIndex < lstAddressToUpdate.size()) {
            objRecId = lstAddressToUpdate[intIndex].Id;
          }
          for (Database.Error objErr : objSaveResult.getErrors()) {
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                objRecId,
                UserInfo.getUserId(),
                'Failed',
                null,
                objRecId,
                null,
                null,
                null,
                null,
                'Business Location',
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
      WHERE DeveloperName = 'TaskOwnerChangeBatch'
    ];
    Database.executeBatch(
      new TaskOwnerChangeBatch(
        mapAllAccountIdOldOwnerId,
        mapContactToAccountId,
        mapOpportunitiesToAccountId,
        this.objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
  }
}
