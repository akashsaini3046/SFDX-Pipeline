@isTest
private class CC_ContractDetailControllerTest {
  @TestSetup
  static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);

    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Acc',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;
    Account account = [SELECT ID, Name FROM Account LIMIT 1];

    List<Contract> contractList = TestDataUtility.getContracts(
      '20-00001',
      account.Id,
      1,
      false
    );
    contractList[0].Contract_Paper__c = 'Crowley Paper';
    insert contractList;
    Contract cont = [SELECT ID, Name FROM Contract LIMIT 1];

    Contract_Account__c conAcc = new Contract_Account__c();
    conAcc.Name = account.Name + '-' + cont.Name;
    conAcc.Account__c = account.Id;
    conAcc.Contract__c = cont.Id;

    insert conAcc;
  }

  @isTest
  static void getContractsRecordTest() {
    Contract cont = [SELECT ID FROM Contract LIMIT 1];
    Test.startTest();
    CC_ContractDetailController.ContractDetailWrapper gcr = CC_ContractDetailController.getContractsRecord(
      cont.Id
    );
    Test.stopTest();
    System.assertNotEquals(null, gcr.contract, 'should not be null');
  }
}
