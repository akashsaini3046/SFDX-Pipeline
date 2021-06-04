/*
 * Name: ContactTriggerHandlerTest
 * Purpose: Test class for ContactTriggerHandler.
 * Author: Nagarro
 * Created Date: 11-Sept-2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@IsTest
public class ContactTriggerHandlerTest {
  @testSetup
  static void dataSetup() {
    List<ProfileNames__c> Plist = TestDataUtility.ProfileNames();
    insert Plist;

    GovernanceTeamEmail__c govEmail = TestDataUtility.GovernanceTeamEmail();
    insert govEmail;

    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> lstAccObj = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      true,
      1
    );
    insert lstAccObj;

    List<Account> lstAccObj1 = TestDataUtility.createAccount(
      'Account 456',
      null,
      null,
      null,
      true,
      1
    );
    insert lstAccObj1;

    List<Address__c> lstBusinessLocationObj = TestDataUtility.createBusinessLocation(
      lstAccObj,
      'Business Location2',
      'City1',
      'CA',
      '1111111',
      '88888888888',
      'US',
      1
    );
    insert lstBusinessLocationObj;

    List<Address__c> lstBusinessLocationObj1 = TestDataUtility.createBusinessLocation(
      lstAccObj1,
      'Business Location3',
      'City2',
      'CA',
      '1111112',
      '88888888883',
      'US',
      1
    );
    insert lstBusinessLocationObj1;

    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();

    List<Contact> con = TestDataUtility.createContact(
      recordTypeId,
      lstAccObj,
      lstBusinessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      true,
      null,
      1
    );
    insert con;
    List<Account> accList = new List<Account>();
    List<Case> blrevcs = TestDataUtility.createBLRevisionCase(
      accList,
      con,
      null,
      'BL Rev Case 1',
      'Description 1',
      'Web',
      UserInfo.getUserId(),
      'Open',
      1
    );
    insert blrevcs;
    List<Contact> con1 = new List<Contact>();
    con1.addAll(con);
    con[0].AccountId = lstAccObj1[0].Id;
    con[0].Address__c = lstBusinessLocationObj1[0].Id;
    update con;
    Map<Id, Contact> newContactMap = new Map<Id, Contact>();
    newContactMap.putAll(con);
    ContactTriggerHandler.UpdateAccountonCase(con, con1, newContactMap);

    system.debug('****' + con);

    List<Opportunity> opp = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con,
      lstAccObj1,
      'Prospecting',
      null,
      System.today(),
      null,
      'Air',
      null,
      false,
      1
    );
    insert opp;
  }

  @isTest
  private static void contactTriggerHandler_TestMethod() {
    Account accountobject = [SELECT id FROM Account WHERE Name = 'Account 456'];
    List<Address__c> blList = [
      SELECT Id, Account__c, Country__c
      FROM Address__c
      WHERE Account__c = :accountobject.Id
      LIMIT 1
    ];
    system.debug('****' + blList);
    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();
    Contact con1 = [
      SELECT Id, Address__c
      FROM Contact
      WHERE AccountId = :accountobject.Id
      LIMIT 1
    ];
    System.debug('****' + con1.Address__c);
    List<Contact> conListToDelete = new List<Contact>();
    conListToDelete.add(con1);
    Opportunity opp = [
      SELECT Id
      FROM Opportunity
      WHERE AccountId = :accountobject.Id
      LIMIT 1
    ];
    test.startTest();
    for (Address__c bl : blList) {
      System.assertNotEquals(null, bl.Country__c);
      System.assertEquals(bl.Id, con1.Address__c);
    }
    System.assertNotEquals(null, recordTypeId);
    System.assertNotEquals(null, opp);
    try {
      delete conListToDelete;
    } catch (Exception e) {
      System.debug('Exception in Contact Test Class' + e.getMessage());
    }
    test.stopTest();
  }
}
