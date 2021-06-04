@isTest
public class CommonUtilityTest {
  @isTest
  static void getCommunityNameTest() {
    Test.startTest();
    List<Network> net = [SELECT name, UrlPathPrefix FROM Network];
    CommonUtility.networkId = net[0].Id;
    String communityName = CommonUtility.getCommunityName();
    Test.stopTest();
    System.assertEquals(net[0].name, communityName, 'Community Name Check');
  }

  @isTest
  static void getCommunityUrlPathPrefixTest() {
    Test.startTest();
    List<Network> net = [SELECT name, UrlPathPrefix FROM Network];
    CommonUtility.networkId = net[0].Id;
    String communityUrlPathPrefix = CommonUtility.getCommunityUrlPathPrefix();
    Test.stopTest();
    System.assertEquals(
      net[0].UrlPathPrefix,
      communityUrlPathPrefix,
      'Community Url Check'
    );
  }

  @isTest
  static void getCommunityNameNegativeTest() {
    Test.startTest();
    String communityName = CommonUtility.getCommunityName();
    Test.stopTest();
    System.assertEquals(null, communityName, 'Community Name Check');
  }

  @isTest
  static void getCommunityUrlPathPrefixNegativeTest() {
    Test.startTest();
    String communityUrlPathPrefix = CommonUtility.getCommunityUrlPathPrefix();
    Test.stopTest();
    System.assertEquals(null, communityUrlPathPrefix, 'Community Url Check');
  }
}
