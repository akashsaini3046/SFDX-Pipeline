@isTest
private class CC_QuoteControllerTest {
  @testSetup
  static void setup() {
    List<Location__c> listlocations = TestDataUtility.CreateLocation(
      'Test Location',
      'BERTH',
      1,
      false
    );
    insert listlocations;

    List<Quote__c> q = TestDataUtility.CreateQuote(1);
    insert q;
  }

  @isTest
  static void testGetBookingWrapper() {
    Test.startTest();
    CC_BookingWrapper bwrapper = CC_QuoteController.getBookingWrapper();
    Test.stopTest();
    System.debug('returned result is :' + bwrapper);
    System.assertNotEquals(
      null,
      bwrapper,
      'BookingWrapper should not be null '
    );
  }
  /* @isTest static void testFetchLocation(){
        Location__c location=[Select Id from Location__c];
        String locId = location.Id;
        Test.startTest();
        List<Location__c> llocation = CC_QuoteController.fetchLocation(locId);
        Test.stopTest();
        System.debug('returned :'+llocation);
        System.assertEquals(1,llocation.size(),'This list contains one record');
    }*/

  @isTest
  static void testSubmitQuote() {
    String bowrap = TestDataUtility.bookingwrapper();
    String rwrap = TestDataUtility.responsewrapper();
    String sroutes = TestDataUtility.selectedroutes();
    String rmap = TestDataUtility.rateMapping();
    Test.startTest();
    CC_BookingWrapper bwrap = CC_QuoteController.submitQuote(
      bowrap,
      rwrap,
      sroutes,
      rmap
    );
    Test.stopTest();
    System.assertNotEquals(null, bwrap, 'should not be null');
  }
  @isTest
  static void testSendQuoteEmail() {
    String email = 'saurabh.sharma08@nagarro.com';
    String bwrap = TestDataUtility.bookingwrapper();
    Test.startTest();
    CC_QuoteController.sendQuoteEmail(email, bwrap);
    Test.stopTest();
  }
  @isTest
  static void testCreateQuoteData() {
    String bwrap = TestDataUtility.bookingwrapper();
    CC_BookingWrapper bkwrap = (CC_BookingWrapper) JSON.deserialize(
      bwrap,
      CC_BookingWrapper.class
    );
    Test.startTest();
    Quote__c quote = CC_QuoteController.createQuoteData(bkwrap);
    Test.stopTest();
    System.assertNotEquals(null, quote, 'should not be null');
  }
  /*  @isTest static void testCreateQuoteWithChargeLines(){
        String bowrap = TestDataUtility.bookingwrapper();
        String rwrap = TestDataUtility.responsewrapper();
        CC_BookingWrapper bwrapper = (CC_BookingWrapper) JSON.deserialize(bowrap, CC_BookingWrapper.class);
        CC_SoftshipRatingResponse rwrapper = (CC_SoftshipRatingResponse) JSON.deserialize(rwrap, CC_SoftshipRatingResponse.class);
        String sroutes = TestDataUtility.selectedroutes();
        String rmap = TestDataUtility.rateMapping();
        Test.startTest();
        CC_BookingWrapper bookingWrapper = CC_QuoteController.createQuoteWithChargeLines(bwrapper, rwrapper, sroutes, rmap);
        Test.stopTest();
        System.assertNotEquals(null, bookingWrapper, 'should not be null');
        
    }
*/
  @isTest
  static void testCreateShipmentRecord() {
    List<Quote__c> qu = [SELECT Id, Name, Status__c FROM Quote__c];
    String bwrap = TestDataUtility.bookingwrapper();
    CC_BookingWrapper bkwrap = (CC_BookingWrapper) JSON.deserialize(
      bwrap,
      CC_BookingWrapper.class
    );
    Test.startTest();
    Shipment__c ship = CC_QuoteController.createShipmentRecord(bkwrap, qu[0]);
    Test.stopTest();
    System.assertNotEquals(null, ship, 'should not be null');
  }
  @isTest
  static void testCreateFreightRecord() {
    String bwrap = TestDataUtility.bookingwrapper();
    CC_BookingWrapper bkwrap = (CC_BookingWrapper) JSON.deserialize(
      bwrap,
      CC_BookingWrapper.class
    );
    Test.startTest();
    List<FreightDetail__c> lfreightdetail = CC_QuoteController.createFreightRecord(
      bkwrap,
      'TestRecord'
    );
    Test.stopTest();
    System.assertNotEquals(null, lfreightdetail, 'should not be null');
  }
  @isTest
  static void testCreateRequirementAndCommodities() {
    String bwrap = TestDataUtility.bookingwrapper();
    CC_BookingWrapper bkwrap = (CC_BookingWrapper) JSON.deserialize(
      bwrap,
      CC_BookingWrapper.class
    );
    Test.startTest();
    CC_QuoteController.createRequirementAndCommodities(
      bkwrap,
      'TestRecord',
      'container'
    );
    Test.stopTest();
  }

