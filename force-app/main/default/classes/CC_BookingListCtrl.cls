/*
 * 05-09-2020 – Drupad Preenja – Created this class for handling functionality related to Booking List Page.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : Service Side Controller for CC_BookingList, CC_BookingListFilter Lightning Components
 *                Also used by CC_AccountDetailController Apex Class
 * @history     : Version 1.0
 * @test class  : CC_BookingListCtrlTest
 */
public with sharing class CC_BookingListCtrl {
  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in direct(" = ") filters
  public static Map<String, String> paramVsStringFieldAPI = new Map<String, String>{
    'statusSelected' => 'Status__c',
    'transModeOriginSelected' => 'Transportation_Management_System_Origin__c',
    'transModeDestSelected' => 'Transportation_Management_System_Destina__c',
    'contractInput' => 'Contract_Number__c'
  };

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( "LIKE") filters
  public static Map<String, String> paramVsLikeFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in Date ( without quotes ) filters
  public static Map<String, String> paramVsDateFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( ">=" , "<  =") filters
  public static Map<String, String> paramVsRangeFieldAPI = new Map<String, String>{
    'departureFromDate' => 'Date_of_Discharge__c',
    'departureToDate' => 'Date_of_Discharge__c'
  };

  /*
   * @purpose     : Method to get Metadata for the filters on Bookings List Page
   * @return      : BookingListMetadata - Inner class containing the information for the filters of Bookings
   */
  @AuraEnabled
  public static BookingListMetadata getBookingMetaData() {
    BookingListMetadata bookingListMetadata = new BookingListMetadata();
    bookingListMetadata.statuses = CC_SharedUtility.getPicklistValuesList(
      Booking__c.Status__c.getDescribe()
    );
    bookingListMetadata.originMovementTypes = getMovementTypes();
    bookingListMetadata.destMovementTypes = getMovementTypes();
    bookingListMetadata.transModesOrigin = CC_SharedUtility.getPicklistValuesList(
      Booking__c.Transportation_Management_System_Origin__c.getDescribe()
    );
    bookingListMetadata.transModesDestination = CC_SharedUtility.getPicklistValuesList(
      Booking__c.Transportation_Management_System_Destina__c.getDescribe()
    );
    bookingListMetadata.containerTypes = getContainerTypes();
    bookingListMetadata.commodities = getCommodities();
    bookingListMetadata.vessals = CC_SharedUtility.getPicklistValuesList(
      Booking__c.Vessels__c.getDescribe()
    );
    return bookingListMetadata;
  }

  /*
   * @purpose     : Method to get List of BookingDataWrapper corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<CC_BookingListCtrl.BookingDataWrapper> - List of BookingDataWrapper inner class
   */
  @AuraEnabled
  public static List<BookingDataWrapper> getBookingListData(
    List<Id> accountIds,
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    List<BookingDataWrapper> bookingDataWrapperList = new List<BookingDataWrapper>();
    List<Booking__c> bookings = getBookingRecords(
      accountIds,
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
    Map<Id, Booking__c> bookingsMap = new Map<Id, Booking__c>(bookings);
    Map<Id, String> bookingIdVsStopsCount = getStopsCount(bookingsMap.keySet());
    Map<Id, List<Shipment__c>> bookingIdVsShipmentList = getShipmentsMap(
      bookingsMap.keySet()
    );
    Map<Id, List<Voyage__c>> bookingIdVsVoyageList = getVoyagesMap(
      bookingsMap.keySet()
    );
    Map<Id, List<Commodity__c>> bookingIdVsCommodityList = getCommoditiesMap(
      bookingsMap.keySet()
    );
    for (Booking__c booking : bookings) {
      BookingDataWrapper bookingDataWrapper = new BookingDataWrapper();
      bookingDataWrapper.booking = booking;
      bookingDataWrapper.noOfStops = (bookingIdVsStopsCount != null &&
        bookingIdVsStopsCount.get(booking.Id) != null)
        ? bookingIdVsStopsCount.get(booking.Id)
        : '0 Stops';
      bookingDataWrapper.shipments = (bookingIdVsShipmentList != null &&
        bookingIdVsShipmentList.get(booking.Id) != null)
        ? bookingIdVsShipmentList.get(booking.Id)
        : null;
      bookingDataWrapper.voyages = (bookingIdVsVoyageList != null &&
        bookingIdVsVoyageList.get(booking.Id) != null)
        ? bookingIdVsVoyageList.get(booking.Id)
        : null;
      bookingDataWrapper.commodities = (bookingIdVsCommodityList != null &&
        bookingIdVsCommodityList.get(booking.Id) != null)
        ? bookingIdVsCommodityList.get(booking.Id)
        : null;
      bookingDataWrapperList.add(bookingDataWrapper);
    }
    return bookingDataWrapperList;
  }

  /*
   * @purpose     : Method to get List of Booking__c Records corresponding to the the list of account ids and with all the filters by using Database query
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<Booking__c> - List of Booking__c records
   */
  private static List<Booking__c> getBookingRecords(
    List<Id> accountIds,
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    String query = createBookingListQuery(
      accountIds,
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
    System.debug('@@@@@ ' + query);
    return BookingDAO.getBookingByQuery(query, accountIds);
  }

  /*
   * @purpose     : Method to get Query string corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : String - query string corresponding to the the list of account ids and with all the filters
   */
  private static String createBookingListQuery(
    List<Id> accountIds,
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    System.debug(filterObjectString);
    Map<String, Object> filterObject = new Map<String, Object>();
    Map<String, Object> paginationParams = new Map<String, Object>();
    String query =
      'SELECT Id, Name, Booking_Number__c, Container_Mode__c, Is_Hazardous__c, Customer_Origin_Code__c, Description__c,Customer_Destination_City__c,Customer_Destination_State__c,Customer_Destination_Country__c,toLabel(Status__c),' +
      'Customer_Origin_City__c,Customer_Origin_State__c,Customer_Origin_Country__c,Transit_Days__c, Customer_Destination_Code__c, Account__r.Name, Contract_Number__c, Date_of_Loading__c, Date_of_Discharge__c, Vessel_Name__c FROM Booking__c';
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
        'Booking__C',
        'Account_Detail_Search_Bookings'
      );
      if (whereAdded) {
        query += searchFilter;
      } else {
        query += ' WHERE ' + searchFilter.trim().removeStart('AND');
      }
    }
    if (
      paginationParamsString != null &&
      paginationParamsString != CC_Constants.BLANK_STRING
    ) {
      paginationParams = (Map<String, Object>) JSON.deserializeUntyped(
        paginationParamsString
      );
      query += CC_SharedUtility.getLimitOffest(paginationParams);
    }
    return query;
  }

  /*
   * @purpose     : Method to get Total Number of Bookings corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings numbers it to be fetched
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : Integer - Number of Bookings corresponding to the List of account ids
   */
  @AuraEnabled
  public static Integer getTotalBookings(
    List<Id> accountIds,
    String filterObjectString,
    String searchListKeyword
  ) {
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = 'SELECT Count(Id) Total From Booking__c ';
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
        'Booking__C',
        'Account_Detail_Search_Bookings'
      );
      if (whereAdded) {
        query += searchFilter;
      } else {
        query += ' WHERE ' + searchFilter.trim().removeStart('AND');
      }
    }
    System.debug('###' + query);
    return BookingDAO.getTotalBookingsByQueryAccountIds(query, accountIds);
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
      filters = getShipmentTypeFilters(filterObject, filters);
      filters = getHazBookFilters(filterObject, filters);
      //filters = getContractFilters(filterObject, filters);// Yet to DO
      filters = getCommoditiesFilters(filterObject, filters);
      filters = getOriginDestinationFilters(filterObject, filters);
      filters = getContainerTypeFilters(filterObject, filters);
      filters = getVesselNameFilters(filterObject, filters);
    }
    if (filters != null && !filters.isEmpty()) {
      query += String.join(filters, ' AND ');
    }
    if (childAccfilters != null && childAccfilters != '') {
      query += ' AND (' + childAccfilters + ' )';
    }
    return query;
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
      List<Requirement__c> requirements = BookingDAO.getRequirementsByCommodityName(
        commodity
      );
      List<FreightDetail__c> freightdetails = BookingDAO.getFreightDetailsByCommodityName(
        commodity
      );
      if (
        requirements != null && !requirements.isEmpty() ||
        freightdetails != null && !freightdetails.isEmpty()
      ) {
        Set<Id> bookingIds = new Set<Id>();
        if (requirements != null && !requirements.isEmpty()) {
          for (Requirement__c requirement : requirements) {
            bookingIds.add(requirement.Freight__r.Shipment__r.Booking__c);
          }
        }
        if (freightdetails != null && !freightdetails.isEmpty()) {
          for (FreightDetail__c fdVar : freightdetails) {
            bookingIds.add(fdVar.Shipment__r.Booking__c);
          }
        }
        if (bookingIds != null && !bookingIds.isEmpty()) {
          String values = '(\'';
          values += String.join(
            (List<String>) JSON.deserialize(
              JSON.serialize(bookingIds),
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
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the Shipment Type
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getShipmentTypeFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    if (
      filterObject.get('shippingType') != null &&
      (String) filterObject.get('shippingType') != CC_Constants.BLANK_STRING
    ) {
      String containerMode = (String) filterObject.get('shippingType');
      List<String> clause = new List<String>();
      if (containerMode.containsIgnoreCase('FCL')) {
        clause.add('\'FCL\'');
      }
      if (containerMode.containsIgnoreCase('LCL')) {
        clause.add('\'LCL\'');
      }
      filtersClauses.add(
        ' Container_Mode__c IN (' +
        String.join(clause, ',') +
        ') '
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
      filterObject.get('hazBook') != null &&
      (String) filterObject.get('hazBook') != CC_Constants.BLANK_STRING
    ) {
      String hazBook = (String) filterObject.get('hazBook');
      String clause = CC_Constants.BLANK_STRING;
      if (hazBook.containsIgnoreCase('Yes')) {
        clause += 'TRUE';
      }
      if (hazBook.containsIgnoreCase('No')) {
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
    if (origin != null && origin != CC_Constants.BLANK_STRING) {
      if (origin.equalsIgnoreCase('P')) {
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
    if (destination != null && destination != CC_Constants.BLANK_STRING) {
      if (destination.equalsIgnoreCase('P')) {
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
    Set<Id> originBookingIds = new Set<Id>();
    Set<Id> destinationBookingIds = new Set<Id>();
    List<Shipment__c> shipments = BookingDAO.getShipmentByOriginDestinationCode(
      ports.values(),
      ports.values()
    );
    if (shipments != null && !shipments.isEmpty()) {
      for (Shipment__c shipment : shipments) {
        if (
          shipment.Origin_Code__c != null &&
          ports != null &&
          ports.get('Origin') != null &&
          shipment.Origin_Code__c.equalsIgnoreCase(ports.get('Origin'))
        ) {
          originBookingIds.add(shipment.Booking__c);
        }
        if (
          shipment.Destination_Code__c != null &&
          ports != null &&
          ports.get('Destination') != null &&
          shipment.Destination_Code__c.equalsIgnoreCase(
            ports.get('Destination')
          )
        ) {
          destinationBookingIds.add(shipment.Booking__c);
        }
      }
      if (originBookingIds != null && !originBookingIds.isEmpty()) {
        String values = '(\'';
        values += String.join(
          (List<String>) JSON.deserialize(
            JSON.serialize(originBookingIds),
            List<String>.class
          ),
          '\',\''
        );
        values += '\') ';
        filters.add(' Id IN ' + values);
      }
      if (destinationBookingIds != null && !destinationBookingIds.isEmpty()) {
        String values = '(\'';
        values += String.join(
          (List<String>) JSON.deserialize(
            JSON.serialize(destinationBookingIds),
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
      List<Requirement__c> requirements = BookingDAO.getRequirementsByContainerType(
        containerType
      );
      if (requirements != null && !requirements.isEmpty()) {
        Set<Id> bookingIds = new Set<Id>();
        for (Requirement__c requirement : requirements) {
          bookingIds.add(requirement.Freight__r.Shipment__r.Booking__c);
        }
        if (bookingIds != null && !bookingIds.isEmpty()) {
          String values = '(\'';
          values += String.join(
            (List<String>) JSON.deserialize(
              JSON.serialize(bookingIds),
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
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for Vessel Name
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getVesselNameFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    if (
      filterObject.get('vessalSelected') != null &&
      (String) filterObject.get('vessalSelected') != CC_Constants.BLANK_STRING
    ) {
      String filterClause = CC_Constants.BLANK_STRING;
      String vessalName = (String) filterObject.get('vessalSelected');
      List<Voyage__c> voyages = BookingDAO.getVoyageswithBookingIdsbyVessalName(
        vessalName
      );
      if (voyages != null && !voyages.isEmpty()) {
        Set<Id> bookingIds = new Set<Id>();
        for (Voyage__c voyageObj : voyages) {
          bookingIds.add(voyageObj.Shipment__r.Booking__c);
        }
        if (bookingIds != null && !bookingIds.isEmpty()) {
          String values = '(\'';
          values += String.join(
            (List<String>) JSON.deserialize(
              JSON.serialize(bookingIds),
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

  // public static List<String> getContractFilters(Map < String, Object > filterObject, List<String> filters){
  //     List<String> filtersClauses = filters;
  //     if (filterObject.get('selectedContractId') != null && (String) filterObject.get('selectedContractId') != CC_Constants.BLANK_STRING) {
  //         String filterClause = CC_Constants.BLANK_STRING;

  //         filterClause = CC_Constants.SPACE_STRING;
  //         filtersClauses.add(filterClause);
  //     }
  //     return filtersClauses;
  // }

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
    movementTypes.add(moveTypeDoor);
    movementTypes.add(moveTypePort);
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
   * @purpose     : Method to get Stops Count corresponding to the Booking Ids provided
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : Map of booking Id and corresponding stop count
   */
  public static Map<Id, String> getStopsCount(Set<Id> bookingIds) {
    Map<Id, String> bookingIdVsStops = new Map<Id, String>();
    List<AggregateResult> stops = BookingDAO.getStopsCountByBookingId(
      bookingIds
    );

    for (AggregateResult result : stops) {
      bookingIdVsStops.put(
        (Id) result.get('bookingId'),
        result.get('Total') + ' Stops'
      );
    }
    return bookingIdVsStops;
  }

  /*
   * @purpose     : Method to get Map of booking Id and corresponding List of Shipment Records
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : Map of booking Id and corresponding List of Shipment Records
   */
  public static Map<Id, List<Shipment__c>> getShipmentsMap(Set<Id> bookingIds) {
    Map<Id, List<Shipment__c>> bookingIdVsShipmentList = new Map<Id, List<Shipment__c>>();
    List<Shipment__c> shipments = BookingDAO.getShipmentByBookingIds(
      bookingIds
    );
    for (Shipment__c shipment : shipments) {
      if (
        bookingIdVsShipmentList != null &&
        bookingIdVsShipmentList.get(shipment.Booking__c) != null
      ) {
        List<Shipment__c> ships = bookingIdVsShipmentList.get(
          shipment.Booking__c
        );
        ships.add(shipment);
        bookingIdVsShipmentList.put(shipment.Booking__c, ships);
      } else {
        List<Shipment__c> ships = new List<Shipment__c>();
        ships.add(shipment);
        bookingIdVsShipmentList.put(shipment.Booking__c, ships);
      }
    }
    return bookingIdVsShipmentList;
  }

  /*
   * @purpose     : Method to get Map of booking Id and corresponding List of Voyage Records
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : Map of booking Id and corresponding List of Voyage Records
   */
  public static Map<Id, List<Voyage__c>> getVoyagesMap(Set<Id> bookingIds) {
    Map<Id, List<Voyage__c>> bookingIdVsVoyageList = new Map<Id, List<Voyage__c>>();
    List<Voyage__c> voyages = BookingDAO.getVoyagesByBookingIds(bookingIds);
    for (Voyage__c voyage : voyages) {
      if (
        bookingIdVsVoyageList != null &&
        bookingIdVsVoyageList.get(voyage.Shipment__r.Booking__c) != null
      ) {
        List<Voyage__c> vogs = bookingIdVsVoyageList.get(
          voyage.Shipment__r.Booking__c
        );
        vogs.add(voyage);
        bookingIdVsVoyageList.put(voyage.Shipment__r.Booking__c, vogs);
      } else {
        List<Voyage__c> vogs = new List<Voyage__c>();
        vogs.add(voyage);
        bookingIdVsVoyageList.put(voyage.Shipment__r.Booking__c, vogs);
      }
    }
    return bookingIdVsVoyageList;
  }

  /*
   * @purpose     : Method to get Map of booking Id and corresponding List of Commodity Records
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : Map of booking Id and corresponding List of Voyage Records
   */
  public static Map<Id, List<Commodity__c>> getCommoditiesMap(
    Set<Id> bookingIds
  ) {
    Map<Id, List<Commodity__c>> bookingIdVsCommodityList = new Map<Id, List<Commodity__c>>();
    List<Commodity__c> commodities = BookingDAO.getCommoditiesByBookingIds(
      bookingIds
    );
    for (Commodity__c commodity : commodities) {
      if (
        bookingIdVsCommodityList != null &&
        bookingIdVsCommodityList.get(
          commodity.Freight__r.Shipment__r.Booking__c
        ) != null
      ) {
        List<Commodity__c> vogs = bookingIdVsCommodityList.get(
          commodity.Freight__r.Shipment__r.Booking__c
        );
        vogs.add(commodity);
        bookingIdVsCommodityList.put(
          commodity.Freight__r.Shipment__r.Booking__c,
          vogs
        );
      } else {
        List<Commodity__c> vogs = new List<Commodity__c>();
        vogs.add(commodity);
        bookingIdVsCommodityList.put(
          commodity.Freight__r.Shipment__r.Booking__c,
          vogs
        );
      }
    }
    return bookingIdVsCommodityList;
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

  @AuraEnabled
  public static Booking__c getBookingDetails(Id bookingId) {
    List<Booking__c> listBookings = new List<Booking__c>();
    listBookings = BookingDAO.getBookingDetails(new Set<Id>{ bookingId });
    return listBookings[0];
  }

  @AuraEnabled
  public static String fetchDownloadUrl(Id BookingId) {
    String BookUrl;
    String communityUrlPathPrefix = CommonUtility.getCommunityUrlPathPrefix();
    if (Network.getNetworkId() != null) {
      BookUrl =
        '/' +
        communityUrlPathPrefix +
        '/apex/CC_BookingConfirmationPDF?Id=' +
        BookingId;
    } else {
      BookUrl =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/CC_BookingConfirmationPDF?Id=' +
        BookingId;
    }
    System.debug('BookUrl is ' + BookUrl);
    return BookUrl;
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
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : BookingListMetadata wrapper class to hold the Booking Filter Metadata
   * @history     : Version 1.0
   */
  public class BookingListMetadata {
    @AuraEnabled
    public List<Map<String, String>> statuses { get; set; }
    @AuraEnabled
    public List<Map<String, String>> originMovementTypes { get; set; }
    @AuraEnabled
    public List<Map<String, String>> destMovementTypes { get; set; }
    @AuraEnabled
    public List<Map<String, String>> transModesOrigin { get; set; }
    @AuraEnabled
    public List<Map<String, String>> transModesDestination { get; set; }
    @AuraEnabled
    public List<Map<String, String>> containerTypes { get; set; }
    @AuraEnabled
    public List<String> commodities { get; set; }
    @AuraEnabled
    public List<Map<String, String>> vessals { get; set; }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : BookingDataWrapper wrapper class to hold the Booking Information
   * @history     : Version 1.0
   */
  public class BookingDataWrapper {
    @AuraEnabled
    public Booking__c booking { get; set; }
    @AuraEnabled
    public List<Shipment__c> shipments { get; set; }
    @AuraEnabled
    public String noOfStops { get; set; }
    @AuraEnabled
    public List<Voyage__c> voyages { get; set; }
    @AuraEnabled
    public List<Commodity__c> commodities { get; set; }
  }
}
