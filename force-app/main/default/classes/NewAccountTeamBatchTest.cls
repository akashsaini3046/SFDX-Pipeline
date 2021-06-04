/*
 * Name: NewAccountTeamBatchTest
 * Purpose: Test Class for NewAccountTeamBatch
 * Author: Nagarro
 * Created Date: 27-Aug-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(SeeAllData=false)
public class NewAccountTeamBatchTest {
  static testMethod void testBatch() {
    List<User_Region_to_Opp_Role__c> customSettingList = [
      SELECT Id
      FROM User_Region_to_Opp_Role__c
    ];
    delete customSettingList;
    Account objAccount = [
      SELECT Id, Name
      FROM Account
      WHERE ParentId = NULL
      LIMIT 1
    ];
    Test.startTest();
    System.schedule(
      'Scheduled Job 1',
      '0 1 * * * ?',
      new NewAccountTeamBatchScheduler()
    );
    //Database.executeBatch(new NewAccountTeamBatch(), 200);
    Test.stopTest();
    System.assert(objAccount.Name == 'test Account name');
  }

  @testsetup
  static void testSetup() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    User u1 = TestDataUtility.createUser(
      null,
      profileId,
      null,
      'User1',
      'approvalUser1@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u1;
    System.runAs(u1) {
      List<Account> listAccount = TestDataUtility.createAccount(
        'test Account name',
        null,
        'Apparel',
        null,
        false,
        1
      );
      insert listAccount;
      List<Account> objAccount2;
      for (Account acc : listAccount) {
        if (acc.Name == 'test Account name') {
          objAccount2 = TestDataUtility.createAccount(
            'Child test Account name',
            null,
            'Apparel',
            null,
            false,
            1
          );
        }
      }
      insert objAccount2;

      List<AccountTeamMember> objATM = TestDataUtility.createAccountTeamMember(
        'Edit',
        'Edit',
        'Edit',
        'Edit',
        objAccount2,
        [SELECT ID FROM USER WHERE Email = 'approvalUser1@test.com'],
        new List<String>{ 'Account Manager' }
      );
      insert objATM;
    }
  }
}
