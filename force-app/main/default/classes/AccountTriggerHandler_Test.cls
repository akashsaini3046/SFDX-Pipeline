/*
 * Name: AccountTriggerHandler_Test
 * Purpose: Test class for AccountTriggerHandler.
 * Author: Nagarro
 * Created Date: 11-Sept-2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@IsTest
public class AccountTriggerHandler_Test {
  @testSetup
  static void dataSetup() {
    List<ProfileNames__c> Plist = TestDataUtility.ProfileNames();
    insert Plist;
    //for loop to create a map of Profile name and id
    Map<String, Id> pMap = new Map<String, Id>();
    for (Profile p : [SELECT Id, Name FROM Profile]) {
      pMap.put(p.Name, P.Id);
    }
    User u1 = TestDataUtility.createUser(
      null,
      pMap.get('Data Steward'),
      'standarduser',
      'Testing',
      'standarduser@testorg.com',
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
      pMap.get('Sales Leader'),
      'standarduser',
      'Testing1',
      'standarduser1@testorg.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u2;

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
    List<Account> accountObject1 = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      false,
      1
    );
    insert accountObject1;

    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      accountObject1,
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
      accountObject1,
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

    List<Opportunity> opp = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con,
      accountObject1,
      'Prospecting',
      null,
      System.today(),
      null,
      'Air',
      null,
      false,
      1
    );
    system.debug('###' + opp);
    insert opp;
    List<Account> accountList2 = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      null,
      null,
      false,
      4
    );
    for (Account acc : accountList2) {
      if (acc.Name == 'Test Account3') {
        acc.Created_From_Lead_Conversion__c = true;
      }
      if (acc.Name == 'Test Account1') {
        acc.Phone = '-123456789(0)';
        acc.Created_From_Lead_Conversion__c = true;
      }
    }
    insert accountList2;
  }

  static testMethod void accountTriggerHandler_TestMethod() {
    List<Account> accListToDelete = [SELECT Id FROM Account LIMIT 3];
    Account account1 = [SELECT Id FROM Account WHERE Name = 'Account 123'];
    Opportunity opp = [
      SELECT id, AccountId
      FROM Opportunity
      WHERE AccountId = :account1.Id
      LIMIT 1
    ];
    Address__c businessLocationObj = [
      SELECT Id, Account__c
      FROM Address__c
      WHERE Account__c = :account1.Id
      LIMIT 1
    ];
    User u1 = [SELECT Id FROM User WHERE Profile.Name = 'Data Steward' LIMIT 1];
    User u2 = [SELECT Id FROM User WHERE Profile.Name = 'Sales Leader' LIMIT 1];

    test.startTest();
    System.assertNotEquals(opp.AccountId, null);
    System.assertEquals(businessLocationObj.Account__c, opp.AccountId);

    try {
      delete accListToDelete;
    } catch (Exception e) {
      System.debug('Exception in Account Test Class' + e.getMessage());
    }
    test.stopTest();
  }

  static testMethod void testCreateTrackHistoryRecord() {
    List<Account> lstAccount = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Account' OR Name = 'Test Account1'
    ];
    Account objPrntAcc;
    Account objChldAcc;
    for (Account a : lstAccount) {
      if (a.Name == 'Test Account') {
        objPrntAcc = a;
      }
      if (a.Name == 'Test Account1') {
        objChldAcc = a;
      }
    }
    test.startTest();
    objChldAcc.ParentId = objPrntAcc.Id;
    update objChldAcc;
    test.stopTest();
    for (Track_History__c objTrackHistory : [
      SELECT Previous_Value__c, New_Value__c
      FROM Track_History__c
      WHERE Object_Name__c = 'Account' AND Operation__c = 'Modified'
      ORDER BY CreatedDate DESC
    ]) {
      System.assert(objTrackHistory.Previous_Value__c == null);
      System.assert(objTrackHistory.New_Value__c == 'Test Account');
    }
  }

  static testMethod void testDeleteAccounts() {
    List<Account> accListToDelete = [SELECT Id FROM Account LIMIT 3];
    Account account1 = [SELECT Id FROM Account WHERE Name = 'Account 123'];
    Opportunity opp = [
      SELECT id, AccountId
      FROM Opportunity
      WHERE AccountId = :account1.Id
      LIMIT 1
    ];
    Address__c businessLocationObj = [
      SELECT Id, Account__c
      FROM Address__c
      WHERE Account__c = :account1.Id
      LIMIT 1
    ];
    User u1 = [SELECT Id FROM User WHERE Profile.Name = 'Data Steward' LIMIT 1];
    User u2 = [SELECT Id FROM User WHERE Profile.Name = 'Sales Leader' LIMIT 1];

    test.startTest();
    System.assertNotEquals(opp.AccountId, null);
    System.assertEquals(businessLocationObj.Account__c, opp.AccountId);

    try {
      System.runAs(u1) {
        delete accListToDelete;
      }
      System.runAs(u2) {
        delete accListToDelete;
      }
    } catch (Exception e) {
      System.debug('Exception in Account Test Class' + e.getMessage());
    }
    test.stopTest();
  }
}
