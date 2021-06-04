@isTest
public class CC_QuoteUtilityTest {
  @testSetup
  static void setup() {
    List<Account> accounts = TestDataUtility.getAccountData(
      'NA',
      'AccTest',
      1,
      true
    );
    List<Booking__c> booking = TestDataUtility.getBookingRecords(
      accounts[0].Id,
      'Test Booking',
      1,
      false
    );
    booking[0].Booking_Number__c = 'CAT1234598aas';
    insert booking;
    List<Quote__c> listquotes = TestDataUtility.CreateQuote(2);

    listquotes[0].Description__c = 'DP';
    listquotes[0].Customer_Origin_Country__c = 'Uk,';
    listquotes[1].Customer_Origin_Country__c = 'US';
    insert listquotes;

    //Create charge line
    List<Charge_Line__c> chargeline = TestDataUtility.CreateChargeLine(
      listquotes[0].id,
      1
    );
    chargeline[0].Booking__c = booking[0].id;
    insert chargeline;

    //create shipments
    List<Shipment__c> shipments = TestDataUtility.getShipmentRecords(
      booking,
      1,
      false
    );
    shipments[0].Quote__c = listquotes[0].id;
    insert shipments;

    //create
    List<FreightDetail__c> freightdetail = TestDataUtility.CreateFreightDetail(
      shipments,
      1
    );
    freightdetail[0].Cargo_Type__c = 'EQUIP';
    insert freightdetail;

    //create container
    Container__c c = TestDataUtility.CreateContainer(
      '20 Dry Container',
      '123',
      'NA',
      'NA',
      'NA'
    );
    c.CICS_ISO_Code__c = 'BB83';
    insert c;
  }

  @isTest
  static void TestgetQuoteDetails() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    CC_QuoteUtility.QuoteWrapper qWrap = CC_QuoteUtility.getQuoteDetails(
      quote1.Id,
      true
    );
    Test.stopTest();
    system.assert(
      qWrap.orgDestVsMovementType.get('destination') == 'Port',
      'check destination'
    );
  }

  @isTest
  static void TestgetQuoteDetails2() {
    Quote__c quote1 = [
      SELECT Id
      FROM Quote__c
      WHERE Customer_Origin_Country__c = 'US'
      LIMIT 1
    ];
    Test.startTest();
    quote1.Description__c = 'PD';
    update quote1;
    CC_QuoteUtility.QuoteWrapper qWrap = CC_QuoteUtility.getQuoteDetails(
      quote1.Id,
      false
    );
    Test.stopTest();
    system.assert(
      qWrap.orgDestVsMovementType.get('origin') == 'Port',
      'check origin'
    );
    system.debug(qWrap.orgDestVsMovementType.get('origin') == 'Port');
  }
}
