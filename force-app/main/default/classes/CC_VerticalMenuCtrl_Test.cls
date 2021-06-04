@isTest
public class CC_VerticalMenuCtrl_Test {
  @testSetup
  static void setup() {
    Account ObjAccount;
    User objportalUser, objadminUser;

    UserRole objuserRole = new UserRole(DeveloperName = 'CEO', Name = 'CEO');
    insert objuserRole;

    User objCurrentUser = [
      SELECT Id
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    objCurrentUser.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE Name = 'CEO'
      LIMIT 1
    ]
    .Id;
    update objCurrentUser;

    System.runAs(objCurrentUser) {
      ObjAccount = TestDataUtility.createAccount(
        'Nagarro',
        null,
        'Customer',
        null,
        false,
        1
      )[0];
      insert ObjAccount;

      DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
      List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
      Address__c ObjbusinessLocation = TestDataUtility.createBusinessLocation(
        new List<Account>{ new Account(Id = ObjAccount.Id) },
        'BL1',
        'City1',
        stateAvailableValues[0].getValue(),
        '1111111',
        '88888888888',
        'US',
        1
      )[0];
      insert ObjbusinessLocation;
      System.assertNotEquals(null, ObjbusinessLocation.Country__c);

      Id idRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Create_Record')
        .getRecordTypeId();
      Contact objContact = TestDataUtility.createContact(
        idRecordType,
        new List<Account>{ objAccount },
        new List<Address__c>{ ObjbusinessLocation },
        'First Name',
        'Test Community Con1',
        'communityexample@gmail.com',
        '11111111111',
        false,
        null,
        1
      )[0];
      insert objContact;
      Id IdprofilePortal = [
        SELECT Id
        FROM Profile
        WHERE Name = 'Customer Community Plus Login User Custom'
        LIMIT 1
      ]
      .Id;
      objportalUser = TestDataUtility.createUser(
        null,
        IdprofilePortal,
        'TestPortal',
        'Mgr1',
        'approvalMgr1@test.com',
        'en_US',
        'en_US',
        'UTF-8',
        'America/Los_Angeles',
        objContact.Id,
        null
      );

      insert objportalUser;

      List<NetworkMember> membership = [
        SELECT network.name, networkId, memberID
        FROM NetworkMember
        WHERE memberID = :IdprofilePortal
      ];
      System.debug('membership -->' + membership);

      String nwid = Network.getNetworkId();
      System.debug('nwid' + nwid);

      Id IdprofileAdmin = [
        SELECT Id
        FROM Profile
        WHERE Name = 'System Administrator'
        LIMIT 1
      ]
      .Id;
      objadminUser = TestDataUtility.createUser(
        null,
        IdprofileAdmin,
        'TestAdmin',
        'Mgr1',
        'approvalMgr1@test.com',
        'en_US',
        'en_US',
        'UTF-8',
        'America/Los_Angeles',
        null,
        null
      );
      insert objadminUser;
    }
  }
  @isTest
  static void getMenuItems_positive() {
    CC_VerticalMenuController.networkIdVsName = new Map<Id, String>{
      null => 'Employees'
    };
    User objportalUser = [SELECT id FROM User WHERE FirstName = 'TestPortal'];
    System.runAs(objportalUser) {
      System.assertEquals(UserInfo.getUserId(), objportalUser.Id);
      Test.startTest();
      CC_VerticalMenuController.getMenuItems();
    }
    Test.stopTest();
  }
  @isTest
  static void getMenuItems_negative() {
    User objadminUser = [SELECT Id FROM User WHERE FirstName = 'TestAdmin'];
    System.runAs(objadminUser) {
      System.assertEquals(UserInfo.getUserId(), objadminUser.Id);
      Test.startTest();
      CC_VerticalMenuController.getMenuItems();
    }
    Test.stopTest();
  }
}
