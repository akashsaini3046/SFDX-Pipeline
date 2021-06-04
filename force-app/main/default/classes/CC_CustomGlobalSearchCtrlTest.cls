@isTest(SeeAllData=false)
public without sharing class CC_CustomGlobalSearchCtrlTest {
  @testSetup
  static void setup() {
    List<Account> listAccounts = new List<Account>();
    listAccounts = TestDataUtility.createAccount(
      'WALMART',
      null,
      'Customer',
      null,
      false,
      5
    );
    if (listAccounts != null && !listAccounts.isEmpty()) {
      insert listAccounts;
    }
  }
  @isTest
  static void getSObjectsTest() {
    Test.startTest();
    Map<String, String> mapSobjects = CC_CustomGlobalSearchCtrl.getSObjects();
    Test.stopTest();
    //System.assertEquals(1, mapSobjects.size(), 'Incomplete records');
    System.assertNotEquals(null, mapSobjects);
  }
  @isTest
  static void searchAllObjectsTest1() {
    List<Account> listaccounts = [SELECT Id, Name FROM Account];
    Id[] fixedSearchResults = new List<Id>(1);
    fixedSearchResults[0] = listaccounts[0].Id;
    Test.setFixedSearchResults(fixedSearchResults);
    Test.startTest();
    List<CC_CustomGlobalSearchCtrl.SObjectResult> listObjectResults = CC_CustomGlobalSearchCtrl.searchAllObjects(
      listaccounts[0].Name,
      'Accounts',
      'Account'
    );
    Test.stopTest();
    System.assertEquals(1, listObjectResults.size(), 'Incomplete records');
  }
  @isTest
  static void searchAllObjectsTest2() {
    List<Account> listaccounts = [SELECT Id, Name FROM Account];
    Id[] fixedSearchResults = new List<Id>(1);
    fixedSearchResults[0] = listaccounts[0].Id;
    Test.setFixedSearchResults(fixedSearchResults);
    Test.startTest();
    List<CC_CustomGlobalSearchCtrl.SObjectResult> listObjectResults = CC_CustomGlobalSearchCtrl.searchAllObjects(
      listaccounts[0].Name,
      'All',
      ''
    );
    Test.stopTest();
    System.assertEquals(1, listObjectResults.size(), 'Incomplete records');
  }
}
