@isTest(SeeAllData=false)
public class UserTriggerHandlerTest {
  @isTest
  public static void testUserTriggerHandler() {
    Test.startTest();
    Id profileOne = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    USerRole objRole = [
      SELECT Id, ParentRoleId
      FROM UserRole
      WHERE ParentRoleId != NULL
      LIMIT 1
    ];
    User userOne = TestDataUtility.createUser(
      objRole.ParentRoleId,
      profileOne,
      null,
      'User1',
      'manager123@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert userOne;
    User userTwo = TestDataUtility.createUser(
      objRole.Id,
      profileOne,
      null,
      'User1',
      'subordinate124@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert userTwo;
    System.runAs(userOne) {
      List<ProfileToGroupMap__c> profileGroupCustomSetting = new List<ProfileToGroupMap__c>();
      ProfileToGroupMap__c profileGroup1 = new ProfileToGroupMap__c(
        Name = 'Crowley Marketing Team',
        Group_Name__c = 'Marketing_Group'
      );
      profileGroupCustomSetting.add(profileGroup1);
      ProfileToGroupMap__c profileGroup2 = new ProfileToGroupMap__c(
        Name = 'Non Sales Users',
        Group_Name__c = 'Non_Sales_Group'
      );
      profileGroupCustomSetting.add(profileGroup2);
      ProfileToGroupMap__c profileGroup3 = new ProfileToGroupMap__c(
        Name = 'Sales Leader',
        Group_Name__c = 'Sales_Leader_Group'
      );
      profileGroupCustomSetting.add(profileGroup3);
      ProfileToGroupMap__c profileGroup4 = new ProfileToGroupMap__c(
        Name = 'Sales Manager',
        Group_Name__c = 'Sales_Manager_Group'
      );
      profileGroupCustomSetting.add(profileGroup4);
      ProfileToGroupMap__c profileGroup5 = new ProfileToGroupMap__c(
        Name = 'Sales Rep',
        Group_Name__c = 'Sales_Rep'
      );
      profileGroupCustomSetting.add(profileGroup5);

      insert profileGroupCustomSetting;
    }

    Id profileThree = [SELECT Id FROM Profile WHERE Name = 'Sales Rep' LIMIT 1]
    .Id;

    User userThree = TestDataUtility.createUser(
      null,
      profileOne,
      null,
      'USA SYSTEM ADMIN',
      'USASYSTEMADMIN@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert userThree;
    User userFour = TestDataUtility.createUser(
      null,
      profileOne,
      null,
      'user1',
      'approvalUser1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      userThree.Id
    );
    insert userFour;

    userFour.ManagerId = null;
    userFour.ProfileId = profileThree;
    update userFour;
    Test.stopTest();
  }
}
