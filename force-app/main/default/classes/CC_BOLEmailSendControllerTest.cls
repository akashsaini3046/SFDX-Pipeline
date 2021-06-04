@isTest
public class CC_BOLEmailSendControllerTest {
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
  static void sendEmailTest1() {
    String bookingId = [SELECT Id FROM Booking__c][0].Id;
    String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;
    CC_BOLEmailSendController.sendEmail(
      'abc@g.com',
      bookingId,
      bolId,
      'xyz',
      'Bill of Lading',
      'CC_BOL_For_Release'
    );
  }

  @isTest
  static void sendEmailTest2() {
    String bookingId = [SELECT Id FROM Booking__c][0].Id;
    String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;
    CC_BOLEmailSendController.sendEmail(
      'abc@g.com',
      bookingId,
      bolId,
      'xyz',
      'Shipping Instruction',
      'CC_BOL_For_Release'
    );
  }
}
