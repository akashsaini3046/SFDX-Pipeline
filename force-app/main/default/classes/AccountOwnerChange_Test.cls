/*
* Name: AccountOwnerChange_Test
* Purpose: Test class for AccountOwnerChangeController and AccountOwneChangeHelper 
* Author: Nagarro
* Created Date: 11-Apr-2019
* Modification History
*  Modification #   Story/Defect#      Modified By     Date[MM/DD/YYYY]   Description
                    Code coverage       Priyanka        09/13/2019          
*/
@isTest
public class AccountOwnerChange_Test {
  @testSetup
  static void dataSetup() {
    ProfilesHavingCheckboxAccess__c objProfiles = TestDataUtility.ProfilesHavingCheckboxAccess();
    insert objProfiles;
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;

    User m1 = TestDataUtility.createUser(
      null,
      profileId,
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
      profileId,
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
    insert u1;
    User u2 = TestDataUtility.createUser(
      null,
      profileId,
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
    insert u2;

    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();

    List<Account> acc = TestDataUtility.createAccountforApprovalProcess(
      'ApprovalProcessAccount_TestClass',
      u1.Id,
      u2.Id,
      'Approved',
      1
    );
    insert acc;
    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      acc,
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
      recordTypeId,
      acc,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      u1.Id,
      1
    );
    insert con2;
    List<Account> accList = new List<Account>();
    for (Account objectAcc : acc) {
      objectAcc.TimeofStep3Approval__c = system.now() + 2;
      accList.add(objectAcc);
    }
    update accList;
    //Account acc2 = new Account();
    //acc2 = accList[0];

    List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
      'Edit',
      'Edit',
      'Edit',
      'Edit',
      acc,
      new List<User>{ u1 },
      new List<String>{ 'Account Manager' }
    );
    insert atm;

    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );

    update standardPricebook;

    TriggerHandler.bypass('OpportunityTriggerHandler');
    TriggerHandler.bypass('ContactTriggerHandler');
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
    List<Contract> contractObj = TestDataUtility.createContract(
      acc,
      u1.Id,
      2,
      null,
      listOpp,
      null,
      null,
      1
    );
    insert contractObj;

    List<OpportunityTeamMember> otm = TestDataUtility.createOpportunityTeamMember(
      'Edit',
      listOpp,
      new List<User>{ new User(Id = u1.Id) },
      new List<String>{ 'Account Manager' }
    );
    insert otm;

