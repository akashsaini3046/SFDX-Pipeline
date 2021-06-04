@isTest
public class APICalloutUtilityTest {
  @isTest
  static void testGetCallout() {
    Test.startTest();

    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );

    String response = APICalloutUtility.callAPIResponseService(
      'GetService',
      '{"test":"Get"}',
      null,
      null
    );
    Test.stopTest();

    System.assertEquals('{"success":true}', response, 'Response Body check');
  }

  @isTest
  static void testPostCalloutWithQueryParams() {
    Test.startTest();

    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );
    String response = APICalloutUtility.callAPIResponseService(
      'GetService',
      '{"test":"Post"}',
      new Map<String, String>{ 'test' => 'parameter' },
      null
    );
    Test.stopTest();

    System.assertEquals('{"success":true}', response, 'Response Body check');
  }

  @isTest
  static void testPostCallout() {
    Test.startTest();

    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );

    String response = APICalloutUtility.callAPIResponseService(
      'PostService',
      '{"test":"Post"}',
      null,
      null
    );
    Test.stopTest();

    System.assertEquals('{"success":true}', response, 'Response Body check');
  }

  @isTest
  static void testPutCallout() {
    Test.startTest();

    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );

    String response = APICalloutUtility.callAPIResponseService(
      'PutService',
      '{"test":"Put"}',
      null,
      null
    );
    Test.stopTest();

    System.assertEquals('{"success":true}', response, 'Response Body check');
  }

  @isTest
  static void testDeleteCallout() {
    Test.startTest();

    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );

    String response = APICalloutUtility.callAPIResponseService(
      'DeleteService',
      '{"test":"Delete"}',
      null,
      null
    );
    Test.stopTest();

    System.assertEquals('{"success":true}', response, 'Response Body check');
  }

  @isTest
  static void testForIntegrationServiceVar() {
    Test.startTest();

    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );
    String response = APICalloutUtility.callAPIResponseService(
      'GetService',
      '{"test":"Get"}',
      null,
      null
    );

    Test.stopTest();

    System.assertEquals('', response, 'Response Body check');
  }

  @isTest
  static void testForServiceEnvironmentVar() {
    Test.startTest();
    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );
    String response = APICalloutUtility.callAPIResponseService(
      'GetService',
      '{"test":"Get"}',
      null,
      null
    );

    Test.stopTest();

    System.assertEquals('', response, 'Response Body check');
  }

  @isTest
  static void testForServiceEnvParamVar() {
    Test.startTest();
    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );
    String response = APICalloutUtility.callAPIResponseService(
      'GetService',
      '{"test":"Get"}',
      null,
      null
    );

    Test.stopTest();

    System.assertEquals('', response, 'Response Body check');
  }

  @isTest
  static void testErrorCallout() {
    Test.startTest();

    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(
      HttpCalloutMock.class,
      new MockResponsesUtility.APIUtilityMockHttpResponse()
    );
    Boolean isErrorThrown = false;
    try {
      String response = APICalloutUtility.callAPIResponseService(
        'ErrorService',
        '{"test":"Error"}',
        null,
        null
      );
    } catch (Exception e) {
      isErrorThrown = true;
    }
    Test.stopTest();

    System.assertEquals(true, isErrorThrown, 'Error Thrown check');
  }

  @isTest
  static void testCreateContinuationAPIRequest() {
    String bwrap = TestDataUtility.bookingwrapper();
    System.debug('777');
    System.debug(bwrap);
    CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(
      bwrap,
      CC_BookingWrapper.class
    );
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();
    System.debug('bookingwrapper in test @@@ ' + bookingWrap);
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.shipment.cargoType = CC_SoftshipRatingConstant.CONTAINER;
    bookingWrap.shipment.isSelected = true;
    bookingWrap.shipment.listCargo[0]
      .cargoType = CC_SoftshipRatingConstant.CONTAINER;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 2;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Freight_Quantity__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Length_Major__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Length_Minor__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .measureUnit = 'kg/m';
    CC_SoftshipRatingRequest ratingRequest = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    System.debug('ratingRequest111--->' + ratingRequest);
    String requestBody = JSON.serialize(ratingRequest, true);
    System.debug('requestBody--->' + requestBody);

    Test.startTest();
    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.FindARoute_getIntegrationServiceTestMap();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    HttpRequest request = APICalloutUtility.createContinuationAPIRequest(
      'FindARoutePOST',
      requestBody,
      null,
      ''
    );
    Test.stopTest();
    System.debug('request---->' + request);
    System.assertNotEquals(null, request, 'should not be null');
  }

  @isTest
  static void testElseLoop() {
    Test.startTest();
    String response = APICalloutUtility.callAPIResponseService(
      null,
      null,
      null,
      null
    );
    HttpRequest request = APICalloutUtility.createContinuationAPIRequest(
      null,
      null,
      null,
      ''
    );
    Test.stopTest();
    System.debug(response);
    System.debug(request);
    System.assertEquals(null, request);
  }
}
