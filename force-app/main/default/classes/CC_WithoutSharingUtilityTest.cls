@isTest
public class CC_WithoutSharingUtilityTest {
  @testSetup
  static void setup() {
    // List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
    // Account Creation
    List<Account> accList = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      'Accounting',
      null,
      false,
      5
    );
    insert accList;

    List<Address__c> lstBusinessLocationObj = TestDataUtility.createBusinessLocation(
      accList,
      'Business Location2',
      'City1',
      'CA',
      '1111111',
      '88888888888',
      'US',
      1
    );
    insert lstBusinessLocationObj;
    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();
    List<Contact> conList = TestDataUtility.createContact(
      recordTypeId,
      accList,
      lstBusinessLocationObj,
      'Test',
      'Testlast',
      'test@email.com',
      '9666888222',
      false,
      null,
      1
    );
    insert conList;

    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    User u1 = TestDataUtility.createUser(
      null,
      profileId,
      'TestAdmin',
      'Mgr1',
      'approvalMgr1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u1;
    //List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember('Edit', 'Edit','Edit', 'Edit', accList, new List<User>{u1}, new List<String>{'Account Manager'});
    // insert atm;

    List<Quote__c> listquotes = TestDataUtility.CreateQuote(2);
    for (Quote__c quote : listquotes) {
      quote.Description__c = 'DP';
    }
    insert listquotes;
  }

  @isTest
  static void getAccountTeamMembersTest() {
    Account acc = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    List<AccountTeamMember> atms = CC_WithoutSharingUtility.getAccountTeamMembers(
      acc.Id
    );
    Test.stopTest();

    System.assertEquals(0, atms.size(), 'ATM check');
  }

  @isTest
  static void getTotalContactsByQueryAccountIdsTest() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    List<Id> accIds = new List<Id>{ acc.Id };
    String query = 'SELECT Count(Id) Total From Contact WHERE accountId IN :accountIds';
    Test.startTest();
    Integer contactNumber = CC_WithoutSharingUtility.getTotalContactsByQueryAccountIds(
      query,
      accIds
    );
    Test.stopTest();

    System.assertEquals(5, contactNumber, 'Number of Contacts');
  }

  @isTest
  static void getsObjectDataTest() {
    String query = 'SELECT id FROM Account';
    Test.startTest();
    List<sObject> sObjects = CC_WithoutSharingUtility.getsObjectData(query);
    Test.stopTest();

    System.assertEquals(5, sObjects.size(), 'Number of Accounts');
  }

  @isTest
  static void getQuoteWithChargeLineByQuoteIdsTest() {
    List<Quote__c> quotes = [SELECT Id FROM Quote__c];
    Set<Id> quoteIds = new Set<Id>();
    for (Quote__c q : quotes) {
      quoteIds.add(q.Id);
    }
    Test.startTest();
    List<Quote__c> Listquotes = CC_WithoutSharingUtility.getQuoteWithChargeLineByQuoteIds(
      quoteIds
    );
    Test.stopTest();

    System.assertEquals(2, Listquotes.size(), 'List size check');
  }
  @isTest
  static void getContactsByIdsTest() {
    Map<Id, Contact> accountsMap = new Map<Id, Contact>(
      [SELECT Id FROM Contact LIMIT 1]
    );
    Set<Id> contactIds = new Set<Id>(accountsMap.keySet());
    Test.startTest();
    List<Contact> totalContact = CC_WithoutSharingUtility.fetchContactDetailsById(
      contactIds
    );
    Test.stopTest();
    System.assertEquals(
      1,
      totalContact.size(),
      'There should be total 1 records'
    );
  }
  @isTest
  static void getContactsDetailByFirstNLastNPhoneEmailTest() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    String firstName = 'Test';
    String lastname = 'con1';
    String phone = '99999999999';
    String email = 'contact@email.com';
    Id accountId = acc.id;

    Test.startTest();
    List<Contact> totalContact = CC_WithoutSharingUtility.getContactsDetailByFirstNLastNPhoneEmail(
      firstName,
      lastname,
      phone,
      email,
      accountId
    );
    Test.stopTest();
    System.assertEquals(
      0,
      totalContact.size(),
      'There should be total 0 records'
    );
  }
}
