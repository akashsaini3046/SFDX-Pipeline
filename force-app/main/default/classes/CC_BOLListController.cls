/*
 * 25-11-2020 – Piyush Kumar – Created this class for handling functionality related to BOL List Page.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 25-11-2020
 * @author      : Nagarro
 * @description : Service Side Controller for CC_BOLList, CC_BOLListFilter Lightning Components
 *                Also used by CC_AccountDetailController Apex Class
 * @history     : Version 1.0
 * @test class  : CC_BOLListCtrlTest
 */
public without sharing class CC_BOLListController {
  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in direct(" = ") filters
  public static Map<String, String> paramVsStringFieldAPI = new Map<String, String>{
    'selectedAccountId' => 'Booking_Number__r.Account__c',
    'bookingNumber' => 'Booking_Number__c',
    'createdBy' => 'CreatedById',
    'status' => 'Bill_of_lading_Status__c'
  };

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( "LIKE") filters
  public static Map<String, String> paramVsLikeFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in Date ( without quotes ) filters
  public static Map<String, String> paramVsDateFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( ">=" , "<  =") filters
  public static Map<String, String> paramVsRangeFieldAPI = new Map<String, String>{
    'sailBetweenFrom' => 'Booking_Number__r.Date_of_Loading__c',
    'sailBetweenTo' => 'Booking_Number__r.Date_of_Loading__c'
  };

  /*
   * @purpose     : Method to get List of BOLDataWrapper corresponding to the the list of account ids and with all the filters
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<CC_BOLListCtrl.BOLDataWrapper> - List of BOLDataWrapper inner class
   */
  @AuraEnabled
  public static List<BolDataWrapper> getBolListData(
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    List<BolDataWrapper> bolDataWrapperList = new List<BolDataWrapper>();
    //List<Bill_Of_Lading__c> bols = getbolRecords(paginationParamsString);
    List<Bill_Of_Lading__c> bols = getbolRecords(
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
    for (Bill_Of_Lading__c bol : bols) {
      BolDataWrapper bolDataWrapper = new BolDataWrapper();
      bolDataWrapper.billOfLading = bol;
      bolDataWrapperList.add(bolDataWrapper);
    }
    return bolDataWrapperList;
  }

  /*
   * @purpose     : Method to get List of Bill_Of_Lading__c Records corresponding to the the list of account ids and with all the filters by using Database query
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<Bill_Of_Lading__c> - List of Bill_Of_Lading__c records
   */
  private static List<Bill_Of_Lading__c> getBolRecords(
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    String query = createBolListQuery(
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
    System.debug('@@@@@ ' + query);
    return Database.query(query);
  }

  /*
   * @purpose     : Method to get Query string corresponding to the the list of account ids and with all the filters
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : String - query string corresponding to the the list of account ids and with all the filters
   */
  private static String createBolListQuery(
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword
  ) {
    String query =
      'SELECT Id, Booking_Number__c, Name, Bill_Of_Lading_Number__c, Booking_Number__r.Booking_Number__c,Booking_Number__r.Account__r.Name, Account_Name__c,Bill_of_lading_Status__c,' +
      'Booking_Number__r.Date_of_Loading__c,CreatedBy.Name,Load_Port__c,Origin_Voyage__c,Load_Port_Description__c FROM Bill_Of_Lading__c';
    Boolean whereAdded = false;
    query += getQueryWhere(
      filterObjectString,
      paginationParamsString,
      searchListKeyword,
      whereAdded
    );

    return query;
  }

  private static String getQueryWhere(
    String filterObjectString,
    String paginationParamsString,
    String searchListKeyword,
    Boolean whereAdded
  ) {
    Map<String, Object> paginationParams = new Map<String, Object>();
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = '';
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
    if (
      searchListKeyword != null &&
      searchListKeyword != CC_Constants.BLANK_STRING
    ) {
      String searchFilter = CC_SharedUtility.getSearchKeywordFilter(
        searchListKeyword,
        'Bill_Of_Lading__c',
        'Search_BOL'
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
   * @purpose     : Method to get WHERE clause for the Query depending on the filters provided using custom logic for each parameter
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @return      : String - WHERE clause for the Query
   */
  public static String getCustomFilters(Map<String, Object> filterObject) {
    String query = CC_Constants.BLANK_STRING;
    List<String> filters = new List<String>();
    if (filterObject != null) {
      filters = getLoadPortFilters(filterObject, filters);
    }
    if (filters != null && !filters.isEmpty()) {
      query += String.join(filters, ' AND ');
    }
    return query;
  }

  /*
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the LoadPortFilters
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getLoadPortFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    Map<String, Id> locTypeVsId = new Map<String, Id>();

    if (
      filterObject.get('originLocationId') != null &&
      (String) filterObject.get('originLocationId') != CC_Constants.BLANK_STRING
    ) {
      locTypeVsId.put('Origin', (String) filterObject.get('originLocationId'));
    }
    if (locTypeVsId != null && !locTypeVsId.isEmpty()) {
      List<Location__c> locations = getLocations(locTypeVsId.values());
      Map<Id, Location__c> locationsMap = new Map<Id, Location__c>(locations);

      filtersClauses.add(
        '( Load_Port_Description__c = \'' +
        locationsMap.get(locTypeVsId.get('Origin')).Location_Name__c +
        '\'' +
        ' OR ' +
        ' Load_Port_Description__c = \'' +
        locationsMap.get(locTypeVsId.get('Origin')).Location_Name__c +
        '\'' +
        ' OR ' +
        'Load_Port__c = \'' +
        locationsMap.get(locTypeVsId.get('Origin')).Name +
        '\')'
      );
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get List of Location__c records by Ids
   * @parameter   : locIds - List of Location__c Ids
   * @return      : List of Location__c records
   */
  public static List<Location__c> getLocations(List<Id> locIds) {
    Set<Id> LocationIds = new Set<Id>();
    LocationIds.addAll(locIds);
    return LocationDAO.getLocationsByIds(LocationIds);
  }

  /*
   * @purpose     : Method to get Total Number of BOLs corresponding to the the list of account ids and with all the filters
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : Integer - Number of BOLs corresponding to the List of account ids
   */
  @AuraEnabled
  public static Integer getTotalBols(
    String filterObjectString,
    String searchListKeyword
  ) {
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = 'SELECT Count(Id) Total From Bill_Of_Lading__c ';
    Boolean whereAdded = false;
    query += getQueryWhere(
      filterObjectString,
      null,
      searchListKeyword,
      whereAdded
    );
    AggregateResult results = Database.query(query);
    Integer totalRecords = (Integer) results.get('Total');
    return totalRecords;
  }

  /*
   * @purpose     : Method to get pdf download url
   * @parameter   : bookingId - It holds booking id
   * @parameter   : bolId - It holds bol id
   * @parameter   : strPageName - It holds VF page name
   * @return      : String - pdf download url
   */
  @AuraEnabled
  public static String fetchPDFUrl(
    String bookingId,
    String bolId,
    String strPageName
  ) {
    String PDFUrl;
    String communityUrlPathPrefix = CommonUtility.getCommunityUrlPathPrefix();
    if (Network.getNetworkId() != null) {
      PDFUrl =
        '/' +
        communityUrlPathPrefix +
        '/apex/' +
        strPageName +
        '?bookingId=' +
        bookingId +
        '&bolId=' +
        bolId;
    } else {
      PDFUrl =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/' +
        strPageName +
        '?Id=' +
        bookingId +
        '&bolId=' +
        bolId;
    }
    System.debug('PDFUrl is ' + PDFUrl);
    return PDFUrl;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : BolDataWrapper wrapper class to hold the BOL Information
   * @history     : Version 1.0
   */
  public class BolDataWrapper {
    @AuraEnabled
    public Bill_Of_Lading__c billOfLading { get; set; }
  }
}
