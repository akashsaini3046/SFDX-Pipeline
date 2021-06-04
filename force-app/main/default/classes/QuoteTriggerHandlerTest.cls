@isTest
public class QuoteTriggerHandlerTest {
  @testSetup
  static void setup() {
    Container__c newContainer = TestDataUtility.CreateContainer(
      '53MA',
      'FM808',
      '53 Mafi',
      'CTR',
      'Container'
    );
    insert newContainer;

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

    // Contact Creation
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
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert conList;

    //Quote Creation
    List<Quote__c> lstquotes = TestDataUtility.CreateQuote(4);
    for (Quote__c q : lstquotes) {
      q.Status__c = 'Sent to Pricing';
      q.Description__c = 'DD';
      q.Customer_Email__c = 'contact@email.com';
      q.Customer_Destination_City__c = 'Jacksonville';
      q.Customer_Destination_Country__c = 'US';
      q.Customer_Destination_State__c = 'Florida';
      q.Customer_Destination_Zip__c = '1234567';
      q.Customer_Origin_City__c = 'Boston';
      q.Customer_Origin_State__c = 'Boston';
      q.Customer_Origin_Country__c = 'US';
      q.Customer_Origin_Zip__c = '1876543';
      q.Ready_Date__c = Date.newInstance(2020, 11, 1);
    }
    lstquotes[1].Description__c = 'PP';
    lstquotes[2].Description__c = 'PD';
    lstquotes[3].Description__c = 'DP';
    insert lstquotes;

    //Shipment Creation
    List<Shipment__c> lstshipments = TestDataUtility.CreateShipment(
      lstquotes,
      1
    );
    insert lstshipments;

    //FreightDetail Creation
    List<FreightDetail__c> lstfds = TestDataUtility.CreateFreightDetail(
      lstshipments,
      2
    );
    lstfds[1].Cargo_Type__c = 'Equip';
    lstfds[2].Cargo_Type__c = 'BBulk';
    insert lstfds;

    //Requirement Creation
    List<Requirement__c> lstreq = TestDataUtility.CreateRequirement(lstfds, 2);
    insert lstreq;
  }

  @isTest
  static void insertTest() {
    Test.startTest();
    Quote__c q1 = new Quote__c();
    q1.Status__c = 'Active';
    insert q1;
    Test.stopTest();
    Integer size = [SELECT COUNT() FROM Quote__c WHERE Status__c = 'Active'];
    system.assertEquals(1, size, 'Size should be 1');
  }

  @isTest
  static void updateTest() {
    List<Quote__c> quotes = [
      SELECT Id, Status__c, Additional_Information__c
      FROM Quote__c
      WHERE Status__c = 'Sent to Pricing'
    ];
    Test.startTest();
    for (Quote__c q : quotes) {
      q.Additional_Information__c = 'test';
    }
    update quotes;
    Test.stopTest();
    Integer size = [SELECT COUNT() FROM Case];
    system.assertEquals(4, size, 'size should be 4');
  }

  @isTest
  static void DeleteTest() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    delete quote1;
    Test.stopTest();
    Integer size = [SELECT COUNT() FROM Quote__c];
    system.assertEquals(3, size, 'Size should be 0');
  }

  @isTest
  static void UpdateTest2() {
    Quote__c quote1 = new Quote__c();
    quote1.Status__c = 'Sent to Pricing';
    Test.startTest();
    insert quote1;
    quote1.Ready_Date__c = Date.newInstance(2020, 10, 19);
    update quote1;
    Test.stopTest();
    Integer size = [SELECT COUNT() FROM Case];
    System.assertEquals(1, size, 'Size should be 1');
  }

  @isTest
  static void UpdateTest3() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    quote1.Ready_Date__c = Date.newInstance(2020, 10, 19);
    update quote1;
    quote1.Additional_Information__c = 'test';
    update quote1;
    Test.stopTest();
    Integer size = [SELECT COUNT() FROM Case];
    System.assertEquals(
      1,
      size,
      'Size should be 1. should not create another case'
    );
  }
}
