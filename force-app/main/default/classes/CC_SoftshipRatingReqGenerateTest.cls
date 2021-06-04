@isTest
public class CC_SoftshipRatingReqGenerateTest {
  @testSetup
  static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
    List<Optional_Service__c> listop = new List<Optional_Service__c>();
    Optional_Service__c op = new Optional_Service__c();
    op.Name = 'Additional Chains';
    op.Basis_Field_Name__c = 'Additional_Chains_Qty__c';
    op.FieldMapping_Name__c = 'Additional_Chains__c';
    op.Tariff_Code__c = '103';
    listop.add(op);
    Optional_Service__c op1 = new Optional_Service__c();
    op1.Name = 'Marine Cargo Insurance';
    op1.FieldMapping_Name__c = 'Marine_Cargo_Insurance__c';
    op1.FieldMapping_Type__c = 'Text';
    op1.Tariff_Code__c = '102';
    listop.add(op1);
    insert listop;

    TestDataUtility.getAccountData('NA', 'Account Dummy', 1, true);
  }
  @isTest
  static void getRatingRequestWrapperTest1() {
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.shipment.listCargo[0]
      .cargoType = CC_SoftshipRatingConstant.BREAKBULK;
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Freight_Quantity__c = 2;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Additional_Chains__c = true;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Additional_Chains_Qty__c = 1;
    bookingWrap.booking.Port_of_Load__c = '2';
    bookingWrap.booking.Port_of_Discharge__c = '4';
    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();
    System.assertNotEquals(null, request, 'Request must be created');
  }
  @isTest
  static void getRatingRequestWrapperTest2() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.shipment.listCargo[0]
      .cargoType = CC_SoftshipRatingConstant.RORO;
    bookingWrap.booking.Description__c = 'PR';
    bookingWrap.booking.Customer_Origin_Country__c = 'US';
    bookingWrap.booking.Customer_Destination_Country__c = 'US';
    bookingWrap.booking.Port_of_Load__c = '2';
    bookingWrap.booking.Port_of_Discharge__c = '4';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);

    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();

    System.assertNotEquals(null, request, 'Request must be created');
  }
  @isTest
  static void getRatingRequestWrapperTest3() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.booking.Contract_Number__c = '123';
    bookingWrap.booking.Description__c = 'RP';
    bookingWrap.booking.Customer_Origin_Country__c = 'US';
    bookingWrap.booking.Customer_Destination_Country__c = 'US';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.shipment.listCargo[0].isHazardous = true;
    bookingWrap.booking.Port_of_Load__c = '2';
    bookingWrap.booking.Port_of_Discharge__c = '4';
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.OutOfGauge__c = true;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 2;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.IsShippersOwn__c = true;
    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();

    System.assertNotEquals(null, request, 'Request must be created');
  }

  @isTest
  static void getRatingRequestWrapperTest4() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.booking.Contract_Number__c = '123';
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.shipment.listCargo[0].cargoType = 'BBULK';
    bookingWrap.booking.Description__c = 'PD';
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
    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();

    System.assertNotEquals(null, request, 'Request must be created');
  }

  @isTest
  static void getRatingRequestWrapperTest5() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.booking.Contract_Number__c = '123';
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.shipment.listCargo[0].cargoType = 'AUTO';
    bookingWrap.booking.Description__c = 'DP';
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 2;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Freight_Quantity__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Length_Major__c = 6;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Length_Minor__c = 6;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .measureUnit = 'lb/ft';
    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();

    System.assertNotEquals(null, request, 'Request must be created');
  }

  @isTest
  static void getRatingRequestWrapperTest6() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.booking.Contract_Number__c = '123';
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.shipment.listCargo[0].cargoType = 'BBULK';
    bookingWrap.booking.Description__c = 'PP';
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 2;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Freight_Quantity__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Length_Minor__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .measureUnit = 'kg/m';
    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();

    System.assertNotEquals(null, request, 'Request must be created');
  }

  @isTest
  static void getRatingRequestWrapperTest7() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.booking.Contract_Number__c = '123';
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.booking.Description__c = 'DD';
    bookingWrap.shipment.listCargo[0].cargoType = 'AUTO';
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 2;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Freight_Quantity__c = 3;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .freightDetail.Length_Minor__c = 6;
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .measureUnit = 'lb/ft';
    test.startTest();
    CC_SoftshipRatingRequest request = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );
    test.stopTest();

    System.assertNotEquals(null, request, 'Request must be created');
  }

  @isTest
  static void sendRatingRequestTest() {
    Id accountId = [SELECT id FROM Account LIMIT 1][0].id;
    CC_BookingWrapper bookingWrap = CC_BookingWrapper.getBookingWrapper();

    bookingWrap.booking.Account__c = accountId;
    bookingWrap.booking.Contract_Number__c = '123';
    bookingWrap.booking.Description__c = 'Booking Description';
    bookingWrap.booking.Ready_Date__c = Date.newInstance(2020, 9, 9);
    bookingWrap.shipment.listCargo[0]
      .listFreightDetailWrapper[0]
      .listRequirementWrapper[0]
      .requirement.Quantity__c = 2;

    CC_SoftshipRatingRequest ratingRequest = CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(
      bookingWrap
    );

    MockResponsesUtility.SoftShipMockResponse mock = new MockResponsesUtility.SoftShipMockResponse(
      false
    );

    test.startTest();
    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceMapForTest();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(HttpCalloutMock.class, mock);
    CC_SoftshipRatingResponse resWrap = CC_SoftshipRatingReqGenerate.sendRatingRequest(
      ratingRequest
    );
    test.stopTest();

    System.assertNotEquals(null, resWrap, 'Response must be created');
  }
}
