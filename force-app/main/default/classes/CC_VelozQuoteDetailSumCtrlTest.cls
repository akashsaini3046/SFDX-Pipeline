@isTest
public class CC_VelozQuoteDetailSumCtrlTest {
  @testSetup
  static void setup() {
    List<Quote__c> listquotes = TestDataUtility.CreateQuote(2);
    for (Quote__c quote : listquotes) {
      quote.Description__c = 'DP';
    }
    insert listquotes;
  }

  @isTest
  static void TestgetQuoteDetails() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    CC_QuoteUtility.QuoteWrapper qWrap = CC_VelozQuoteDetailSumCtrl.getQuoteDetails(
      quote1.Id
    );
    Test.stopTest();
    system.assert(
      qWrap.orgDestVsMovementType.get('destination') == 'Port',
      'check destination'
    );
  }

  @isTest
  static void isInternalCommunityTest() {
    Test.startTest();
    Boolean res = CC_VelozQuoteDetailSumCtrl.isInternalCommunity();
    Test.stopTest();
    System.assertEquals(true, res);
  }

  @isTest
  static void isInternalCommunityTest1() {
    Test.startTest();
    List<Network> net = [SELECT name, UrlPathPrefix FROM Network];
    CommonUtility.networkId = net[0].Id;
    Boolean res = CC_VelozQuoteDetailSumCtrl.isInternalCommunity();
    Test.stopTest();
    //System.assertEquals(false, res);
  }

  @isTest
  static void fetchIframeUrlTest() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    String url = CC_VelozQuoteDetailSumCtrl.fetchIframeUrl(quote1.Id);
    Test.stopTest();
    system.debug(url);
  }
}
