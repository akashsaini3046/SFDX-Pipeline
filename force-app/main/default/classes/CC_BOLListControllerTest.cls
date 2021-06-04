@isTest
public class CC_BOLListControllerTest {
  @testSetup
  static void setup() {
    TestDataUtility.getLocations('Loc Dummy', 10, true);
    List<Account> accounts = TestDataUtility.getAccountData(
      'NA',
      'DummyAcc',
      1,
      true
    );
    List<Booking__c> bookingList = TestDataUtility.getBookingWithChildren(
      accounts[0].Id,
      'BookingDesc',
      'FCL',
      '40 DS',
      1
    );
    bookingList[0].Bill_of_Lading_Number__c = '12345';
    update bookingList[0];
    TestDataUtility.getBillOfLading(bookingList[0], '12345', 1);
  }

  @isTest
  static void getBolListDataTest1() {
    String filterObjectString = '';
    String paginationParamsString = '';
    CC_BOLListController.getBolListData(
      filterObjectString,
      paginationParamsString,
      ''
    );
  }

  @isTest
  static void getBolListDataTest2() {
    List<Location__c> locations = [SELECT id FROM Location__c];
    String filterObjectString =
      '{"departureFromDate":"2020-09-03","status":"IN PROCESS","originLocationId":"' +
      locations[0].id +
      '"}';
    String paginationParamsString = '{"limit":10,"offset":0}';
    CC_BOLListController.getBolListData(
      filterObjectString,
      paginationParamsString,
      'a'
    );
  }

  @isTest
  static void getBolListDataTest3() {
    List<Location__c> locations = [SELECT id FROM Location__c];
    String filterObjectString =
      '{"originLocationId":"' +
      locations[0].id +
      '"}';
    String paginationParamsString = '';
    CC_BOLListController.getBolListData(
      filterObjectString,
      paginationParamsString,
      ''
    );
  }
  @isTest
  static void getBolListDataTest4() {
    String filterObjectString = '';
    String paginationParamsString = '';
    CC_BOLListController.getBolListData(
      filterObjectString,
      paginationParamsString,
      'a'
    );
  }

  @isTest
  static void getTotalBolsTest() {
    String filterObjectString = '';
    String paginationParamsString = '';
    CC_BOLListController.getTotalBols(filterObjectString, '');
  }

  @isTest
  static void fetchPDFUrlTest1() {
    String bookingId = [SELECT Id FROM Booking__c][0].Id;
    String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;
    CC_BOLListController.fetchPDFUrl(bookingId, bolId, 'abc');
  }
}
