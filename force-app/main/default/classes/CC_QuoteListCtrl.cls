public class CC_QuoteListCtrl {
  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in direct(" = ") filters
  public static Map<String, String> paramVsStringFieldAPI = new Map<String, String>{
    'statusSelected' => 'Status__c',
    'contractInput' => 'Contract_Number__c',
    'selectedContractId' => 'Contract__c',
    'vessalSelected' => 'Vessel_Name__c'
  };

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( "LIKE") filters
  public static Map<String, String> paramVsLikeFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in Date ( without quotes ) filters
  public static Map<String, String> paramVsDateFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( ">=" , "<  =") filters
  public static Map<String, String> paramVsRangeFieldAPI = new Map<String, String>{
    'departureFromDate' => 'DAY_ONLY(CreatedDate)',
    'departureToDate' => 'DAY_ONLY(CreatedDate)'
  };

  @AuraEnabled
  public static String fetchIframeUrl(Id QuoteId) {
    String quoteUrl;
    String communityUrlPathPrefix = getCommunityUrlPathPrefix();
    if (Network.getNetworkId() != null) {
      quoteUrl =
        '/' +
        communityUrlPathPrefix +
        '/apex/CC_EmployeeQuoteRecordPDF?Id=' +
        QuoteId;
    } else {
      quoteUrl =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/CC_EmployeeQuoteRecordPDF?Id=' +
        QuoteId;
    }
    System.debug('quoteURL is ' + quoteUrl);
    return quoteUrl;
  }

  private static String getCommunityUrlPathPrefix() {
    String nwid = Network.getNetworkId();
    if (!String.isBlank(nwid)) {
      String communityUrlPathPrefix = [
        SELECT urlPathPrefix
        FROM Network
        WHERE id = :nwid
      ][0]
      .urlPathPrefix;
      return communityUrlPathPrefix;
    } else {
      return null;
    }
  }

  /*
   * @purpose     : Method to get Metadata for the filters on Quotes List Page
   * @return      : QuoteListMetadata - Inner class containing the information for the filters of Quotes
   */
  @AuraEnabled
  public static QuoteListMetadata getQuoteMetaData() {
    QuoteListMetadata quoteListMetadata = new QuoteListMetadata();
    quoteListMetadata.statuses = CC_SharedUtility.getPicklistValuesList(
      Quote__c.Status__c.getDescribe()
    );
    quoteListMetadata.originMovementTypes = getMovementTypes();
    quoteListMetadata.destMovementTypes = getMovementTypes();
    quoteListMetadata.containerTypes = getContainerTypes();
    quoteListMetadata.commodities = getCommodities();
    quoteListMetadata.vessals = CC_SharedUtility.getPicklistValuesList(
      Quote__c.Vessels__c.getDescribe()
    );
    system.debug('&&&' + quoteListMetadata.vessals);
    return quoteListMetadata;
  }

  /*
   * @purpose     : Method to get List of BookingDataWrapper corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<CC_BookingListCtrl.QuoteDataWrapper> - List of QuoteDataWrapper inner class
   */
  @AuraEnabled
  public static List<QuoteDataWrapper> getQuoteListData(
    List<Id> accountIds,
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    List<QuoteDataWrapper> quoteDataWrapperList = new List<QuoteDataWrapper>();
    List<Quote__c> quotes = getQuoteRecords(
      accountIds,
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
    Map<Id, Quote__c> quotesMap = new Map<Id, Quote__c>(quotes);
    Map<Id, List<FreightDetail__c>> quoteIdVsFreightDetailList = getFreightDetailsMap(
      quotesMap.keySet()
    );
    Map<Id, List<Requirement__c>> quoteIdVsRequirementList = getRequirementsMap(
      quotesMap.keySet()
    );
    for (Quote__c quote : quotes) {
      QuoteDataWrapper quoteDataWrapper = new QuoteDataWrapper();
      quoteDataWrapper.quote = quote;
      quoteDataWrapper.freightdetails = (quoteIdVsFreightDetailList != null &&
        quoteIdVsFreightDetailList.get(quote.Id) != null)
        ? quoteIdVsFreightDetailList.get(quote.Id)
        : null;
      quoteDataWrapper.requirements = (quoteIdVsRequirementList != null &&
        quoteIdVsRequirementList.get(quote.Id) != null)
        ? quoteIdVsRequirementList.get(quote.Id)
        : null;
      quoteDataWrapperList.add(quoteDataWrapper);
    }
    system.debug('quote-->' + quoteDataWrapperList);
    return quoteDataWrapperList;
  }

  /*
   * @purpose     : Method to get List of Quote__c Records corresponding to the the list of account ids and with all the filters by using Database query
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<Quote__c> - List of Quote__c records
   */
  private static List<Quote__c> getQuoteRecords(
    List<Id> accountIds,
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    String query = createQuoteListQuery(
      accountIds,
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
    System.debug('@@@@@ ' + query);
    return QuoteDAO.getQuoteByQuery(query, accountIds);
  }

  /*
   * @purpose     : Method to get Query string corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : String - query string corresponding to the the list of account ids and with all the filters
   */
  private static String createQuoteListQuery(
    List<Id> accountIds,
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    System.debug(filterObjectString);
    Map<String, Object> filterObject = new Map<String, Object>();
    Map<String, Object> paginationParams = new Map<String, Object>();
    String query =
      'SELECT CreatedDate, Name, Id, Account__c, Account__r.Name, Contract__c, Contract__r.Name, Contract_Number__c, Customer_Destination_City__c, Customer_Destination_Code__c, Customer_Destination_Country__c, Customer_Destination_State__c, Customer_Destination_Zip__c,Customer_Origin_City__c, ' +
      'Customer_Origin_Code__c, Customer_Origin_Country__c,Transit_Time_Day_Hours__c,Grand_Total_Amount__c, Customer_Origin_State__c, Customer_Origin_Zip__c, Description__c, Valid_To__c, Is_Hazardous__c, Ready_Date__c,toLabel(Status__c), Total_Amount__c, Transit_Time__c,Vessel_Name__c,Voyage_Number__c,No_of_Stop__c,Quote_Type__c FROM Quote__c';
    Boolean whereAdded = false;
    if (
      filterObjectString != null &&
      filterObjectString != CC_Constants.BLANK_STRING
    ) {
      filterObject = (Map<String, Object>) JSON.deserializeUntyped(
        filterObjectString
      );
      String filteredQuery = CC_SharedUtility.getFilters(
        filterObject,
        paramVsStringFieldAPI,
        paramVsDateFieldAPI,
        paramVsRangeFieldAPI,
        paramVsLikeFieldAPI
      );
      if (
        filteredQuery != null &&
        filteredQuery.trim() != null &&
        filteredQuery.trim() != CC_Constants.BLANK_STRING
      ) {
        query += ' WHERE ' + filteredQuery;
        whereAdded = true;
      }
      String customFilters = getCustomFilters(filterObject);
      if (
        customFilters != null &&
        customFilters.trim() != null &&
        customFilters.trim() != CC_Constants.BLANK_STRING
      ) {
        if (
          filteredQuery != null &&
          filteredQuery.trim() != CC_Constants.BLANK_STRING
        ) {
          query += ' AND ' + customFilters + CC_Constants.SPACE_STRING;
          whereAdded = true;
        } else {
          query += ' WHERE ' + customFilters + CC_Constants.SPACE_STRING;
          whereAdded = true;
        }
      }
    }
    if (accountIds != null && !accountIds.isEmpty()) {
      if (whereAdded) {
        query += ' AND Account__c IN :accountIds';
      } else {
        query += ' WHERE Account__c IN :accountIds';
        whereAdded = true;
      }
    }
    if (
      searchListKeyword != null &&
      searchListKeyword != CC_Constants.BLANK_STRING
    ) {
      String searchFilter = CC_SharedUtility.getSearchKeywordFilter(
        searchListKeyword,
        'Quote__c',
        'Account_Detail_Search_Quotes'
      );
      if (whereAdded) {
        query += searchFilter;
      } else {
        query += ' WHERE ' + searchFilter.trim().removeStart('AND');
      }
    }
    query += ' ORDER BY Name DESC';
    if (
      paginationParamsString != null &&
      paginationParamsString != CC_Constants.BLANK_STRING
    ) {
      paginationParams = (Map<String, Object>) JSON.deserializeUntyped(
        paginationParamsString
      );
      query += CC_SharedUtility.getLimitOffest(paginationParams);
    }
    system.debug('query->' + query);
    return query;
  }

  /*
   * @purpose     : Method to get Map of Quote Id and corresponding List of FreightDetail Records
   * @parameter   : quoteIds - Set of Quote Ids
   * @return      : Map of Quote Id and corresponding List of FreightDetail Records
   */
  public static Map<Id, List<FreightDetail__c>> getFreightDetailsMap(
    Set<Id> QuoteIds
  ) {
    Map<Id, List<FreightDetail__c>> quoteIdVsFreightDetailList = new Map<Id, List<FreightDetail__c>>();
    List<FreightDetail__c> Freightdetails = QuoteDAO.getFreightDetailsByQuoteIds(
      QuoteIds
    );
    for (FreightDetail__c fdobj : Freightdetails) {
      if (
        quoteIdVsFreightDetailList != null &&
        quoteIdVsFreightDetailList.get(fdobj.Shipment__r.Quote__c) != null
      ) {
        List<FreightDetail__c> Freights = quoteIdVsFreightDetailList.get(
          fdobj.Shipment__r.Quote__c
        );
        Freights.add(fdobj);
        quoteIdVsFreightDetailList.put(fdobj.Shipment__r.Quote__c, Freights);
      } else {
        List<FreightDetail__c> Freights = new List<FreightDetail__c>();
        Freights.add(fdobj);
        quoteIdVsFreightDetailList.put(fdobj.Shipment__r.Quote__c, Freights);
      }
    }
    return quoteIdVsFreightDetailList;
  }

  /*
   * @purpose     : Method to get Map of Quote Id and corresponding List of Requirement Records
   * @parameter   : quoteIds - Set of Quote Ids
   * @return      : Map of Quote Id and corresponding List of Requirement Records
   */
  public static Map<Id, List<Requirement__c>> getRequirementsMap(
    Set<Id> QuoteIds
  ) {
    Map<Id, List<Requirement__c>> quoteIdVsRequirementList = new Map<Id, List<Requirement__c>>();
    List<Requirement__c> Requirementlist = QuoteDAO.getRequirementByQuoteIds(
      QuoteIds
    );
    for (Requirement__c requirement : Requirementlist) {
      if (
        quoteIdVsRequirementList != null &&
        quoteIdVsRequirementList.get(
          requirement.Freight__r.Shipment__r.Quote__c
        ) != null
      ) {
        List<Requirement__c> Requirements = quoteIdVsRequirementList.get(
          requirement.Freight__r.Shipment__r.Quote__c
        );
        Requirements.add(requirement);
        quoteIdVsRequirementList.put(
          requirement.Freight__r.Shipment__r.Quote__c,
          Requirements
        );
      } else {
        List<Requirement__c> Requirements = new List<Requirement__c>();
        Requirements.add(requirement);
        quoteIdVsRequirementList.put(
          requirement.Freight__r.Shipment__r.Quote__c,
          Requirements
        );
      }
    }
    return quoteIdVsRequirementList;
  }

  /*
   * @purpose     : Method to get Total Number of Bookings corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings numbers it to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : Integer - Number of Bookings corresponding to the List of account ids
   */
  @AuraEnabled
  public static Integer getTotalQuotes(
    List<Id> accountIds,
    String filterObjectString,
    String searchListKeyword
  ) {
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = 'SELECT Count(Id) Total From Quote__c ';
    Boolean whereAdded = false;
    if (
      filterObjectString != null &&
      filterObjectString != CC_Constants.BLANK_STRING
    ) {
      filterObject = (Map<String, Object>) JSON.deserializeUntyped(
        filterObjectString
      );
      String filteredQuery = CC_SharedUtility.getFilters(
        filterObject,
        paramVsStringFieldAPI,
        paramVsDateFieldAPI,
        paramVsRangeFieldAPI,
        paramVsLikeFieldAPI
      );
      if (
        filteredQuery.trim() != null &&
        filteredQuery.trim() != CC_Constants.BLANK_STRING
      ) {
        query += ' WHERE ' + filteredQuery;
        whereAdded = true;
      }
      String customFilters = getCustomFilters(filterObject);
      if (
        customFilters != null &&
        customFilters.trim() != null &&
        customFilters.trim() != CC_Constants.BLANK_STRING
      ) {
        if (
          filteredQuery != null &&
          filteredQuery.trim() != CC_Constants.BLANK_STRING
        ) {
          query += ' AND ' + customFilters + CC_Constants.SPACE_STRING;
          whereAdded = true;
        } else {
          query += ' WHERE ' + customFilters + CC_Constants.SPACE_STRING;
          whereAdded = true;
        }
      }
    }
    if (accountIds != null && !accountIds.isEmpty()) {
      if (whereAdded) {
        query += ' AND Account__c IN: accountIds';
        whereAdded = true;
      } else {
        query += ' WHERE Account__c IN: accountIds';
        whereAdded = true;
      }
    }
    if (
      searchListKeyword != null &&
      searchListKeyword != CC_Constants.BLANK_STRING
    ) {
      String searchFilter = CC_SharedUtility.getSearchKeywordFilter(
        searchListKeyword,
        'Quote__c',
        'Account_Detail_Search_Quotes'
      );
      if (whereAdded) {
        query += searchFilter;
      } else {
        query += ' WHERE ' + searchFilter.trim().removeStart('AND');
      }
    }
    System.debug('###' + query);
    return QuoteDAO.getTotalQuotesByQueryAccountIds(query, accountIds);
  }

  /*
   * @purpose     : Method to get List of Account records corresponding to the account Id provided
   * @parameter   : accountId - The Id of the account whose information is to be fetched
   * @return      : List < Account > - List of Account records corresponding to the account Id provided
   */
  @AuraEnabled
  public static List<Account> getChildAccounts(Id accountId) {
    Account accountRecord = new Account();
    List<Account> childAccounts = new List<Account>();
    try {
      accountRecord = AccountDAO.getAccountByAccountId(accountId);
      if (
        accountRecord.ChildAccounts != null &&
        !accountRecord.ChildAccounts.isEmpty()
      ) {
        childAccounts = accountRecord.ChildAccounts;
      }
      return childAccounts;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_AccountDetailController',
        'getAccountRecord',
        'Account Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      return null;
    }
  }

  /*
   * @purpose     : Method to get WHERE clause for the Query depending on the filters provided using custom logic for each parameter
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @return      : String - WHERE clause for the Query
   */
  public static String getCustomFilters(Map<String, Object> filterObject) {
    String query = CC_Constants.BLANK_STRING;
    List<String> filters = new List<String>();
    String childAccfilters = '';
    if (filterObject != null) {
      filters = getShowAccFilters(filterObject, filters);
      filters = getHazBookFilters(filterObject, filters);
      filters = getCommoditiesFilters(filterObject, filters);
      filters = getOriginDestinationFilters(filterObject, filters);
      filters = getContainerTypeFilters(filterObject, filters);
    }
    if (filters != null && !filters.isEmpty()) {
      query += String.join(filters, ' AND ');
    }
    if (childAccfilters != null && childAccfilters != '') {
      query += ' AND (' + childAccfilters + ' )';
    }
    return query;
  }

  /*public static List<String> getContractFilters(Map < String, Object > filterObject, List<String> filters){
         List<String> filtersClauses = filters;
         if (filterObject.get('selectedContractId') != null && (String) filterObject.get('selectedContractId') != CC_Constants.BLANK_STRING) {
             String filterClause = CC_Constants.BLANK_STRING;
             filterClause = CC_Constants.SPACE_STRING;
             filtersClauses.add(filterClause);
         }
         return filtersClauses;
     }*/

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the Show Child Acc Data
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getShowAccFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    String accountId = '';
    List<String> accIds = new List<String>();
    if (
      filterObject.get('selectedAccountId') != null &&
      (String) filterObject.get('selectedAccountId') !=
      CC_Constants.BLANK_STRING
    ) {
      accountId = (String) filterObject.get('selectedAccountId');
      accIds.add(accountId);
    }
    if (
      filterObject.get('showChildAcc') != null &&
      (String) filterObject.get('showChildAcc') != CC_Constants.BLANK_STRING &&
      ((String) filterObject.get('showChildAcc')).containsIgnoreCase('Yes')
    ) {
      Account acc = AccountDAO.getAccountByAccountId(accountId);
      if (acc.ChildAccounts != null && !acc.ChildAccounts.isEmpty()) {
        for (Account account : acc.ChildAccounts) {
          accIds.add(account.Id);
        }
      }
    }
    if (accIds != null && !accIds.isEmpty()) {
      filtersClauses.add(
        ' Account__c IN (\'' +
        String.join(accIds, '\',\'') +
        '\') '
      );
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the Hazardous Booking
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getHazBookFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    if (
      filterObject.get('hazQuote') != null &&
      (String) filterObject.get('hazQuote') != CC_Constants.BLANK_STRING
    ) {
      String hazQuote = (String) filterObject.get('hazQuote');
      String clause = CC_Constants.BLANK_STRING;
      if (hazQuote.containsIgnoreCase('Yes')) {
        clause += 'TRUE';
      }
      if (hazQuote.containsIgnoreCase('No')) {
        clause += (clause != CC_Constants.BLANK_STRING
          ? ',' + 'FALSE'
          : 'FALSE');
      }
      filtersClauses.add(' Is_Hazardous__c IN (' + clause + ') ');
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the Origin and Destination
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getOriginDestinationFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    String description = CC_Constants.BLANK_STRING;
    String origin = CC_Constants.BLANK_STRING;
    String destination = CC_Constants.BLANK_STRING;
    Map<String, Id> locTypeVsId = new Map<String, Id>();
    if (
      filterObject.get('originMovementType') != null &&
      (String) filterObject.get('originMovementType') !=
      CC_Constants.BLANK_STRING
    ) {
      description += (String) filterObject.get('originMovementType');
      origin = (String) filterObject.get('originMovementType');
    } else {
      description += '%';
    }
    if (
      filterObject.get('destMovementType') != null &&
      (String) filterObject.get('destMovementType') != CC_Constants.BLANK_STRING
    ) {
      description += (String) filterObject.get('destMovementType');
      destination = (String) filterObject.get('destMovementType');
    } else {
      description += '%';
    }
    if (
      description != null &&
      description != CC_Constants.BLANK_STRING &&
      description != '%' &&
      description != '%%'
    ) {
      filtersClauses.add(' Description__c LIKE ' + '\'' + description + '\'');
    }

    if (
      filterObject.get('originLocationId') != null &&
      (String) filterObject.get('originLocationId') != CC_Constants.BLANK_STRING
    ) {
      locTypeVsId.put('Origin', (String) filterObject.get('originLocationId'));
    }
    if (
      filterObject.get('destinationLocationId') != null &&
      (String) filterObject.get('destinationLocationId') !=
      CC_Constants.BLANK_STRING
    ) {
      locTypeVsId.put(
        'Destination',
        (String) filterObject.get('destinationLocationId')
      );
    }
    if (locTypeVsId != null && !locTypeVsId.isEmpty()) {
      List<Location__c> locations = getLocations(locTypeVsId.values());
      Map<Id, Location__c> locationsMap = new Map<Id, Location__c>(locations);
      List<String> resolvedFilterClause = resolveOriginDestFilter(
        origin,
        destination,
        locationsMap,
        locTypeVsId
      );
      if (resolvedFilterClause != null && !resolvedFilterClause.isEmpty()) {
        filtersClauses.addAll(resolvedFilterClause);
      }
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get List of Location__c records by Ids
   * @parameter   : locIds - List of Location__c Ids
   * @return      : List of Location__c records
   */
  public static List<Location__c> getLocations(List<Id> locIds) {
    String query = 'SELECT Id, Name, LcCode__c, Location_Name__c, Country_Name__c, Country_Code__c, City__c, State__c  FROM Location__c WHERE Id IN :locIds';
    return Database.query(query);
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the Origin and Destination
   * @parameter   : origin - Origin Movement Type
   * @parameter   : destination - Destination Movement Type
   * @parameter   : locationsMap - Map of Location Id as key and corresponding record as value
   * @parameter   : locTypeVsId - Map of Location type as key and Location id as value
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> resolveOriginDestFilter(
    String origin,
    String destination,
    Map<Id, Location__c> locationsMap,
    Map<String, Id> locTypeVsId
  ) {
    List<String> filterClause = new List<String>();
    Map<String, String> ports = new Map<String, String>();
    if (
      origin != null &&
      origin != CC_Constants.BLANK_STRING &&
      locTypeVsId.get('Origin') != null
    ) {
      if (origin.equalsIgnoreCase('P') || origin.equalsIgnoreCase('R')) {
        ports.put('Origin', locationsMap.get(locTypeVsId.get('Origin')).Name);
      }
      if (origin.equalsIgnoreCase('D')) {
        filterClause.add(
          ' Customer_Origin_Zip__c = \'' +
          locationsMap.get(locTypeVsId.get('Origin')).Name +
          '\''
        );
      }
    }
    if (
      destination != null &&
      destination != CC_Constants.BLANK_STRING &&
      locTypeVsId.get('Destination') != null
    ) {
      if (
        destination.equalsIgnoreCase('P') || destination.equalsIgnoreCase('R')
      ) {
        ports.put(
          'Destination',
          locationsMap.get(locTypeVsId.get('Destination')).Name
        );
      }
      if (destination.equalsIgnoreCase('D')) {
        filterClause.add(
          ' Customer_Destination_Zip__c = \'' +
          locationsMap.get(locTypeVsId.get('Destination')).Name +
          '\''
        );
      }
    }

    if (ports != null && !ports.isEmpty()) {
      List<String> portFilterClauses = getPortFilters(ports);
      if (portFilterClauses != null && !portFilterClauses.isEmpty()) {
        filterClause.addAll(portFilterClauses);
      }
    }
    return filterClause;
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the Ports provided
   * @parameter   : ports - Map of Origin or destination as key and corresponding port name as value
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getPortFilters(Map<String, String> ports) {
    List<String> filters = new List<String>();
    Set<Id> originQuoteIds = new Set<Id>();
    Set<Id> destinationQuoteIds = new Set<Id>();
    List<Quote__c> quotes = QuoteDAO.getQuoteByOriginDestinationCode(
      ports.values(),
      ports.values()
    );
    if (quotes != null && !quotes.isEmpty()) {
      for (Quote__c QuoteObj : quotes) {
        if (
          QuoteObj.Customer_Origin_Code__c != null &&
          ports != null &&
          ports.get('Origin') != null &&
          QuoteObj.Customer_Origin_Code__c.equalsIgnoreCase(ports.get('Origin'))
        ) {
          originQuoteIds.add(QuoteObj.Id);
        }
        if (
          QuoteObj.Customer_Destination_Code__c != null &&
          ports != null &&
          ports.get('Destination') != null &&
          QuoteObj.Customer_Destination_Code__c.equalsIgnoreCase(
            ports.get('Destination')
          )
        ) {
          destinationQuoteIds.add(QuoteObj.Id);
        }
      }
      if (originQuoteIds != null && !originQuoteIds.isEmpty()) {
        String values = '(\'';
        values += String.join(
          (List<String>) JSON.deserialize(
            JSON.serialize(originQuoteIds),
            List<String>.class
          ),
          '\',\''
        );
        values += '\') ';
        filters.add(' Id IN ' + values);
      }
      if (destinationQuoteIds != null && !destinationQuoteIds.isEmpty()) {
        String values = '(\'';
        values += String.join(
          (List<String>) JSON.deserialize(
            JSON.serialize(destinationQuoteIds),
            List<String>.class
          ),
          '\',\''
        );
        values += '\') ';
        filters.add(' Id IN ' + values);
      }
    }
    return filters;
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for Container Type
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getContainerTypeFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    if (
      filterObject.get('containerTypeSelected') != null &&
      (String) filterObject.get('containerTypeSelected') !=
      CC_Constants.BLANK_STRING
    ) {
      String filterClause = CC_Constants.BLANK_STRING;
      String containerType = (String) filterObject.get('containerTypeSelected');
      List<Requirement__c> requirements = QuoteDAO.getRequirementsByContainerType(
        containerType
      );
      if (requirements != null && !requirements.isEmpty()) {
        Set<Id> QuoteIds = new Set<Id>();
        for (Requirement__c requirement : requirements) {
          QuoteIds.add(requirement.Freight__r.Shipment__r.Quote__c);
        }
        if (QuoteIds != null && !QuoteIds.isEmpty()) {
          String values = '(\'';
          values += String.join(
            (List<String>) JSON.deserialize(
              JSON.serialize(QuoteIds),
              List<String>.class
            ),
            '\',\''
          );
          values += '\') ';
          filtersClauses.add(' Id IN ' + values);
        }
      } else {
        filtersClauses.add(' Id = NULL ');
      }
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for Commodities
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getCommoditiesFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    if (
      filterObject.get('comoditySelected') != null &&
      (String) filterObject.get('comoditySelected') != CC_Constants.BLANK_STRING
    ) {
      String filterClause = CC_Constants.BLANK_STRING;
      String commodity = (String) filterObject.get('comoditySelected');
      List<Requirement__c> requirements = QuoteDAO.getRequirementsByCommodityName(
        commodity
      );
      List<FreightDetail__c> freightdetails = QuoteDAO.getFreightDetailsByCommodityName(
        commodity
      );
      if (
        requirements != null && !requirements.isEmpty() ||
        freightdetails != null && !freightdetails.isEmpty()
      ) {
        Set<Id> QuoteIds = new Set<Id>();
        if (requirements != null && !requirements.isEmpty()) {
          for (Requirement__c requirement : requirements) {
            QuoteIds.add(requirement.Freight__r.Shipment__r.Quote__c);
          }
        }
        if (freightdetails != null && !freightdetails.isEmpty()) {
          for (FreightDetail__c fdVar : freightdetails) {
            QuoteIds.add(fdVar.Shipment__r.Quote__c);
          }
        }
        if (QuoteIds != null && !QuoteIds.isEmpty()) {
          String values = '(\'';
          values += String.join(
            (List<String>) JSON.deserialize(
              JSON.serialize(QuoteIds),
              List<String>.class
            ),
            '\',\''
          );
          values += '\') ';
          filtersClauses.add(' Id IN ' + values);
        }
      } else {
        filtersClauses.add(' Id = NULL ');
      }
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get List of Map of Movement Type Values
   * @return      : List of Map of Movement Type Values
   */
  private static List<Map<String, String>> getMovementTypes() {
    List<Map<String, String>> movementTypes = new List<Map<String, String>>();
    Map<String, String> moveTypeDoor = CC_SharedUtility.convertToLabelValue(
      'Door',
      'D'
    );
    Map<String, String> moveTypePort = CC_SharedUtility.convertToLabelValue(
      'Port',
      'P'
    );
    Map<String, String> moveTypeRail = CC_SharedUtility.convertToLabelValue(
      'Rail Ramp',
      'R'
    );
    movementTypes.add(moveTypeDoor);
    movementTypes.add(moveTypePort);
    movementTypes.add(moveTypeRail);
    return movementTypes;
  }

  /*
   * @purpose     : Method to get List of Map of Container Type Values
   * @return      : List of Map of Container Type Values
   */
  private static List<Map<String, String>> getContainerTypes() {
    List<Map<String, String>> containreTypes = new List<Map<String, String>>();
    for (String code : containersCICSCodeVsDescriptionCSMap.keySet()) {
      Map<String, String> codeVsType = CC_SharedUtility.convertToLabelValue(
        containersCICSCodeVsDescriptionCSMap.get(code),
        code
      );
      containreTypes.add(codeVsType);
    }
    return containreTypes;
  }

  /*
   * @purpose     : Method to get List of Map of Commoditiy Values
   * @return      : List of Map of Commodities Values
   */
  private static List<String> getCommodities() {
    List<Open_Tariff_Commodities__mdt> openTariffCommoditiesList = new List<Open_Tariff_Commodities__mdt>();
    Map<String, String> commodityCodeNameMap = new Map<String, String>();
    openTariffCommoditiesList = CustomMetadataTypeDAO.getOpenTariffCommodities();
    for (Open_Tariff_Commodities__mdt OTCobj : openTariffCommoditiesList) {
      if (
        commodityCodeNameMap.isEmpty() ||
        !commodityCodeNameMap.containsKey(OTCobj.Commodity_Code__c)
      ) {
        commodityCodeNameMap.put(
          OTCobj.Commodity_Code__c,
          OTCobj.Commodity_Name__c
        );
      }
    }
    return commodityCodeNameMap.values();
  }

  // Getter and Setter for Map of Container Code as key and Description as Value
  public static Map<String, String> containersCICSCodeVsDescriptionCSMap {
    get {
      if (containersCICSCodeVsDescriptionCSMap == null) {
        containersCICSCodeVsDescriptionCSMap = new Map<String, String>();
        for (String name : Container__c.getAll().keySet()) {
          containersCICSCodeVsDescriptionCSMap.put(
            Container__c.getAll().get(name).CICS_ISO_Code__c,
            Container__c.getAll().get(name).Description__c
          );
        }
      }
      return containersCICSCodeVsDescriptionCSMap;
    }
    set;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 20-10-2020
   * @author      : Nagarro
   * @description : QuoteListMetadata wrapper class to hold the Quote Filter Metadata
   * @history     : Version 1.0
   */
  public class QuoteListMetadata {
    @AuraEnabled
    public List<Map<String, String>> statuses { get; set; }
    @AuraEnabled
    public List<Map<String, String>> originMovementTypes { get; set; }
    @AuraEnabled
    public List<Map<String, String>> destMovementTypes { get; set; }
    @AuraEnabled
    public List<Map<String, String>> containerTypes { get; set; }
    @AuraEnabled
    public List<String> commodities { get; set; }
    @AuraEnabled
    public List<Map<String, String>> vessals { get; set; }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 20-10-2020
   * @author      : Nagarro
   * @description : QuoteDataWrapper wrapper class to hold the Quote Information
   * @history     : Version 1.0
   */
  public class QuoteDataWrapper {
    @AuraEnabled
    public Quote__c quote { get; set; }
    @AuraEnabled
    public List<FreightDetail__c> freightdetails { get; set; }
    @AuraEnabled
    public List<Requirement__c> requirements { get; set; }
  }
}
