@isTest
public class ContractDAOTest {
  @testSetup
  static void setup() {
    // List<Transaction_Reference__c> ts =TestDataUtility.createTransactionReference('00000287',1);

    Account accObj1 = TestDataUtility.createAccount(
      'Nagarro',
      'Customer',
      'Industrial',
      null,
      false,
      1
    )[0];
    insert accObj1;
    DescribeFieldResult describeState = Address__c.State_Picklist__c.getDescribe();
    List<PicklistEntry> stateAvailableValues = describeState.getPicklistValues();

    Address__c businessLocationObj = TestDataUtility.createBusinessLocation(
      new List<Account>{ new Account(Id = accObj1.Id) },
      'BL1',
      'City1',
      stateAvailableValues[0].getValue(),
      '1111111',
      '88888888888',
      'US',
      1
    )[0];
    List<Contact> con = TestDataUtility.createContact(
      null,
      new List<Account>{ new Account(Id = accObj1.Id) },
      new List<Address__c>{ new Address__c(Id = businessLocationObj.Id) },
      'Test',
      'con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );

    List<Product2> lstProducts = TestDataUtility.createProduct(
      new List<String>{ 'CrowleyFresh', 'Air', 'Asset Management' }
    );

    List<Opportunity> opp1 = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con,
      new List<Account>{ new Account(Id = accObj1.Id) },
      ConstantClass.PROSPECTING_OPP_STAGE,
      null,
      System.today(),
      null,
      'CrowleyFresh',
      null,
      true,
      1
    );

    List<Contract> contractObj = TestDataUtility.createContract(
      new List<Account>{ new Account(Id = accObj1.Id) },
      null,
      2,
      System.today(),
      opp1,
      'Pricing Team Review',
      null,
      1
    );
    contractObj[0].AccountId = accObj1.Id;
    contractObj[0].Contract_Paper__c = 'Crowley Paper';
    insert contractObj;
  }
  @isTest
  static void getContractTest() {
    List<Contract> cnt = [SELECT Id FROM Contract LIMIT 1];
    User intUserList = [
      SELECT Id, Profile.Name
      FROM User
      WHERE Profile.Name = 'Integration User'
      LIMIT 1
    ];
    //SELECT Id, Username FROM User WHERE Username =  'lovesh.tomar@nagarro.com'

    //System.debug (' ProfileName: ' + UserFinderUtility.getCurrentUserProfile());
    Test.startTest();
    // System.debug([Select Name from Transaction_Reference__c LIMIT 1]);
    ContractDAO.getContract(cnt[0].id);
    Test.stopTest();
  }
}
