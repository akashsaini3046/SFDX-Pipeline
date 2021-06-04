@isTest
private class CC_ScheduleAutoExpireQuotesTest {
  @TestSetup
  static void setup() {
    List<Quote__c> qlist = TestDataUtility.CreateQuote(200);
    for (Quote__c quo : qlist) {
      quo.CreatedDate = date.newInstance(2020, 10, 20);
    }
    insert qlist;
  }
  @isTest
  static void testExecute() {
    String CRON_EXP = '0 0 0 * * ? *';
    List<Quote__c> lquote = new List<Quote__c>();
    Test.startTest();
    CC_ScheduleAutoExpireQuotes saeq = new CC_ScheduleAutoExpireQuotes();
    String jobId = System.schedule('ScheduledApexTest', CRON_EXP, saeq);
    saeq.execute(null);
    Test.stopTest();
    lquote = [SELECT ID FROM Quote__c WHERE Status__c = 'Expired'];
    System.assertEquals(200, lquote.size(), 'quote list size should be same');
  }
}
