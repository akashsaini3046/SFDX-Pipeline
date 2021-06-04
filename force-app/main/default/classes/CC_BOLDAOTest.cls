@isTest(SeeAllData=false)
private class CC_BOLDAOTest {
  static testMethod void CC_BOLDAOTest() {
    CC_BOLDAO BOLDAO = new CC_BOLDAO();
    Test.startTest();
    CC_BOLDAO.getBOLNumberFromBucket();
    CC_BOLDAO.getBolWithBooking(null);
    CC_BOLDAO.getBooking(null);
    CC_BOLDAO.getShipment(null);
    CC_BOLDAO.getDockReceipt(null);
    //CC_BOLDAO.getLocation(null);
    CC_BOLDAO.getRequirements(null);
    CC_BOLDAO.getBookingForCompare(null);
    CC_BOLDAO.getShipmentForCompare(null);
    CC_BOLDAO.getBOL(null, true);
    CC_BOLDAO.getBOL(null, false);
    CC_BOLDAO.getBolParty(null);
    CC_BOLDAO.getBillItems(null);
    CC_BOLDAO.getHTS(null);
    CC_BOLDAO.getOldVoyage(null);
    CC_BOLDAO.getCommodities(null);
    CC_BOLDAO.getChargeLine(null);

    Test.stopTest();
  }
}
