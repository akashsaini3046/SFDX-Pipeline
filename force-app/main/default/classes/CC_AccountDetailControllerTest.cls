@isTest
public class CC_AccountDetailControllerTest {
  @testSetup
  public static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);

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

    // Child Account Creation
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
    List<Account> childAcclist = TestDataUtility.createAccount(
      'Child Test Account',
      'Customer',
      'Accounting',
      acc.id,
      false,
      1
    );
    insert childAcclist;

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

    // Account Team Memeber creation
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
    List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
      'Edit',
      'Edit',
      'Edit',
      'Edit',
      accList,
      new List<User>{ u1 },
      new List<String>{ 'Account Manager' }
    );
    insert atm;

    // Bookings Creation
    List<Booking__c> listBooking = TestDataUtility.getBookingRecords(
      'Test Description',
      1,
      false
    );
    insert listBooking;
    List<Shipment__c> shipments = TestDataUtility.getShipmentRecords(
      listBooking,
      1,
      true
    );
    List<FreightDetail__c> freightDetails = TestDataUtility.getFreightDetailRecords(
      shipments,
      'Auto',
      1,
      true
    );
    List<Requirement__c> requirements = TestDataUtility.getRequirementRecords(
      freightDetails,
      1,
      true
    );
  }

  @isTest
  public static void getTotalChildAccountsTest1() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    String filter = '{"accountType": "Customer","comoditySelected":"Cargo, NOS","accountOwner":"sanakam mounika"}';

    Test.startTest();

    Integer total = CC_AccountDetailController.getTotalChildAccounts(
      acc.Id,
      filter,
      'Test'
    );

    Test.stopTest();

    System.assertEquals(0, total, 'Total Child Check');
  }

  @isTest
  public static void getTotalChildAccountsTest2() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    String filter = '{"accountType": "Customer"}';

    Test.startTest();

    Integer total = CC_AccountDetailController.getTotalChildAccounts(
      acc.Id,
      '{}',
      'Test'
    );

    Test.stopTest();

    System.assertEquals(1, total, 'Total Child Check');
  }

  @isTest
  public static void getTotalChildAccountsTest3() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    String filter = '{"accountType": "Customer"}';

    Test.startTest();

    Integer total = CC_AccountDetailController.getTotalChildAccounts(
      acc.Id,
      null,
      'Test'
    );

    Test.stopTest();

    System.assertEquals(1, total, 'Total Child Check');
  }

  @isTest
  public static void fetchTotalContsTest() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

    Test.startTest();

    Integer total = CC_AccountDetailController.fetchTotalConts(
      new List<Id>{ acc.Id },
      'Test'
    );

    Test.stopTest();

    System.assertEquals(5, total, 'Total Contacts Check');
  }

  @isTest
  public static void getTableJsonTest() {
    String name = 'Test';

    Test.startTest();

    CC_TableJsonUtility.TableJsonWrapper tablejsonWrap = new CC_TableJsonUtility.TableJsonWrapper();
    tablejsonWrap = CC_AccountDetailController.getTableJson(name);

    Test.stopTest();

    System.assertEquals(null, tablejsonWrap.cardClassName, 'Table Json Check');
  }

  @isTest
  public static void getBookingMetaDataTest() {
    CC_BookingListCtrl.BookingListMetadata bookingmtd = new CC_BookingListCtrl.BookingListMetadata();
    Test.startTest();

    bookingmtd = CC_AccountDetailController.getBookingMetaData();

    Test.stopTest();

    System.assertNotEquals(null, bookingmtd, 'Booking Metadata Check');
  }

  @isTest
  public static void getBookingRecordsTest() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Booking__c booking = [SELECT Id, Account__c FROM Booking__C LIMIT 1];
    booking.Account__c = acc.Id;
    booking.Booking_Number__c = 'aaaaaa';
    update booking;
    String paginationParamsString = '{"limit":10,"offset":0}';
    List<CC_BookingListCtrl.BookingDataWrapper> listbookingdataWrap = new List<CC_BookingListCtrl.BookingDataWrapper>();

    Test.startTest();

    listbookingdataWrap = CC_AccountDetailController.getBookingRecords(
      new List<Id>{ acc.Id },
      paginationParamsString,
      null,
      'a'
    );

    Test.stopTest();
    System.assertNotEquals(null, listbookingdataWrap, 'Booking Data Check');
  }

  @isTest
  public static void getTotalBookingsTest() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Booking__c booking = [SELECT Id, Account__c FROM Booking__C LIMIT 1];
    booking.Account__c = acc.Id;
    booking.Booking_Number__c = 'aaaaaa';
    update booking;
    Test.startTest();

    Integer total = CC_AccountDetailController.getTotalBookings(
      new List<Id>{ acc.Id },
      null,
      null
    );

    Test.stopTest();

    System.assertEquals(1, total, 'Total Bookings Check');
  }

  @isTest
  public static void TestgetChildAccFilterMetaData() {
    CC_AccountDetailController.ChildAccMetaData childAccmtd;

    Test.startTest();

    childAccmtd = CC_AccountDetailController.getChildAccFilterMetaData();

    Test.stopTest();

    System.assertNotEquals(null, childAccmtd, 'Total Child Account Check');
  }

  @isTest
  public static void NegativeTestgetAccountRecord() {
    Account acc = new Account();
    CC_AccountDetailController.AccountDetailWrapper adWrap;

    Test.startTest();

    adWrap = CC_AccountDetailController.getAccountRecord(acc.Id);

    Test.stopTest();

    System.assertEquals(null, adWrap, 'Total Account Check');
  }

  @isTest
  public static void TestChildDatagetAccountRecord() {
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Child Test Account'
    ];
    CC_AccountDetailController.AccountDetailWrapper adWrap;

    Test.startTest();

    adWrap = CC_AccountDetailController.getAccountRecord(acc.Id);

    Test.stopTest();

    System.assertEquals(false, adWrap.isParent, 'Parent Check');
  }

  @isTest
  public static void TestgetAccountRecord() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    CC_AccountDetailController.AccountDetailWrapper adWrap;

    Test.startTest();

    adWrap = CC_AccountDetailController.getAccountRecord(acc.Id);

    Test.stopTest();

    System.assertEquals(true, adWrap.isParent, 'Parent Check');
  }

  //added by mounika
  @isTest
  public static void TestgetQuoteMetaData() {
    CC_QuoteListCtrl.QuoteListMetadata datawrap = new CC_QuoteListCtrl.QuoteListMetadata();
    Test.startTest();
    datawrap = CC_AccountDetailController.getQuoteMetaData();
    Test.stopTest();
    System.assertNotEquals(null, datawrap, 'Quote MetaData  Check');
  }

  @isTest
  public static void TestgetTotalQuotes() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    String filterObjectString = '{"accountType": "Customer"}';
    String searchListKeyword = 'test';
    Integer n;
    Test.startTest();
    n = CC_AccountDetailController.getTotalQuotes(
      new List<Id>{ acc.Id },
      filterObjectString,
      searchListKeyword
    );
    Test.stopTest();
    System.assertEquals(n, 0);
  }

  @isTest
  public static void TestfetchTotalContrts() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Integer n;
    String filterObjectString = '{"Deliveryterm__c": "P"}';
    String searchListKeyword = 'test';
    Test.startTest();
    n = CC_AccountDetailController.fetchTotalContrts(
      new List<Id>{ acc.Id },
      filterObjectString,
      searchListKeyword
    );
    Test.stopTest();
    System.assertEquals(n, 0);
  }
  @isTest
  public static void TestNegativefetchTotalContrts() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    String searchListKeyword = 'test';
    Integer n;
    Test.startTest();
    n = CC_AccountDetailController.fetchTotalContrts(
      new List<Id>{ acc.Id },
      null,
      searchListKeyword
    );
    Test.stopTest();
    System.assertEquals(n, 0);
  }

  @isTest
  public static void TestgetContractFilterMetaData() {
    Test.startTest();
    CC_AccountDetailController.getContractFilterMetaData();
    System.assert(
      (CC_AccountDetailController.getContractFilterMetaData() != null)
    );
    Test.stopTest();
  }

  @isTest
  public static void getQuoteListDataTest() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Booking__c booking = [SELECT Id, Account__c FROM Booking__C LIMIT 1];
    booking.Account__c = acc.Id;
    booking.Booking_Number__c = 'aaaaaa';
    update booking;
    String paginationParamsString = '{"limit":10,"offset":0}';
    List<CC_QuoteListCtrl.QuoteDataWrapper> listbookingdataWrap = new List<CC_QuoteListCtrl.QuoteDataWrapper>();
    String filterObjectString = '{"accountType": "Customer"}';
    String searchListKeyword = 'test';
    Test.startTest();
    listbookingdataWrap = CC_AccountDetailController.getQuoteListData(
      new List<Id>{ acc.Id },
      paginationParamsString,
      filterObjectString,
      searchListKeyword
    );
    Test.stopTest();
    System.assertNotEquals(null, listbookingdataWrap, 'Booking Data Check');
  }
}
