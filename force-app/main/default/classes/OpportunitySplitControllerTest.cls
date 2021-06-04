/*
 * Name: OpportunitySplitControllerTest
 * Purpose: Test class for OpportunitySplitController
 * Author: Nagarro
 * Created Date: 1-Mar-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class OpportunitySplitControllerTest {
  /*
   * Method Name: testGetOpportunityLineItems
   * Purpose: test method for OpportunitySplitController.getOpportunityLineItems
   */
  public static testMethod void testGetOpportunityLineItems() {
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      'DESKTOP_CLOSED_WON'
    );
    System.assert(lstOpportunitySplitServiceWrapper.size() > 0);
  }

  /*
   * Method Name: testSaveSplitOpportunity
   * Purpose: test method for OpportunitySplitController.saveSplitOpportunity
   */
  public static testMethod void testSaveSplitOpportunity() {
    Test.startTest();
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      'DESKTOP_CLOSED_WON'
    );
    lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
    //Check split success
    System.assert(
      OpportunitySplitController.saveSplitOpportunity(
        [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
        .Id,
        lstOpportunitySplitServiceWrapper
      )
    );
    Test.stopTest();
  }

  /*
   * Method Name: testSaveSplitOpportunityNegative
   * Purpose: negative test method for OpportunitySplitController.saveSplitOpportunity
   */
  public static testMethod void testSaveSplitOpportunityNegative() {
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      'DESKTOP_CLOSED_WON'
    );
    lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
    //Check split failure
    System.assert(
      OpportunitySplitController.saveSplitOpportunity(
        null,
        lstOpportunitySplitServiceWrapper
      ) == false
    );
  }

  /*
   * Method Name: testGetOpportunity
   * Purpose: test method for OpportunitySplitController.getOpportunity
   */
  public static testMethod void testGetOpportunity() {
    System.assert(
      OpportunitySplitController.getOpportunity(
          [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
          .Id
        )
        .OpportunityLineItems.size() > 0
    );
  }

  /*
   * Method Name: testGetWonAndLostOppSize
   * Purpose: test method for OpportunitySplitController.getWonAndLostOppSize
   */
  public static testMethod void testGetWonAndLostOppSize() {
    Map<String, Decimal> mapWonLostOppSize = new Map<String, Decimal>();

    Test.startTest();
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      'DESKTOP_CLOSED_WON'
    );
    lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
    OpportunitySplitController.saveSplitOpportunity(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      lstOpportunitySplitServiceWrapper
    );

    mapWonLostOppSize = OpportunitySplitController.getWonAndLostOppSize(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id
    );
    System.assert(mapWonLostOppSize.get('WON_OPP_SIZE') == 4.00);
    System.assert(mapWonLostOppSize.get('LOST_OPP_SIZE') == 2.00);
    Test.stopTest();
  }

  /*
   * Method Name: testGetUIThemeDescription
   * Purpose: test method for OpportunitySplitController.getUIThemeDescription
   */
  public static testMethod void testGetUIThemeDescription() {
    List<String> lstTheme = new List<String>{
      'Theme1',
      'Theme2',
      'Theme3',
      'Theme4d',
      'Theme4t',
      'Theme4u',
      'PortalDefault',
      'Webstore'
    };
    System.assert(
      lstTheme.contains(OpportunitySplitController.getUIThemeDescription())
    );
  }

  /*
   * Method Name: testRestoreLostOpportunityLineItem
   * Purpose: test method for OpportunitySplitController.restoreLostOpportunityLineItem
   */
  public static testMethod void testRestoreLostOpportunityLineItem() {
    Test.startTest();
    List<OpportunitySplitServiceWrapper> lstOpportunitySplitServiceWrapper = OpportunitySplitController.getOpportunityLineItems(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      'DESKTOP_CLOSED_WON'
    );
    lstOpportunitySplitServiceWrapper[0].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[1].boolServiceStatus = true;
    lstOpportunitySplitServiceWrapper[2].boolServiceStatus = false;
    OpportunitySplitController.saveSplitOpportunity(
      [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Id,
      lstOpportunitySplitServiceWrapper
    );
    System.assert(
      [SELECT Id, Amount FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Amount == 4
    );

    Opportunity objOpportunity = [
      SELECT Id
      FROM Opportunity
      WHERE Name = 'Test Opportunity'
    ][0];
    objOpportunity.StageName = 'Proposal Presented';
    update objOpportunity;
    System.assert(
      [SELECT Id, Amount FROM Opportunity WHERE Name = 'Test Opportunity'][0]
      .Amount == 6
    );
    Test.stopTest();
  }

  /*
   * Method Name: testDataSetup
   * Purpose: Prepare test data
   */
  @testSetup
  public static void testDataSetup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    //Create Account
    List<Account> lstTestAccounts = TestDataUtility.createAccount(
      'Test Account',
      null,
      'Apparel',
      null,
      false,
      1
    );
    insert lstTestAccounts;
    //Create Child Account
    List<Account> childAccs;
    for (Account acc : lstTestAccounts) {
      if (acc.Name == 'Test Account') {
        childAccs = TestDataUtility.createAccount(
          'Child Test Account',
          null,
          'Apparel',
          acc.Id,
          false,
          1
        );
      }
    }
    insert childAccs;
    //Create business location
    List<Address__c> lstAddress = TestDataUtility.createBusinessLocation(
      lstTestAccounts,
      'Test Address line 1',
      'Test City',
      'CA',
      '123456',
      null,
      'US',
      1
    );
    insert lstAddress;
    //Create Contact
    List<Contact> lstTestContact = TestDataUtility.createContact(
      null,
      lstTestAccounts,
      lstAddress,
      'Test',
      ' LastName',
      'test@testExample.com',
      null,
      false,
      null,
      1
    );
    insert lstTestContact;
    //Create Opportunity
    Id idOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Create Record')
      .getRecordTypeId();
    List<Opportunity> lstTestOpportunity = TestDataUtility.createOpportunity(
      idOpportunityRecordTypeId,
      null,
      'Test Opportunity',
      lstTestContact,
      lstTestAccounts,
      'Prospecting',
      'USA - United States',
      Date.today(),
      Date.today(),
      'Air',
      null,
      false,
      1
    );
    insert lstTestOpportunity;
    system.debug('****' + lstTestOpportunity);
    Opportunity oppobj = new Opportunity();
    for (Opportunity opp : lstTestOpportunity) {
      oppobj.Id = opp.Id;
    }
    system.debug('****' + oppobj);
    //Create products
    List<Product2> lstProducts = TestDataUtility.createProduct(
      new List<String>{ 'Air', 'Insurance', 'Asset Management' }
    );
    insert TestDataUtility.createOpportunityLineItem(oppobj, lstProducts, 1, 2);
  }
}
