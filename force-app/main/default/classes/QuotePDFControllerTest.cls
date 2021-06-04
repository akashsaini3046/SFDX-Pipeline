@isTest
public class QuotePDFControllerTest {
  @testSetup
  static void setup() {
    List<Quote__c> listquotes = TestDataUtility.CreateQuote(2);

    for (Quote__c quote : listquotes) {
      quote.Description__c = 'DP';
    }
    listquotes[1].Description__c = '2';
    insert listquotes;

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
      true
    );

    //create shipments
    List<Shipment__c> shipments = TestDataUtility.getShipmentRecords(
      booking,
      2,
      false
    );

    shipments[0].Quote__c = listquotes[0].id;
    shipments[1].Quote__c = listquotes[1].id;
    insert shipments;

    //create freightdetail
    List<FreightDetail__c> freightdetail = TestDataUtility.CreateFreightDetail(
      shipments,
      2
    );
    freightdetail[0].Cargo_Type__c = 'EQUIP';
    freightdetail[0].Shipment__c = shipments[0].id;
    freightdetail[1].Cargo_Type__c = 'BBULK';
    freightdetail[1].Shipment__c = shipments[1].id;

    insert freightdetail;

    //create requirement
    List<Requirement__c> requirements = TestDataUtility.getRequirementRecords(
      freightdetail,
      1,
      false
    );
    requirements[0].Container_Type__c = '20 Dry Container';
    requirements[0].Quantity__c = 2;
    insert requirements;

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

    List<Charge_Line__c> listChargeLines = new List<Charge_Line__c>();
    for (Quote__c quote : listquotes) {
      listChargeLines.addall(TestDataUtility.CreateChargeLine(quote.Id, 2));
    }
    insert listChargeLines;
  }

  @isTest
  static void QuotePDFControllerTest1() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    List<Shipment__c> shipments = [SELECT Id, Quote__c FROM Shipment__c];
    List<FreightDetail__c> freightdetail = [
      SELECT Id, Cargo_Type__c, Shipment__c
      FROM FreightDetail__c
      WHERE Cargo_Type__c = 'EQUIP'
    ];
    Test.startTest();
    PageReference pageRef = Page.QuoteRecordPDF;
    pageRef.getParameters().put('Id', String.valueOf(quote1.Id));
    Test.setCurrentPage(pageRef);
    QuotePDFController pdfctrl = new QuotePDFController();
    pdfctrl.downloadPDF();
    Test.stopTest();
    System.assert(pdfctrl != null);
  }

  @isTest
  static void QuotePDFControllerTest2() {
    Quote__c quote1 = [
      SELECT Id, Description__c
      FROM Quote__c
      WHERE Description__c = '2'
      LIMIT 1
    ];

    Shipment__c shipments = [
      SELECT Id, Quote__c
      FROM Shipment__c
      WHERE Quote__c = :quote1.id
      LIMIT 1
    ];

    List<FreightDetail__c> freightdetail = [
      SELECT Id, Cargo_Type__c, Shipment__c
      FROM FreightDetail__c
      WHERE FreightDetail__c.Shipment__r.Quote__c = :quote1.id
      LIMIT 1
    ];

    for (FreightDetail__c fw : freightdetail) {
      fw.Vehicle_Name__c = 'Bike';
      fw.Package_Type__c = 'PVEH';
      fw.Freight_Quantity__c = 2;
    }
    update freightdetail;
    Test.startTest();
    PageReference pageRef = Page.QuoteRecordPDF;
    pageRef.getParameters().put('Id', String.valueOf(quote1.Id));
    Test.setCurrentPage(pageRef);
    QuotePDFController pdfctrl = new QuotePDFController();
    pdfctrl.downloadPDF();
    Test.stopTest();
    System.assert(pdfctrl != null);
  }

  @isTest
  static void QuotePDFControllerTest3() {
    List<Quote__c> quote1 = TestDataUtility.CreateQuote(1);
    insert quote1;

    List<Booking__c> booking = [SELECT Id, Name FROM Booking__c];

    List<Shipment__c> shipments = TestDataUtility.getShipmentRecords(
      booking,
      1,
      false
    );
    shipments[0].Quote__c = quote1[0].id;
    insert shipments;

    List<FreightDetail__c> freightdetail = TestDataUtility.CreateFreightDetail(
      shipments,
      1
    );
    freightdetail[0].Cargo_Type__c = 'BBUlK';
    freightdetail[0].Shipment__c = shipments[0].id;
    freightdetail[0].Package_Type__c = 'BOAT';
    insert freightdetail;
    Test.startTest();
    PageReference pageRef = Page.QuoteRecordPDF;
    pageRef.getParameters().put('Id', String.valueOf(quote1[0].Id));
    Test.setCurrentPage(pageRef);
    QuotePDFController pdfctrl = new QuotePDFController();
    pdfctrl.downloadPDF();
    Test.stopTest();
    System.assert(pdfctrl != null);
  }
}
