/*
 * Name: AccountTeamMemberInfoDeleteBatch
 * Purpose: Test Class for Batchlass to delete 3 month old records in Account Team Member Info object.
 * Author: Nagarro
 * Created Date: 12-Feb-2020
 * Modification History
 *  Modification # #  Story/Defect#      Modified By     Date   Description
 */
@isTest(SeeAllData=false)
public class AccountTeamMemberInfoDeleteBatchTest {
  @testSetup
  static void setupTestData() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;
    List<Account> accountList = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      false,
      1
    );
    insert accountList;
    List<Address__c> businessLocationList = TestDataUtility.createBusinessLocation(
      accountList,
      'BL1',
      'City1',
      'CA',
      '1111111',
      '88888888888',
      'US',
      1
    );
    insert businessLocationList;
  }

  static testMethod void accountTeamMemberInfoDelete() {
    Test.startTest();
    String CRON_EXP = '0 0 0 15 3 ? *';
    String jobId = System.schedule(
      'AccountTeamMemberInfoDeleteBatchSchedule',
      CRON_EXP,
      new AccountTeamMemberInfoDeleteBatchSchedule()
    );
    Test.stopTest();
  }
}
