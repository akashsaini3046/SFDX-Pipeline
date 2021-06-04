@isTest(SeeAllData=false)
public class CC_LoginControllerTest {
  @testSetup
  static void setup() {
    User objportalUser = new User();
    UserRole userrole = [
      SELECT Id, DeveloperName
      FROM UserRole
      WHERE DeveloperName = 'Corporate' OR DeveloperName = 'Crowley_Global'
      LIMIT 1
    ];
    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE Profile.Name = 'System Administrator' AND isActive = :true
      LIMIT 1
    ];
    adminUser.UserRoleId = userRole.Id;
    update adminUser;
    System.debug('userrole---->' + userrole + 'adminUser---->' + adminUser);
    System.runAs(adminUser) {
      Account ObjAccount = new Account();
      ObjAccount = TestDataUtility.createAccount(
        'Nagarro',
        null,
        'Customer',
        null,
        false,
        1
      )[0];
      ObjAccount.ownerId = adminUser.id;
      insert ObjAccount;
      // List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
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
      //objContact.Accountid = ObjAccount.Id;
      insert objContact;
      Id IdprofilePortal = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1]
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
      //objportalUser.ContactId = objContact.Id;
      //objportalUser.portalRole = 'Manager';
      //TestDataUtility.createUser(null, IdprofilePortal, 'TestAdmin', 'Mgr1', 'approvalMgr1@test.com', 'en_US', 'en_US', 'UTF-8', 'America/Los_Angeles', objContact,null);

      insert objportalUser;

      /*String nwid = Network.getNetworkId();
            System.debug('nwid' + nwid) ;
            
            System.setPassword(objportalUser.Id,'testUser#123');
            update objportalUser;*/
    }
  }
  @isTest
  static void checkPortalTest() {
    User objportalUser = [SELECT Id, Name, UserName FROM User LIMIT 1];
    System.debug('objportalUser@@@' + objportalUser);
    Test.startTest();
    String lgn = CC_LoginController.checkPortal(
      objportalUser.UserName,
      'test@123',
      'https://crowley2--commdev1.my.salesforce.com/'
    );
    Test.stopTest();
    System.assertEquals('False', lgn, 'Should be false');
  }
  @isTest
  static void checkPortalTestNegative() {
    Test.startTest();
    String lgn = CC_LoginController.checkPortal(null, null, null);
    Test.stopTest();
    System.assertEquals('False', lgn, 'Should be false');
  }
  @isTest
  static void getCommunityUrlPathPrefixTest() {
    Test.startTest();
    String lgn = CC_LoginController.getCommunityUrlPathPrefix();
    Test.stopTest();
    System.assertEquals(null, lgn);
  }
  @isTest
  static void LoginTest() {
    User objportalUser = [
      SELECT id, UserName, FirstName
      FROM User
      WHERE FirstName = 'TestPortal'
    ];
    System.debug('objportalUser@@@' + objportalUser);
    Test.startTest();
    string status = CC_LoginController.Login(
      objportalUser.UserName,
      'testUser#123',
      'https://commdev1-crowleydev.cs92.force.com/Employees/s/'
    );
    Test.stopTest();
    system.debug(status);
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void LoginTest2() {
    Test.startTest();
    string status = CC_LoginController.Login(
      'manaswini.datla@nagarro.com.comdev1',
      'testUser#123',
      'https://commdev1-crowleydev.cs92.force.com/Employees/s/'
    );
    Test.stopTest();
    system.debug(status);
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void usernameExistsTest() {
    Test.startTest();
    User user = [SELECT Id, Name, Email, Username FROM User LIMIT 1];
    string status = CC_LoginController.usernameExists(user.Username);
    Test.stopTest();
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void usernameExistsTest2() {
    Test.startTest();
    System.debug('************************' + [SELECT Id, Username FROM User]);
    String status = CC_LoginController.usernameExists('unsuccesful');
    Test.stopTest();
    system.debug(status);
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void usernameExistsTest3() {
    User objportalUser = [
      SELECT id, UserName, FirstName, Name
      FROM User
      WHERE FirstName = 'TestPortal'
    ];
    Test.startTest();
    String status = CC_LoginController.usernameExists(objportalUser.Name);
    Test.stopTest();
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void setNewPasswordTest() {
    Contact con = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    String status = CC_LoginController.setNewPassword(con.Id, 'password');
    Test.stopTest();
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void setNewPasswordTest3() {
    Id IdprofilePortal = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1]
    .Id;
    User user1 = [SELECT Id FROM User LIMIT 1];
    Test.startTest();
    String status = CC_LoginController.setNewPassword(user1.Id, 'testUser#123');
    Test.stopTest();
    system.debug(status);
    System.assertEquals('False', status, 'Unsuccessful');
  }

  @isTest
  static void setNewPasswordTest2() {
    Test.startTest();
    String status = CC_LoginController.setNewPassword('autouser', 'password');
    Test.stopTest();
    System.assertEquals('False', status, 'Unsuccessful');
  }
  @isTest
  static void setNewPasswordTest4() {
    Id IdprofilePortal = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1]
    .id;
    Test.startTest();
    String status = CC_LoginController.setNewPassword(
      String.valueOf(IdprofilePortal),
      'password'
    );
    Test.stopTest();
    System.assertEquals('False', status, 'Unsuccessful');
  }
}
