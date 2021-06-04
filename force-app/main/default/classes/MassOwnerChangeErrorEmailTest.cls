/*
 * Name: MassOwnerChangeErrorEmailTest
 * Purpose: Test Class for MassOwnerChangeErrorEmail
 * Author: Nagarro
 * Created Date: 30/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
@isTest(SeeAllData=false)
public class MassOwnerChangeErrorEmailTest {
  @isTest
  private static void testSendErrorEmai() {
    MassOwnerChangeErrorEmail.sendErrorEmai(
      Datetime.newInstance(2020, 4, 30),
      UserInfo.getUserId()
    );
    System.assert([SELECT Id FROM Owner_Change_Logger__c].size() > 0);
  }

  @testSetup
  private static void setupdate() {
    Owner_Change_Logger__c objLog = OwnerChangeLoggerUtility.createLogger(
      Datetime.newInstance(2020, 4, 30),
      null,
      UserInfo.getUserId(),
      'Failed',
      null,
      null,
      null,
      null,
      null,
      null,
      'Account',
      'Test Error'
    );
    insert objLog;
  }
}
