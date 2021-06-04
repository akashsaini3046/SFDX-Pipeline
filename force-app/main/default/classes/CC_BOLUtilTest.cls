@isTest
private class CC_BOLUtilTest {
  @TestSetup
  static void setup() {
    //create accounts
    List<Account> accounts = TestDataUtility.getAccountData(
      'NA',
      'AccTest',
      1,
      false
    );
    insert accounts;
    //create bookings
    List<Booking__c> bookings = TestDataUtility.getBookingRecords(
      accounts[0].Id,
      'DOOR To DOOR',
      1,
      false
    );
    bookings[0].Customer_Origin_State__c = 'Florida';
    bookings[0].Customer_Origin_Country__c = 'US';
    bookings[0].Customer_Origin_Code__c = 'USJAX';
    bookings[0].Customer_Destination_Code__c = 'USJAX';
    insert bookings;
    //create shipments
    List<Shipment__c> shipments = TestDataUtility.getShipmentRecords(
      bookings,
      1,
      false
    );
    shipments[0].Origin_Country__c = 'US';
    shipments[0].Origin_State__c = 'Florida';
    shipments[0].Origin_Code__c = 'originTest';
    insert shipments;
    //create bol
    /*Bill_Of_Lading__c bol = TestDataUtility.getBillOfLading(bookings[0], 'BOL001', 1);
        bol.Booking_Number__c = bookings[0].id;
        insert bol; */
    Bill_Of_Lading__c billOfLading = new Bill_Of_Lading__c();
    billOfLading.Bill_Of_Lading_Number__c = 'JAX1234';
    billOfLading.Booking_Number__c = bookings[0].Id;
    insert billOfLading;
    //create location
    List<Location__c> listlocations = TestDataUtility.CreateLocation(
      'Test Location',
      'BERTH',
      1,
      false
    );
    listlocations[0].Name = 'USJAX';
    listlocations[0].Location_Type__c = 'DOOR';
    insert listlocations;
    //create container
    Container__c c = TestDataUtility.CreateContainer(
      '20 Dry Container',
      '123',
      'NA',
      'NA',
      'NA'
    );
    c.Unit_Type__c = '2';
    insert c;
  }

  @isTest
  static void testSetLocationPointOfOrigin() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c
      FROM Booking__c
      LIMIT 1
    ];
    Shipment__c shipment = [
      SELECT id, Origin_Country__c, Origin_State__c, Origin_Code__c
      FROM Shipment__c
      LIMIT 1
    ];

    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setLocationPointOfOrigin(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }

  @isTest
  static void testGetLocationType1() {
    test.startTest();
    String locationType = CC_BOLUtil.getLocationType('D');
    test.stopTest();
    System.assertEquals(
      locationType,
      'DOOR',
      'returned location type is not correct'
    );
  }
  @isTest
  static void testGetLocationType2() {
    test.startTest();
    String locationType = CC_BOLUtil.getLocationType('R');
    test.stopTest();
    System.assertEquals(
      locationType,
      'RAIL RAMP',
      'returned location type is not correct'
    );
  }
  @isTest
  static void testGetLocationType3() {
    test.startTest();
    String locationType = CC_BOLUtil.getLocationType('P');
    test.stopTest();
    System.assertEquals(
      locationType,
      'PORT',
      'returned location type is not correct'
    );
  }

  @isTest
  static void testSetLocationPlaceOfReceipt1() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Origin_Code__c
      FROM Booking__c
      LIMIT 1
    ];
    booking.Description__c = 'R';
    Shipment__c shipment = [
      SELECT id, Origin_Country__c, Origin_State__c, Origin_Code__c
      FROM Shipment__c
      LIMIT 1
    ];

    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setLocationPlaceOfReceipt(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }
  @isTest
  static void testSetLocationPlaceOfReceipt2() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Origin_Code__c
      FROM Booking__c
      LIMIT 1
    ];
    booking.Description__c = 'P';
    Shipment__c shipment = [
      SELECT id, Origin_Country__c, Origin_State__c, Origin_Code__c
      FROM Shipment__c
      LIMIT 1
    ];

    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setLocationPlaceOfReceipt(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }
  @isTest
  static void testSetLocationPlaceOfReceipt3() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Origin_Code__c
      FROM Booking__c
      LIMIT 1
    ];
    Shipment__c shipment = [
      SELECT id, Origin_Country__c, Origin_State__c, Origin_Code__c
      FROM Shipment__c
      LIMIT 1
    ];
    booking.Description__c = 'D';
    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setLocationPlaceOfReceipt(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }

  @isTest
  static void testSetPlaceOfDelivery1() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Destination_Code__c
      FROM Booking__c
      LIMIT 1
    ];
    Shipment__c shipment = [
      SELECT id, Origin_Country__c, Origin_State__c, Origin_Code__c
      FROM Shipment__c
      LIMIT 1
    ];
    booking.Description__c = 'R';
    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setPlaceOfDelivery(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }
  @isTest
  static void testSetPlaceOfDelivery2() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Destination_Code__c
      FROM Booking__c
      LIMIT 1
    ];
    Shipment__c shipment = [
      SELECT id, Origin_Country__c, Origin_State__c, Origin_Code__c
      FROM Shipment__c
      LIMIT 1
    ];
    booking.Description__c = 'D';
    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setPlaceOfDelivery(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }
  @isTest
  static void testSetPlaceOfDelivery3() {
    Bill_Of_Lading__c bol = [
      SELECT
        id,
        Point_Of_Origin_Country__c,
        Point_Of_Origin_State__c,
        Point_Of_Origin_Description__c
      FROM Bill_Of_Lading__c
      LIMIT 1
    ];
    Booking__c booking = [
      SELECT
        id,
        Description__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Destination_Code__c
      FROM Booking__c
      LIMIT 1
    ];
    Shipment__c shipment = [
      SELECT
        id,
        Origin_Country__c,
        Origin_State__c,
        Origin_Code__c,
        Destination_Code__c
      FROM Shipment__c
      LIMIT 1
    ];
    shipment.Destination_Code__c = 'PRSJU';
    booking.Description__c = 'P';
    test.startTest();
    Bill_Of_Lading__c bolLocationPoint = CC_BOLUtil.setPlaceOfDelivery(
      bol,
      booking,
      shipment
    );
    test.stopTest();
    System.assertNotEquals(null, bolLocationPoint.id, 'BOL should not be null');
  }
  /*
    @isTest static void testGetEquipmentUnitTypeMap() {
        test.startTest();
        Map<String, String> equipmentUnitType = CC_BOLUtil.getEquipmentUnitTypeMap();
        test.stopTest();
        System.assertNotEquals(null, equipmentUnitType, 'returned value should not be null');
    }
*/
}
