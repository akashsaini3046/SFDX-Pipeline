@isTest
private class CC_CreateProspectCtrlTest {
  @testSetup
  static void setup() {
    // List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);

    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Acc',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;

    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      listAccounts,
      'Business Location11',
      'City11',
      'CA',
      '1134111',
      '86788888888',
      'US',
      1
    );
    insert businessLocationObj;
    List<Contact> con2 = TestDataUtility.createContact(
      null,
      listAccounts,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert con2;
  }

  @isTest
  static void fetchInitialValuesTest() {
    Test.startTest();
    CC_CreateProspectCtrl.InitValWrapper ivw = CC_CreateProspectCtrl.fetchInitialValues();
    Test.stopTest();
    System.assertNotEquals(
      null,
      ivw.marketSegments.size(),
      'should not be null'
    );
  }

  @isTest
  static void createProspectRecordsTest() {
    String objValues = '{"contactNumber":"8979","firstName":"Test","lastName":"Name","accountName":"Test PRS","emailAddress":"x@m.com","marketSegment":"Beverages","countryName":"IN","cityName":"Gurgaon","zipCode":"11111","address":"Test","createAddress":false,"createContact":false}';
    Test.startTest();
    List<Map<String, Object>> result = CC_CreateProspectCtrl.createProspectRecords(
      objValues
    );
    Test.stopTest();
    System.assertNotEquals(null, result.size(), 'should not be null');
  }

  @isTest
  static void createProspectRecordsTest_contact() {
    String objValues = '{"contactNumber":"8979","firstName":"Test","lastName":"Name","accountName":"Test PRS","emailAddress":"x@m.com","marketSegment":"Beverages","countryName":"IN","cityName":"Gurgaon","zipCode":"11111","address":"Test","createAddress":true,"createContact":true}';
    Test.startTest();
    List<Map<String, Object>> result = CC_CreateProspectCtrl.createProspectRecords(
      objValues
    );
    Test.stopTest();
    System.assertNotEquals(null, result.size(), 'should not be null');
  }

  @isTest
  static void createProspectRecordsTest_contact2() {
    String objValues = '{"contactNumber":"99999999999","firstName":"Test","lastName":" con1","accountName":"Test PRS","emailAddress":"contact@email.com","marketSegment":"Beverages","countryName":"IN","cityName":"Gurgaon","zipCode":"11111","address":"Test","createAddress":true,"createContact":true}';
    Test.startTest();
    List<Map<String, Object>> result = CC_CreateProspectCtrl.createProspectRecords(
      objValues
    );
    Test.stopTest();
    System.assertNotEquals(null, result.size(), 'should not be null');
  }

  @isTest
  static void createProspectRecordsTest_address() {
    String objValues = '{"contactNumber":"8979","firstName":"Test","lastName":"Name","accountName":"Test PRS","emailAddress":"x@m.com","marketSegment":"Beverages","countryName":"IN","cityName":"Gurgaon","zipCode":"11111","address":"Test","createAddress":true,"createContact":false}';
    Test.startTest();
    List<Map<String, Object>> result = CC_CreateProspectCtrl.createProspectRecords(
      objValues
    );
    Test.stopTest();
    System.assertNotEquals(null, result.size(), 'should not be null');
  }

  @isTest
  static void TestgetAccountDetails() {
    List<Account> listAccounts = [SELECT Id FROM Account];
    Test.startTest();
    Account result = CC_CreateProspectCtrl.getAccountDetails(
      listAccounts[0].id
    );
    Test.stopTest();
    System.assertNotEquals(null, result, 'should not be null');
  }
}
