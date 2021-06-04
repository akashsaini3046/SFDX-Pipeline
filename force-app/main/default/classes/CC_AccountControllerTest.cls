@isTest
public class CC_AccountControllerTest {
  @testSetup
  static void setup() {
    TestDataUtility.getAccountData('NA', 'DummyAcc', 10, true);
  }

  @isTest
  static void TableJsonWrapperTest() {
    Test.startTest();
    CC_TableJsonUtility.TableJsonWrapper tableWrapper = CC_AccountController.getTableJson(
      'Account List'
    );
    Test.stopTest();
    System.assertNotEquals(
      null,
      tableWrapper,
      'tableWrapper should not be null'
    );
  }

  @isTest
  static void fetchTotalAccountsTest() {
    String filter = '{"accountType": "Customer","accountOwner":"Mounika"}';
    Test.startTest();
    Integer accountsCount = CC_AccountController.fetchTotalAccounts(filter);
    Test.stopTest();

    System.assertEquals(0, accountsCount, 'Count of account mismatch');
  }

  @isTest
  static void getChildAccFilterMetaDataTest() {
    Test.startTest();
    CC_AccountController.ChildAccMetaData childAccMetaData = CC_AccountController.getChildAccFilterMetaData();
    Test.stopTest();
    System.assertNotEquals(null, childAccMetaData);
  }
}
