@isTest(SeeAllData=false)
private class CC_FetchBOLUtilTest {
  static Party__c getParty(
    String bookingPartyId,
    String billOfLadingId,
    String Type
  ) {
    Party__c bolParty = new Party__c();
    bolParty.Bill_Of_Lading_Number__c = billOfLadingId;
    bolParty.Booking_Party__c = bookingPartyId;
    bolParty.Reference_Number__c = 'ref1,ref2';
    bolParty.Type__c = Type;
    return bolParty;
  }

  static Booking__c getBooking(String bookingNumber) {
    Booking__c booking = new Booking__c();
    booking.Booking_Number__c = bookingNumber;
    return booking;
  }

  static Shipment__c getShipment(String bookingId) {
    Shipment__c shipment = new Shipment__c();
    shipment.Booking__c = bookingId;
    return shipment;
  }

  static Container__c getContainer() {
    Container__c container = new Container__c();
    container.Name = '40DS';
    container.CICS_EQ_Types__c = 'test';
    container.CICS_ISO_Code__c = 'test';
    container.CICS_EQ_Types__c = 'Description__c';
    return container;
  }

  static Voyage__c getVoyage(String shipmentId, String billOfLadingId) {
    Voyage__c voyage = new Voyage__c();
    voyage.Voyage_Number__c = '123';
    voyage.Vessel_Name__c = '123';
    voyage.Shipment__c = shipmentId;
    voyage.Bill_Of_Lading_Number__c = billOfLadingId;
    return voyage;
  }

  static Bill_Of_Lading__c getBillOfLading(String bookingId) {
    Bill_Of_Lading__c billOfLading = new Bill_Of_Lading__c();
    billOfLading.Bill_Of_Lading_Number__c = 'JAX1234';
    billOfLading.Booking_Number__c = bookingId;
    billOfLading.ITN_Number__c = '123';
    billOfLading.Secoundry_ITN_Number__c = '123,456';
    billOfLading.IE_Inbound_Number__c = '123';
    billOfLading.Consignee_Reference_Number__c = '123';
    return billOfLading;
  }

  static Equipment__c getEquipment(String billOfLadingId) {
    Equipment__c equipment = new Equipment__c();
    equipment.Bill_Of_Lading_Number__c = billOfLadingId;
    equipment.Unit_of_Measure_for_Cargo_Weight__c = 'KG';
    equipment.VMG_Scale_Weight_Kilo__c = '10';
    equipment.Seal_Numbers__c = '10,20,30';
    equipment.Equipment_Number_Copy__c = 'Unique1';
    equipment.Number__c = '1';
    return equipment;
  }

  static Bill_Item__c getBillItem(String billOfLadingId) {
    Bill_Item__c objBillItem = new Bill_Item__c();
    objBillItem.Bill_Of_Lading_Number__c = billOfLadingId;
    objBillItem.Secondary_Schedule_B_Number__c = '12,23,32';
    objBillItem.Schedule_B_Number__c = 'HTS Name';
    return objBillItem;
  }

  static HTS_Master__c getHts() {
    HTS_Master__c hts = new HTS_Master__c();
    hts.Type__c = 'type1';
    hts.Name = 'HTS Name';
    hts.Description__c = 'Description';
    insert hts;
    return hts;
  }

  static Commodity__c getCommodity(String billItemId) {
    Commodity__c commodity = new Commodity__c();
    commodity.Equipment_Number_Copy__c = 'Unique1';
    commodity.Bill_Item__c = billItemId;
    commodity.Dock_Receipt_Number__c = '12,32,21';
    return commodity;
  }

  static Charge_Line__c getChargeLine(String billOfLadingId) {
    Charge_Line__c objChargeLine = new Charge_Line__c();
    objChargeLine.Bill_Of_Lading_Number__c = billOfLadingId;
    objChargeLine.Item_Name__c = 'Text';
    return objChargeLine;
  }

