@isTest
public class PartyDAOTest {
  @testSetup
  static void setup() {
    List<Account> listAccounts = TestDataUtility.createAccount(
      'Account DataTest',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;

    List<Id> accIds = new List<Id>();
    for (Account acc : listAccounts) {
      accIds.add(acc.Id);
    }

    List<Booking__c> listbookings = TestDataUtility.CreateBooking(
      accIds,
      '',
      1
    );
    insert listbookings;

    List<Party__c> listParties = TestDataUtility.CreateParty(
      accIds,
      'Test Party',
      1
    );
    for (Party__c partyobj : listParties) {
      for (Booking__c bkg : listbookings) {
        partyobj.Booking__c = bkg.Id;
      }
    }
    insert listParties;
  }

  @isTest
  static void TestgetPartyDetails() {
    List<Party__c> parties = [SELECT Id FROM Party__c];
    Set<Id> partyIds = new Set<Id>();
    for (Party__c pt : parties) {
      partyIds.add(pt.Id);
    }
    Test.startTest();
    List<Party__c> partylist = PartyDAO.getPartyDetails(partyIds);
    Test.stopTest();
    System.assertEquals(1, partylist.size(), 'This list contains one record');
  }

  @isTest
  static void NegativeTestgetPartyDetails() {
    Set<Id> partyIds = new Set<Id>();
    Test.startTest();
    List<Party__c> partylist = PartyDAO.getPartyDetails(partyIds);
    Test.stopTest();
    System.assertEquals(
      0,
      partylist.size(),
      'This list does not contain any record'
    );
  }

  @isTest
  static void TestgetPartyDetailsByBooking() {
    List<Booking__c> bookinglist = [SELECT Id FROM Booking__c];
    Set<Id> bookingIds = new Set<Id>();
    for (Booking__c bkg : bookinglist) {
      bookingIds.add(bkg.Id);
    }
    Test.startTest();
    List<Party__c> partylist = PartyDAO.getPartyDetailsByBooking(bookingIds);
    Test.stopTest();
    System.assertEquals(1, partylist.size(), 'This list contains one record');
  }

  @isTest
  static void NegativeTestgetPartyDetailsByBooking() {
    Set<Id> bookingIds = new Set<Id>();
    Test.startTest();
    List<Party__c> partylist = PartyDAO.getPartyDetailsByBooking(bookingIds);
    Test.stopTest();
    System.assertEquals(
      0,
      partylist.size(),
      'This list does not contain any record'
    );
  }
}
