/*
 * Name: OpportunityTeamMemberTriggerHandlerTest
 * Purpose: Test class for OpportunityTeamMemberTriggerHandler
 * Author: Nagarro
 * Created Date: 05/04/2020
 * Modification History
 * Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
@isTest
public class OpportunityTeamMemberTriggerHandlerTest {
  @testSetup
  static void setup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

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

    Id salesAgentProfileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Sales Agent'
      LIMIT 1
    ]
    .Id;

    User salesAgent = TestDataUtility.createUser(
      null,
      salesAgentProfileId,
      null,
      'Agent',
      'salesagent1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert salesAgent;
    List<Opportunity> opp1 = TestDataUtility.createOpportunity(
      null,
      null,
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
  }
  static testMethod void addOpportunityTeamMemberTest() {
    User salesAgent = [SELECT Id FROM User WHERE name = 'Agent'];

    Test.startTest();
    List<Opportunity> oppList = [SELECT Id FROM Opportunity];

    OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
    oppTeamMem.OpportunityId = oppList[0].Id;
    oppTeamMem.OpportunityAccessLevel = 'Read';
    oppTeamMem.TeamMemberRole = 'Sales Agent';
    oppTeamMem.UserId = salesAgent.Id;

    insert oppTeamMem;

    oppTeamMem.OpportunityAccessLevel = 'Edit';
    update oppTeamMem;

    Test.stopTest();
  }
}
