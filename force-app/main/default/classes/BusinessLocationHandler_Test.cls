/*
 * Name: BusinessLocationHandler_Test
 * Purpose: Test class for AddressTriggerHandler.
 * Author: Nagarro
 * Created Date: 11-Oct-2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest
public class BusinessLocationHandler_Test {
  @testSetup
  static void dataSetup() {
    Governance_Team_Fields__c objGTF = TestDataUtility.GovernanceTeamFields(
      '1',
      'Address Line 1',
      'Address_Line_1__c',
      'Business Location',
      'Text',
      ''
    );
    insert objGTF;

    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> accList = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      null,
      null,
      false,
      2
    );
    insert accList;
    List<Address__c> lstBusinessLocations = TestDataUtility.createBusinessLocation(
      accList,
      'Business Location1',
      'City1',
      'CA',
      '1111111',
      '88888888888',
      'US',
      2
    );
    insert lstBusinessLocations;
    List<Contact> con = TestDataUtility.createContact(
      null,
      accList,
      lstBusinessLocations,
      'Test',
      ' con1',
      'con@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert con;
  }

  static testMethod void businessLocationHandler_TestMethod() {
    List<User_Region_to_Opp_Role__c> customSetting = [
      SELECT Id
      FROM User_Region_to_Opp_Role__c
    ];

    delete customSetting;
    List<Address__c> businessLocationListToDelete = [
      SELECT Id, Country__c, Account__c
      FROM Address__c
    ];
    Contact con = [SELECT Id, Address__c FROM Contact LIMIT 1];
    Address__c BL = [SELECT Id FROM Address__c WHERE Id = :con.Address__c];

    test.startTest();
    for (Address__c listBL : businessLocationListToDelete) {
      System.assertNotEquals(listBL.Country__c, null);
      System.assertNotEquals(listBL.Account__c, null);
    }
    System.assertEquals(BL.Id, con.Address__c);
    try {
      delete businessLocationListToDelete;
    } catch (Exception e) {
      System.debug(
        'Exception in Business Location Test Class' + e.getMessage()
      );
    }
    test.stopTest();
  }

  static testMethod void testCreateTrackHistoryRecord() {
    Test.startTest();
    List<Address__c> objAddress = [
      SELECT Id, Name, Address_Line_1__c
      FROM Address__c
      WHERE Address_Line_1__c = 'Test BL'
    ];
    for (Address__c addObj : objAddress) {
      addObj.Address_Line_1__c = 'Address Line 11';
    }
    update objAddress;

    List<Track_History__c> objTrackHistory = [
      SELECT Previous_Value__c, New_Value__c
      FROM Track_History__c
      WHERE Object_Name__c = 'Business Location' AND Operation__c = 'Modified'
      ORDER BY CreatedDate DESC
    ];
    for (Track_History__c trackHistory : objTrackHistory) {
      System.assert(trackHistory.Previous_Value__c == 'Address Line 1');
      System.assert(trackHistory.New_Value__c == 'Address Line 11');
    }
    Test.stopTest();
  }
}
