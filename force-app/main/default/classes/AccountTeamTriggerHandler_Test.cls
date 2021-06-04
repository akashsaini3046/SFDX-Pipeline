@isTest
public class AccountTeamTriggerHandler_Test {
  @testSetup
  static void dataSetup() {
    Governance_Team_Fields__c objGTF = TestDataUtility.GovernanceTeamFields(
      '1',
      'Parent Account',
      'ParentId',
      'Account',
      'Lookup',
      'Account'
    );
    insert objGTF;
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;
    Map<String, Id> pMap = new Map<String, Id>();
    for (Profile p : [SELECT Id, Name FROM Profile]) {
      pMap.put(p.Name, P.Id);
    }
    //Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
    //Id profileId2 = [SELECT Id FROM Profile WHERE Name = 'Sales Rep' Limit 1].Id;

    User u1 = TestDataUtility.createUser(
      null,
      pMap.get('System Administrator'),
      null,
      'User1',
      'approvalUser1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u1;

    User u2 = TestDataUtility.createUser(
      null,
      pMap.get('Sales Rep'),
      null,
      'User2',
      'approvalUser2@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    u2.region__c = 'PRT - Puerto Rico';

    insert u2;

    User u3 = TestDataUtility.createUser(
      null,
      pMap.get('Sales Rep'),
      null,
      'User3',
      'approvalUser3@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );

    u3.region__c = 'TRK - Trucking Team';

    insert u3;

    User u4 = TestDataUtility.createUser(
      null,
      pMap.get('Account Manager'),
      null,
      'User4',
      'approvalUser4@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );

    insert u4;

    System.runAs(u2) {
      //List<User_Region_to_Opp_Role__c> customSetting =TestDataUtility.UserRegiontoOppRole();
      //insert customSetting;
      List<Account> acc = TestDataUtility.createAccount(
        'Test Account Team53254**&&',
        'Customer',
        null,
        null,
        false,
        1
      );
      system.debug('***' + acc);
      insert acc;
      system.debug('***' + acc);
      Account acc1 = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test Account Team53254**&&'
      ];
      system.debug('***' + acc1);
      //List<User_Region_to_Opp_Role__c> customSetting1 = [Select Id from User_Region_to_Opp_Role__c];

      //delete customSetting1;

      List<Account> accChild = TestDataUtility.createAccount(
        'Account Team Child324',
        'Prospect',
        'Beverages',
        acc1.Id,
        false,
        1
      );
      insert accChild;

      Opportunity_Split_Constant__mdt objOpportunitySplitCustomMetadata = [
        SELECT Trigger_Handlers__c
        FROM Opportunity_Split_Constant__mdt
        WHERE DeveloperName = 'Bypass_Handlers'
        LIMIT 1
      ];
      for (
        String strHandlerToBypass : new List<String>{
          'AddressTriggerHandler',
          'ContactTriggerHandler'
        }
      ) {
        TriggerHandler.bypass(strHandlerToBypass);
      }

      List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
        acc,
        'Business Location1',
        'City1',
        'CA',
        '1111111',
        '88888888888',
        'US',
        1
      );
      insert businessLocationObj;
      List<Contact> con = TestDataUtility.createContact(
        null,
        acc,
        businessLocationObj,
        null,
        'Test con1',
        'contact@email.com',
        '(99999999999',
        true,
        null,
        1
      );
      insert con;

      for (
        String strHandlerToBypass : new List<String>{
          'AddressTriggerHandler',
          'ContactTriggerHandler'
        }
      ) {
        TriggerHandler.clearBypass(strHandlerToBypass);
      }
      /* AccountTeamMember atm2 = TestDataUtility.createAccountTeamMember('Edit', 'Edit', 
'Edit', 'Edit', 
new List<Account>{acc}, 
new List<User>{u2}, new List<String>{'PRT - Sales Rep'})[0]; */
    }


    //TestDataUtility.CustomSettingData();
    //List<Account> accList = TestDataUtility.createAccounts('Test data account team', 'Prospect', null, null, false, 1);
  }

  static testMethod void accountTeamTriggerHandler_TestMethodInsert() {
    List<User> userList = new List<User>();
    List<String> roleList = new List<String>();

    User u1 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User1'
    ];
    User u2 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User2'
    ];
    //User u3 = [Select Id, Name, Region__c, Email, profile.Name  from User Where Name = 'User3'];
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Account Team53254**&&'
    ];
    try {
      System.runAs(u2) {
        Test.startTest();

        List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
          'Edit',
          'Edit',
          'Edit',
          'Edit',
          new List<Account>{ acc },
          new List<User>{ u1, u2 },
          new List<String>{ 'Contracts Rep', 'PRT - Sales Rep' }
        );
        insert atm;

        /*  AccountTeamMember objAccountTeamMember = new AccountTeamMember();
                    objAccountTeamMember.AccountAccessLevel = 'Edit';
                    objAccountTeamMember.CaseAccessLevel = 'Edit';
                    objAccountTeamMember.ContactAccessLevel = 'Edit';
                    objAccountTeamMember.OpportunityAccessLevel = 'Edit';
                    objAccountTeamMember.AccountId = acc.Id;
                    objAccountTeamMember.UserId = u1.Id;
                    objAccountTeamMember.TeamMemberRole ='Contracts';
                insert objAccountTeamMember;*/

        Test.stopTest();

        //Test.startTest();

        //AccountTeamMember atm3 = TestDataUtility.createAccountTeamMember('Edit', 'Edit',
        //                                                                 'Edit', 'Edit',
        //                                                                 new List<Account>{accChild},
        //                                                                 new List<User>{u3}, new List<String>{'TRK - Sales Rep'})[0];
      }

    } catch (Exception e) {
      System.debug('Exception in Account Test Class' + e.getMessage());
    }
  }

  static testMethod void accountTeamTriggerHandler_TestMethodUpdate() {
    //User u1 = [Select Id, Name, Region__c, Email,profile.Name   from User Where Name = 'User1'];
    //User u2 = [Select Id, Name, Region__c, Email, profile.Name  from User Where Name = 'User2'];
    User u3 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User3'
    ];
    System.debug('u3: ' + u3);
    List<User_Region_to_Opp_Role__c> customSetting1 = [
      SELECT Id
      FROM User_Region_to_Opp_Role__c
    ];
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Account Team53254**&&'
      LIMIT 1
    ];
    List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
      'Edit',
      'Edit',
      'Edit',
      'Edit',
      new List<Account>{ acc },
      new List<User>{ u3 },
      new List<String>{ 'TRK - Sales Rep' }
    );
    insert atm;
    AccountTeamMember atm1 = [
      SELECT Id, TeamMemberRole
      FROM AccountTeamMember
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];
    //AccountTeamMember atmChild = [Select Id, TeamMemberRole from AccountTeamMember where Account.Name = 'Account Team Child324' LIMIT 1];

    try {
      System.runAs(u3) {
        Test.startTest();
        atm1.TeamMemberRole = 'USA - Sales Rep';
        TriggerHandler.clearBypass('AccountTeamTriggerHandler');
        update atm1;
        //delete atmChild;
        Test.stopTest();
      }
    } catch (Exception e) {
      System.debug('Exception message' + e.getMessage());
    }
  }

  static testMethod void accountTeamTriggerHandler_TestMethodDelete() {
    User u1 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User1'
    ];
    User u4 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User4'
    ];
    System.debug('u4: ' + u4);
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Account Team53254**&&'
    ];
    try {
      System.runAs(u4) {
        Test.startTest();
        List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
          'Edit',
          'Edit',
          'Edit',
          'Edit',
          new List<Account>{ acc },
          new List<User>{ u1, u4 },
          new List<String>{ 'Contracts Rep', '  Customer Care - Account Mgr' }
        );
        insert atm;
        delete atm;
        Test.stopTest();
      }
    } catch (Exception e) {
      System.debug('Exception message' + e.getMessage());
    }
  }

  static testMethod void accountTeamTriggerHandler_TestPreventChildAccountTeamDeletion() {
    User u1 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User1'
    ];
    User u4 = [
      SELECT Id, Name, Region__c, Email, profile.Name
      FROM User
      WHERE Name = 'User4'
    ];
    System.debug('u4: ' + u4);
    Account parentAcc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Account Team53254**&&'
    ];
    System.debug('parentAcc' + parentAcc);
    Account childAcc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Account Team Child324'
    ];
    System.debug('childAcc' + childAcc);
    try {
      System.runAs(u1) {
        Test.startTest();
        List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
          'Edit',
          'Edit',
          'Edit',
          'Edit',
          new List<Account>{ parentAcc },
          new List<User>{ u4 },
          new List<String>{ 'Customer Care - Account Mgr' }
        );
        insert atm;
        System.debug('arm' + atm);
        system.Assert(
          atm != null,
          'AccountHandlerTest.testInactive FAIL:Account was not inserted properly!'
        );
        delete atm;
        Test.stopTest();
      }
    } catch (Exception e) {
      String message = e.getMessage();
      system.assert(
        message.contains('Users can only add/modify themselves'),
        'message=' + message
      );
    }
  }
}
