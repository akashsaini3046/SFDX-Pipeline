/*
 * Name: CC_OriginDestinationCtrl_Test
 * Purpose: Test class for CC_OriginDestinationCtrl
 * Author: Nagarro
 * Created Date: 22-Dec-2020
 * Created By:Sanakam Mounika
 */
@isTest
public class CC_OriginDestinationCtrl_Test {
  @testSetup
  static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
    List<Location__c> listlocations = TestDataUtility.CreateLocation(
      'Test Location',
      'BERTH',
      4,
      false
    );
    listlocations[0].Name = 'USJAX';
    listlocations[0].Sub_Location_Type__c = 'PORT';
    listlocations[1].Name = 'PRSJU';
    listlocations[1].Sub_Location_Type__c = 'RAIL RAMP';
    listlocations[2].Name = 'PRSJU';
    listlocations[2].Sub_Location_Type__c = 'origin';
    listlocations[3].Name = 'PRSJU';
    listlocations[3].Sub_Location_Type__c = 'destination';
    insert listlocations;

    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Acc',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
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
    // contractObj[0].Contracted_Commodities__c='OTCargoNOS';
    contractObj[0].Contracted_Commodities__c = System.label.CC_CargoNOS_Code;
    contractObj[0].Contracted_Commodities_Vehicle__c = 'VehiclNew';
    contractObj[0].Contracted_Equipments__c = '40DS';
    contractObj[0].Contract_Paper__c = 'Crowley Paper';
    insert contractObj;
  }
  /*
   * Method Name: createAccount
   * Input Parameters:
   * String recordId: This holds location record Id.
   * Return value: List<Location__c>
   * Purpose: This method get location details list.
   * */
  static testMethod void test_fetchLocation() {
    List<Id> idList = new List<Id>(
      new Map<Id, Location__c>([SELECT ID FROM Location__c]).keySet()
    );
    Test.startTest();
    List<Location__c> lList = CC_OriginDestinationCtrl.fetchLocation(idList[0]);
    Test.stopTest();
    System.assertNotEquals(null, lList.size(), 'should not be null');
  }

  static testMethod void TestgetSubLocationsByUNLocCode_RAIL_RAMP() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'RAIL RAMP'
      LIMIT 1
    ];
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = CC_OriginDestinationCtrl.fetchSubLocation(
      location.UN_Location_Code__c,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assertEquals(0, listLocations.size(), 'This list is not empty');
  }

  static testMethod void TestgetSubLocationsByUNLocCode_PORT() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'PORT'
      LIMIT 1
    ];
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = CC_OriginDestinationCtrl.fetchSubLocation(
      location.UN_Location_Code__c,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assertEquals(0, listLocations.size(), 'This list is not empty');
  }

  static testMethod void TestfetchContractsList() {
    Account acc = [SELECT Id FROM Account];
    List<Contract> listContract;
    Test.startTest();
    listContract = CC_OriginDestinationCtrl.fetchContractsList(acc.Id);
    Test.stopTest();
    System.assertEquals(1, listContract.size(), 'This list is not empty');
  }

  static testMethod void TestgetCommodities() {
    Contract con = [SELECT Id FROM Contract];
    List<Map<String, String>> res;
    Test.startTest();
    res = CC_OriginDestinationCtrl.getCommodities(con.Id);
    Test.stopTest();
    //System.assertEquals(1,res.size(),'This list is not empty');
  }
  static testMethod void TestgetCommoditiesVehicle() {
    Contract con = [SELECT Id FROM Contract];
    List<Map<String, String>> res;
    Test.startTest();
    res = CC_OriginDestinationCtrl.getCommoditiesVehicle(con.Id);
    Test.stopTest();
    //System.assertEquals(1,res.size(),'This list is not empty');
  }
  static testMethod void TestgetEquipments() {
    Contract con = [SELECT Id FROM Contract];
    List<Map<String, String>> res;
    Test.startTest();
    res = CC_OriginDestinationCtrl.getEquipments(con.Id);
    Test.stopTest();
    //System.assertEquals(1,res.size(),'This list is not empty');
  }
  static testMethod void TestfetchOriginDestinationLocation() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'origin'
      LIMIT 1
    ];

    List<Location__c> res;
    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    newBookingWrap.booking.Description__c = 'P';
    newBookingWrap.booking.Customer_Origin_Code__c = '0001';
    String json = JSON.serialize(newBookingWrap);
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchOriginDestinationLocation(
      json,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assert(res != null);
  }
  static testMethod void TestfetchOriginDestinationLocation_D() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'origin'
      LIMIT 1
    ];

    List<Location__c> res;
    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    newBookingWrap.booking.Description__c = 'D';
    newBookingWrap.booking.Customer_Origin_Code__c = '0001';
    newBookingWrap.booking.Customer_Origin_Zip__c = '522501';
    newBookingWrap.booking.Customer_Origin_City__c = 'Florida';
    String json = JSON.serialize(newBookingWrap);
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchOriginDestinationLocation(
      json,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assert(res != null);
  }
  static testMethod void TestfetchOriginDestinationLocation_R() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'origin'
      LIMIT 1
    ];

    List<Location__c> res;
    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    newBookingWrap.booking.Description__c = 'R';
    newBookingWrap.booking.Customer_Origin_Code__c = '0001';
    String json = JSON.serialize(newBookingWrap);
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchOriginDestinationLocation(
      json,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assert(res != null);
  }

  static testMethod void TestfetchOriginDestinationLocation_destination() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'destination'
      LIMIT 1
    ];
    List<Location__c> res;
    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    newBookingWrap.booking.Description__c = 'P';
    newBookingWrap.booking.Customer_Destination_Code__c = '0001';
    String json = JSON.serialize(newBookingWrap);
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchOriginDestinationLocation(
      json,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assert(res != null);
  }
  static testMethod void TestfetchOriginDestinationLocation_D_destination() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'destination'
      LIMIT 1
    ];

    List<Location__c> res;
    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    newBookingWrap.booking.Description__c = 'D';
    newBookingWrap.booking.Customer_Destination_Code__c = '0001';
    newBookingWrap.booking.Customer_Destination_Zip__c = '522501';
    newBookingWrap.booking.Customer_Destination_City__c = 'Florida';
    String json = JSON.serialize(newBookingWrap);
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchOriginDestinationLocation(
      json,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assert(res != null);
  }
  static testMethod void TestfetchOriginDestinationLocation_R_destination() {
    Location__c location = [
      SELECT ID, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
      WHERE Sub_Location_Type__c = 'destination'
      LIMIT 1
    ];

    List<Location__c> res;
    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    newBookingWrap.booking.Description__c = 'R';
    newBookingWrap.booking.Customer_Destination_Code__c = '0001';
    String json = JSON.serialize(newBookingWrap);
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchOriginDestinationLocation(
      json,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assert(res != null);
  }
  static testMethod void TestfetchAccountDetails() {
    Account acc = [SELECT Id FROM Account];
    Account res;
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchAccountDetails(acc.Id);
    Test.stopTest();
    System.assertEquals(res.Id, acc.Id);
  }
  static testMethod void TestfetchContactDetails() {
    Contact acc = [SELECT Id FROM Contact];
    Contact res;
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchContactDetails(acc.Id);
    Test.stopTest();
    System.assertEquals(res.Id, acc.Id);
  }
  static testMethod void TestfetchAddressDetails() {
    Address__c acc = [SELECT Id FROM Address__c LIMIT 1];
    Address__c res;
    Test.startTest();
    res = CC_OriginDestinationCtrl.fetchAddressDetails(acc.Id);
    Test.stopTest();
    System.assertEquals(res.Id, acc.Id);
  }

  static testMethod void TestfetchAccountDetailsByIds() {
    Account acc = [SELECT Id FROM Account];
    Map<Id, Account> result;
    Test.startTest();
    result = CC_OriginDestinationCtrl.fetchAccountDetailsByIds(
      new List<Id>{ acc.Id }
    );
    Test.stopTest();
    System.assert(result.get(acc.Id) != null);
  }
  static testMethod void TestfetchContactDetailsByIds() {
    Contact con = [SELECT Id FROM Contact];
    Map<Id, Contact> result;
    Test.startTest();
    result = CC_OriginDestinationCtrl.fetchContactDetailsByIds(
      new List<Id>{ con.Id }
    );
    Test.stopTest();
    System.assert(result.get(con.Id) != null);
  }

  static testMethod void TestfetchAddressDetailsByIds() {
    Address__c acc = [SELECT Id FROM Address__c LIMIT 1];
    Map<Id, Address__c> result;
    Test.startTest();
    result = CC_OriginDestinationCtrl.fetchAddressDetailsByIds(
      new List<Id>{ acc.Id }
    );
    Test.stopTest();
    System.assert(result.get(acc.Id) != null);
  }
}