  /*   @isTest static void testGetRates(){
        String bwrap = TestDataUtility.bookingwrapper();
        CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(bwrap, CC_BookingWrapper.class);
        CC_SoftshipRatingRequest ratingRequest= CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(bookingwrapper);
        System.debug('ratingRequest111--->'+ ratingRequest);
        String requestBody = JSON.serialize(ratingRequest, true);
        System.debug('requestBody--->'+ requestBody);
        
        List<String> label = new List<String>();
        label.add('Continuation-1');
         
        Test.startTest();
        APICalloutUtility.integrationServiceMdtMap = TestDataUtility.FindARoute_getIntegrationServiceTestMap();
        APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
        APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
        HttpRequest request = APICalloutUtility.createContinuationAPIRequest('FindARoutePOST', requestBody, null, '');
        System.debug('request---->'+request);
        System.assertNotEquals(null, request,'should not be null');
        
        Continuation conti = (Continuation)CC_QuoteController.getRates(bwrap);
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success":true}');
        System.debug('label--> '+label);
        System.debug('print response--> '+response);
        CC_SoftshipRatingResponse result = CC_QuoteController.processRatingResponse(label,null);
        Test.stopTest();
        System.debug('api result---->'+result);
        System.assertNotEquals(null, result, 'not be null');
        
    }
    @isTest static void testGetRates2(){
        String bwrap = TestDataUtility.bookingwrapper();
        String rwrap = TestDataUtility.responsewrapper();
        CC_SoftshipRatingResponse rwrapper = (CC_SoftshipRatingResponse) JSON.deserialize(rwrap, CC_SoftshipRatingResponse.class);
        System.debug('responsewrapper --'+rwrapper);
        CC_BookingWrapper bookingwrapper = (CC_BookingWrapper) JSON.deserialize(bwrap, CC_BookingWrapper.class);
        CC_SoftshipRatingRequest ratingRequest= CC_SoftshipRatingReqGenerate.getRatingRequestWrapper(bookingwrapper);
        System.debug('ratingRequest111--->'+ ratingRequest);
        String requestBody = JSON.serialize(ratingRequest, true);
        System.debug('requestBody--->'+ requestBody);
        
        List<String> label = new List<String>();
        label.add('Continuation-1');
         
        Test.startTest();
        APICalloutUtility.integrationServiceMdtMap = TestDataUtility.FindARoute_getIntegrationServiceTestMap();
        APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
        APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
        HttpRequest request = APICalloutUtility.createContinuationAPIRequest('FindARoutePOST', requestBody, null, '');
        System.debug('request---->'+request);
        System.assertNotEquals(null, request,'should not be null');
       
        Continuation conti = (Continuation)CC_QuoteController.getRates(bwrap);
        System.debug('conti-- '+conti);
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(rwrap); 
        System.debug('label--> '+label);
        System.debug('print response--> '+response);
        CC_SoftshipRatingResponse result = CC_QuoteController.processRatingResponse(label,conti);
        Test.stopTest();
        System.debug('api result---->'+result);
        System.assertNotEquals(null, result, 'not be null');        
    }
    */
  @isTest
  static void testCreateChildRecords() {
    String bwrap = TestDataUtility.bookingwrapper();
    CC_BookingWrapper bkwrap = (CC_BookingWrapper) JSON.deserialize(
      bwrap,
      CC_BookingWrapper.class
    );
    Quote__c qu = [SELECT Id, Name, Status__c FROM Quote__c];
    Test.startTest();
    CC_BookingWrapper returnRecords = CC_QuoteController.createChildRecords(
      bkwrap,
      qu
    );
    Test.stopTest();
    System.assertNotEquals(null, returnRecords, 'should not be null');
  }
  @isTest
  static void testQuoteForCaseCreation() {
    String bwrap = TestDataUtility.bookingwrapper();
    Test.startTest();
    CC_BookingWrapper returnRecords = CC_QuoteController.quoteForCaseCreation(
      bwrap
    );
    Test.stopTest();
    System.assertNotEquals(null, returnRecords, 'should not be null');
  }
  /*  @isTest static void testFetchSubLocation(){
        Test.startTest();
        List<Location__c> result = CC_QuoteController.fetchSubLocation('USQAT','PORT');
        Test.stopTest();
        System.debug('result '+result);
        System.assertEquals(1, result.size(),'size should be one');        
    }
    @isTest static void testFetchSubLocation2(){
        Test.startTest();
        List<Location__c> result = CC_QuoteController.fetchSubLocation('USQAT','RAIL RAMP');
        Test.stopTest();
        System.debug('result '+result);
        System.assertEquals(0, result.size(),'size should be zero');               
    }*/
  @isTest
  static void createCaseAndNotifyTest() {
    String bowrap = TestDataUtility.bookingwrapper();
    String rwrap = TestDataUtility.responsewrapper();
    String sroutes = TestDataUtility.selectedroutes();
    String rmap = TestDataUtility.rateMapping();
    Test.startTest();
    CC_QuoteController.createCaseAndNotify(bowrap, rwrap, sroutes, rmap);
    Test.stopTest();
  }
}
