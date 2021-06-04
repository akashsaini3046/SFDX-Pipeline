@isTest
public class CC_SharedUtilityTest {
  @testSetup
  static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
    TestDataUtility.getLocations('Loc Dummy', 10, true);
    List<Account> accounts = TestDataUtility.getAccountData(
      'NA',
      'DummyAcc',
      1,
      true
    );
    TestDataUtility.getBookingWithChildren(
      accounts[0].Id,
      'BookingDesc',
      'FCL',
      '40 DS',
      10
    );
  }
  @isTest
  static void getLimitOffestTest() {
    Map<String, Object> paginationParams = new Map<String, Object>();
    paginationParams.put('limit', 10);
    paginationParams.put('offset', 0);

    Test.startTest();
    String query = CC_SharedUtility.getLimitOffest(paginationParams);
    Test.stopTest();

    System.assertNotEquals('', query, 'getLimitOffestTest failed');
  }

  @isTest
  static void getFiltersTest() {
    Map<String, Object> filterObject = new Map<String, Object>();
    filterObject.put('shippingType', 'FCL');
    filterObject.put('hazBook', 'Yes');
    filterObject.put('originMovementType', 'P');
    filterObject.put('destMovementType', 'P');
    filterObject.put('departureFromDate', '2020-09-03');
    filterObject.put('departureToDate', '2020-09-08');
    filterObject.put('statusSelected', 'A');

    Map<String, String> paramVsStringFieldAPI = new Map<String, String>();
    paramVsStringFieldAPI.put('statusSelected', 'Status__c');
    paramVsStringFieldAPI.put('selectedAccountId', 'Account__c');
    paramVsStringFieldAPI.put(
      'transModeOriginSelected',
      'Transportation_Management_System_Origin__c'
    );
    paramVsStringFieldAPI.put(
      'transModeDestSelected',
      'Transportation_Management_System_Destina__c'
    );
    paramVsStringFieldAPI.put('contractInput', 'Contract_Number__c');

    Map<String, String> paramVsDateFieldAPI = new Map<String, String>();
    Map<String, String> paramVsLikeFieldAPI = new Map<String, String>();

    Map<String, String> paramVsRangeFieldAPI = new Map<String, String>();
    paramVsRangeFieldAPI.put('departureFromDate', 'Date_of_Discharge__c');
    paramVsRangeFieldAPI.put('departureToDate', 'Date_of_Discharge__c');

    Test.startTest();
    String query = CC_SharedUtility.getFilters(
      filterObject,
      paramVsStringFieldAPI,
      paramVsDateFieldAPI,
      paramVsRangeFieldAPI,
      paramVsLikeFieldAPI
    );
    Test.stopTest();

    System.assertNotEquals('', query, 'Query must have been generated');
  }

  @isTest
  static void getFieldSetListTest() {
    Test.startTest();
    List<String> strFilterQuery = CC_SharedUtility.getFieldSetList(
      'Booking__c',
      'Booking_Detail_Internal'
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      strFilterQuery,
      'Query must have been generated'
    );
  }

  @isTest
  static void getPicklistValuesListTest() {
    Test.startTest();
    List<Map<String, String>> picklistValuesList = CC_SharedUtility.getPicklistValuesList(
      Account.Type.getDescribe()
    );
    Test.stopTest();

    System.assertNotEquals(null, picklistValuesList, 'Picklist Null Check');
  }

  @isTest
  static void fetchMultiplePickListValuesTest() {
    Map<String, Object> mapFieldValuestoGet = new Map<String, Object>();
    List<String> fieldnames = new List<String>();
    fieldnames.add('Booking_Pending_Reasons__c');
    mapFieldValuestoGet.put('Booking__c', fieldnames);
    Test.startTest();
    Map<String, Map<String, String>> picklistValuesList = CC_SharedUtility.fetchMultiplePickListValues(
      mapFieldValuestoGet
    );
    Test.stopTest();

    System.assertNotEquals(null, picklistValuesList, 'Picklist Null Check');
  }

  @isTest
  static void getSearchKeywordFilterTest1() {
    Test.startTest();
    String query = CC_SharedUtility.getSearchKeywordFilter(
      'z',
      'Booking__c',
      'Booking_Detail_Internal'
    );
    Test.stopTest();

    System.assertNotEquals('', query, 'Should not be blank');
  }

  @isTest
  static void getSearchKeywordFilterTest2() {
    Test.startTest();
    String query = CC_SharedUtility.getSearchKeywordFilter(
      '',
      'Booking__c',
      'Booking_Detail_Internal'
    );
    Test.stopTest();

    System.assertNotEquals('', query, 'Should not be blank');
  }

  @isTest
  static void getRecordTypeIdTest1() {
    List<RecordType> recordType = [
      SELECT SobjectType, DeveloperName
      FROM RecordType
      WHERE isActive = TRUE
    ];

    Test.startTest();
    Id recordTypeId = CC_SharedUtility.getRecordTypeId(
      recordType[0].SobjectType +
      ':' +
      recordType[0].DeveloperName
    );
    Test.stopTest();

    System.assertNotEquals(null, recordTypeId, 'Should not be blank');
  }
  @isTest
  static void getRecordTypeIdTest2() {
    Test.startTest();
    Id recordTypeId = CC_SharedUtility.getRecordTypeId('');
    Test.stopTest();

    System.assertEquals(null, recordTypeId, 'Should be blank');
  }
}
