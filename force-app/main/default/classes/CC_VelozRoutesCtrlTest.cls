@isTest
public class CC_VelozRoutesCtrlTest {
  @isTest
  static void fetchTermsAndConditionsTest() {
    Test.startTest();
    List<String> liststr = CC_VelozRoutesCtrl.fetchTermsAndConditions();
    Test.stopTest();
    System.assertNotEquals(
      null,
      liststr.size(),
      'This list size should not be null'
    );
  }
}
