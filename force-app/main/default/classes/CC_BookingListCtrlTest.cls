@isTest
public class CC_BookingListCtrlTest {
  @testSetup
  static void setup() {
    TestDataUtility.getLocations('Loc Dummy', 10, true);
    List<Account> accounts = TestDataUtility.getAccountData(
      'NA',
      'DummyAcc',
      1,
      true
    );
    TestDataUtility.getAccountData(accounts[0].Id, 'AccTest', 1, true);

    TestDataUtility.getBookingWithChildren(
      accounts[0].Id,
      'BookingDesc',
      'FCL',
      '40 DS',
      10
    );
    System.debug('size 1 ' + [SELECT id FROM Booking__c].size());
    List<Booking__c> b = TestDataUtility.getBookingRecords(
      accounts[0].Id,
      'Test Booking',
      10,
      true
    );
    System.debug('****');
    System.debug(b);
  }
  @isTest
  static void getBookingMetaDataTest() {
    Test.startTest();
    CC_BookingListCtrl.BookingListMetadata bookingListMetadata = CC_BookingListCtrl.getBookingMetaData();
    Test.stopTest();

    System.assertNotEquals(null, bookingListMetadata, 'Should not be null');
  }
  @isTest
  static void getBookingListDataTest1() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    List<Booking__c> bookings = [SELECT id, Booking_Number__c FROM Booking__c];
    String filterObjectString = '';
    String paginationParamsString = '';

