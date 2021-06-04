@isTest
public class CC_CustomLookupCtrlTest {
  @testSetup
  static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
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
    contractObj[0].Softship_Contract_Number__c = '20-0032';
    contractObj[0].Contract_Paper__c = 'Crowley Paper';
    insert contractObj;
    system.debug('contract->' + contractObj);
    List<Booking__c> bookings = TestDataUtility.getBookingRecords(
      listAccounts[0].Id,
      'Test Booking',
      1,
      false
    );
    bookings[0].Booking_Number__c = 'BK000';
    upsert bookings;
    List<Location__c> listlocations = TestDataUtility.CreateLocation(
      'Test Location',
      'PORT',
      2,
      false
    );
    insert listlocations;
    system.debug('list&&&' + listlocations);

    Container__c containerobj = TestDataUtility.CreateContainer(
      '20TT',
      'TT00',
      '20 Dry Trailer Van',
      'TRV',
      'Container'
    );
    insert containerobj;

    Profile Profile1 = [SELECT Id, Name FROM Profile LIMIT 1];
    List<User> users = new List<User>();
    users.add(
      new User(
        alias = ('sucrow'),
        email = 'test123@noemail.com',
        emailencodingkey = 'UTF-8',
        lastname = 'Testing',
        languagelocalekey = 'en_US',
        localesidkey = 'en_US',
        profileid = Profile1.id,
        country = 'United States',
        IsActive = true,
        timezonesidkey = 'America/Los_Angeles',
        username = ('sampleuser180520@crowley.com')
      )
    );
    insert users;
  }
  @isTest
  static void TestfetchAccounts() {
    Test.startTest();
    List<Account> listAccounts = CC_CustomLookupCtrl.fetchAccounts('Account');
    Test.stopTest();
    system.assertEquals(
      1,
      listAccounts.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void TestfetchAccountsBooking() {
    Test.startTest();
    List<Account> listAccounts = CC_CustomLookupCtrl.fetchAccountsBooking(
      'Account'
    );
    Test.stopTest();
    system.assertEquals(
      1,
      listAccounts.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void TestfetchContractsBooking() {
    Account acc = [SELECT Id FROM Account];
    Test.startTest();
    List<Contract> listContracts = CC_CustomLookupCtrl.fetchContractsBooking(
      '20-0',
      acc.Id
    );
    Test.stopTest();
    system.debug(listContracts.size() + ' ' + listContracts);
    system.assertEquals(
      1,
      listContracts.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void NegativeTestfetchContractsBooking() {
    Account acc = [SELECT Id FROM Account];
    Test.startTest();
    List<Contract> listContracts = CC_CustomLookupCtrl.fetchContractsBooking(
      '20-0',
      '0013F00000bSUmLQAW'
    );
    Test.stopTest();
    system.debug(listContracts.size() + ' ' + listContracts);
    system.assertEquals(0, listContracts.size(), 'This list is empty');
  }

  @isTest
  static void PortTestfetchDoorOrPort() {
    Test.startTest();
    List<Location__c> listLocations = CC_CustomLookupCtrl.fetchDoorOrPort(
      'Test',
      'p'
    );
    Test.stopTest();
    system.debug(listLocations);
    system.assertEquals(
      2,
      listLocations.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void DoorTestfetchDoorOrPort() {
    Test.startTest();
    List<Location__c> listLocations = CC_CustomLookupCtrl.fetchDoorOrPort(
      'Test',
      'd'
    );
    Test.stopTest();
    system.debug(listLocations);
    system.assertEquals(0, listLocations.size(), 'This list is empty');
  }

  @isTest
  static void TestfetchOriginDestination() {
    Test.startTest();
    List<Location__c> listLocations = CC_CustomLookupCtrl.fetchOriginDestination(
      'Test'
    );
    Test.stopTest();
    system.assert(listLocations.size() > 0);
  }

  @isTest
  static void TestfetchLoadPortDestinationPort() {
    Test.startTest();
    List<Location__c> listLocations = CC_CustomLookupCtrl.fetchLoadPortDestinationPort(
      'Test'
    );
    Test.stopTest();
    system.assertEquals(2, listLocations.size(), 'This list is empty');
  }

  @isTest
  static void TestgetContainer() {
    Test.startTest();
    List<Container__c> listContainers = CC_CustomLookupCtrl.getContainer('Dry');
    Test.stopTest();
    system.assertEquals(
      1,
      listContainers.size(),
      'This list contains one record'
    );
  }
  //added by mounika
  //
  @isTest
  static void TestfetchParentAccounts() {
    Test.startTest();
    List<Account> listAccounts = CC_CustomLookupCtrl.fetchParentAccounts(
      'Account'
    );
    Test.stopTest();
    system.assertEquals(
      1,
      listAccounts.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void TestfetchContacts() {
    Contact c = [SELECT Id, Name, Address__c FROM Contact];
    System.debug('%%%%%%%%%%%%55' + c);
    Test.startTest();
    List<Contact> listContacts = CC_CustomLookupCtrl.fetchContacts('TEST CON1');
    Test.stopTest();
    system.assertEquals(
      1,
      listContacts.size(),
      'This list contains one record'
    );
  }
  @isTest
  static void TestgetContracts() {
    Test.startTest();
    List<Contract> listContract = CC_CustomLookupCtrl.getContracts('20-0032');
    Test.stopTest();
    system.assertEquals(
      1,
      listContract.size(),
      'This list contains one record'
    );
  }
  @isTest
  static void TestfetchBOLAccounts() {
    Test.startTest();
    List<Account> listAccounts = CC_CustomLookupCtrl.fetchBOLAccounts(
      'Account'
    );
    Test.stopTest();
    system.assertEquals(
      1,
      listAccounts.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void TestfetchBOLBookings() {
    Test.startTest();
    List<Booking__c> listBookings = CC_CustomLookupCtrl.fetchBOLBookings(
      'BK000'
    );
    Test.stopTest();
    system.assertEquals(
      1,
      listBookings.size(),
      'This list contains one record'
    );
  }

  /*@isTest
    static void TestfetchAccountsCombo(){
        Test.startTest();
        List<Account> listAccounts= CC_CustomLookupCtrl.fetchAccountsCombo('Account');
        Test.stopTest();
        system.assertEquals(1,listAccounts.size(),'This list contains one record');
    }
    
    @isTest
    
    static void TestfetchContactsCombo(){
        Account acc=[Select Id from Account];
        Test.startTest();
        List<Contact> listContacts= CC_CustomLookupCtrl.fetchContactsCombo('TEST CON1',acc.Id);
        Test.stopTest();
        system.assertEquals(1,listContacts.size(),'This list contains one record');
    }*/

  @isTest
  static void RampTestfetchDoorOrPort() {
    Test.startTest();
    List<Location__c> listLocations = CC_CustomLookupCtrl.fetchDoorOrPort(
      'Test',
      'R'
    );
    Test.stopTest();
    system.debug(listLocations);
    system.assertEquals(0, listLocations.size(), 'This list is empty');
  }

  /*@isTest
    static void TestfetchBusinessLocations(){
        Test.startTest();
        List<Address__c> listAddresses= CC_CustomLookupCtrl.fetchBusinessLocations('Business Location11');
        Test.stopTest();
        system.assertEquals(1,listAddresses.size(),'This list contains one record');
    }
    
    @isTest
    static void TestfetchAddressesCombo(){
        Account acc=[Select Id from Account];
        Test.startTest();
        List<Address__c> listAddresses= CC_CustomLookupCtrl.fetchAddressesCombo('Business Location11',acc.Id);
        Test.stopTest();
        system.assertEquals(1,listAddresses.size(),'This list contains one record');
    }*/
  @isTest
  static void TestfetchBOLLocation() {
    Test.startTest();
    List<Location__c> listLocation = CC_CustomLookupCtrl.fetchBOLLocation(
      'Test Location'
    );
    Test.stopTest();
    system.assertEquals(
      2,
      listLocation.size(),
      'This list contains one record'
    );
  }

  /*@isTest
    static void TestfetchBusinessLocationsByAccount(){
        Account acc=[Select Id from Account];
        Test.startTest();
        List<Address__c> listAddresses=CC_CustomLookupCtrl.fetchBusinessLocationsByAccount('Business Location11',acc.id);
        Test.stopTest();
        system.assertEquals(1,listAddresses.size(),'This list contains one record');
    }
    @isTest
    static void TestfetchContactsByAccount(){
        Account acc=[Select Id from Account];
        Test.startTest();
        List<Contact> listContact=CC_CustomLookupCtrl.fetchContactsByAccount('Test con1',acc.id);
        Test.stopTest();
        system.assertEquals(1,listContact.size(),'This list contains one record');
    }*/

  @isTest
  static void TestfetchUsers() {
    User users = [SELECT Id, Full_Name__c FROM User LIMIT 1];
    String Name = users.Full_Name__c;
    Test.startTest();
    List<User> listusers = CC_CustomLookupCtrl.fetchUsers(Name);
    Test.stopTest();
    //system.assertEquals(5,listusers.size(),'This list contains one record');
  }

  @isTest
  static void TestfetchBOLCreatedByUsers() {
    User users = [
      SELECT Id, Full_Name__c
      FROM User
      ORDER BY Full_Name__c
      LIMIT 1
    ];
    String Name = users.Full_Name__c;
    Test.startTest();
    System.debug(
      [SELECT Id, Full_Name__c FROM User ORDER BY Full_Name__c LIMIT 5]
    );
    List<User> listusers = CC_CustomLookupCtrl.fetchBOLCreatedByUsers(Name);
    Test.stopTest();
    system.assertEquals(0, listusers.size(), 'This list contains one record');
  }

  @isTest
  static void TestfetchVesselName() {
    Test.startTest();
    List<Vessel_Flag__c> listVessel = CC_CustomLookupCtrl.fetchVesselName(
      'Test Location'
    );
    Test.stopTest();
    system.assertEquals(0, listVessel.size(), 'This list contains one record');
  }

  @isTest
  static void TestfetchHts() {
    Test.startTest();
    List<HTS_Master__c> lstHTSNumber = CC_CustomLookupCtrl.fetchHts('');
    Test.stopTest();
    system.assertEquals(0, lstHTSNumber.size(), 'This list is null');
  }
}
