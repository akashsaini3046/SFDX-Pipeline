@isTest
public class PartyTriggerHandlerTest {
  @Testsetup
  static void setup() {
    List<Account> listAccounts = TestDataUtility.createAccount(
      'Account DataTest',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    for (Account acc : listAccounts) {
      acc.CVIF__c = '123456';
    }
    insert listAccounts;

    List<Account> listAccounts1 = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts1;

    List<Id> accIds = new List<Id>();
    for (Account acc : listAccounts) {
      accIds.add(acc.Id);
    }
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

    List<Booking__c> listBookings = TestDataUtility.CreateBooking(
      accIds,
      null,
      1
    );
    for (Booking__c bk : listBookings) {
      bk.Payment_Terms__c = 'PP';
    }
    insert listBookings;
  }

  @isTest
  static void InsertParty() {
    List<Account> listAccounts = [
      SELECT Id, CVIF__c
      FROM Account
      WHERE Name = 'Account DataTest'
    ];
    Booking__c bkg = [SELECT Id FROM Booking__c LIMIT 1];
    List<Id> accIds = new List<Id>();
    String cvifid;
    for (Account acc : listAccounts) {
      accIds.add(acc.Id);
      cvifid = acc.CVIF__c;
    }
    Test.startTest();
    List<Party__c> listParties = TestDataUtility.CreateParty(
      accIds,
      'Test Party',
      1
    );
    for (Party__c prt : listParties) {
      prt.Booking__c = bkg.Id;
      prt.CVIF__c = cvifid;
    }
    insert listParties;
    Test.stopTest();
    List<Party__c> parties = [SELECT Id FROM Party__c];
    system.assertEquals(1, parties.size(), 'This list contains one record');
  }

  @isTest
  static void updateParty() {
    List<Account> listAccounts = [
      SELECT Id, CVIF__c
      FROM Account
      WHERE Name = 'Account DataTest'
    ];
    Account accobj = [SELECT Id FROM Account WHERE Name = 'Test Account'];
    Booking__c bkg = [SELECT Id FROM Booking__c LIMIT 1];
    List<Id> accIds = new List<Id>();
    for (Account acc : listAccounts) {
      accIds.add(acc.Id);
    }
    Test.startTest();
    List<Party__c> listParties = TestDataUtility.CreateParty(
      accIds,
      'Test Party',
      1
    );
    insert listParties;
    List<Party__c> partiesToUpdate = new List<Party__c>();
    System.debug(listParties);
    System.debug(accobj.Id);
    System.debug(bkg.Id);
    for (Party__c prt : listParties) {
      prt.Booking__c = bkg.Id;
      prt.Account__c = accobj.Id;
      prt.Type__c = 'CON';
      partiesToUpdate.add(prt);
    }
    update partiesToUpdate;
    Test.stopTest();
    Party__c parties = [SELECT Id, Booking__c FROM Party__c];
    system.assertEquals(bkg.Id, parties.Booking__c, 'The booking is updated');
  }

  @isTest
  static void updatePartyAccount() {
    List<Account> listAccounts = [
      SELECT Id, CVIF__c
      FROM Account
      WHERE Name = 'Account DataTest'
    ];
    Account accobj = [SELECT Id FROM Account WHERE Name = 'Test Account'];
    Booking__c bkg = [SELECT Id FROM Booking__c LIMIT 1];
    List<Id> accIds = new List<Id>();
    for (Account acc : listAccounts) {
      accIds.add(acc.Id);
    }
    List<Party__c> listParties = TestDataUtility.CreateParty(
      accIds,
      'Test Party',
      1
    );
    insert listParties;
    Test.startTest();
    List<Party__c> partiesToUpdate = new List<Party__c>();
    for (Party__c prt : listParties) {
      prt.Booking__c = bkg.Id;
      prt.CVIF__c = '654321';
      prt.Account__c = accobj.Id;
      prt.Type__c = 'CON';
      partiesToUpdate.add(prt);
    }
    update partiesToUpdate;
    Test.stopTest();
    Party__c parties = [SELECT Id, Booking__c FROM Party__c];
    system.assertEquals(bkg.Id, parties.Booking__c, 'The booking is updated');
  }

  @isTest
  static void deleteParty() {
    List<Account> listAccounts = [
      SELECT Id, CVIF__c
      FROM Account
      WHERE Name = 'Account DataTest'
    ];
    List<Id> accIds = new List<Id>();
    for (Account acc : listAccounts) {
      accIds.add(acc.Id);
    }
    List<Party__c> listParties = TestDataUtility.CreateParty(
      accIds,
      'Test Party',
      1
    );
    insert listParties;
    Test.startTest();
    delete listparties;
    Test.stopTest();
    List<Party__c> parties = [SELECT Id FROM Party__c];
    system.assertEquals(0, parties.size(), 'This List is empty');
  }
}
