@isTest
public class QuoteDAOTest {
  @testSetup
  static void setup() {
    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Acc',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;

    List<Quote__c> lstquotes = TestDataUtility.CreateQuote(4);
    for (Quote__c q : lstquotes) {
      q.Status__c = 'Sent to Pricing';
      for (Account acc : listAccounts) {
        q.Account__c = acc.Id;
      }
      q.Description__c = 'DD';
      q.Customer_Email__c = 'contact@email.com';
      q.Customer_Destination_City__c = 'Jacksonville';
      q.Customer_Destination_Country__c = 'US';
      q.Customer_Destination_State__c = 'Florida';
      q.Customer_Destination_Zip__c = '1234567';
      q.Customer_Origin_City__c = 'Boston';
      q.Customer_Origin_State__c = 'Boston';
      q.Customer_Origin_Country__c = 'US';
      q.Customer_Origin_Zip__c = '1876543';
      q.Customer_Origin_Code__c = 'USJAX';
      q.Customer_Destination_Code__c = 'PRSJU';
      q.Ready_Date__c = Date.newInstance(2020, 11, 1);
    }
    lstquotes[1].Description__c = 'PP';
    lstquotes[2].Description__c = 'PD';
    lstquotes[3].Description__c = 'DP';
    insert lstquotes;

    //Shipment Creation
    List<Shipment__c> lstshipments = TestDataUtility.CreateShipment(
      lstquotes,
      1
    );
    insert lstshipments;

    //FreightDetail Creation
    List<FreightDetail__c> lstfds = TestDataUtility.CreateFreightDetail(
      lstshipments,
      2
    );
    lstfds[1].Cargo_Type__c = 'Equip';
    lstfds[2].Cargo_Type__c = 'BBulk';
    insert lstfds;

    //Requirement Creation
    List<Requirement__c> lstreq = TestDataUtility.CreateRequirement(lstfds, 2);
    insert lstreq;
  }

  @isTest
  static void getQuoteWithChargeLineByQuoteIdsTest() {
    List<Quote__c> quotes = [SELECT Id FROM Quote__c];
    Set<Id> quoteIds = new Set<Id>();
    for (Quote__c q : quotes) {
      quoteIds.add(q.Id);
    }
    Test.startTest();
    List<Quote__c> Listquotes = QuoteDAO.getQuoteWithChargeLineByQuoteIds(
      quoteIds
    );
    Test.stopTest();

    System.assertEquals(4, Listquotes.size(), 'List size check');
  }

  @isTest
  static void getFreightDetailsByQuoteIdsTest() {
    List<Quote__c> quotes = [SELECT Id FROM Quote__c];
    Set<Id> quoteIds = new Set<Id>();
    for (Quote__c q : quotes) {
      quoteIds.add(q.Id);
    }
    Test.startTest();
    List<FreightDetail__c> ListFDs = QuoteDAO.getFreightDetailsByQuoteIds(
      quoteIds
    );
    Test.stopTest();
    System.assertEquals(8, ListFDs.size(), 'List size check');
  }

  @isTest
  static void getRequirementByFreightDetailIdsTest() {
    List<FreightDetail__c> ListFds = [SELECT Id FROM FreightDetail__c];
    Set<Id> FDIds = new Set<Id>();
    for (FreightDetail__c fdVar : ListFds) {
      FDIds.add(fdVar.Id);
    }
    Test.startTest();
    List<Requirement__c> ListRequirements = QuoteDAO.getRequirementByFreightDetailIds(
      FDIds
    );
    Test.stopTest();
    System.assertEquals(2, ListRequirements.size(), 'List size check');
  }

  @isTest
  static void getRequirementByQuoteIdsTest() {
    List<Quote__c> quotes = [SELECT Id FROM Quote__c];
    Set<Id> quoteIds = new Set<Id>();
    for (Quote__c q : quotes) {
      quoteIds.add(q.Id);
    }
    Test.startTest();
    List<Requirement__c> ListRequirements = QuoteDAO.getRequirementByQuoteIds(
      quoteIds
    );
    Test.stopTest();
    System.assertEquals(2, ListRequirements.size(), 'List size check');
  }

  @isTest
  static void getRequirementsByContainerTypeTest() {
    String containerType = 'FM808';
    Test.startTest();
    List<Requirement__c> ListRequirements = QuoteDAO.getRequirementsByContainerType(
      containerType
    );
    Test.stopTest();
    System.assertEquals(2, ListRequirements.size(), 'List size check');
  }

  @isTest
  static void getRequirementsByCommodityNameTest() {
    String commodityName = 'Cargo, NOS';
    Test.startTest();
    List<Requirement__c> ListRequirements = QuoteDAO.getRequirementsByCommodityName(
      commodityName
    );
    Test.stopTest();
    System.assertEquals(2, ListRequirements.size(), 'List size check');
  }

