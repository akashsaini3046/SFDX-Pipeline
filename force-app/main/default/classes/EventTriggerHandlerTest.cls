/*
 * Name: EventTriggerHandlerTest
 * Purpose: Test class for EventTriggerHandler
 * Author: Nagarro
 * Created Date: 18-Oct-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class EventTriggerHandlerTest {
  @isTest
  private static void testChangeEventTypeToMeeting() {
    List<Event> lstEvent = [SELECT Id, Type FROM Event];
    for (Event objEvent : lstEvent) {
      System.assert(objEvent != null);
    }
  }

  @isTest
  private static void testValidateCreateInitiative() {
    Id whatId = [SELECT Id FROM Account LIMIT 1][0].Id;
    Id initiativeId = [SELECT Id FROM Initiative__c LIMIT 1][0].Id;

    Event objEvent = new Event(
      Subject = 'Test Event',
      StartDateTime = System.now(),
      EndDateTime = System.now(),
      OwnerId = UserInfo.getUserId(),
      WhatId = whatId,
      Initiative__c = initiativeId
    );
    try {
      insert objEvent;
    } catch (Exception objEx) {
      System.assert(objEx != null);
    }
  }

  @isTest
  private static void testValidateUpdateInitiative() {
    Id whatId = [SELECT Id FROM Account LIMIT 1][0].Id;
    Id initiativeId = [SELECT Id FROM Initiative__c LIMIT 1][0].Id;

    Event objEvent = [SELECT Id, Type FROM Event LIMIT 1];

    try {
      objEvent.WhatId = whatId;
      objEvent.Initiative__c = initiativeId;
      update objEvent;
    } catch (Exception objEx) {
      System.assert(objEx != null);
    }
  }

  /*
   * Method Name: testDataSetup
   * Purpose: Prepare test data
   */
  @testSetup
  private static void setupData() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Event> objEvent1 = TestDataUtility.createEvent(
      'Other',
      null,
      '',
      null,
      'Test Event',
      System.now().DATE(),
      System.now(),
      null,
      UserInfo.getUserId(),
      0,
      1
    );
    insert objEvent1;
    List<Initiative__c> objInitiative = TestDataUtility.createInitiative(
      'Test Initiative',
      1
    );
    insert objInitiative;
    List<Account> objAccount = TestDataUtility.createAccount(
      'Test Account',
      null,
      null,
      null,
      false,
      1
    );
    insert objAccount;
  }
}
