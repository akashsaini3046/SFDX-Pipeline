@isTest
public class AccountOwnerChange_v2_test {
  @testSetup
  static void dataSetup() {
    ProfilesHavingCheckboxAccess__c objProfiles = TestDataUtility.ProfilesHavingCheckboxAccess();
    insert objProfiles;

    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    Map<String, Id> pMap = new Map<String, Id>();
    for (Profile p : [SELECT Id, Name FROM Profile]) {
      pMap.put(p.Name, P.Id);
    }
    User m1 = TestDataUtility.createUser(
      null,
      pMap.get('System Administrator'),
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
    insert m1;
    User u1 = TestDataUtility.createUser(
      null,
      pMap.get('Sales Rep'),
      null,
      'user1',
      'approvalUser1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      m1.Id
    );

    u1.Region__c = 'TRK - Trucking Team';
    insert u1;

    User u2 = TestDataUtility.createUser(
      null,
      pMap.get('Sales Manager'),
      null,
      'User2',
      'approvalUser2@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      m1.Id
    );

    u2.Region__c = 'USA - United States';
    insert u2;

    User u3 = TestDataUtility.createUser(
      null,
      pMap.get('Sales Manager'),
      null,
      'User3',
      'approvalUser2@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      m1.Id
    );

    u3.Region__c = 'PRT - Puerto Rico';
    insert u3;

    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();
    List<Account> acc, acc2, acc3;
    Id accId, acc2Id, acc3Id;
    TriggerHandler.bypass('AccountTriggerHandler');
    acc = TestDataUtility.createAccount(
      'Owner Change Test',
      'Prospect',
      'Apparel',
      null,
      false,
      1
    );
    insert acc;
    //List<User_Region_to_Opp_Role__c> customSettingList = [Select Id from User_Region_to_Opp_Role__c];
    //delete customSettingList;
    for (Account ac : acc) {
      accId = ac.Id;
    }
    acc2 = TestDataUtility.createAccount(
      'Account duplicate',
      'Prospect',
      '',
      null,
      false,
      1
    );
    insert acc2;
    //List<User_Region_to_Opp_Role__c> customSettingList2 = [Select Id from User_Region_to_Opp_Role__c];
    //delete customSettingList2;
    for (Account ac : acc2) {
      ac.Approval_Process_Action__c = ConstantClass.APPROVAL_PROCESS_ACTION_REJECTED;
      acc2Id = ac.Id;
    }
    update acc2;

    acc3 = TestDataUtility.createAccount(
      '123 Test',
      'Prospect',
      '',
      null,
      false,
      1
    );
    insert acc3;
    //List<User_Region_to_Opp_Role__c> customSettingList3 = [Select Id from User_Region_to_Opp_Role__c];
    //delete customSettingList3;
    for (Account ac : acc3) {
      ac.Approval_Process_Action__c = ConstantClass.APPROVAL_PROCESS_ACTION_APPROVED;
      ac.Keep_Account_Team__c = true;
      ac.Keep_Opportunity_Team__c = true;
      //ac.Proposed_Account_Owner__c = u3.Id;
      acc3Id = ac.Id;
    }
    update acc3;

    List<Account> accListChild = TestDataUtility.createAccount(
      'Child Account',
      'Prospect',
      'Agriculture',
      accId,
      false,
      1
    );
    insert accListChild;
    System.runAs(m1) {
      List<Address__c> businessLocationObj2 = TestDataUtility.createBusinessLocation(
        acc,
        'BL11',
        'City11',
        'CA',
        '1134111',
        '86788888888',
        'US',
        1
      );
      insert businessLocationObj2;
      List<Contact> con2 = TestDataUtility.createContact(
        recordTypeId,
        acc,
        businessLocationObj2,
        'Owner',
        'Test con1',
        'contact@email.com',
        '99999999999',
        false,
        u1.Id,
        1
      );
      insert con2;

      List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
        'Edit',
        'Edit',
        'Edit',
        'Edit',
        acc,
        new List<User>{ u1 },
        new List<String>{ 'TRK - Sales Rep' }
      );
      TriggerHandler.bypass('AccountTeamTriggerHandler');
      insert atm;
      //TriggerHandler.clearBypass('AccountTeamTriggerHandler');
      Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true
      );

      update standardPricebook;
      // Case case1 = TestDataUtility.createCase(acc.Id, 'Web', u1.Id, 'New', 1)[0];

      TriggerHandler.bypass('OpportunityTriggerHandler');
      TriggerHandler.bypass('ContactTriggerHandler');
      TriggerHandler.bypass('CaseTriggerHandler');
      TriggerHandler.bypass('TaskTriggerHandler');
      TriggerHandler.bypass('EventTriggerHandler');
      //Case case1 = TestDataUtility.createCase(acc.Id, 'Web', u1.Id, 'New', 1)[0];
      List<Opportunity> listOpp = TestDataUtility.createOpportunity(
        null,
        null,
        'Opp1',
        con2,
        acc,
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
      //Contract contractObj = TestDataUtility.createContract(acc.Id,u1.Id, 2, null, listOpp, null, null, 1)[0];

      List<Opportunity> opp1 = TestDataUtility.createOpportunity(
        null,
        m1.Id,
        'Opp1',
        con2,
        acc,
        'Prospecting',
        null,
        System.today(),
        null,
        null,
        null,
        false,
        1
      );
      insert opp1;

      List<OpportunityTeamMember> otm = TestDataUtility.createOpportunityTeamMember(
        'Edit',
        opp1,
        new List<User>{ new User(Id = u1.Id) },
        new List<String>{ 'TRK – Sales Rep' }
      );
      insert otm;

      List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
        acc,
        'BL1',
        'City1',
        'CA',
        '1111111',
        '88888888888',
        'US',
        1
      );
      insert businessLocationObj;
      List<Address__c> businessLocationObj3 = TestDataUtility.createBusinessLocation(
        acc2,
        'BL3',
        'City3',
        'CA',
        '1111113',
        '88888888883',
        'US',
        1
      );
      insert businessLocationObj3;

      for (Address__c bl : businessLocationObj) {
        System.assertNotEquals(null, bl.Country__c);
      }

      System.assertNotEquals(null, recordTypeId);

      List<Contact> con = TestDataUtility.createContact(
        recordTypeId,
        acc,
        businessLocationObj,
        'Owner',
        'Test confect2',
        'contact23@email.com',
        '99999999988',
        false,
        m1.Id,
        1
      );
      insert con;
      Id conId;
      for (Contact c : con) {
        conId = c.Id;
      }
      List<Contact> con3 = TestDataUtility.createContact(
        recordTypeId,
        acc2,
        businessLocationObj3,
        'Owner',
        'Contact 24',
        'test24test@email.com',
        '99999999988',
        false,
        m1.Id,
        1
      );
      insert con3;
      List<Opportunity> opp2 = TestDataUtility.createOpportunity(
        null,
        m1.Id,
        'Opp2',
        con3,
        acc2,
        'Prospecting',
        null,
        System.today(),
        null,
        null,
        null,
        false,
        1
      );
      insert opp2;
      List<Task> tlist = TestDataUtility.createTask(
        null,
        null,
        null,
        'Normal',
        'Open',
        acc2Id,
        'Test Task',
        System.today() + 1,
        null,
        conId,
        m1.Id,
        2
      );

      for (Task taskobj : tlist) {
        if (taskobj.Subject == 'Test Task') {
          taskobj.WhatId = accId;
        }
        System.assertEquals(conId, taskobj.WhoId);
      }
      insert tlist;

      List<Event> elist = TestDataUtility.createEvent(
        null,
        null,
        null,
        accId,
        'Test Event',
        System.today(),
        System.now(),
        conId,
        m1.Id,
        30,
        2
      );
      for (Event e : elist) {
        if (e.Subject == 'Test Event') {
          e.WhatId = accId;
        }
      }
      insert elist;
    }
  }
  static testMethod void accountOwnerChangeTestMethod() {
    Account acc, acc2, acc3;
    List<Account> accList = new List<Account>();
    //accList = [Select Id,OwnerId from Account where Name IN ('Owner Change Test', 'Account duplicate', '123 Test')];
    // acc= accList[0];
    // acc2= accList[1];
    // acc3= accList[2];
    test.startTest();

    acc = [
      SELECT Id, OwnerId, (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Owner Change Test'
    ];
    acc2 = [SELECT Id, OwnerId FROM Account WHERE Name = 'Account duplicate'];
    acc3 = [SELECT Id, OwnerId FROM Account WHERE Name = '123 Test'];
    List<AccountTeamMember> atmList1 = [
      SELECT Id, AccountId
      FROM AccountTeamMember
      WHERE AccountId = :acc.Id
    ];
    System.debug('acc------------------' + acc.AccountTeamMembers);
    System.debug('atmList------------------' + atmList1);

    List<User> userList = new List<User>();
    User u1, u2, u3, m1;
    userList = [
      SELECT Id, Name
      FROM User
      WHERE Name IN ('user1', 'User2', 'User3', 'USA SYSTEM ADMIN')
    ];
    for (User u : userList) {
      if (u.Name == 'user1')
        u1 = u;
      if (u.Name == 'user2')
        u2 = u;
      if (u.Name == 'user3')
        u3 = u;
      if (u.Name == 'USA SYSTEM ADMIN')
        m1 = u;
    }
    //'Edit', opp1, new List<User>{new User(Id = u1.Id)}, new List<String>{'TRK – Sales Rep'}
    AccountTeamMember objAccountTeamMember = new AccountTeamMember();
    objAccountTeamMember.AccountAccessLevel = 'Edit';
    objAccountTeamMember.CaseAccessLevel = 'Edit';
    objAccountTeamMember.ContactAccessLevel = 'Edit';
    objAccountTeamMember.OpportunityAccessLevel = 'Edit';
    objAccountTeamMember.AccountId = acc.Id;
    objAccountTeamMember.UserId = m1.Id;
    objAccountTeamMember.TeamMemberRole = 'TRK – Sales Rep';
    // listAccountTeamMember.add(objAccountTeamMember);
    TriggerHandler.bypass('AccountTeamTriggerHandler');
    insert objAccountTeamMember;

    //u1 = userList[0];
    //u2 = userList[1];
    //u3 = userList[2];
    //m1 = userList[3];
    // u2=[Select Id from User where Name='User2'];
    // u3=[Select Id from User where Name='User3'];
    // m1=[Select Id from User where Name='USA SYSTEM ADMIN' limit 1];
    //System.runAs(m1) {
    Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();
    Map<Id, Account> oldAccountMap = new Map<Id, Account>();
    List<Contact> contactList = new List<Contact>();
    List<Opportunity> OppList = new List<Opportunity>();
    Set<Id> accIdSet = new Set<Id>();

    oldAccountMap.put(acc2.Id, acc2);
    mapAccIdNewOwnerId.put(acc2.Id, u2.Id);
    contactList = [SELECT Id, AccountId FROM Contact];
    OppList = [SELECT Id, AccountId FROM Opportunity];
    List<AccountTeamMember> atmList = [
      SELECT Id, AccountId
      FROM AccountTeamMember
    ];
    System.debug('atmList^*&^*&' + atmList);
    accIdSet.add(acc2.Id);

    acc.OwnerId = u1.Id;
    TriggerHandler.clearbypass('AccountTriggerHandler');
    update acc;
    List<AccountTeamMember> atmList2 = [
      SELECT Id, AccountId
      FROM AccountTeamMember
    ];
    System.debug('atmList^*&^*&' + atmList2);
    TriggerHandler.clearbypass('AccountTeamTriggerHandler');

    AccountOwnerChangeHelper_V2.transferActivityOwner(
      accIdSet,
      OppList,
      contactList,
      mapAccIdNewOwnerId,
      oldAccountMap
    );

    acc2.OwnerId = u2.Id;
    //  update acc2;

    acc3.OwnerId = u3.Id;
    // update acc3;

    test.stopTest();
    //}
  }

  static testMethod void changeNeglectedChildAccOwnerTest() {
    Test.startTest();
    Account acc;
    List<Account> accList = new List<Account>();
    accList = [
      SELECT Id, OwnerId, Name
      FROM Account
      WHERE Name IN ('Owner Change Test', 'Account duplicate', '123 Test')
    ];
    acc = accList[0];
    Neglected_Account_Data__c negRec = new Neglected_Account_Data__c();
    negRec.Account__c = acc.Id;
    negRec.AccountId__c = acc.Id;
    negRec.Name = acc.Name;
    insert negRec;
    User u1;
    List<User> userList = new List<User>();
    userList = [
      SELECT Id, Name
      FROM User
      WHERE Name IN ('user1', 'User2', 'User3', 'USA SYSTEM ADMIN')
    ];
    for (User u : userList) {
      if (u.Name == 'user1')
        u1 = u;
    }
    Map<Id, Account> oldAccountMap = new Map<Id, Account>();
    Map<Id, Account> newAccountMap = new Map<Id, Account>();
    oldAccountMap.put(acc.Id, acc);
    acc.OwnerId = u1.Id;
    update acc;
    newAccountMap.put(acc.Id, acc);
    AccountOwnerChangeHelper_V2.changeNeglectedChildAccOwner(
      newAccountMap,
      oldAccountMap
    );
    test.stopTest();
  }

  static testMethod void handleOwnerUpdateBeforeUpdateTestMethod() {
    Account acc, acc2, acc3;
    List<Account> accList = new List<Account>();
    test.startTest();
    acc = [
      SELECT
        Id,
        OwnerId,
        Keep_Account_Team__c,
        Proposed_Account_Owner__c,
        Approval_Process_Action__c,
        PreviousOwnersManager__c,
        Requester_Notes__c,
        PreviousOwnersManagerCopy__c,
        Requester_Notes_Copy__c,
        (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Owner Change Test'
    ];
    acc2 = [
      SELECT
        Id,
        OwnerId,
        Keep_Account_Team__c,
        Proposed_Account_Owner__c,
        Approval_Process_Action__c,
        PreviousOwnersManager__c,
        Requester_Notes__c,
        PreviousOwnersManagerCopy__c,
        Requester_Notes_Copy__c,
        (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Account duplicate'
    ];
    acc3 = [SELECT Id, OwnerId FROM Account WHERE Name = '123 Test'];
    List<AccountTeamMember> atmList1 = [
      SELECT Id, AccountId
      FROM AccountTeamMember
      WHERE AccountId = :acc.Id
    ];

    List<User> userList = new List<User>();
    User u1, u2, u3, m1;
    userList = [
      SELECT Id, Name
      FROM User
      WHERE Name IN ('user1', 'User2', 'User3', 'USA SYSTEM ADMIN')
    ];
    for (User u : userList) {
      if (u.Name == 'user1')
        u1 = u;
      if (u.Name == 'user2')
        u2 = u;
      if (u.Name == 'user3')
        u3 = u;
      if (u.Name == 'USA SYSTEM ADMIN')
        m1 = u;
    }
    Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();
    Map<Id, Account> oldAccountMap = new Map<Id, Account>();
    List<Contact> contactList = new List<Contact>();
    List<Opportunity> OppList = new List<Opportunity>();
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accsList = new List<Account>();

    oldAccountMap.put(acc2.Id, acc2);
    mapAccIdNewOwnerId.put(acc2.Id, u2.Id);
    contactList = [SELECT Id, AccountId FROM Contact];
    OppList = [SELECT Id, AccountId FROM Opportunity];
    List<AccountTeamMember> atmList = [
      SELECT Id, AccountId
      FROM AccountTeamMember
    ];
    System.debug('atmList^*&^*&' + atmList);
    accIdSet.add(acc2.Id);
    accsList.add(acc2);
    acc2.Proposed_Account_Owner__c = u1.Id;
    acc2.Approval_Process_Action__c = 'APPROVED';
    AccountOwnerChangeHelper_V2.handleOwnerUpdateBeforeUpdate(
      accsList,
      oldAccountMap
    );
    TriggerHandler.clearbypass('AccountTriggerHandler');
    update acc;
    List<AccountTeamMember> atmList2 = [
      SELECT Id, AccountId
      FROM AccountTeamMember
    ];
    TriggerHandler.clearbypass('AccountTeamTriggerHandler');
    acc2.Proposed_Account_Owner__c = u2.Id;
    acc2.Approval_Process_Action__c = 'REJECTED';
    AccountOwnerChangeHelper_V2.handleOwnerUpdateBeforeUpdate(
      accsList,
      oldAccountMap
    );
    acc2.OwnerId = u2.Id;
    acc3.OwnerId = u3.Id;
    test.stopTest();
  }

  static testMethod void transferOwnersTestMethod() {
    Account acc, acc2, acc3;
    List<Account> accList = new List<Account>();
    test.startTest();
    acc = [
      SELECT
        Id,
        OwnerId,
        Keep_Account_Team__c,
        Proposed_Account_Owner__c,
        Approval_Process_Action__c,
        PreviousOwnersManager__c,
        Requester_Notes__c,
        PreviousOwnersManagerCopy__c,
        Requester_Notes_Copy__c,
        (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Owner Change Test'
    ];
    acc2 = [
      SELECT
        Id,
        OwnerId,
        Name,
        Keep_Account_Team__c,
        Proposed_Account_Owner__c,
        Approval_Process_Action__c,
        PreviousOwnersManager__c,
        Requester_Notes__c,
        PreviousOwnersManagerCopy__c,
        Requester_Notes_Copy__c,
        TimeofStep3Approval__c,
        (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Account duplicate'
    ];
    acc3 = [SELECT Id, OwnerId FROM Account WHERE Name = '123 Test'];
    List<AccountTeamMember> atmList1 = [
      SELECT Id, AccountId
      FROM AccountTeamMember
      WHERE AccountId = :acc.Id
    ];

    List<User> userList = new List<User>();
    User u1, u2, u3, m1;
    userList = [
      SELECT Id, Name
      FROM User
      WHERE Name IN ('user1', 'User2', 'User3', 'USA SYSTEM ADMIN')
    ];
    for (User u : userList) {
      if (u.Name == 'user1')
        u1 = u;
      if (u.Name == 'user2')
        u2 = u;
      if (u.Name == 'user3')
        u3 = u;
      if (u.Name == 'USA SYSTEM ADMIN')
        m1 = u;
    }
    Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();
    Map<Id, Account> oldAccountMap = new Map<Id, Account>();
    Map<Id, Account> newAccountMap = new Map<Id, Account>();
    List<Contact> contactList = new List<Contact>();
    List<Opportunity> OppList = new List<Opportunity>();
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accsList = new List<Account>();

    oldAccountMap.put(acc2.Id, acc2);
    mapAccIdNewOwnerId.put(acc2.Id, u2.Id);
    contactList = [SELECT Id, AccountId FROM Contact];
    OppList = [SELECT Id, AccountId FROM Opportunity];
    List<AccountTeamMember> atmList = [
      SELECT Id, AccountId
      FROM AccountTeamMember
    ];
    System.debug('atmList^*&^*&' + atmList);
    accIdSet.add(acc2.Id);
    accsList.add(acc2);
    acc2.Keep_Account_Team__c = true;
    TriggerHandler.clearbypass('AccountTriggerHandler');
    update acc;
    TriggerHandler.clearbypass('AccountTeamTriggerHandler');
    newAccountMap.put(acc2.Id, acc2);
    AccountOwnerChangeHelper_V2.transferOwners(newAccountMap, oldAccountMap);
    test.stopTest();
  }

  static testMethod void keepAccountTeamsTestMethod() {
    Account acc, acc2, acc3;
    List<Account> accList = new List<Account>();
    test.startTest();
    acc = [
      SELECT
        Id,
        OwnerId,
        Keep_Account_Team__c,
        Proposed_Account_Owner__c,
        Approval_Process_Action__c,
        PreviousOwnersManager__c,
        Requester_Notes__c,
        PreviousOwnersManagerCopy__c,
        Requester_Notes_Copy__c,
        (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Owner Change Test'
    ];
    acc2 = [
      SELECT Id, OwnerId, Name, (SELECT Id FROM AccountTeamMembers)
      FROM Account
      WHERE Name = 'Account duplicate'
    ];
    acc3 = [SELECT Id, OwnerId FROM Account WHERE Name = '123 Test'];
    List<AccountTeamMember> atmList1 = [
      SELECT Id, AccountId
      FROM AccountTeamMember
      WHERE AccountId = :acc.Id
    ];
    List<User> userList = new List<User>();
    User u1, u2, u3, m1;
    userList = [
      SELECT Id, Name
      FROM User
      WHERE Name IN ('user1', 'User2', 'User3', 'USA SYSTEM ADMIN')
    ];
    for (User u : userList) {
      if (u.Name == 'user1')
        u1 = u;
      if (u.Name == 'user2')
        u2 = u;
      if (u.Name == 'user3')
        u3 = u;
      if (u.Name == 'USA SYSTEM ADMIN')
        m1 = u;
    }
    Map<Id, Id> mapAccIdNewOwnerId = new Map<Id, Id>();
    Map<Id, Id> mapAccIdCurrentOwnerId = new Map<Id, Id>();
    Map<Id, Account> oldAccountMap = new Map<Id, Account>();
    Map<Id, Account> newAccountMap = new Map<Id, Account>();
    List<Contact> contactList = new List<Contact>();
    List<Opportunity> OppList = new List<Opportunity>();
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accsList = new List<Account>();

    oldAccountMap.put(acc.Id, acc);
    mapAccIdCurrentOwnerId.put(acc.Id, u2.Id);
    contactList = [SELECT Id, AccountId FROM Contact];
    OppList = [SELECT Id, AccountId FROM Opportunity];
    List<AccountTeamMember> atmList = [
      SELECT Id, AccountId
      FROM AccountTeamMember
    ];
    System.debug('atmList^*&^*&' + atmList);
    acc.Keep_Account_Team__c = true;
    accIdSet.add(acc.Id);
    accsList.add(acc2);
    acc.OwnerId = u2.Id;
    TriggerHandler.clearbypass('AccountTriggerHandler');
    update acc;
    TriggerHandler.clearbypass('AccountTeamTriggerHandler');
    newAccountMap.put(acc2.Id, acc2);
    mapAccIdNewOwnerId.put(acc.Id, u1.Id);
    AccountOwnerChangeHelper_V2.keepAccountTeams(
      accIdSet,
      mapAccIdCurrentOwnerId,
      mapAccIdNewOwnerId,
      accIdSet
    );
    test.stopTest();
  }
}
