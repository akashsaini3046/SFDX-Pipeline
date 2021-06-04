/*
 * Name: GoalRelationshipTriggerHandlerTest
 * Purpose: Test class of GoalRelationshipTriggerHandler
 * Author: Nagarro
 * Created Date: 06-Feb-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class GoalRelationshipTriggerHandlerTest {
  @isTest
  static void checkAndPreventDeleteTest() {
    try {
      delete [SELECT Id FROM Goal_Initiative__c];
    } catch (Exception objEx) {
      System.assert(
        objEx.getMessage().contains(Label.AINI_GI_DELETION_NOT_ALLOWED)
      );
    }
  }
  /*
   * Method Name: testDataSetup
   * Purpose: Prepare test data
   */
  @testSetup
  public static void testDataSetup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    Id initId, accId;
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
    for (Account acc : lstTestAccounts) {
      accId = acc.Id;
    }
    //Create Initiative
    List<Initiative__c> lstInitiative = TestDataUtility.createInitiative(
      'Test Initiative',
      1
    );
    insert lstInitiative;
    for (Initiative__c init : lstInitiative) {
      initId = init.Id;
    }
    //Goal Initiative
    Goal_Initiative__c objGoalInitiative = TestDataUtility.createInitiativeRelationship(
      initId,
      accId
    );
    insert objGoalInitiative;
  }
}
