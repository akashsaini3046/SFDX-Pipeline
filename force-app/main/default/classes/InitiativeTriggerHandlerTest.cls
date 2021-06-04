/*
 * Name: InitiativeTriggerHandlerTest
 * Purpose: Test class of InitiativeTriggerHandler
 * Author: Nagarro
 * Created Date: 06-Feb-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class InitiativeTriggerHandlerTest {
  @isTest
  static void checkAndPreventDeleteTest() {
    try {
      delete [SELECT Id FROM Initiative__c];
    } catch (Exception objEx) {
      System.assert(
        objEx.getMessage().contains(Label.AINI_INITIATIVE_DELETION_NOT_ALLOWED)
      );
    }
  }

  /*
   * Method Name: testDataSetup
   * Purpose: Prepare test data
   */
  @testSetup
  public static void testDataSetup() {
    //Create Initiative
    List<Initiative__c> lstInitiative = TestDataUtility.createInitiative(
      'Test Initiative',
      1
    );
    insert lstInitiative;
  }
}
