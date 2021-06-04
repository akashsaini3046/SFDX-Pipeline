/*
 * @company     : Nagarro Inc.
 * @date        : 10-11-2020
 * @author      : Nagarro
 * @description : Batch to update Quote Status
 * @history     : Version 1.0
 */
public class CC_AutoExpireQuotes implements Database.Batchable<sObject>, Database.Stateful {
  public Integer recordsProcessed = 0;
  List<Quote__c> scope = new List<Quote__c>();
  public Database.QueryLocator start(Database.BatchableContext bc) {
    String quoteStatus = CC_Constants.QUOTE_STRING;
    return Database.getQueryLocator(
      'SELECT ID,Status__c FROM Quote__c WHERE Valid_To__c < Today and Status__c != : quoteStatus'
    );
  }

  public void execute(Database.BatchableContext bc, List<Quote__c> scope) {
    List<Quote__c> quoteList = new List<Quote__c>();
    String quoteStatus = CC_Constants.QUOTE_STRING;
    try {
      for (Quote__c quote : scope) {
        quote.Status__c = quoteStatus;
        quoteList.add(quote);
        recordsProcessed = recordsProcessed + 1;
      }
      List<SObject> quoteRecordList = (List<SObject>) quoteList;
      Database.SaveResult[] results = DMLUtility.updateRecords(
        quoteRecordList,
        false
      );
    } catch (Exception ex) {
      LogFactory.error(
        'CC_AutoExpireQuotes',
        '',
        '',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
    }
  }

  public void finish(Database.BatchableContext bc) {
    System.debug(recordsProcessed + ' records processed.');
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
      FROM AsyncApexJob
      WHERE Id = :bc.getJobId()
    ];
    System.debug(job);
  }
}
