@isTest
public class BookingDAOTest {
  @testSetup
  static void setup() {
    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Acc',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;

    BookingTriggerHandler.recursionVarBeforeUpdate = false;
    BookingTriggerHandler.recursionVarBeforeInsert = false;

    List<Booking__c> bookings = TestDataUtility.getBookingWithChildren(
      listAccounts[0].id,
      'BookingDesc',
      'FCL',
      '40 DS',
      1
    );

    List<Shipment__c> shipments = TestDataUtility.getShipmentRecords(
      bookings,
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
    requirements[0].Container_Type__c = 'BB4C';

    List<Quote__c> listquotes = TestDataUtility.CreateQuote(1);
    insert listquotes;
    List<Charge_Line__c> listChargeLines = TestDataUtility.CreateChargeLine(
      listquotes[0].id,
      1
    );
    listChargeLines[0].Booking__c = bookings[0].id;
    insert listChargeLines;
    TestDataUtility.getPartyRecords(bookings, 'CARGO', 1, true);
    List<Transport__c> transport = TestDataUtility.getTransportRecords(
      bookings,
      1,
      true
    );
    List<Stop__c> stop = TestDataUtility.getStopRecords(transport, 1, true);
  }

  @istest
  public static void TestgetBookingDetails() {
    List<Booking__c> bookings = [SELECT Id, Account__c FROM Booking__c];
    system.debug(bookings);
    Set<Id> bookingIds = new Set<Id>();
    for (Booking__c bk : bookings) {
      bookingIds.add(bk.Id);
    }
    Test.startTest();
    List<Booking__c> bookinglist = BookingDAO.getBookingDetails(bookingIds);
    Test.stopTest();
    system.debug(bookinglist);
    System.assertEquals(1, bookinglist.size(), 'This list contains one record');
  }

  @istest
  public static void NegativeTestgetBookingDetails() {
    Booking__c bookings = new Booking__c();
    Test.startTest();
    List<Booking__c> bookinglist = BookingDAO.getBookingDetails(
      new Set<Id>{ bookings.Id }
    );
    Test.stopTest();
    System.assertEquals(
      0,
      bookinglist.size(),
      'This list does not contain any record'
    );
  }

  @istest
  public static void TestgetBookingByQuery() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    system.debug(acc);
    String query = 'SELECT id,Account__c FROM Booking__c limit 1';
    Test.startTest();
    List<Booking__c> bookinglist = BookingDAO.getBookingByQuery(
      query,
      new List<Id>{ acc.Id }
    );
    Test.stopTest();
    system.debug(bookinglist);
    System.assertEquals(1, bookinglist.size(), 'This list contains one record');
  }

  @istest
  public static void NegativeTestgetBookingByQuery() {
    String query = 'SELECT id,Account__c FROM Booking__c WHERE Account__c in: accountIds';
    Test.startTest();
    List<Booking__c> bookinglist = BookingDAO.getBookingByQuery(
      query,
      new List<Id>{}
    );
    Test.stopTest();
    system.debug(bookinglist);
    System.assertEquals(
      0,
      bookinglist.size(),
      'This list does not contain any record'
    );
  }

  @istest
  public static void TestgetShipmentByOriginDestinationCode() {
    List<Shipment__c> shipments;
    Test.startTest();
    shipments = BookingDAO.getShipmentByOriginDestinationCode(
      new List<String>{ 'Loc Dummy' },
      new List<String>{ 'Loc Dummy 1' }
    );
    Test.stopTest();
    System.assertEquals(3, shipments.size(), 'This list contains two records');
  }

  @istest
  public static void TestgetShipmentByBookingIds() {
    Booking__c bookings = [SELECT Id FROM Booking__c];
    List<Shipment__c> shipments;
    Test.startTest();
    shipments = BookingDAO.getShipmentByBookingIds(new Set<Id>{ bookings.Id });
    Test.stopTest();
    System.assertEquals(3, shipments.size(), 'This list contains two records');
  }

  @isTest
  static void getVoyagesByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();

    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Voyage__c> voyages = BookingDAO.getVoyagesByBookingIds(bookingIds);
    Test.stopTest();

