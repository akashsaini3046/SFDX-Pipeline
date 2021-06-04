@isTest
private class CrowleyBookRecDetCtrlTest {
  @testSetup
  static void setup() {
    Booking__c booking = getBookingRecord(true);
    Shipment__c shipment = getShipmentRecord(booking.Id, true);
    Voyage__c voyage1 = getVoyageRecord(shipment.Id, true);
    Voyage__c voyage2 = getVoyageRecord(shipment.Id, true);
    Party__c party = getPartyRecord(booking.Id, true);
    Transport__c transport = getTransportRecord(booking.Id, true);
    Stop__c stop = getStopRecord(transport.Id, true);
  }

  @isTest
  static void getBookingDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'details'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getPartiesDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'parties'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getTransportDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'transports'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getStopDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'stops'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getShipmentDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'shipment'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getBookingRemarksDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'bookingRemarks'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getVoyageDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'voyages'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getFreightDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'freightDetails'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getCommodityDetailTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'commodities'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getDockReceiptsTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'dockReceipts'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getCustNotifTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'customerNotifications'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  @isTest
  static void getEquipmentsTest() {
    Test.startTest();
    Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
    Map<String, List<Map<String, String>>> result = CrowleyBookRecDetCtrl.getBookingDetail(
      booking.Id,
      'equipments'
    );
    System.assertNotEquals(null, result);
    Test.stopTest();
  }

  private static Booking__c getBookingRecord(Boolean isInsert) {
    Booking__c booking = new Booking__c(
      Booked_Date__c = Date.valueOf('2020-06-09'),
      Do_Not_Split__c = true,
      Booking_Number__c = 'CAT1234'
    );
    if (isInsert) {
      insert booking;
    }
    return booking;
  }

  private static Party__c getPartyRecord(Id bookingId, Boolean isInsert) {
    Party__c party = new Party__c(Booking__c = bookingId, Notify__c = true);
    if (isInsert) {
      insert party;
    }
    return party;
  }

  private static Transport__c getTransportRecord(
    Id bookingId,
    Boolean isInsert
  ) {
    Transport__c transport = new Transport__c(Booking__c = bookingId);
    if (isInsert) {
      insert transport;
    }
    return transport;
  }

  private static Stop__c getStopRecord(Id transportId, Boolean isInsert) {
    Stop__c stop = new Stop__c(
      Drop_Date__c = Date.valueOf('2020-06-09'),
      Drop_Pull__c = true,
      Transport__c = transportId
    );
    if (isInsert) {
      insert stop;
    }
    return stop;
  }

  private static Voyage__c getVoyageRecord(Id shipmentId, Boolean isInsert) {
    Voyage__c voyage = new Voyage__c(
      Name = 'Test Voyage',
      Shipment__c = shipmentId
    );
    if (isInsert) {
      insert voyage;
    }
    return voyage;
  }

  private static Shipment__c getShipmentRecord(Id bookingId, Boolean isInsert) {
    Shipment__c shipment = new Shipment__c(
      Name = 'Test Voyage',
      Booking__c = bookingId
    );
    if (isInsert) {
      insert shipment;
    }
    return shipment;
  }
}
