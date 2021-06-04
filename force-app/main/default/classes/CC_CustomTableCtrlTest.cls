@isTest
public class CC_CustomTableCtrlTest {
  @testSetup
  public static void setup() {
    List<Account> accList = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert accList;
  }

  @isTest
  static Void fetchRecordsTest() {
    Test.startTest();

    String querymdt = TestDataUtility.getTableJsonTest(false);
    System.debug(querymdt);
    List<sObject> response = CC_CustomTableCtrl.fetchRecords(querymdt);
    Test.stopTest();

    System.assertEquals(1, response.size(), 'Result count check');
  }
  @isTest
  static Void fetchRecordsNegativeTest() {
    Test.startTest();

    String querymdt = TestDataUtility.getTableJsonTest(true);
    List<sObject> response = CC_CustomTableCtrl.fetchRecords(querymdt);

    Test.stopTest();

    System.assertEquals(null, response, 'Error Check');
  }
}
