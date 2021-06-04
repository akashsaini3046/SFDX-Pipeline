/*
 * Name: LeadTriggerHandler_Test
 * Purpose: Test class for LeadTriggerHandler.
 * Author: Nagarro
 * Created Date: 25-Sept-2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest
public class LeadTriggerHandler_Test {
  @testSetup
  static void setup() {
    Map<String, Id> pMap = new Map<String, Id>();
    for (Profile p : [SELECT Id, Name FROM Profile]) {
      pMap.put(p.Name, P.Id);
    }
    //Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1].Id;
    User u = TestDataUtility.createUser(
      null,
      pMap.get('System Administrator'),
      null,
      'Admin',
      'adminemail@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u;

    User u1 = TestDataUtility.createUser(
      null,
      pMap.get('System Administrator'),
      null,
      'Admin1',
      'adminemail1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u1;

    //Market Manager profile
    //Id marketManagerProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' Limit 1].Id;
    User marketManager = TestDataUtility.createUser(
      null,
      pMap.get('Sales Manager'),
      null,
      'Manager',
      'marektm1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    marketManager.Region__c = 'PRT - Puerto Rico';
    insert marketManager;
    System.debug('marketManager: ' + marketManager.Id);
    //Assign Market Manager permission set
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Permission_Set_For_Marketing_Managers'
    ];
    insert new PermissionSetAssignment(
      AssigneeId = marketManager.id,
      PermissionSetId = ps.Id
    );

    //Sales agent profile
    //Id salesAgentProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Agent' Limit 1].Id;
    User salesAgent = TestDataUtility.createUser(
      null,
      pMap.get('Sales Agent'),
      null,
      'Agent',
      'salesagent1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      marketManager.Id
    );
    salesAgent.Region__c = 'PRT - Puerto Rico';
    insert salesAgent;
    System.debug('salesAgent: ' + salesAgent.Id);
    System.debug('salesAgent manager: ' + salesAgent.ManagerId);

    Group USAGroup = new Group(Name = 'Queue - USA', type = 'Queue');
    insert USAGroup;

    GroupMember USAGroupMember = new GroupMember(
      UserOrGroupId = u1.Id,
      GroupId = USAGroup.Id
    );
    insert USAGroupMember;

    QueuesObject USAQueue = new QueueSObject(
      QueueID = USAGroup.id,
      SobjectType = 'Lead'
    );
    insert USAQueue;

    Group CARGroup = new Group(Name = 'Queue - CAR', type = 'Queue');
    insert CARGroup;

    GroupMember CARGroupMember = new GroupMember(
      UserOrGroupId = u.Id,
      GroupId = CARGroup.Id
    );
    insert CARGroupMember;

    QueuesObject CARQueue = new QueueSObject(
      QueueID = CARGroup.id,
      SobjectType = 'Lead'
    );
    insert CARQueue;

    System.runAs(new User(Id = UserInfo.getUserId())) {
      List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
      insert UserRegionRole;

      CountryRegionMapping__c crm = new CountryRegionMapping__c();
      crm.Name = '1';
      crm.Country_Name__c = 'United States';
      crm.Region__c = 'USA';
      insert crm;

      List<Lead> consolidatedLeadList = new List<Lead>();
      List<Lead> leadObj1 = TestDataUtility.createLead(
        'Test',
        'Test',
        'test@test.com',
        'ABC Ltd.',
        ConstantClass.LEADSOURCE,
        'Carriers',
        'Air',
        'ASSOCIATE',
        true,
        u.Id,
        'US',
        'TEST',
        'GA',
        '123456',
        'TEST',
        1
      );
      // insert leadObj1;
      consolidatedLeadList.addAll(leadObj1);

      List<Lead> leadObj2 = TestDataUtility.createLead(
        'Test1',
        'Test 23',
        'test11@test.com',
        'ABC Ltd.',
        ConstantClass.LEADSOURCE,
        'Carriers',
        'Air',
        'ASSOCIATE',
        true,
        [SELECT id FROM Group WHERE Name = 'Queue - CAR' LIMIT 1]
        .Id,
        'US',
        'TEST',
        'GA',
        '234567',
        'TEST',
        1
      );
      //insert leadObj2;
      consolidatedLeadList.addAll(leadObj2);
      List<Lead> leadObj3 = TestDataUtility.createLead(
        'Test2',
        'Test 22',
        'test22@test.com',
        'ABC Ltd.',
        ConstantClass.LEADSOURCE,
        'Carriers',
        'Air',
        'ASSOCIATE',
        true,
        [SELECT id FROM Group WHERE Name = 'Queue - CAR' LIMIT 1]
        .Id,
        'US',
        'TEST',
        'GA',
        '234575',
        'TEST',
        1
      );
      // insert leadObj3;
      consolidatedLeadList.addAll(leadObj3);
      List<Lead> leadObj4 = TestDataUtility.createLead(
        'Test3',
        'Test 33',
        'test33@test.com',
        'ABC Ltd.',
        ConstantClass.LEADSOURCE,
        'Carriers',
        'Air',
        'ASSOCIATE',
        true,
        [SELECT id FROM Group WHERE Name = 'Queue - CAR' LIMIT 1]
        .Id,
        'US',
        'TEST',
        'GA',
        '234575',
        'TEST',
        1
      );
      // insert leadObj4;
      consolidatedLeadList.addAll(leadObj4);
      insert consolidatedLeadList;
      List<Account> accObj1 = TestDataUtility.createAccount(
        'Account 123',
        null,
        null,
        null,
        false,
        1
      );
      insert accObj1;
      system.debug('acccccccccccccccccccccccccccccccccccccccc' + accObj1);

      GovernanceTeamEmail__c govEmail = TestDataUtility.GovernanceTeamEmail();
      insert govEmail;

      List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
        accObj1,
        'BL1',
        'City1',
        'CA',
        '1111111',
        '88888888888',
        'US',
        1
      );
      insert businessLocationObj;

      Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Create_Record')
        .getRecordTypeId();

      System.assertNotEquals(null, recordTypeId);

      List<Contact> con = TestDataUtility.createContact(
        null,
        accObj1,
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
      List<Task> t;
      for (Lead lobj : leadObj1) {
        t = TestDataUtility.createTask(
          null,
          'Task',
          null,
          'Normal',
          'Open',
          null,
          'Lead Follow Up- ' + lobj.Company,
          System.today(),
          null,
          lobj.Id,
          lobj.OwnerId,
          1
        );
      }
      insert t;
      List<Product2> lstProducts = TestDataUtility.createProduct(
        new List<String>{ 'CrowleyFresh', 'Air', 'Asset Management' }
      );
      List<Initiative__c> objInitiative = TestDataUtility.createInitiative(
        'Test Initiative',
        1
      );
      insert objInitiative;
    }
  }

  static testMethod void insertTestMethod2() {
    Lead leadObj4 = [
      SELECT Id, Phone
      FROM lead
      WHERE FirstName = 'Test3'
      LIMIT 1
    ];
    test.startTest();
    try {
      leadObj4.Phone = '2222234';

      leadObj4.MobilePhone = '2222234';

      update leadObj4;
    } catch (exception e) {
      system.debug(e.getMessage());
    }
    test.stopTest();
  }

  static testMethod void insertTestMethod1() {
    Lead leadObj3 = [
      SELECT Id, Phone
      FROM lead
      WHERE FirstName = 'Test2'
      LIMIT 1
    ];
    system.debug('phone23456--------------' + leadObj3.Phone);
    test.startTest();
    try {
      leadObj3.Phone = '233333345';
      update leadObj3;
    } catch (exception e) {
      system.debug(e.getMessage());
    }

    try {
      leadObj3.Phone = null;
      update leadObj3;
    } catch (exception e) {
      system.debug(e.getMessage());
    }

    try {
      leadObj3.Phone = 'qwertyui';
      update leadObj3;
    } catch (exception e) {
      system.debug(e.getMessage());
    }
    test.stopTest();
  }

  static testMethod void insertTestMethod() {
    Lead leadObj1 = [
      SELECT Id, OwnerId, Company, IsConverted
      FROM lead
      WHERE FirstName = 'Test'
      LIMIT 1
    ];

    Contact con = [SELECT Id FROM Contact];
    Account acc = [SELECT Id FROM Account];

    User admin = [SELECT Id FROM User WHERE Name = 'Admin' LIMIT 1];

    System.assertNotEquals(null, leadObj1);
    System.assertNotEquals(null, con);
    System.assertNotEquals(null, acc);

    Task t = [
      SELECT Id, Who.Id, Who.Type, Status, OwnerId
      FROM Task
      WHERE Who.Type = 'Lead' AND Who.Id = :leadObj1.Id
      LIMIT 1
    ];

    System.assertNotEquals(null, t);
    t.Status = 'Completed';
    update t;

    Test.startTest();
    leadObj1.Hot_Lead__c = true;
    update leadObj1;

    try {
      leadObj1.Phone = '1222223';
      update leadObj1;
    } catch (exception e) {
      system.debug(e.getMessage());
    }

    try {
      leadObj1.Phone = 'abc';
      update leadObj1;
    } catch (exception e) {
      system.debug(e.getMessage());
    }

    System.runAs(admin) {
      Database.LeadConvert lc = new database.LeadConvert();
      lc.setLeadId(leadObj1.id);
      lc.setDoNotCreateOpportunity(true);
      lc.setConvertedStatus('Qualified');
      lc.setAccountId(acc.Id);
      lc.setContactId(con.Id);

      Database.LeadConvertResult lcr = Database.convertLead(lc);

      System.assert(lcr.isSuccess());
      System.assertEquals(leadObj1.OwnerId, t.OwnerId);

      Test.stopTest();
    }
  }

  static testMethod void updateTestMethod() {
    Lead leadObj1 = [SELECT Id, Followup__c FROM Lead LIMIT 1];
    System.assertNotEquals(null, leadObj1);

    Test.startTest();
    leadObj1.Followup__c = false;
    update leadObj1;
    Test.stopTest();
  }

  static testMethod void deleteTestMethod() {
    Lead leadObj1 = [SELECT Id FROM Lead LIMIT 1];

    Test.startTest();
    List<Lead> leadListToDelete = new List<Lead>();
    leadListToDelete.add(leadObj1);

    try {
      delete leadListToDelete;
      System.assert([SELECT Id FROM Lead WHERE Id = :leadObj1.Id].size() == 0);
    } catch (Exception e) {
      System.debug('Exception in Lead Test Class' + e.getMessage());
    }
    Test.stopTest();
  }

  static testMethod void changeLeadOwner() {
    User admin1 = [SELECT Id FROM User WHERE Name = 'Admin1' LIMIT 1];
    User admin = [SELECT Id FROM User WHERE Name = 'Admin' LIMIT 1];

    Lead leadObj1 = [
      SELECT Id, OwnerId, Followup__c
      FROM Lead
      WHERE FirstName = 'Test'
      LIMIT 1
    ];
    System.assertNotEquals(null, leadObj1);

    Test.startTest();
    leadObj1.Followup__c = false;
    leadObj1.OwnerId = [SELECT id FROM Group WHERE Name = 'Queue - CAR' LIMIT 1]
    .Id;
    update leadObj1;
    Test.stopTest();
  }

  static testMethod void changeLeadOwner1() {
    User admin1 = [SELECT Id FROM User WHERE Name = 'Admin1' LIMIT 1];
    User admin = [SELECT Id FROM User WHERE Name = 'Admin' LIMIT 1];

    Lead leadObj1 = [
      SELECT Id, OwnerId, Followup__c
      FROM Lead
      WHERE FirstName = 'Test1'
      LIMIT 1
    ];
    System.assertNotEquals(null, leadObj1);

    Test.startTest();
    leadObj1.Followup__c = false;
    leadObj1.OwnerId = admin1.Id;
    update leadObj1;
    Test.stopTest();
  }
  //Test logic when lead created by Sales Agent,owner is changed to his Market Manager
  static testMethod void assignLeadOwnerToMarketManager() {
    User salesAgent = [SELECT Id FROM User WHERE Name = 'Agent' LIMIT 1];
    User marketManager = [SELECT Id FROM User WHERE Name = 'Manager' LIMIT 1];

    System.debug('salesAgent userid: ' + salesAgent.Id);
    System.debug('marketManager userid: ' + marketManager.Id);

    Id leadId;
    Test.startTest();
    Lead leadObj = new lead();
    System.runAs(salesAgent) {
      leadObj.FirstName = 'Sales';
      leadObj.LastName = 'Agent';
      leadObj.Email = 'test@test.com';
      leadObj.Company = 'ABC1234 Ltd.';
      leadObj.LeadSource = 'Other';
      leadObj.Industry = 'Apparel';
      leadObj.Service__c = 'Air';
      leadObj.Title = 'Test';
      leadObj.Followup__c = true;
      leadObj.OwnerId = UserInfo.getUserId();
      leadObj.Country = 'AF';
      leadObj.Country__c = 'AF';
      leadObj.PostalCode = '201010';
      leadObj.Postal_Code__c = '201010';
      leadObj.Phone = '12345678923';
      leadObj.Sales_Rep_Region__c = 'CAM - Central America';
      leadObj.Status = 'New';
      leadObj.Address_Line_1__c = 'New York';
      leadObj.Address_Line_2__c = 'New York';
      leadObj.Address_Line_3__c = 'New York';
      //leadObj.Conversion_Ready__c = True;
      leadObj.City = 'New York';
      leadObj.City__c = 'New York';
      //leadObj.Created_from_Lead_Conversion__c =true;
      System.debug('before update');
      insert leadObj;
      System.debug('after update');

      //Contact c = [Select Id, Name from Contact where Name='Test con1'];
      //System.debug('contact: ' + c);

      leadId = leadObj.Id;
      System.debug('leadObj id: ' + leadObj.Id);
      System.debug('leadObj ownerid: ' + leadObj.OwnerId);
    }

    Lead leadobj2 = [
      SELECT Id, OwnerID, Owner.Name, Createdby.Name, createdbyId
      FROM Lead
      WHERE Id = :leadId
    ];

    List<Task> tasklist = new List<Task>(
      [
        SELECT Id, Who.Id, Who.Type, Status
        FROM Task
        WHERE Who.Type = 'Lead' AND Who.Id = :leadobj2.Id
      ]
    );

    // System.runAs(marketManager){
    for (Task t : tasklist) {
      t.Status = 'Completed';
    }
    System.debug('tasklist: ' + tasklist);
    update tasklist;

    System.debug('leadobj2 owner: ' + leadobj2.Owner.Name);
    System.debug('leadobj2 owner: ' + leadobj2.createdby.Name);

    System.debug('runAS: ' + userInfo.getUserId());
    Database.leadConvert lc = new Database.leadConvert();
    lc.setLeadId(leadObj.Id);
    leadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    System.debug('convertStatus: ' + convertStatus);
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    System.debug('lcr isSuccess: ' + lcr.isSuccess());
    System.debug('acc id: ' + lcr.getAccountId());
    System.debug('con id: ' + lcr.getContactId());
    System.debug('opp id: ' + lcr.getOpportunityId());
    List<Lead> leadList = [
      SELECT Id, IsConverted
      FROM Lead
      WHERE Id = :leadObj.Id
    ];
    System.debug('leadObj----------' + leadList);
    System.assert(lcr.isSuccess());

    //}
    Test.stopTest();
  }
  static testMethod void initiativeConvertLead() {
    Initiative__c objInitiative = [SELECT Id FROM Initiative__c LIMIT 1];
    Test.startTest();
    Lead leadObj = new lead();
    leadObj.FirstName = 'Sales';
    leadObj.Initiative__c = objInitiative.Id;
    leadObj.Hot_Lead__c = true;
    leadObj.LastName = 'Agent';
    leadObj.Email = 'test@test.com';
    leadObj.Company = 'ABC1234 Ltd.';
    leadObj.LeadSource = 'Other';
    leadObj.Industry = 'Apparel';
    leadObj.Service__c = 'Air';
    leadObj.Title = 'Test';
    leadObj.Followup__c = true;
    leadObj.OwnerId = UserInfo.getUserId();
    leadObj.Country = 'AF';
    leadObj.Country__c = 'AF';
    leadObj.PostalCode = '201010';
    leadObj.Postal_Code__c = '201010';
    leadObj.Phone = '12345678923';
    leadObj.Sales_Rep_Region__c = 'CAM - Central America';
    leadObj.Status = 'New';
    leadObj.Address_Line_1__c = 'New York';
    leadObj.Address_Line_2__c = 'New York';
    leadObj.Address_Line_3__c = 'New York';
    leadObj.City = 'New York';
    leadObj.City__c = 'New York';
    insert leadObj;

    List<Task> tasklist = new List<Task>(
      [
        SELECT Id, Who.Id, Who.Type, Status
        FROM Task
        WHERE Who.Type = 'Lead' AND Who.Id = :leadObj.Id
      ]
    );

    // System.runAs(marketManager){
    for (Task t : tasklist) {
      t.Status = 'Completed';
    }
    System.debug('tasklist: ' + tasklist);
    update tasklist;

    System.debug('runAS: ' + userInfo.getUserId());

    Database.leadConvert lc = new Database.leadConvert();
    lc.setDoNotCreateOpportunity(true);
    lc.setLeadId(leadObj.Id);
    leadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    System.debug('convertStatus: ' + convertStatus);
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    System.debug('lcr isSuccess: ' + lcr.isSuccess());
    System.debug('acc id: ' + lcr.getAccountId());
    System.debug('con id: ' + lcr.getContactId());
    System.debug('opp id: ' + lcr.getOpportunityId());
    List<Lead> leadList = [
      SELECT Id, IsConverted
      FROM Lead
      WHERE Id = :leadObj.Id
    ];
    System.debug('leadObj----------' + leadList);
    System.assert(lcr.isSuccess());
    Test.stopTest();
  }
}
