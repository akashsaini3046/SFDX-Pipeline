public class CC_EmployeeQuoteDetailCtrl {
  @AuraEnabled
  public static Quote__c getQuotationNumber(String quoId) {
    Quote__c qNo = [SELECT Name FROM Quote__c WHERE Id = :quoId];
    return qNo;
  }
}
