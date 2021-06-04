@isTest
public class CC_BillOfLadingVFControllerTest {
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
  static void setInvoiceDataForPDFTest() {
    String bookingId = [SELECT Id FROM Booking__c][0].Id;
    String bolId = [SELECT Id FROM Bill_Of_Lading__c][0].Id;

    Test.startTest();
    Test.setCurrentPageReference(new PageReference('Page.myPage'));
    System.currentPageReference().getParameters().put('bolId', bolId);
    System.currentPageReference().getParameters().put('bookingId', bookingId);
    CC_BillOfLadingVFController bolvf = new CC_BillOfLadingVFController();
    Test.stopTest();
  }
}
