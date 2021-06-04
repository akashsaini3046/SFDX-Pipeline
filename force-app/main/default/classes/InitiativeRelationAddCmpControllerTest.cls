/*
 * Name: InitiativeRelationAddCmpControllerTest
 * Purpose: Test class for InitiativeRelationshipAddCmpController.
 * Author: Nagarro
 * Created Date: 15-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class InitiativeRelationAddCmpControllerTest {
  @isTest
  private static void testGetAccounts() {
    List<AccountInitiativeWrapper> lstAccountInitiativeWrapper = InitiativeRelationshipAddCmpController.getAccounts(
      'Test',
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id,
      null,
      null,
      false
    );
    System.assert(lstAccountInitiativeWrapper.size() > 0);

    lstAccountInitiativeWrapper = InitiativeRelationshipAddCmpController.getAccounts(
      'Test',
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id,
      null,
      null,
      true
    );
    System.assert(lstAccountInitiativeWrapper.size() > 0);

    lstAccountInitiativeWrapper = InitiativeRelationshipAddCmpController.getAccounts(
      '',
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id,
      JSON.serialize(
        new List<String>{ [SELECT Id FROM Account LIMIT 1][0].Id }
      ),
      null,
      false
    );
    System.assert(lstAccountInitiativeWrapper.size() > 0);
  }

  @isTest
  private static void testGetLeds() {
    List<LeadInitiativeWrapper> lstLeadInitiativeWrapper = InitiativeRelationshipAddCmpController.getLeads(
      'ABC',
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id,
      null,
      null
    );
    System.assert(lstLeadInitiativeWrapper.size() > 0);

    lstLeadInitiativeWrapper = InitiativeRelationshipAddCmpController.getLeads(
      '',
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id,
      JSON.serialize(new List<String>{ [SELECT Id FROM Lead LIMIT 1][0].Id }),
      null
    );
    System.assert(lstLeadInitiativeWrapper.size() > 0);
  }

  @isTest
  private static void testSaveInitiativeAccount() {
    List<String> lstSelectAccounts = new List<String>();
    lstSelectAccounts.add([SELECT Id FROM Account LIMIT 1][0].Id);
    Map<String, String> mapSaveResult = InitiativeRelationshipAddCmpController.saveInitiativeAccount(
      JSON.serialize(lstSelectAccounts),
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id
    );
    System.assert(mapSaveResult.get('SAVE_RESULT') == 'TRUE');
  }

  @isTest
  private static void testSaveLeadInitiative() {
    List<String> lstSelectLead = new List<String>();
    lstSelectLead.add([SELECT Id FROM Lead LIMIT 1][0].Id);
    Map<String, String> mapSaveResult = InitiativeRelationshipAddCmpController.saveInitiativeLead(
      JSON.serialize(lstSelectLead),
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id
    );
    System.assert(mapSaveResult.get('SAVE_RESULT') == 'TRUE');
  }

  @isTest
  private static void testIsInitiativeActive() {
    System.assert(
      InitiativeRelationshipAddCmpController.isInitiativeActive(
        [SELECT Id FROM Initiative__c LIMIT 1][0]
        .Id
      ) == true
    );
  }

  @isTest
  private static void testGetAccountById() {
    System.assert(
      InitiativeRelationshipAddCmpController.getAccountById(
        [SELECT Id FROM Account LIMIT 1][0]
        .Id
      ) != null
    );
  }

  @isTest
  private static void testGetAllInitiative() {
    System.assert(
      InitiativeRelationshipAddCmpController.getAllInitiative(
        [SELECT Id FROM Account LIMIT 1][0]
        .Id
      ) != null
    );
  }

  @isTest
  private static void testSaveAccountInitiative() {
    Map<String, String> mapSaveResult = InitiativeRelationshipAddCmpController.saveAccountInitiative(
      [SELECT Id FROM Account LIMIT 1][0]
      .Id,
      [SELECT Id FROM Initiative__c LIMIT 1][0]
      .Id
    );
    System.assert(mapSaveResult.get('SAVE_RESULT') == 'TRUE');
  }

  @isTest
  private static void testGetSearchFiled() {
    System.assert(
      InitiativeRelationshipAddCmpController.getSearchFiled('Account').size() >
      0
    );
  }

  @testSetup
  private static void testSetup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> childAccs;
    List<Initiative__c> lstInitiative = TestDataUtility.createInitiative(
      'Test Initiative',
      1
    );
    insert lstInitiative;
    //Initiative__c objInitiative = TestDataUtility.createInitiative('Test Initiative', 1);
    List<Account> objAccount = TestDataUtility.createAccount(
      'Test Account',
      null,
      null,
      null,
      false,
      1
    );
    insert objAccount;
    for (Account acc : objAccount) {
      childAccs = TestDataUtility.createAccount(
        'Test Child',
        null,
        null,
        acc.Id,
        false,
        1
      );
    }
    insert childAccs;

    List<Lead> objLead = TestDataUtility.createLead(
      'Test',
      'Test',
      'test@test.com',
      'ABC Ltd.',
      ConstantClass.LEADSOURCE,
      'Carriers',
      'Air',
      'ASSOCIATE',
      true,
      USerInfo.getUserId(),
      'US',
      'TEST',
      'GA',
      '123456',
      'TEST',
      1
    );
    insert objLead;
  }
}
