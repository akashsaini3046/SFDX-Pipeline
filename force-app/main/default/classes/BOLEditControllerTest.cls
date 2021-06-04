@isTest
public class BOLEditControllerTest {
  @testSetup
  static void setup() {
    List<Account> accounts = TestDataUtility.getAccountData(
      'NA',
      'DummyAcc',
      1,
      true
    );
    List<Booking__c> bookingList = TestDataUtility.getBookingWithChildren(
      accounts[0].Id,
      'BookingDesc',
      'FCL',
      '40 DS',
      1
    );
    bookingList[0].Bill_of_Lading_Number__c = '12345';
    update bookingList[0];
    TestDataUtility.getBillOfLading(bookingList[0], '12345', 1);
  }

  @isTest
  static void getTaxOptionsTest() {
    BOLEditController.getTaxOptions('Bill_Of_Lading__c', 'Route__c');
  }

  @isTest
  static void fetchPDFUrlTest() {
    String bookingId = [SELECT Id FROM Booking__c][0].Id;
    String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;
    BOLEditController.fetchPDFUrl(bookingId, bolId, 'abc');
  }
  @isTest
  static void getBolTest() {
    String bookingId = [SELECT Id FROM Booking__c][0].Id;
    String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;
    BOLEditController.getBol(bookingId, bolId, false);
  }

  /* @isTest
    static void saveBOLDataTest(){
        BOLEditController.BolView bolView = new BOLEditController.BolView();
        String bolViewString = JSON.serialize(bolView); 
        String bookingId = [SELECT Id FROM Booking__c][0].Id;
        String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;
        BOLEditController.saveBOLData(bolViewString,bookingId,bolId);
    }*/
}
