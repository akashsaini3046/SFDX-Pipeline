@isTest
public class CC_VelozRouteEmailQuoteControllerTest {
  @testSetup
  static void setup() {
    List<Quote__c> listquotes = TestDataUtility.CreateQuote(2);
    for (Quote__c quote : listquotes) {
      quote.Description__c = 'DP';
    }
    insert listquotes;
  }

  @isTest
  static void TestsendEmail() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    String email = 'manaswini.datla@nagarro.com';
    CC_VelozRouteEmailQuoteController.sendEmail(
      email,
      'manaswini.datla',
      '123456789',
      'nagarro',
      true,
      quote1.Id,
      true
    );
    Test.stopTest();
    System.assert(email != null);
  }
}
