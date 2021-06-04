/*
 * Name: TransportationSpendControllerTest
 * Purpose: Test class for TransportationSpendController
 * Author: Nagarro
 * Created Date: 9-Feb-2021
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class TransportationSpendControllerTest {
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
    //Create Transportation Spend
    Transportation_Spend__c tspRec = new Transportation_Spend__c();
    tspRec.Account__c = lstTestAccounts[0].Id;
    tspRec.Service__c = 'AIR';
    tspRec.Sub_Service__c = '';
    insert tspRec;
  }

  /*
   * Method Name: testGetTransportationSpends
   * Purpose: test method for TransportationSpendController.getTransportationSpends
   */
  public static testMethod void testGetTransportationSpends() {
    List<TransportationSpendController.wrapperClass> lstTspWrapperClass = TransportationSpendController.getTransportationSpends(
      [SELECT Id FROM Account WHERE Name = 'Test Account'][0]
      .Id
    );
    System.assert(lstTspWrapperClass.size() > 0);
  }

  /*
   * Method Name: testSaveSpends
   * Purpose: test method for TransportationSpendController.saveSpends
   */
  public static testMethod void testSaveSpends() {
    Test.startTest();
    List<TransportationSpendController.wrapperClass> lstTspWrapperClass = new List<TransportationSpendController.wrapperClass>();
    TransportationSpendController.wrapperClass wcObj = new TransportationSpendController.wrapperClass();
    wcObj.Amount = 200.00;
    wcObj.accountId = [SELECT Id FROM Account WHERE Name = 'Test Account'][0]
    .Id;
    wcObj.Service = 'AIR';
    lstTspWrapperClass.add(wcObj);
    TransportationSpendController.saveSpends(lstTspWrapperClass);
    Test.stopTest();
  }
}
