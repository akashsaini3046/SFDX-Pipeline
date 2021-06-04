@isTest
public class AccountDAOTest {
  @testSetup
  static void setup() {
    //List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);
    List<Account> listAccounts = TestDataUtility.createAccount(
      'Account DataTest',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    for (Account acc : listAccounts) {
      acc.CVIF__c = '123456';
    }
    insert listAccounts;

    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      listAccounts,
      'Business Location11',
      'City11',
      'CA',
      '1134111',
      '86788888888',
      'US',
      1
    );
    insert businessLocationObj;
    List<Contact> con2 = TestDataUtility.createContact(
      null,
      listAccounts,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert con2;

    List<Opportunity> listOpp = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con2,
      listAccounts,
      ConstantClass.PROSPECTING_OPP_STAGE,
      null,
      System.today(),
      null,
      'CrowleyFresh;',
      null,
      false,
      1
    );
    insert listOpp;

    List<Contract> contractObj = TestDataUtility.getContract(
      listAccounts,
      null,
      2,
      null,
      listOpp,
      null,
      null,
      1
    );
    contractObj[0].Contract_Paper__c = 'Crowley Paper';

    insert contractObj;

    TestDataUtility.getAccountData(listAccounts[0].id, 'DummyAcc', 5, true);
  }

  @isTest
  static void TestgetAccountByAccountId() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Account DataTest'];
    Test.startTest();
    Account accobj = AccountDAO.getAccountByAccountId(acc.Id);
    Test.stopTest();
    system.debug(accobj != null);
    System.assertEquals(
      '123456',
      accobj.CVIF__c,
      'Gets all data in that Account'
    );
  }

  /* @isTest
    static void NegativeTestgetAccountListByAccountId(){
        Account acc=new Account();
        Test.startTest();
        Account accobj=AccountDAO.getAccountListByAccountId(acc.Id);
        Test.stopTest();
    }*/

  @isTest
  static void TestgetAccountDataFromContract() {
    List<Contract> contracts = [SELECT Id, ContractNumber, Name FROM Contract];
    Set<String> contractSet = new Set<String>();
    for (Contract contrct : contracts) {
      contractSet.add(contrct.Name);
    }
    Test.startTest();
    Map<String, Id> mapOfContractAndAccount = AccountDAO.getAccountDataFromContract(
      contractSet
    );
    Test.stopTest();
    system.debug(mapOfContractAndAccount != null);
    system.assert(mapOfContractAndAccount != null);
  }

  @isTest
  static void NegativeTestgetAccountDataFromContract() {
    Set<String> contractSet = new Set<String>();
    Test.startTest();
    Map<String, Id> mapOfContractAndAccount = AccountDAO.getAccountDataFromContract(
      contractSet
    );
    Test.stopTest();
    system.assert(mapOfContractAndAccount.size() == 0);
  }

  @isTest
  static void TestgetAccountByCVIF() {
    List<Account> accs = [SELECT Id, CVIF__c FROM Account];
    Set<String> CVIFSet = new Set<String>();
    for (Account acc : accs) {
      CVIFSet.add(acc.CVIF__c);
    }
    Test.startTest();
    List<Account> acclist = AccountDAO.getAccountByCVIF(CVIFSet);
    Test.stopTest();
    system.debug(acclist);
    system.assert(acclist.size() > 0);
  }

  @isTest
  static void NegativeTestgetAccountByCVIF() {
    Set<String> CVIFSet = new Set<String>();
    Test.startTest();
    List<Account> acclist = AccountDAO.getAccountByCVIF(CVIFSet);
    Test.stopTest();
    system.debug(acclist);
    system.assert(acclist.size() == 0);
  }

  @isTest
  static void TestgetAccountTeamMembersByAccountId() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Account DataTest'];
    Test.startTest();
    List<AccountTeamMember> accobjTeam = AccountDAO.getAccountTeamMembersByAccountId(
      acc.Id
    );
    Test.stopTest();
    System.assert(accobjTeam.size() == 0);
  }

  @isTest
  static void TestgetTotalChildAccountsByQuery() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Account DataTest'];
    string query = 'Select Count(Id) Total from Account where ParentId=:accountId';
    Test.startTest();
    Integer total = AccountDAO.getTotalChildAccountsByQuery(query, acc.Id);
    Test.stopTest();
    system.debug(total);
    System.assertEquals(5, total, 'This counts the child accounts on Parent');
  }

  @isTest
  static void TestgetAccountDetailsByAccountIds() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Account DataTest'];
    Set<Id> accountId = new Set<Id>();
    accountId.add(acc.Id);
    Test.startTest();
    List<Account> total = AccountDAO.getAccountDetailsByAccountIds(accountId);
    Test.stopTest();
    system.debug(total);
    System.assertEquals(
      1,
      total.size(),
      'This counts the child accounts on Parent'
    );
  }
}
