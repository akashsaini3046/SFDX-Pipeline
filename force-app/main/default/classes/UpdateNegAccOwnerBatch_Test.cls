@isTest
public class UpdateNegAccOwnerBatch_Test {
  @testSetup
  static void dataSetup() {
    Account acc;
    acc = TestDataUtility.createAccount(
      'Test Account',
      'Customer',
      null,
      null,
      false,
      1
    )[0];
    insert acc;
    Neglected_Account_Data__c negRec = new Neglected_Account_Data__c();
    negRec.Account__c = acc.Id;
    negRec.AccountId__c = acc.Id;
    negRec.Name = acc.Name;
    insert negRec;
  }

  static testMethod void startMethod() {
    List<Id> accIds = new List<Id>();
    List<Account> accList = [
      SELECT Id, Name, OwnerId, Owner.Name
      FROM Account
      LIMIT 1
    ];
    for (Account acc : accList) {
      accIds.add(acc.Id);
    }
    List<Neglected_Account_Data__c> negRecs = [
      SELECT Id, Name, Account__c
      FROM Neglected_Account_Data__c
      LIMIT 1
    ];
    test.startTest();
    UpdateNegAccOwnerBatch objUpdateNegAccOwnerBatch = new UpdateNegAccOwnerBatch(
      accIds
    );
    Database.QueryLocator objQuery = objUpdateNegAccOwnerBatch.start(null);
    objUpdateNegAccOwnerBatch.execute(null, negRecs);
    DataBase.executeBatch(objUpdateNegAccOwnerBatch);
    test.stopTest();
  }
}