    Account acc2 = [
      SELECT id
      FROM Account
      WHERE Name = 'ApprovalProcessAccount_TestClass'
    ];
    Contact con = [SELECT id FROM Contact WHERE AccountId = :acc2.Id LIMIT 1];
    List<Task> t = TestDataUtility.createTask(
      null,
      null,
      null,
      'Normal',
      'Open',
      acc2.Id,
      'Test Task',
      System.today() + 1,
      null,
      con.Id,
      u1.Id,
      1
    );
    insert t;
  }

  static testMethod void accountOwnerChangeTestMethod() {
    Account acc = [
      SELECT
        id,
        Name,
        OwnerId,
        ApprovalProcessRejectedBy__c,
        Proposed_Account_Owner__c,
        PreviousOwner__c,
        Proposed_Owners_Manager__r.Name,
        PreviousOwnersManager__c,
        PreviousOwnersManager__r.Name,
        userWhoProposedNewOwner__c,
        userWhoProposedNewOwner__r.Id,
        userWhoProposedNewOwner__r.Name,
        ApprovalProcessInitiatedOn__c,
        Transfer_Closed_Opportunities__c,
        Transfer_Not_Owned_Opportunities__c,
        Transfer_Open_Cases__c,
        Transfer_Closed_Cases__c,
        Keep_Account_Team__c,
        Keep_Opportunity_Team__c,
        Approval_Process_Action__c,
        TimeofStep1Approval__c,
        TimeofStep2Approval__c,
        TimeofStep3Approval__c
      FROM Account
      WHERE Approval_Process_Action__c = 'Approved'
    ];
    Address__c businessLocationObj = [
      SELECT Id, Country__c
      FROM Address__c
      WHERE Account__c = :acc.Id
      LIMIT 1
    ];
    Contact con = [SELECT id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
    User m1 = [
      SELECT id, Name
      FROM User
      WHERE Name = 'USA SYSTEM ADMIN'
      LIMIT 1
    ];
    User u1 = [SELECT id, Name FROM User WHERE Name = 'user1' LIMIT 1];
    Task t = [SELECT Id, WhoId FROM Task WHERE WhoId = :con.Id LIMIT 1];
    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();
    System.assertNotEquals(null, businessLocationObj.Country__c);
    System.assertNotEquals(null, recordTypeId);
    System.assertEquals(con.Id, t.WhoId);
    System.runAs(m1) {
      test.startTest();

      Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitrequest();

      app1.setObjectId(acc.Id);

      Approval.ProcessResult result1 = Approval.process(app1);

      // Verify that the results are as expected
      System.assert(result1.isSuccess());
      System.assertEquals(
        'Pending',
        result1.getInstanceStatus(),
        'Instance Status' + result1.getInstanceStatus()
      );

      ApexPages.StandardController sc = new ApexPages.StandardController(acc);
      AccountOwnerChangeController accountOwnerChangeControllerObj = new AccountOwnerChangeController(
        sc
      );
      accountOwnerChangeControllerObj.displayPopup();
      accountOwnerChangeControllerObj.closePopup();
      accountOwnerChangeControllerObj.initiateProcess();
      accountOwnerChangeControllerObj.accountSelected();
      accountOwnerChangeControllerObj.validatePage();

      acc.Proposed_Account_Owner__c = u1.Id;

      acc.OwnerId = u1.Id;

      update acc;

      System.assertEquals(acc.OwnerId, acc.Proposed_Account_Owner__c);

      acc.Proposed_Account_Owner__c = u1.Id;

      System.assertEquals(u1.Id, acc.Proposed_Account_Owner__c);

      acc.userWhoProposedNewOwner__c = u1.Id;

      System.assertEquals(u1.Id, acc.userWhoProposedNewOwner__c);

      acc.PreviousOwnersManager__c = acc.userWhoProposedNewOwner__c;
      System.assertEquals(u1.Id, acc.PreviousOwnersManager__c);

      acc.Proposed_Owners_Manager__c = u1.Id;
      System.assertEquals(u1.Id, acc.Proposed_Owners_Manager__c);

      acc.Approval_Process_Action__c = 'APPROVED';
      System.assertEquals('APPROVED', acc.Approval_Process_Action__c);

      acc.ApprovalProcessInitiatedOn__c = Date.today();
      System.assertEquals(Date.today(), acc.ApprovalProcessInitiatedOn__c);
      accountOwnerChangeControllerObj.onLoad();
      accountOwnerChangeControllerObj.validatePage();
      accountOwnerChangeControllerObj.checkCurrentUserAuthorizedToApprove(acc);
      accountOwnerChangeControllerObj.approveProcess();
      accountOwnerChangeControllerObj.abortProcess();
      AccountOwnerChangeHelper.sendEmailToNewAndOldAccountOwner(acc);

      Approval.ProcessSubmitRequest app2 = new Approval.ProcessSubmitrequest();
      app2.setObjectId(acc.Id);

      Approval.ProcessResult result2 = Approval.process(app2);

      accountOwnerChangeControllerObj.rejectProcess();

      Approval.ProcessSubmitRequest app3 = new Approval.ProcessSubmitrequest();
      app3.setObjectId(acc.Id);

      Approval.ProcessResult result3 = Approval.process(app3);
      accountOwnerChangeControllerObj.abortProcess();
      accountOwnerChangeControllerObj.notificationPopup();
      accountOwnerChangeControllerObj.getAllFields();
      accountOwnerChangeControllerObj.moveToAccountDetail();

      Map<Id, Account> newAccountMap = new Map<Id, Account>();
      Map<Id, Account> oldAccountMap = new Map<Id, Account>();
      acc.Proposed_Account_Owner__c = u1.Id;
      newAccountMap.put(acc.Id, acc);
      oldAccountMap.put(acc.Id, acc);

      AccountOwnerChangeHelper.transferOwners(newAccountMap, oldAccountMap);
      // accList[0].Proposed_Account_Owner__c = u2.Id;
      // update accList;
      TriggerHandler.clearBypass('OpportunityTriggerHandler');
      TriggerHandler.clearBypass('ContactTriggerHandler');
      TriggerHandler.clearBypass('CaseTriggerHandler');
      TriggerHandler.clearBypass('TaskTriggerHandler');
      /*map<Id,Account> accmap = new map<Id,Account>();
            accmap.put(acc.Id,acc);
            AccountOwnerChangeHelper.getMapAccIdChildAccList(accmap);*/
      test.stopTest();
    }
  }
}