    System.assertEquals(4, voyages.size(), 'This list contains four records');
  }
  @isTest
  static void getCommoditiesByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();

    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Commodity__c> commodities = BookingDAO.getCommoditiesByBookingIds(
      bookingIds
    );
    Test.stopTest();

    System.assertEquals(
      4,
      commodities.size(),
      'This list contains one records'
    );
  }

  @isTest
  static void getStopsCountByBookingIdTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);

    Test.startTest();
    List<AggregateResult> stops = BookingDAO.getStopsCountByBookingId(
      bookingIds
    );
    Test.stopTest();

    System.assertEquals(1, stops.size(), 'This list contains one record');
  }

  @isTest
  static void getRequirementsByContainerTypeTest() {
    Test.startTest();
    List<Requirement__c> requirements = BookingDAO.getRequirementsByContainerType(
      '40 DS'
    );
    Test.stopTest();
    System.debug('requirements ' + requirements);
    System.assertEquals(
      2,
      requirements.size(),
      'This list contains two records'
    );
  }

  @isTest
  static void getTotalBookingsByQueryAccountIdsTest() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Test Acc'];
    List<Id> accountIds = new List<Id>();
    accountIds.add(acc.id);
    System.debug(acc.id);
    string query = 'Select Count(Id) Total from Booking__c where Account__c IN: accountIds';
    System.debug('@@@@@');
    System.debug([SELECT id, Account__c FROM Booking__c]);
    Test.startTest();
    Integer bookingCount = BookingDAO.getTotalBookingsByQueryAccountIds(
      query,
      accountIds
    );
    Test.stopTest();

    System.assertEquals(1, bookingCount, 'Count does not match');
  }
  //Added by @mounika
  @isTest
  static void getRequirementsByCommodityNameTest() {
    Test.startTest();
    List<Requirement__c> requirements = BookingDAO.getRequirementsByCommodityName(
      'Cargo, NOS'
    );
    Test.stopTest();
    System.debug('requirements ' + requirements);
    System.assertEquals(1, requirements.size(), 'This list contains record');
  }

  @isTest
  static void getRequirementByFreightDetailIdsTest() {
    FreightDetail__c fdetail = [SELECT Id FROM FreightDetail__c LIMIT 1];
    Test.startTest();
    List<Requirement__c> requirements = BookingDAO.getRequirementByFreightDetailIds(
      new Set<Id>{ fdetail.Id }
    );
    Test.stopTest();
    System.debug('requirements ' + requirements);
    System.assertEquals(1, requirements.size(), 'This list contains record');
  }

  @isTest
  static void getVoyageswithBookingIdsbyVessalNameTest() {
    Test.startTest();
    List<Voyage__c> voyage = BookingDAO.getVoyageswithBookingIdsbyVessalName(
      'Paradero'
    );
    Test.stopTest();
    System.debug('voyage ' + voyage);
    System.assertEquals(0, voyage.size(), 'This list contains zero records');
  }

  @isTest
  static void getFreightDetailsByCommodityNameTest() {
    Test.startTest();
    List<FreightDetail__c> freightdetail = BookingDAO.getFreightDetailsByCommodityName(
      'Cargo, NOS'
    );
    Test.stopTest();
    System.debug('freightdetail ' + freightdetail);
    System.assertEquals(
      3,
      freightdetail.size(),
      'This list contains three record'
    );
  }

  @isTest
  static void getCommodityByFreightDetailIdsTest() {
    FreightDetail__c fdetail = [SELECT Id FROM FreightDetail__c LIMIT 1];
    Test.startTest();
    List<Commodity__c> Commodity = BookingDAO.getCommodityByFreightDetailIds(
      new Set<Id>{ fdetail.Id }
    );
    Test.stopTest();
    System.debug('Commodity ' + Commodity);
    System.assertEquals(2, Commodity.size(), 'This list contains two records');
  }

  @isTest
  static void getChargelinesByBookingIdTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Charge_Line__c> chargeline = BookingDAO.getChargelinesByBookingId(
      bookingIds
    );
    Test.stopTest();
    System.debug('chargeline ' + chargeline);
    System.assertEquals(1, chargeline.size(), 'This list contains one record');
  }

  @isTest
  static void getPartyTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Party__c> party = BookingDAO.getPartyDetails(bookingIds);
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(6, party.size(), 'This list contains one record');
  }

  @isTest
  static void getFreightDetailsByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<FreightDetail__c> party = BookingDAO.getFreightDetailsByBookingIds(
      bookingIds
    );
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(3, party.size(), 'This list contains one record');
  }
  @isTest
  static void getRequirementsByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Requirement__c> party = BookingDAO.getRequirementsByBookingIds(
      bookingIds
    );
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(3, party.size(), 'This list contains one record');
  }

  @isTest
  static void getEquipmentsByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Equipment__c> party = BookingDAO.getEquipmentsByBookingIds(bookingIds);
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(2, party.size(), 'This list contains one record');
  }

  @isTest
  static void getStopDetailsByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Stop__c> party = BookingDAO.getStopDetailsByBookingIds(bookingIds);
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(3, party.size(), 'This list contains one record');
  }

  @isTest
  static void getTransportsByBookingIdsTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Transport__c> party = BookingDAO.getTransportsByBookingIds(bookingIds);
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(2, party.size(), 'This list contains one record');
  }

  @isTest
  static void getBookingRemarksTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<Booking_Remark__c> party = BookingDAO.getBookingRemarks(bookingIds);
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(0, party.size(), 'This list contains one record');
  }

  @isTest
  static void getFilesbyBookingIdTest() {
    List<Booking__c> bookings = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    bookingIds.add(bookings[0].Id);
    Test.startTest();
    List<ContentVersion> party = BookingDAO.getFilesbyBookingId(bookings[0].Id);
    Test.stopTest();
    System.debug('party ' + party);
    System.assertEquals(0, party.size(), 'This list contains one record');
  }
}