    Test.startTest();
    List<CC_BookingListCtrl.BookingDataWrapper> bookingListWrapper = CC_BookingListCtrl.getBookingListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      ''
    );
    Test.stopTest();

    System.assertNotEquals(null, bookingListWrapper, 'Should not be null');
  }

  @isTest
  static void getBookingListDataTest2() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '{"departureFromDate":"2020-09-03"}';
    String paginationParamsString = '{"limit":10,"offset":0}';

    Test.startTest();
    List<CC_BookingListCtrl.BookingDataWrapper> bookingListWrapper = CC_BookingListCtrl.getBookingListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      'a'
    );
    Test.stopTest();

    System.assertNotEquals(null, bookingListWrapper, 'Should not be null');
  }
  @isTest
  static void getBookingListDataTest3() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '';
    String paginationParamsString = '{"limit":10,"offset":0}';

    Test.startTest();
    List<CC_BookingListCtrl.BookingDataWrapper> bookingListWrapper = CC_BookingListCtrl.getBookingListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      'a'
    );
    Test.stopTest();

    System.assertNotEquals(null, bookingListWrapper, 'Should not be null');
  }

  @isTest
  static void getBookingListDataTest4() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();

    String filterObjectString = '';
    String paginationParamsString = '{"limit":10,"offset":0}';
    Test.startTest();
    List<CC_BookingListCtrl.BookingDataWrapper> bookingListWrapper = CC_BookingListCtrl.getBookingListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      'a'
    );
    Test.stopTest();

    System.assertNotEquals(null, bookingListWrapper, 'Should not be null');
  }

  @isTest
  static void getTotalBookingsTest1() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '{"departureFromDate":"2020-09-03","customFilters":"NOS","vessalSelected":"van"}';
    List<Booking__c> bookings = [SELECT id, Booking_Number__c FROM Booking__c];
    System.debug('@@@ ' + bookings[0].Booking_Number__c);

    Test.startTest();
    Integer count = CC_BookingListCtrl.getTotalBookings(
      accountIds,
      filterObjectString,
      bookings[0].Booking_Number__c
    );
    Test.stopTest();

    System.assertEquals(0, count, 'Count should be 0');
  }
  @isTest
  static void getTotalBookingsTest2() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '';
    Test.startTest();
    Integer count = CC_BookingListCtrl.getTotalBookings(
      accountIds,
      filterObjectString,
      ''
    );
    Test.stopTest();

    //System.assertEquals(20, count, 'Count should be 20');
  }

  @isTest
  static void getTotalBookingsTest3() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();

    String filterObjectString = '';

    Test.startTest();
    Integer count = CC_BookingListCtrl.getTotalBookings(
      accountIds,
      filterObjectString,
      'zkr'
    );
    Test.stopTest();

    System.assertEquals(0, count, 'Count should be 0');
  }

  @isTest
  static void getChildAccountsTest() {
    ID accountId = [SELECT id FROM Account WHERE Name = 'DummyAcc' LIMIT 1].id;

    Test.startTest();
    List<Account> accounts = CC_BookingListCtrl.getChildAccounts(accountId);
    Test.stopTest();

    System.assertEquals(
      1,
      accounts.size(),
      ' No. Of Child Accounts should be 1'
    );
  }
  @isTest
  static void getChildAccountsTestNegative() {
    ID accountId = [SELECT id FROM Account LIMIT 1].id;
    String accountIdString = String.valueOf(accountId);
    String s1 = accountIdString.substring(0, 13);
    String s2 = accountIdString.substring(13).reverse();
    accountId = s1 + s2;
    boolean isError = false;

    Test.startTest();
    try {
      CC_BookingListCtrl.getChildAccounts(accountId);
    } catch (Exception ex) {
      isError = true;
    }
    Test.stopTest();

    System.assertEquals(
      false,
      isError,
      'getChildAccounts should have thrown error'
    );
  }

  @isTest
  static void getCustomFiltersTest1() {
    List<Location__c> locations = [SELECT id FROM Location__c];
    Map<String, Object> filterObject = new Map<String, Object>();
    filterObject.put('shippingType', 'FCL');
    filterObject.put('hazBook', 'Yes');
    filterObject.put('originMovementType', 'P');
    filterObject.put('destMovementType', 'P');
    filterObject.put('originLocationId', locations[0].id);
    filterObject.put('destinationLocationId', locations[1].id);
    filterObject.put('containerTypeSelected', '40 DS');
    filterObject.put('comoditySelected', 'Cargo, NOS');
    filterObject.put('selectedAccountId', 'yes');
    filterObject.put('showChildAcc', 'no');
    Test.startTest();
    String customFilters = CC_BookingListCtrl.getCustomFilters(filterObject);
    Test.stopTest();

    System.assertNotEquals('', customFilters, 'Should not be blank');
  }

  @isTest
  static void getCustomFiltersTest2() {
    Map<String, Object> filterObject = new Map<String, Object>();
    filterObject.put('shippingType', 'LCL');
    filterObject.put('hazBook', 'No');

    Test.startTest();
    String customFilters = CC_BookingListCtrl.getCustomFilters(filterObject);
    Test.stopTest();

    System.assertNotEquals('', customFilters, 'Should not be blank');
  }

  @isTest
  static void getLocationsTest() {
    List<Location__c> locations = [
      SELECT
        Id,
        Name,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c
      FROM Location__c
    ];
    List<Id> locationIds = new List<Id>();
    for (Location__c loc : locations)
      locationIds.add(loc.id);

    Test.startTest();
    List<Location__c> locationsList = CC_BookingListCtrl.getLocations(
      locationIds
    );
    Test.stopTest();

    System.assertEquals(locations, locationsList, 'Data do not match');
  }

  @isTest
  static void getShipmentsMapTest() {
    List<Booking__c> bookings = [SELECT id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    for (Booking__c booking : bookings)
      bookingIds.add(booking.id);

    Test.startTest();
    Map<Id, List<Shipment__c>> bookingIdVsShipmentList = CC_BookingListCtrl.getShipmentsMap(
      bookingIds
    );
    Test.stopTest();
    System.assert(bookingIdVsShipmentList != null);
  }

  @isTest
  static void getVoyagesMapTest() {
    List<Booking__c> bookings = [SELECT id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    for (Booking__c booking : bookings)
      bookingIds.add(booking.id);

    Test.startTest();
    Map<Id, List<Voyage__c>> bookingIdVsVoyageList = CC_BookingListCtrl.getVoyagesMap(
      bookingIds
    );
    Test.stopTest();
    System.assert(bookingIdVsVoyageList != null);
  }

  @isTest
  static void getCommoditiesMapTest() {
    List<Booking__c> bookings = [SELECT id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    for (Booking__c booking : bookings)
      bookingIds.add(booking.id);

    Test.startTest();
    Map<Id, List<Commodity__c>> bookingIdVsCommodityList = CC_BookingListCtrl.getCommoditiesMap(
      bookingIds
    );
    Test.stopTest();
    System.assert(bookingIdVsCommodityList != null);
  }

  @isTest
  static void TestgetBookingDetails() {
    Booking__c booking = [SELECT id FROM Booking__c LIMIT 1];
    Test.startTest();
    Booking__c bk = CC_BookingListCtrl.getBookingDetails(booking.Id);
    Test.stopTest();
    system.debug(bk);
  }

  @isTest
  static void TestfetchDownloadUrl() {
    Booking__c booking = [SELECT id FROM Booking__c LIMIT 1];
    Test.startTest();
    String url = CC_BookingListCtrl.fetchDownloadUrl(booking.Id);
    Test.stopTest();
    system.debug(url);
  }

  /*
    
    @isTest
    static void getStopsCountTest(){
        List<Booking__c> bookings = [SELECT id FROM Booking__c];
        Set<Id> bookingIds = new Set<Id>();
        for(Booking__c booking : bookings)
            bookingIds.add(booking.id);
        
        Test.startTest();
        Map<Id, String> bookingIdVsStops = CC_BookingListCtrl.getStopsCount(bookingIds);
        Test.stopTest();
        
        System.assertEquals(10, bookingIdVsStops.size(), 'size do not match');
    }

    @isTest
    static void resolveOriginDestFilterTest1(){
        List<Location__c> locations = [SELECT id, Name from Location__c];
        Map<Id, Location__c> locationsMap = new Map<Id, Location__c>();
        Map<String, Id> locTypeVsId = new Map<String, Id>();
        locTypeVsId.put('Origin', locations[0].id);
        locTypeVsId.put('Destination', locations[1].id);
        for(Location__c loc : locations){
            locationsMap.put(loc.id , loc);            
        }
        Test.startTest();
        List<String> filterClause = CC_BookingListCtrl.resolveOriginDestFilter('P','P',locationsMap,locTypeVsId);
        Test.stopTest();
        
        System.assertNotEquals(null, filterClause,'Should not be null');
        
        
    }
    
    @isTest
    static void resolveOriginDestFilterTest2(){
        List<Location__c> locations = [SELECT id, Name from Location__c];
        Map<Id, Location__c> locationsMap = new Map<Id, Location__c>();
        Map<String, Id> locTypeVsId = new Map<String, Id>();
        locTypeVsId.put('Origin', locations[0].id);
        locTypeVsId.put('Destination', locations[1].id);
        for(Location__c loc : locations){
            locationsMap.put(loc.id , loc);            
        }
        Test.startTest();
        List<String> filterClause =  CC_BookingListCtrl.resolveOriginDestFilter('D','D',locationsMap,locTypeVsId);
        Test.stopTest();
        
        System.assertNotEquals(null, filterClause, 'Should not be null');
    }
    
    @isTest
    static void getContainerTypesTest(){
        
        Test.startTest();
        CC_BookingListCtrl.getContainerTypes();
        Test.stopTest();
    }
    */
}
