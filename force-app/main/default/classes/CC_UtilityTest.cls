@isTest
public class CC_UtilityTest {
  @isTest
  static void TestgetMonth() {
    Test.startTest();
    String Month = CC_Utility.getMonth(12);
    Test.stopTest();
    system.assertEquals('Dec', Month, '12 Month is december');
  }

  @isTest
  static void NegativeTestgetMonth() {
    Test.startTest();
    String Month = CC_Utility.getMonth(16);
    Test.stopTest();
    system.assertEquals(null, Month, 'There is no 16 Month');
  }

  @isTest
  static void TestgetHours() {
    Test.startTest();
    String hour = CC_Utility.getHours(23);
    Test.stopTest();
    system.assertEquals('11', hour, 'This is 11PM');
  }

  @isTest
  static void NegativeTestgetHours() {
    Test.startTest();
    String hour = CC_Utility.getHours(24);
    Test.stopTest();
    system.assertEquals(null, hour, '0 is 24th Hour');
  }
}
