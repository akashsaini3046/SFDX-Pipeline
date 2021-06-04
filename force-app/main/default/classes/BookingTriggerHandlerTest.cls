@isTest
public class BookingTriggerHandlerTest {
  @testSetup
  static void setup() {
    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;

    List<Account> listAccounts1 = TestDataUtility.createAccount(
      'Account DataTest',
      'Customer',
      'Apparel',
      null,
      false,
      1
    );
    insert listAccounts1;

    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      listAccounts,
      'Business Location11',
      'City11',
      'CA',
      '1134111',
      '86788888888',
      'US',
      1
    );
    insert businessLocationObj;
    List<Contact> con2 = TestDataUtility.createContact(
      null,
      listAccounts,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert con2;

    List<Opportunity> listOpp = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con2,
      listAccounts,
      ConstantClass.PROSPECTING_OPP_STAGE,
      null,
      System.today(),
      null,
      'CrowleyFresh;',
      null,
      false,
      1
    );
    insert listOpp;

    List<Contract> contractObj = TestDataUtility.getContract(
      listAccounts,
      null,
      2,
      null,
      listOpp,
      null,
      null,
      1
    );
    insert contractObj;
  }

  @isTest
  static void insertBooking() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Contract contrct = [
      SELECT Id, ContractNumber, AccountId
      FROM Contract
      WHERE AccountId = :acc.Id
    ];
    system.debug(contrct);
    Test.startTest();
    List<Booking__c> listBookings = TestDataUtility.CreateBooking(
      new List<Id>{ acc.Id },
      contrct.ContractNumber,
      2
    );
    insert listBookings;
    system.debug(listbookings);
    Test.stopTest();
    List<Booking__c> totalBookings = [SELECT Id FROM Booking__c];
    system.assertEquals(totalBookings.size(), 2);
  }

  /* @isTest
    static void NullCheckupdateBooking(){
        Account acc=[Select Id,Name from Account where Name='Account DataTest'];
        Test.startTest();
        List<Booking__c> listBookings=TestDataUtility.CreateBooking(new List < Id >{acc.Id},null,1);
        insert listBookings;
        for(Booking__c bk:listBookings){
            bk.Contract_Number__c='abc12345';
        }
        update listBookings;
        Test.stopTest();
        Booking__c Bookings=[Select Id,Account__c,Contract_Number__c from Booking__c];
        system.debug('bookings->'+bookings);
        System.assertEquals('abc12345',Bookings.Contract_Number__c,'This is to check whether contract number is updated');
        
    }*/

  @isTest
  static void updateBooking() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Contract contrct = [
      SELECT Id, ContractNumber
      FROM Contract
      WHERE AccountId = :acc.Id
    ];
    Test.startTest();
    List<Booking__c> listBookings = TestDataUtility.CreateBooking(
      new List<Id>{ acc.Id },
      null,
      1
    );
    insert listBookings;
    for (Booking__c bk : listBookings) {
      bk.Contract_Number__c = contrct.ContractNumber;
      bk.Payment_Terms__c = 'PP';
    }
    update listBookings;
    system.debug(listBookings);
    Test.stopTest();
    Booking__c Bookings = [
      SELECT Id, Account__c, Contract_Number__c
      FROM Booking__c
    ];
    system.debug(Bookings);
    System.assertEquals(
      contrct.ContractNumber,
      Bookings.Contract_Number__c,
      'This is to check whether contract number is updated'
    );
  }

  @isTest
  static void DeleteBooking() {
    Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
    Contract contrct = [
      SELECT Id, ContractNumber
      FROM Contract
      WHERE AccountId = :acc.Id
    ];

    List<Booking__c> listBookings = TestDataUtility.CreateBooking(
      new List<Id>{ acc.Id },
      contrct.ContractNumber,
      1
    );
    insert listBookings;
    Test.startTest();
    delete listBookings;
    Test.stopTest();
    List<Booking__c> totalBookings = [SELECT Id FROM Booking__c];
    system.assertEquals(totalBookings.size(), 0);
  }
}