  @isTest
  static void getFreightDetailsByCommodityNameTest() {
    String commodityName = 'NIT/Break Bulk, Vehicles';
    Test.startTest();
    List<FreightDetail__c> ListFDs = QuoteDAO.getFreightDetailsByCommodityName(
      commodityName
    );
    Test.stopTest();
    System.assertEquals(8, ListFDs.size(), 'List size check');
  }

  @isTest
  static void getQuoteByOriginDestinationCodeTest() {
    String OriginCode = 'USJAX';
    Test.startTest();
    List<Quote__c> Listquotes = QuoteDAO.getQuoteByOriginDestinationCode(
      new List<String>{ OriginCode },
      new List<String>{}
    );
    Test.stopTest();
    System.assertEquals(4, Listquotes.size(), 'List size check');
  }

  @isTest
  static void getQuoteByOriginDestinationCodeTest1() {
    String destinationCode = 'PRSJU';
    Test.startTest();
    List<Quote__c> Listquotes = QuoteDAO.getQuoteByOriginDestinationCode(
      new List<String>{},
      new List<String>{ destinationCode }
    );
    Test.stopTest();
    System.assertEquals(4, Listquotes.size(), 'List size check');
  }

  @isTest
  static void getQuoteByOriginDestinationCodeTest2() {
    String OriginCode = 'USJAX';
    String destinationCode = 'PRSJU';
    Test.startTest();
    List<Quote__c> Listquotes = QuoteDAO.getQuoteByOriginDestinationCode(
      new List<String>{ OriginCode },
      new List<String>{ destinationCode }
    );
    Test.stopTest();
    System.assertEquals(4, Listquotes.size(), 'List size check');
  }

  @isTest
  static void getTotalQuotesByQueryAccountIdsTest() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    String query = 'SELECT Count(Id) Total From Quote__c where Account__c IN: accountIds';
    Test.startTest();
    Integer total = QuoteDAO.getTotalQuotesByQueryAccountIds(
      query,
      new List<Id>{ acc.Id }
    );
    Test.stopTest();
    system.assertEquals(4, total, 'Total must be 4');
  }

  @isTest
  static void getTotalQuotesByQueryAccountIdsTest1() {
    String query = 'SELECT Count(Id) Total From Quote__c where Account__c IN: accountIds';
    Test.startTest();
    Integer total = QuoteDAO.getTotalQuotesByQueryAccountIds(
      query,
      new List<Id>{}
    );
    Test.stopTest();
    system.assertEquals(0, total, 'Total must be 0');
  }

  @isTest
  static void getQuoteByQueryTest() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    String query =
      'SELECT CreatedDate, Name, Id, Account__c, Account__r.Name, Contract__c, Contract__r.Name, Contract_Number__c, Customer_Destination_City__c, Customer_Destination_Code__c, Customer_Destination_Country__c, Customer_Destination_State__c, Customer_Destination_Zip__c,Customer_Origin_City__c, ' +
      'Customer_Origin_Code__c, Customer_Origin_Country__c,Transit_Time_Day_Hours__c,Grand_Total_Amount__c, Customer_Origin_State__c, Customer_Origin_Zip__c, Description__c, Valid_To__c, Is_Hazardous__c, Ready_Date__c,toLabel(Status__c), Total_Amount__c, Transit_Time__c,Vessel_Name__c,Voyage_Number__c,No_of_Stop__c,Quote_Type__c FROM Quote__c where Account__c IN: accountIds';
    Test.startTest();
    List<Quote__c> Listquotes = QuoteDAO.getQuoteByQuery(
      query,
      new List<Id>{ acc.Id }
    );
    Test.stopTest();
    system.assertEquals(4, Listquotes.size(), 'List size check');
  }

  @isTest
  static void getQuoteByQueryTest1() {
    String query =
      'SELECT CreatedDate, Name, Id, Account__c, Account__r.Name, Contract__c, Contract__r.Name, Contract_Number__c, Customer_Destination_City__c, Customer_Destination_Code__c, Customer_Destination_Country__c, Customer_Destination_State__c, Customer_Destination_Zip__c,Customer_Origin_City__c, ' +
      'Customer_Origin_Code__c, Customer_Origin_Country__c,Transit_Time_Day_Hours__c,Grand_Total_Amount__c, Customer_Origin_State__c, Customer_Origin_Zip__c, Description__c, Valid_To__c, Is_Hazardous__c, Ready_Date__c,toLabel(Status__c), Total_Amount__c, Transit_Time__c,Vessel_Name__c,Voyage_Number__c,No_of_Stop__c,Quote_Type__c FROM Quote__c where Account__c IN: accountIds';
    Test.startTest();
    List<Quote__c> Listquotes = QuoteDAO.getQuoteByQuery(query, new List<Id>{});
    Test.stopTest();
    system.assertEquals(0, Listquotes.size(), 'List size check');
  }
}
