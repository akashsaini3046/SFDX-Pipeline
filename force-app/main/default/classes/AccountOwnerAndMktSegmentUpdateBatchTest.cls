@isTest
public class AccountOwnerAndMktSegmentUpdateBatchTest {
  @testSetup
  static void dataSetup() {
    CDM_Team_Email_Addresses__c objCDMTeamEmailAddresses = TestDataUtility.CDMTeamEmailAddresses();
    insert objCDMTeamEmailAddresses;
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
      LIMIT 2
    ];
    System.debug('list' + accList);
    test.startTest();
    AccountOwnerAndMktSegmentUpdateBatch objAccountOwnerAndMktSegmentUpdateBatch = new AccountOwnerAndMktSegmentUpdateBatch();
    Database.QueryLocator objQuery = objAccountOwnerAndMktSegmentUpdateBatch.start(
      null
    );
    objAccountOwnerAndMktSegmentUpdateBatch.execute(null, accList);
    DataBase.executeBatch(objAccountOwnerAndMktSegmentUpdateBatch);
    test.stopTest();
  }
}
