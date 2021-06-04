/*
 * Name: SendEmailToPricingTeamControllerTest
 * Purpose: Test class for Email Sent Functionality For Pricing Quote On Click of Send Email button for SendEmailToPricingTeamController Class.
 * Author: Nagarro
 * Created Date: 13-April-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest
private class SendEmailToPricingTeamControllerTest {
  @TestSetup
  static void setupData() {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

    GovernanceTeamEmail__c govEmail = TestDataUtility.GovernanceTeamEmail();
    insert govEmail;
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> accObj1 = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      true,
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
      true,
      null,
      1
    );
    insert con;

    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;
    String customLabelValue = System.Label.PricingTeamEmail;
    List<Opportunity> opp = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con,
      accObj1,
      'Prospecting',
      null,
      System.today(),
      null,
      'Air',
      'CaribbeanBreakbulk@Crowley.com',
      false,
      1
    );
    insert opp;
  }

  // Test Method to check Email Send Functionality In case of Email Send Successfully.
  private static testMethod void validateSendEmailToPricng() {
    Test.startTest();
    Opportunity opp1 = [
      SELECT id, name, PricingTeamEmailPicklist__c
      FROM Opportunity
      WHERE name = 'Opp1'
      LIMIT 1
    ];
    ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
    SendEmailToPricingTeamController stpc = new SendEmailToPricingTeamController(
      sc
    );
    stpc.sendEmail();
    System.assert(stpc.redirect() != null);
    Test.stopTest();
  }

  // Test Method to check Email Send Functionality In case of invalid Email ID.
  private static testMethod void validateSendEmailToPricngFail() {
    Test.startTest();
    Opportunity opp2 = [
      SELECT id, name, PricingTeamEmailPicklist__c
      FROM Opportunity
      WHERE name = 'Opp1'
      LIMIT 1
    ];
    ApexPages.StandardController sc = new ApexPages.StandardController(opp2);
    SendEmailToPricingTeamController stpc = new SendEmailToPricingTeamController(
      sc
    );
    stpc.sendEmail();
    System.assert(stpc.redirect() != null);
    Test.stopTest();
  }
}
