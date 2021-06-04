/*
 * Name: OpportunityTriggerHandler_Test
 * Purpose: Test class for OpportunityTriggerHandler.
 * Author: Nagarro
 * Created Date: 16-Oct-2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest
public class OpportunityTriggerHandler_Test {
  @testSetup
  static void setup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;
    Map<String, Id> pMap = new Map<String, Id>();
    for (Profile p : [SELECT Id, Name FROM Profile]) {
      pMap.put(p.Name, P.Id);
    }
    User u1 = TestDataUtility.createUser(
      null,
      pMap.get('Pricing Agent'),
      null,
      'User1',
      'teammember1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u1;
    List<Account> accObj1 = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      false,
      1
    );
    insert accObj1;

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
    List<Contact> con = TestDataUtility.createContact(
      null,
      accObj1,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert con;

    List<Product2> lstProducts = TestDataUtility.createProduct(
      new List<String>{ 'CrowleyFresh', 'Air', 'Asset Management' }
    );
    CountryRegionMapping__c crm = TestDataUtility.CountryRegionMapping();
    insert crm;

    List<ProfileNames__c> plist = TestDataUtility.ProfileNames();
    insert plist;

    List<Opportunity> opp1 = TestDataUtility.createOpportunity(
      null,
      u1.Id,
      'Opp1',
      con,
      accObj1,
      ConstantClass.PROSPECTING_OPP_STAGE,
      null,
      System.today(),
      null,
      'CrowleyFresh;',
      null,
      true,
      1
    );
    insert opp1;
    List<Contract> contractObj = TestDataUtility.createContract(
      accObj1,
      null,
      2,
      System.today(),
      opp1,
      'Pricing Team Review',
      [SELECT Id FROM Pricebook2 LIMIT 1]
      .Id,
      1
    );
    insert contractObj;
    for (Opportunity opp : opp1) {
      OppAmountReminderController.getOpportunityStageValue(opp.Id);
      OppAmountReminderController.getQuotedPriceOfOpportunity(opp.Id);
    }

    List<AccountTeamMember> atm = TestDataUtility.createAccountTeamMember(
      'Edit',
      'Edit',
      'Edit',
      'Edit',
      new List<Account>{ accObj1[0] },
      new List<User>{ u1 },
      new List<String>{ 'Contracts Rep' }
    );
    insert atm;
  }

  static testMethod void insertOpportunityTestMethod() {
    Opportunity opp = [SELECT Id, Service_Type__c, StageName FROM Opportunity];
    Test.startTest();
    System.assertNotEquals(null, opp);
    System.assertEquals(opp.StageName, ConstantClass.PROSPECTING_OPP_STAGE);
    Test.stopTest();
  }

  static testMethod void insertOpportunityLineItemTestMethod() {
    Opportunity opp = [SELECT Id, Service_Type__c FROM Opportunity];
    System.assertNotEquals(null, opp);
    Test.startTest();
    PriceBookEntry pbEntry = [SELECT Id, UnitPrice FROM PriceBookEntry][0];
    OpportunityLineItem oppLineItem = new OpportunityLineItem();
    oppLineItem.OpportunityId = opp.Id;
    oppLineItem.Quantity = 5;
    oppLineItem.PricebookEntryId = pbEntry.Id;
    oppLineItem.TotalPrice = oppLineItem.Quantity * pbEntry.UnitPrice;
    insert oppLineItem;
    System.assertNotEquals(null, oppLineItem);
    Test.stopTest();
  }

  static testMethod void updateOpportunityTestMethod() {
    Opportunity opp = [SELECT Id, Service_Type__c, StageName FROM Opportunity];
    Test.startTest();
    System.assertNotEquals(null, opp);
    System.assertEquals(opp.StageName, ConstantClass.PROSPECTING_OPP_STAGE);

    opp.Service_Type__c = 'Air;';
    opp.StageName = 'Contracting';
    opp.Est_Business_Start_Date__c = System.today();
    update opp;
    Test.stopTest();
  }

  static testMethod void deleteOpportunityTestMethod() {
    Opportunity opp = [SELECT Id FROM Opportunity];
    System.assertNotEquals(null, opp);
    List<Opportunity> oppListToDelete = new List<Opportunity>();
    oppListToDelete.add(opp);

    test.startTest();
    try {
      delete oppListToDelete;
    } catch (Exception e) {
      System.debug('Exception in Opportunity Test Class' + e.getMessage());
    }

    test.stopTest();
  }

  static testMethod void deleteOpportunityLineItemTestMethod2() {
    OpportunityLineItem oppLineItem = [SELECT Id FROM OpportunityLineItem];
    System.assertNotEquals(null, oppLineItem);
    List<OpportunityLineItem> oppLineItemListToDelete = new List<OpportunityLineItem>();
    oppLineItemListToDelete.add(oppLineItem);

    test.startTest();

    try {
      delete oppLineItemListToDelete;
    } catch (Exception e) {
      System.debug('Exception in Opportunity Test Class' + e.getMessage());
    }
    test.stopTest();
  }
}
