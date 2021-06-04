@isTest
public class AccAndLocationUpdateBatch_Test {
  @testSetup
  static void dataSetup() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    Account acc;
    List<Address__c> addList = new List<Address__c>();
    DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
    List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();
    acc = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      null,
      null,
      false,
      1
    )[0];
    addList = TestDataUtility.createBusinessLocation(
      new List<Account>{ acc },
      'BL11',
      'City11',
      stateAvailableValues[0].getValue(),
      '1134111',
      '86788888888',
      'US',
      1
    );
    System.debug('list' + addList);
  }

  static testMethod void startMethod() {
    List<Account> accList = [
      SELECT
        Id,
        Name,
        CVIF__c,
        CDM_Org_Id__c,
        OwnerId,
        Owner.Name,
        Owner.FederationIdentifier,
        Industry,
        Parent_CVIF_Id__c
      FROM Account
      LIMIT 1
    ];
    List<Address__c> addList = [
      SELECT
        Id,
        CVIF_Location_Id__c,
        LocationType__c,
        Account__r.CDM_Org_Id__c,
        Account__r.CVIF__c
      FROM Address__c
    ];
    System.debug('list' + addList);
    test.startTest();
    AccAndLocationUpdateBatch objAccAndLocationUpdateBatch = new AccAndLocationUpdateBatch();
    Database.QueryLocator objQuery = objAccAndLocationUpdateBatch.start(null);
    objAccAndLocationUpdateBatch.execute(null, addList);
    DataBase.executeBatch(objAccAndLocationUpdateBatch);
    test.stopTest();
  }
}
