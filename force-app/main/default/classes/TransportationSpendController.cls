public without sharing class TransportationSpendController {
  /*
     @AuraEnabled
    public static List<Transportation_Spend__c> getTransportationSpend(Id accountId){
        System.debug('account Id' + accountId);
        List<Transportation_Spend__c> tspList = new List<Transportation_Spend__c>();
        tspList = [SELECT Id, Account__c, Service__c, Sub_Service__c, Amount__c FROM Transportation_Spend__c WHERE Account__c = :accountId];
        if(tspList.size() == 0){
            for(Transportation_Spend_Service_Sub_Service__c csObj : Transportation_Spend_Service_Sub_Service__c.getall().values()) {            
                Transportation_Spend__c tspRecord = new Transportation_Spend__c();
                tspRecord.Account__c = accountId;
                tspRecord.Service__c = csObj.Service__c;
                if(String.isBlank(csObj.Sub_Service__c)){
                    tspRecord.Sub_Service__c = '--';
                } else {
                    tspRecord.Sub_Service__c = csObj.Sub_Service__c;
                }
                tspRecord.Amount__c = 0;
                tspList.add(tspRecord);
            }
        }
        return tspList;
    }
    */
  @AuraEnabled
  public static List<Transportation_Spend__c> saveSpends(
    List<wrapperClass> spendsWToInsert
  ) {
    List<Transportation_Spend__c> spendsToUpsert = new List<Transportation_Spend__c>();
    for (wrapperClass wcObj : spendsWToInsert) {
      Transportation_Spend__c tspRecord = new Transportation_Spend__c();
      if (wcObj.recordId != null)
        tspRecord.Id = wcObj.recordId;
      tspRecord.Account__c = wcObj.accountId;
      tspRecord.Service__c = wcObj.service;
      tspRecord.Name = wcObj.service;
      tspRecord.Sub_Service__c = wcObj.subService;
      tspRecord.Remarks__c = wcObj.remarks;
      tspRecord.Amount__c = wcObj.amount;
      spendsToUpsert.add(tspRecord);
    }
    Database.UpsertResult[] results = Database.upsert(spendsToUpsert);
    return spendsToUpsert;
  }

  public class wrapperClass {
    @AuraEnabled
    public Id recordId { get; set; }
    @AuraEnabled
    public Integer spendCount { get; set; }
    @AuraEnabled
    public Id accountId { get; set; }
    @AuraEnabled
    public Decimal amount { get; set; }
    @AuraEnabled
    public String service { get; set; }
    @AuraEnabled
    public String subService { get; set; }
    @AuraEnabled
    public String remarks { get; set; }
  }

  @AuraEnabled
  public static List<wrapperClass> getTransportationSpends(Id accountId) {
    List<wrapperClass> returnwrapperClass = new List<wrapperClass>();
    List<Transportation_Spend__c> tspList = new List<Transportation_Spend__c>();
    Integer i = 1;
    System.debug('Account Id' + accountId);
    tspList = [
      SELECT
        Id,
        Account__c,
        Name,
        Service__c,
        Sub_Service__c,
        Amount__c,
        Remarks__c
      FROM Transportation_Spend__c
      WHERE Account__c = :accountId
    ];
    List<Transportation_Spend_Service_Sub_Service__c> csList = [
      SELECT Service__c, Sub_Service__c, Name
      FROM Transportation_Spend_Service_Sub_Service__c
      ORDER BY Name
    ];
    if (tspList.size() == 0) {
      for (Transportation_Spend_Service_Sub_Service__c csObj : csList) {
        wrapperClass wrap = new wrapperClass();
        wrap.accountId = accountId;
        wrap.service = csObj.Service__c;
        if (String.isBlank(csObj.Sub_Service__c)) {
          wrap.subService = '--';
        } else {
          wrap.subService = csObj.Sub_Service__c;
        }
        wrap.amount = 0;
        wrap.spendCount = i;
        i++;
        returnwrapperClass.add(wrap);
      }
    } else {
      for (Transportation_Spend__c tspObj : tspList) {
        wrapperClass wrap = new wrapperClass();
        wrap.recordId = tspObj.Id;
        wrap.accountId = accountId;
        wrap.service = tspObj.Service__c;
        wrap.subService = tspObj.Sub_Service__c;
        wrap.amount = tspObj.Amount__c;
        wrap.remarks = tspObj.Remarks__c;
        wrap.spendCount = i;
        i++;
        returnwrapperClass.add(wrap);
      }
    }
    return returnwrapperClass;
  }
}
