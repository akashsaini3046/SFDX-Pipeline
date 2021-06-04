/*
 * Name: OpportunityOwnerUpdateBatch
 * Purpose: Batch class for updating open opportunity owners after owner change on Accounts
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class OpportunityOwnerUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  Set<Id> childOppIdSet = new Set<Id>();
  Map<Id, Id> mapOpportunitiesToAccountId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public OpportunityOwnerUpdateBatch(
    Map<Id, Id> mapAllAccountIdOldOwnerId,
    DateTime objActionStartTime
  ) {
    this.mapAllAccountIdOldOwnerId = mapAllAccountIdOldOwnerId;
    this.objActionStartTime = objActionStartTime;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, OwnerId, AccountId, Account.OwnerId
        FROM Opportunity
        WHERE
          AccountId IN :mapAllAccountIdOldOwnerId.keySet()
          AND isClosed = FALSE
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    List<Opportunity> oppListToUpdate = new List<Opportunity>();
    List<Database.SaveResult> lstDBSaveResult = new List<Database.SaveResult>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
    Map<Id, Opportunity> mapOpportunityIdToOpportunity = new Map<Id, Opportunity>();

    for (Opportunity opp : scope) {
      oppListToUpdate.add(
        new Opportunity(Id = opp.Id, OwnerId = opp.Account.OwnerId)
      );
      childOppIdSet.add(opp.Id);
      mapOpportunitiesToAccountId.put(opp.Id, opp.AccountId);
      mapOpportunityIdToOpportunity.put(opp.Id, opp);
    }

    if (oppListToUpdate.size() > 0) {
      lstDBSaveResult = Database.update(oppListToUpdate, false);

      if (lstDBSaveResult != null && !lstDBSaveResult.isEmpty()) {
        Integer intIndex = 0;
        for (Database.SaveResult sr : lstDBSaveResult) {
          if (sr.isSuccess()) {
            // Operation was successful, so log it
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                sr.getId(),
                UserInfo.getUserId(),
                'Success',
                null,
                null,
                null,
                sr.getId(),
                mapAllAccountIdOldOwnerId.get(
                  mapOpportunityIdToOpportunity.get(sr.getId()).AccountId
                ),
                mapOpportunityIdToOpportunity.get(sr.getId()).Account.OwnerId,
                'Opportunity',
                null
              )
            );
            System.debug('Updated Record ' + sr.id);
          } else {
            Id objRecId = null;
            if (intIndex < oppListToUpdate.size()) {
              objRecId = oppListToUpdate[intIndex].Id;
            }
            for (Database.Error objErr : sr.getErrors()) {
              lstOwnerChangeLogger.add(
                OwnerChangeLoggerUtility.createLogger(
                  objActionStartTime,
                  objRecId,
                  UserInfo.getUserId(),
                  'Failed',
                  null,
                  null,
                  null,
                  objRecId,
                  null,
                  null,
                  'Opportunity',
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
    }

    if (lstOwnerChangeLogger.size() > 0) {
      Database.insert(lstOwnerChangeLogger, false);
    }
  }

  public void finish(Database.BatchableContext bc) {
    Mass_Account_Transfer__mdt objMeta = [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
      WHERE DeveloperName = 'opportunityTeamUpdateBatch'
    ];
    Database.executeBatch(
      new opportunityTeamUpdateBatch(
        mapAllAccountIdOldOwnerId,
        childOppIdSet,
        mapOpportunitiesToAccountId,
        this.objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
  }
}
