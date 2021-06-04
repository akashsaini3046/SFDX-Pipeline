/*
 * Name: NeglectedAccountReport
 * Purpose: For deleting account active records.
 * Author: Nagarro
 * Created Date: 30/04/2020
 *
 *  Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
public without sharing class NeglectedAccountReport {
  public static void deleteNeglectedAccountRecord(Set<Id> sObjectIds) {
    try {
      List<Neglected_Account_Data__c> negDatatoDelList = new List<Neglected_Account_Data__c>();
      System.debug('sObjectIds------------------' + sObjectIds);
      if (
        sObjectIds != null && !sObjectIds.IsEmpty() ||
        (sObjectIds.size() == 1 && !sObjectIds.contains(null))
      ) {
        System.debug('sObjectIds------------------' + sObjectIds);
        negDatatoDelList = [
          SELECT Id, AccountId__c
          FROM Neglected_Account_Data__c
          WHERE AccountId__c IN :sObjectIds
          LIMIT 10000
        ];
      }
      if (negDatatoDelList.size() > 0) {
        delete negDatatoDelList;
      }
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage());
      System.debug('Error line number: ' + e.getLineNumber());
    }
  }
}
