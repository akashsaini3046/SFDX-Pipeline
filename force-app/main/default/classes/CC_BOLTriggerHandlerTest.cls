@isTest
public class CC_BOLTriggerHandlerTest {
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
  static void updateBOLNumberAsUsedTest() {
    Bill_Of_Lading__c bol = [
      SELECT Id, Bill_Of_Lading_Number__c
      FROM Bill_Of_Lading__c
    ][0];
    bol.Bill_Of_Lading_Number__c = '78965';
    update bol;
  }

  @isTest
  static void deleteBOLTest() {
    Bill_Of_Lading__c bol = [
      SELECT Id, Bill_Of_Lading_Number__c
      FROM Bill_Of_Lading__c
    ][0];
    System.debug('bol ' + bol);
    delete bol;
    List<Bill_Of_Lading__c> bol2 = [
      SELECT Id, Bill_Of_Lading_Number__c
      FROM Bill_Of_Lading__c
    ];
    System.debug('bol2 ' + bol2);
  }
  @isTest
  static void withoutShareTest() {
    Bill_Of_Lading__c bol = [
      SELECT Id, Bill_Of_Lading_Number__c
      FROM Bill_Of_Lading__c
    ][0];
    System.debug('bol ' + bol);
    delete bol;
    List<Booking__c> booking = [SELECT Id FROM Booking__c];
    BOL_Number__c bolNumber = new BOL_Number__c();
    bolNumber.Name = 'JAX001';
    //bolNumber.Is_Used__c =  true;
    insert bolNumber;
    CC_BOLTriggerWithoutShareUtil.generateBOLNumber(booking[0].Id);
    //System.debug('bol2 '+bol2);
  }
}
