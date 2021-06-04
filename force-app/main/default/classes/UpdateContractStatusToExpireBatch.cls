/*
 * Name: UpdateContractStatusToExpireBatch
 * Purpose: Batch Class to update status to Expired
 * Author: Nagarro
 * Created Date: 29-Dec-2020
 * Test Class : ContractTriggerHandler_Test
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
global class UpdateContractStatusToExpireBatch implements Database.Batchable<sObject>, Database.Stateful {
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return database.getQueryLocator(
      [
        SELECT Id, Contract_Expiration_Date__c, Status
        FROM Contract
        WHERE Contract_Expiration_Date__c < TODAY
      ]
    );
  }

  global void execute(
    Database.BatchableContext bc,
    list<Contract> contractsList
  ) {
    for (Contract c : contractsList) {
      c.Status = 'Expired';
    }
    if (contractsList != null) {
      update contractsList;
    }
  }

  global void finish(Database.BatchableContext bc) {
  }
}
