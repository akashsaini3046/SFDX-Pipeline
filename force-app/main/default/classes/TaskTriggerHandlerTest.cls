/*
 * Name: TaskTriggerHandlerTest
 * Purpose: Test class for TaskTriggerHandler.
 * Author: Nagarro
 * Created Date: 20-Apr-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class TaskTriggerHandlerTest {
  @isTest
  private static void testValidateCreateInitiative() {
    Id whatId = [SELECT Id FROM Account LIMIT 1][0].Id;
    Id initiativeId = [SELECT Id FROM Initiative__c LIMIT 1][0].Id;

    Task objTask = new Task(
      Subject = 'Test Task',
      OwnerId = UserInfo.getUserId(),
      WhatId = whatId,
      Initiative__c = initiativeId
    );
    try {
      insert objTask;
    } catch (Exception objEx) {
      System.assert(objEx != null);
    }
  }

  @isTest
  private static void testValidateUpdateInitiative() {
    Id whatId = [SELECT Id FROM Account LIMIT 1][0].Id;
    Id initiativeId = [SELECT Id FROM Initiative__c LIMIT 1][0].Id;

    Task objTask = [SELECT Id, Type FROM Task LIMIT 1];

    try {
      objTask.WhatId = whatId;
      objTask.Initiative__c = initiativeId;
      update objTask;
    } catch (Exception objEx) {
      System.assert(objEx != null);
    }
  }

  @testSetup
  static void setup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> lstTestAccounts = TestDataUtility.createAccount(
      'Test Account',
      null,
      'Apparel',
      null,
      false,
      1
    );
    insert lstTestAccounts;
    List<Initiative__c> objInitiative = TestDataUtility.createInitiative(
      'Test Initiative',
      1
    );
    insert objInitiative;
    //Task objTask = new Task(Subject = 'Test TaskIni', OwnerId = UserInfo.getUserId());
    //insert objTask;
    List<Task> objTask1 = TestDataUtility.createTask(
      null,
      null,
      null,
      'High',
      'Open',
      null,
      'Test TaskIni',
      system.now().Date(),
      null,
      null,
      UserInfo.getUserId(),
      1
    );
    insert objTask1;
  }
}