  static testMethod void CC_FetchBOLUtilTest() {
    HTS_Master__c hts = getHts();

    Container__c container = getContainer();
    insert container;

    Booking__c booking = getBooking('CAT1234');
    insert booking;

    Shipment__c shipment = getShipment(booking.Id);
    insert shipment;
    Voyage__c oldVoyage = getVoyage(shipment.Id, null);
    insert oldVoyage;

    Bill_Of_Lading__c billOfLading = getBillOfLading(booking.Id);
    insert billOfLading;

    Equipment__c equipment = getEquipment(billOfLading.Id);
    insert equipment;

    Bill_Item__c objBillItem = getBillItem(billOfLading.Id);
    insert objBillItem;

    Commodity__c commodity = getCommodity(objBillItem.Id);
    insert commodity;

    Charge_Line__c objChargeLine = getChargeLine(billOfLading.Id);
    insert objChargeLine;

    Voyage__c voyage = getVoyage(null, billOfLading.Id);
    insert voyage;

    Party__c bookingParty = getParty(null, null, 'CON');
    bookingParty.Booking__c = booking.Id;
    insert bookingParty;

    List<Party__c> bolPartyLst = new List<Party__c>();
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'CON'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'SHP'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'NOT'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'NO2'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'FOR'));
    insert bolPartyLst;

    CC_FetchBOLUtil fetchBOLUtil = new CC_FetchBOLUtil();
    Test.startTest();
    BOLEditController.BolView objBolView = fetchBOLUtil.fetchBOLData(
      booking.Id,
      billOfLading.Id,
      true
    );
    Test.stopTest();
  }
  static testMethod void CC_FetchBOLUtilFalseTest() {
    HTS_Master__c hts = getHts();

    Container__c container = getContainer();
    insert container;

    Booking__c booking = getBooking('CAT1234');
    insert booking;

    Shipment__c shipment = getShipment(booking.Id);
    insert shipment;
    Voyage__c oldVoyage = getVoyage(shipment.Id, null);
    insert oldVoyage;

    Bill_Of_Lading__c billOfLading = getBillOfLading(booking.Id);
    insert billOfLading;

    Equipment__c equipment = getEquipment(billOfLading.Id);
    equipment.Unit_of_Measure_for_Cargo_Weight__c = 'LB';
    equipment.VGM_Scale_Weight_Pounds__c = '10';
    equipment.VMG_Scale_Weight_Kilo__c = null;
    equipment.Unit_of_measure_Temperature_1__c = 'C';
    insert equipment;

    Bill_Item__c objBillItem = getBillItem(billOfLading.Id);
    insert objBillItem;

    Commodity__c commodity = getCommodity(objBillItem.Id);
    insert commodity;

    Charge_Line__c objChargeLine = getChargeLine(billOfLading.Id);
    insert objChargeLine;

    Voyage__c voyage = getVoyage(null, billOfLading.Id);
    insert voyage;

    Party__c bookingParty = getParty(null, null, 'CON');
    bookingParty.Booking__c = booking.Id;
    insert bookingParty;

    List<Party__c> bolPartyLst = new List<Party__c>();
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'CON'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'SHP'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'NOT'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'NO2'));
    bolPartyLst.add(getParty(bookingParty.Id, billOfLading.Id, 'FOR'));
    insert bolPartyLst;

    CC_FetchBOLUtil fetchBOLUtil = new CC_FetchBOLUtil();
    Test.startTest();
    BOLEditController.BolView objBolView = fetchBOLUtil.fetchBOLData(
      booking.Id,
      billOfLading.Id,
      false
    );
    Test.stopTest();
  }
  static testMethod void CC_FetchBOLUtilNoDataTest() {
    HTS_Master__c hts = getHts();

    Container__c container = getContainer();
    insert container;

    Booking__c booking = getBooking('CAT1234');
    insert booking;

    Shipment__c shipment = getShipment(booking.Id);
    insert shipment;
    Voyage__c oldVoyage = getVoyage(shipment.Id, null);
    insert oldVoyage;

    Bill_Of_Lading__c billOfLading = getBillOfLading(booking.Id);
    insert billOfLading;

    Charge_Line__c objChargeLine = getChargeLine(billOfLading.Id);
    insert objChargeLine;

    Voyage__c voyage = getVoyage(null, billOfLading.Id);
    insert voyage;

    CC_FetchBOLUtil fetchBOLUtil = new CC_FetchBOLUtil();
    Test.startTest();
    BOLEditController.BolView objBolView = fetchBOLUtil.fetchBOLData(
      booking.Id,
      billOfLading.Id,
      false
    );
    Test.stopTest();
  }
}
