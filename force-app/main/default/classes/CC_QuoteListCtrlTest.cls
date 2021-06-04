@isTest
private class CC_QuoteListCtrlTest {
  @testSetup
  static void setup() {
    List<Location__c> listlocations = TestDataUtility.CreateLocation(
      'Test Location',
      'BERTH',
      4,
      false
    );
    listlocations[0].Name = 'USJAX';
    listlocations[1].Name = 'PRSJU';
    listlocations[2].Name = 'USQAT';
    listlocations[3].Name = 'HNPCR';
    insert listlocations;

    List<Account> listAccounts = TestDataUtility.createAccount(
      'Test Acc',
      'Customer',
      'Accounting',
      null,
      false,
      1
    );
    insert listAccounts;
    Account account = [SELECT ID FROM Account LIMIT 1];

    List<Account> childAccounts = TestDataUtility.createAccount(
      'Child Acc',
      'Customer',
      'Accounting',
      account.Id,
      false,
      1
    );
    insert childAccounts;

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
      q.Customer_Destination_Zip__c = '27209';
      q.Customer_Origin_City__c = 'Boston';
      q.Customer_Origin_State__c = 'Boston';
      q.Customer_Origin_Country__c = 'US';
      q.Customer_Origin_Zip__c = '31626';
      q.Customer_Origin_Code__c = 'USJAX';
      q.Customer_Destination_Code__c = 'USQA';
      q.Ready_Date__c = Date.newInstance(2020, 11, 1);
      q.Is_Hazardous__c = true;
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
  static void getQuoteMetaDataTest() {
    Test.startTest();
    CC_QuoteListCtrl.QuoteListMetadata quoListMTD = CC_QuoteListCtrl.getQuoteMetaData();
    Test.stopTest();
    System.assertNotEquals(null, quoListMTD, 'Should not be null');
  }

  @isTest
  static void getQuoteListDataTest() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '';
    String paginationParamsString = '';
    Test.startTest();
    List<CC_QuoteListCtrl.QuoteDataWrapper> quoteWrap = CC_QuoteListCtrl.getQuoteListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      'CQ-'
    );
    Test.stopTest();
    System.assertNotEquals(null, quoteWrap, 'Should not be null');
  }

  @isTest
  static void getQuoteListDataTest1() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '{"statusSelected":"all","hazQuote":"Yes","comoditySelected":"","vessalSelected":"","destinationLocationId":"","originLocationId":"","originMovementType":"D","destMovementType":"D","containerTypeSelected":""}';
    String paginationParamsString = '{"limit":10,"offset":0}';
    Test.startTest();
    List<CC_QuoteListCtrl.QuoteDataWrapper> quoteWrap = CC_QuoteListCtrl.getQuoteListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      ''
    );
    Test.stopTest();
    System.assertNotEquals(null, quoteWrap, 'Should not be null');
  }

  @isTest
  static void getQuoteListDataTest2() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '{"statusSelected":"all","hazQuote":"No","comoditySelected":"Cargo, NOS","originMovementType":"D","destMovementType":"D","containerTypeSelected":"FM808"}';
    String paginationParamsString = '{"limit":10,"offset":0}';
    Test.startTest();
    List<CC_QuoteListCtrl.QuoteDataWrapper> quoteWrap = CC_QuoteListCtrl.getQuoteListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      ''
    );
    Test.stopTest();
    system.debug(quoteWrap);
    System.assertNotEquals(null, quoteWrap, 'Should not be null');
  }

  @isTest
  static void getTotalQuotesTest() {
    List<Account> accounts = [SELECT id FROM ACCOUNT];
    List<Id> accountIds = new List<Id>();
    for (Account acc : accounts) {
      accountIds.add(acc.id);
    }
    String filterObjectString = '{"statusSelected":"all","hazQuote":"No","comoditySelected":"Cargo, NOS","originMovementType":"D","destMovementType":"D","containerTypeSelected":"FM808"}';
    Test.startTest();
    Integer total = CC_QuoteListCtrl.getTotalQuotes(
      accountIds,
      filterObjectString,
      'CQ-'
    );
    Test.stopTest();
    System.assertNotEquals(null, total, 'Should not be null');
  }

  @isTest
  static void fetchIframeUrlTest() {
    Quote__c quote1 = [SELECT Id FROM Quote__c LIMIT 1];
    Test.startTest();
    String url = CC_QuoteListCtrl.fetchIframeUrl(quote1.Id);
    Test.stopTest();
    system.debug(url);
  }

  @isTest
  static void fetchIframeUrlTest1() {
    Quote__c quote1 = new Quote__c();
    Test.startTest();
    String url = CC_QuoteListCtrl.fetchIframeUrl(quote1.Id);
    Test.stopTest();
    system.debug(url);
  }

  @isTest
  static void getChildAccountsTest() {
    Account acc = [SELECT Id FROM Account WHERE ParentId = NULL LIMIT 1];
    Test.startTest();
    List<Account> accList = CC_QuoteListCtrl.getChildAccounts(acc.Id);
    Test.stopTest();
    system.debug(accList);
  }

  @isTest
  static void getChildAccountsTest1() {
    Account acc = new Account();
    Test.startTest();
    List<Account> accList = CC_QuoteListCtrl.getChildAccounts(acc.Id);
    Test.stopTest();
    system.debug(accList);
  }

  @isTest
  static void getChildAccountsTest2() {
    Account acc = [SELECT Id FROM Account WHERE ParentId != NULL LIMIT 1];
    Test.startTest();
    List<Account> accList = CC_QuoteListCtrl.getChildAccounts(acc.Id);
    Test.stopTest();
    system.debug(accList);
  }

  @isTest
  static void getLocationsTest() {
    List<Id> idList = new List<Id>(
      new Map<Id, Location__c>([SELECT ID FROM Location__c]).keySet()
    );
    Test.startTest();
    List<Location__c> lList = CC_QuoteListCtrl.getLocations(idList);
    Test.stopTest();
    System.assertNotEquals(null, lList.size(), 'should not be null');
  }

  @isTest
  static void getCustomFiltersTest() {
    List<Location__c> locations = [SELECT id FROM Location__c];
    Account acc = [SELECT ID FROM Account LIMIT 1];
    Map<String, Object> filterObject = new Map<String, Object>();
    filterObject.put('originMovementType', 'P');
    filterObject.put('destMovementType', 'P');
    filterObject.put('originLocationId', locations[0].id);
    filterObject.put('destinationLocationId', locations[1].id);
    filterObject.put('selectedAccountId', acc.ID);
    filterObject.put('showChildAcc', 'Yes');

    Test.startTest();
    String customFilters = CC_QuoteListCtrl.getCustomFilters(filterObject);
    Test.stopTest();

    System.assertNotEquals('', customFilters, 'Should not be blank');
  }

  @isTest
  static void getCustomFiltersTest1() {
    List<Location__c> locations = [SELECT id FROM Location__c];
    Account acc = [SELECT ID FROM Account LIMIT 1];
    Map<String, Object> filterObject = new Map<String, Object>();
    filterObject.put('originMovementType', 'D');
    filterObject.put('destMovementType', 'D');
    filterObject.put('originLocationId', locations[0].id);
    filterObject.put('destinationLocationId', locations[1].id);
    filterObject.put('selectedAccountId', acc.ID);
    filterObject.put('showChildAcc', 'Yes');

    Test.startTest();
    String customFilters = CC_QuoteListCtrl.getCustomFilters(filterObject);
    Test.stopTest();

    System.assertNotEquals('', customFilters, 'Should not be blank');
  }
}
