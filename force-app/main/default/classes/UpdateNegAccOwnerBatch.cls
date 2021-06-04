/*
 * Name: UpdateNegAccOwnerBatch
 * Purpose: Batch class for updating Neglected Account Data records with parent accounts owner name after owner change on parent accounts
 * Author: Nagarro
 * Created Date: 10/02/2021
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
global class UpdateNegAccOwnerBatch implements Database.Batchable<sObject> {
  public List<Id> accountList = new List<Id>();
  public UpdateNegAccOwnerBatch(List<Id> accList) {
    accountList = accList;
  }
  global Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Account__c, Owner_Name__c
        FROM Neglected_Account_Data__c
        WHERE Account__c IN :accountList
      ]
    );
  }
  global void execute(
    Database.BatchableContext bc,
    List<Neglected_Account_Data__c> objList
  ) {
    List<Account> accsList = [
      SELECT Id, OwnerId, Owner_Name__c
      FROM Account
      WHERE Id IN :accountList
    ];
    List<Neglected_Account_Data__c> negAccsToUpdate = new List<Neglected_Account_Data__c>();
    map<Id, Account> mapAcc = new Map<Id, Account>();
    if (accsList != null && !accsList.isEmpty()) {
      for (Account acc : accsList) {
        mapAcc.put(acc.Id, acc);
      }
    }
    for (Neglected_Account_Data__c childAcc : objList) {
      if (mapAcc.containsKey(childAcc.Account__c)) {
        childAcc.Owner_Name__c = mapAcc.get(childAcc.Account__c).Owner_Name__c;
        negAccsToUpdate.add(childAcc);
      }
    }
    if (negAccsToUpdate != null && !negAccsToUpdate.isEmpty())
      update negAccsToUpdate;
  }
  global void finish(Database.BatchableContext bc) {
  }
}
