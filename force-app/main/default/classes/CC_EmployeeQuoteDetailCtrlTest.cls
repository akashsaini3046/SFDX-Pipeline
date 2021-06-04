@isTest
private class CC_EmployeeQuoteDetailCtrlTest {
  @TestSetup
  static void setup() {
    List<Quote__c> q = TestDataUtility.CreateQuote(1);
    insert q;
  }
  @isTest
  static void testGetQuotationNumber() {
    Id quoteID = [SELECT Id FROM Quote__c][0].Id;
    Test.startTest();
    Quote__c qNO = CC_EmployeeQuoteDetailCtrl.getQuotationNumber(quoteID);
    Test.stopTest();
    System.assertNotEquals(null, qNO.Name, 'Name should not be null');
  }
}
