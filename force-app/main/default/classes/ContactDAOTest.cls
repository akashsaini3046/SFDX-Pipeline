@isTest
public class ContactDAOTest {
  @testSetup
  static void setup() {
    //  List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
    Account accObj1 = TestDataUtility.createAccount(
      'Nagarro',
      'Customer',
      'Industrial',
      null,
      false,
      1
    )[0];
    insert accObj1;
    DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
    List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
    Address__c businessLocationObj = TestDataUtility.createBusinessLocation(
      new List<Account>{ new Account(Id = accObj1.Id) },
      'BL1',
      'City1',
      stateAvailableValues[0].getValue(),
      '1111111',
      '88888888888',
      'US',
      1
    )[0];
    List<Contact> contacts = TestDataUtility.createContact(
      null,
      new List<Account>{ new Account(Id = accObj1.Id) },
      new List<Address__c>{ new Address__c(Id = businessLocationObj.Id) },
      'Test',
      'con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert contacts;
    //List<Contact> contacts = TestDataUtility.getContactRecords('Test', 1 , true);
    contacts[0].AccountId = accObj1.Id;
    contacts[0].Locations_Served__c = 'ANGUILLA';
    contacts[0].FirstName = 'Test';
    contacts[0].Email = 'test@email.com';
    contacts[0].LastName = 'Testlast';
    contacts[0].phone = '9666888222';
    update contacts;
  }

  @isTest
  static void getTotalContactsByQueryAccountIdsTest() {
    Map<Id, Account> accountsMap = new Map<Id, Account>(
      [SELECT Id FROM Account LIMIT 1]
    );
    System.debug(accountsMap);
    List<Id> accountIds = new List<Id>(accountsMap.keySet());
    System.debug(accountIds);
    Test.startTest();
    String query = 'SELECT Count(Id) Total From Contact WHERE accountId IN :accountIds';
    Integer totalContact = ContactDAO.getTotalContactsByQueryAccountIds(
      query,
      accountIds
    );
    Test.stopTest();

    System.assertEquals(1, totalContact, 'There should be total 1 records');
  }

  @isTest
  static void getContactsByEmailsTest() {
    String email = 'test@email.com';
    Test.startTest();
    List<Contact> listcontacts = ContactDAO.getContactsByEmails(
      new Set<String>{ email }
    );
    Test.stopTest();
    System.assertEquals(
      1,
      listcontacts.size(),
      'There should be total 1 records'
    );
  }
  @isTest
  static void getContactsByIdsTest() {
    Map<Id, Contact> accountsMap = new Map<Id, Contact>(
      [SELECT Id FROM Contact LIMIT 1]
    );
    Set<Id> contactIds = new Set<Id>(accountsMap.keySet());
    Test.startTest();
    List<Contact> totalContact = ContactDAO.getContactsByIds(contactIds);
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
    String lastname = 'Testlast';
    String phone = '9666888222';
    String email = 'test@email.com';
    Id accountId = acc.id;

    Test.startTest();
    List<Contact> totalContact = ContactDAO.getContactsDetailByFirstNLastNPhoneEmail(
      firstName,
      lastname,
      phone,
      email,
      accountId
    );
    Test.stopTest();
    System.assertEquals(
      1,
      totalContact.size(),
      'There should be total 1 records'
    );
  }
}
