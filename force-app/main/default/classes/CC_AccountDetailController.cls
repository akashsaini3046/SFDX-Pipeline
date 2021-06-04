/*
 * 05-09-2020 – Drupad Preenja – Created this class for handling functionality related to Account Detail Page.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : Service Side Controller for CC_AccountDetail, CC_AccountDetailBooking,
 *                CC_AccountDetailChildAcc, CC_AccountDetailContacts Lightning Components
 * @history     : Version 1.0
 * @test class  : CC_AccountDetailControllerTest
 */
public with sharing class CC_AccountDetailController {
  public static Map<String, String> paramVsStringFieldAPI = new Map<String, String>{
    'searchRegion' => 'Sales_Rep_Region__c',
    'searchContractRegion' => 'RegionTxt__c',
    'contractStatus' => 'Status',
    'accountId' => 'Id',
    'contractId' => 'Id',
    'accountConId' => 'AccountId',
    'vessalSelected' => 'Vessel_Name__c'
  };
  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( "LIKE") filters
  public static Map<String, String> paramVsLikeFieldAPI = new Map<String, String>{
    'accountType' => 'Type',
    'contractNumber' => 'Name',
    'cvifId' => 'CVIF__c'
  };

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in range ( ">=" , "<=") filters
  public static Map<String, String> paramVsRangeFieldAPI = new Map<String, String>{};

  // Map of client side attribute field identifier as key and its corresponding field API name as value - Used in Date ( without quotes ) filters
  public static Map<String, String> paramVsDateFieldAPI = new Map<String, String>{
    'startContractDate' => 'StartDate',
    'endContractDate' => 'EndDate'
  };

  /*
   * @purpose     : Method to get TableJsonWrapper corresponding to the jsonName provided for the Custom_Table_Json__mdt
   * @parameter   : jsonName - The name of the MasterLabel from the Custom_Table_Json__mdt Custom Metadata
   * @return      : CC_TableJsonUtility.TableJsonWrapper - Inner class of CC_TableJsonUtility containing the information for the Custom Table
   */
  @AuraEnabled
  public static CC_TableJsonUtility.TableJsonWrapper getTableJson(
    String jsonName
  ) {
    return CC_TableJsonUtility.getTableJson(jsonName);
  }

  /*
   * @purpose     : Method to get Account record Details corresponding to the account Id provided
   * @parameter   : account Id - The Id of the account whose information is to be fetched
   * @return      : AccountDetailWrapper - Inner class containing the information for the Account Detail
   */
  @AuraEnabled
  public static AccountDetailWrapper getAccountRecord(Id accountId) {
    AccountDetailWrapper accountWrapper = new AccountDetailWrapper();
    Account accountRecord = new Account();
    List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
    try {
      accountRecord = AccountDAO.getAccountByAccountId(accountId);
      accountTeamMembers = CC_WithoutSharingUtility.getAccountTeamMembers(
        accountId
      );
      System.debug(accountId + ' - ' + accountRecord);
      if (accountRecord != null) {
        accountWrapper.account = accountRecord;
        if (accountRecord.ParentId != null) {
          accountWrapper.isParent = false;
        }
        if (
          accountRecord.ChildAccounts != null &&
          !accountRecord.ChildAccounts.isEmpty()
        ) {
          accountWrapper.childAccounts = accountRecord.ChildAccounts;
        }
        if (accountTeamMembers != null && !accountTeamMembers.isEmpty()) {
          accountWrapper.accountTeamMembers = accountTeamMembers;
        }
        accountWrapper.searchFieldSetChildAcc = CC_SharedUtility.getFieldSetList(
          CC_Constants.ACCOUNT_APINAME,
          CC_Constants.ACCOUNT_DETAIL_SEARCH_CHILD_ACC_FIELDSET
        );
        accountWrapper.searchFieldSetContacts = CC_SharedUtility.getFieldSetList(
          CC_Constants.CONTACT_APINAME,
          CC_Constants.ACCOUNT_DETAIL_SEARCH_CONTACT_FIELDSET
        );
        //accountWrapper.searchFieldSetQuotes = CC_SharedUtility.getFieldSetList();
        accountWrapper.searchFieldSetContracts = CC_SharedUtility.getFieldSetList(
          CC_Constants.CONTRACT_APINAME,
          CC_Constants.ACCOUNT_DETAIL_SEARCH_CONTRACT_FIELDSET
        );
        //accountWrapper.searchFieldSetBookings = CC_SharedUtility.getFieldSetList();
        //accountWrapper.searchFieldSetBol = CC_SharedUtility.getFieldSetList();
      }
      return accountWrapper;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_AccountDetailController',
        'getAccountRecord',
        'Account Detail Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage() +
        ex.getStackTraceString()
      );
      LogFactory.saveLog();
      return null;
    }
  }

  /*
   * @purpose     : Method to get Metadata for the filters on Child Account tab in Account Detail Page
   * @return      : ChildAccMetaData - Inner class containing the information for the filters of Child Accounts Tab
   */
  @AuraEnabled
  public static ChildAccMetaData getChildAccFilterMetaData() {
    ChildAccMetaData childAccMetaData = new ChildAccMetaData();
    childAccMetaData.typesList = CC_SharedUtility.getPicklistValuesList(
      Account.Type.getDescribe()
    );
    childAccMetaData.salesRegionsList = CC_SharedUtility.getPicklistValuesList(
      User.Region__c.getDescribe()
    );
    return childAccMetaData;
  }

  /*
   * @purpose     : Method to get Total Number of Child Accounts corresponding to the account id and with all the filters
   * @parameter   : accountId - Id of the Account whose child numbers it to be fetched
   * @parameter   : filtersList - The JSON string containing the filters and corresponding values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : Integer - Number of Child Accounts corresponding to the account id and with all the filters
   */
  @AuraEnabled
  public static Integer getTotalChildAccounts(
    Id accountId,
    String filtersList,
    String searchKeyWord
  ) {
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = 'SELECT Count(Id) Total From Account ';
    if (filtersList != null && filtersList != CC_Constants.BLANK_STRING) {
      filterObject = (Map<String, Object>) JSON.deserializeUntyped(filtersList);
      if (filterObject != null && !filterObject.isEmpty()) {
        query += ' WHERE ';
        String filter = CC_SharedUtility.getFilters(
          filterObject,
          paramVsStringFieldAPI,
          paramVsDateFieldAPI,
          paramVsRangeFieldAPI,
          paramVsLikeFieldAPI
        );
        if (filter != null && filter.trim() != CC_Constants.BLANK_STRING) {
          query += filter + ' AND ';
        }
        query += ' ParentId = :accountId';
        String customFilters = getCustomFilters(filterObject);
        if (
          customFilters != null &&
          customFilters.trim() != null &&
          customFilters.trim() != CC_Constants.BLANK_STRING
        ) {
          query += ' AND ' + customFilters + CC_Constants.SPACE_STRING;
        }
      } else {
        query += ' WHERE ParentId = :accountId';
      }
    } else {
      query += ' WHERE ParentId = :accountId';
    }
    if (searchKeyWord != null) {
      query += CC_SharedUtility.getSearchKeywordFilter(
        searchKeyWord,
        'Account',
        'Account_Detail_Search_Child_Acc'
      );
    }
    System.debug(query);
    return AccountDAO.getTotalChildAccountsByQuery(query, accountId);
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
      filters = getOwnerFilters(filterObject, filters);
      filters = getCommoditiesFilters(filterObject, filters);
    }
    if (filters != null && !filters.isEmpty()) {
      query += String.join(filters, ' AND ');
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
   * @purpose     : Method to get List of clauses for the WHERE Clause depending on the filters provided for the Accoutn Owner Name
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : filters - Existing List of Clauses which is to be appended
   * @return      : List of String - List of clauses for the WHERE Clause
   */
  private static List<String> getOwnerFilters(
    Map<String, Object> filterObject,
    List<String> filters
  ) {
    List<String> filtersClauses = filters;
    if (
      filterObject.get('accountOwner') != null &&
      (String) filterObject.get('accountOwner') != CC_Constants.BLANK_STRING
    ) {
      String accountOwner = (String) filterObject.get('accountOwner');
      List<String> clause = new List<String>();
      if (accountOwner.trim().contains(' ')) {
        List<String> accOwnNameList = accountOwner.trim().split(' ', 2);
        filtersClauses.add(
          ' Owner.FirstName LIKE \'' +
          accOwnNameList.get(0) +
          '%\' '
        );
        filtersClauses.add(
          ' Owner.LastName LIKE \'' +
          accOwnNameList.get(1) +
          '%\' '
        );
      } else {
        filtersClauses.add(
          ' Owner.FirstName LIKE \'' +
          accountOwner.trim() +
          '%\' '
        );
      }
    }
    return filtersClauses;
  }

  /*
   * @purpose     : Method to get Total Number of Contact records corresponding to the list of account ids
   * @parameter   : accountIds - List of Ids of the Accounts whose contacts numbers it to be fetched
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : Integer - Number of Contact Records corresponding to the List of account ids
   */
  @AuraEnabled
  public static Integer fetchTotalConts(
    List<Id> accountIds,
    String searchKeyWord
  ) {
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = 'SELECT Count(Id) Total From Contact WHERE accountId IN :accountIds';
    if (searchKeyWord != null) {
      query += CC_SharedUtility.getSearchKeywordFilter(
        searchKeyWord,
        'Contact',
        'Account_Detail_Search_Contact'
      );
    }
    System.debug(query);
    return CC_WithoutSharingUtility.getTotalContactsByQueryAccountIds(
      query,
      accountIds
    );
  }

  @AuraEnabled
  public static CC_QuoteListCtrl.QuoteListMetadata getQuoteMetaData() {
    return CC_QuoteListCtrl.getQuoteMetaData();
  }

  @AuraEnabled
  public static Integer getTotalQuotes(
    List<Id> accountIds,
    String filterObjectString,
    String searchListKeyword
  ) {
    return CC_QuoteListCtrl.getTotalQuotes(
      accountIds,
      filterObjectString,
      searchListKeyword
    );
  }

  @AuraEnabled
  public static List<CC_QuoteListCtrl.QuoteDataWrapper> getQuoteListData(
    List<Id> accountIds,
    String paginationParamsString,
    String filterObjectString,
    String searchListKeyword
  ) {
    return CC_QuoteListCtrl.getQuoteListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
  }

  /*
   * @purpose     : Method to get Metadata for the filters on Bookings tab in Account Detail Page
   * @return      : BookingListMetadata - Inner class of CC_BookingListCtrl class containing the information for the filters of Bookings Tab
   */
  @AuraEnabled
  public static CC_BookingListCtrl.BookingListMetadata getBookingMetaData() {
    return CC_BookingListCtrl.getBookingMetaData();
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
    return CC_BookingListCtrl.getTotalBookings(
      accountIds,
      filterObjectString,
      searchListKeyword
    );
  }

  /*
   * @purpose     : Method to get List of BookingDataWrapper corresponding to the the list of account ids and with all the filters
   * @parameter   : accountIds - List of Ids of the Accounts whose bookings is to be fetched
   * @parameter   : paginationParamsString - The JSON string containing the limit and offset values
   * @parameter   : filterObjectString - The JSON string containing the filters and corresponding values
   * @parameter   : searchKeyWord - The search Keyword entered by the user next to the filters button
   * @return      : List<CC_BookingListCtrl.BookingDataWrapper> - List of BookingDataWrapper inner class of CC_BookingListCtrl
   */
  @AuraEnabled
  public static List<CC_BookingListCtrl.BookingDataWrapper> getBookingRecords(
    List<Id> accountIds,
    String paginationParamsString,
    String filterObjectString,
    String searchListKeyword
  ) {
    return CC_BookingListCtrl.getBookingListData(
      accountIds,
      filterObjectString,
      paginationParamsString,
      searchListKeyword
    );
  }

  @AuraEnabled
  public static Integer fetchTotalContrts(
    List<Id> accountIds,
    String filtersList,
    String searchKeyWord
  ) {
    List<Id> contractIds = getContractIds(accountIds);
    Map<String, Object> filterObject = new Map<String, Object>();
    System.debug(filtersList);
    List<String> statusesFilter = new List<String>{ 'Completed' };
    String query = 'SELECT Count(Id) Total From Contract ';
    if (filtersList != null && filtersList != '') {
      filterObject = (Map<String, Object>) JSON.deserializeUntyped(filtersList);
      if (filterObject != null && !filterObject.isEmpty()) {
        query += ' WHERE ';
        String filter = CC_SharedUtility.getFilters(
          filterObject,
          paramVsStringFieldAPI,
          paramVsDateFieldAPI,
          paramVsRangeFieldAPI,
          paramVsLikeFieldAPI
        );
        System.debug(filter);
        if (filter != null && filter.trim() != '') {
          query += filter + ' AND ';
        } // AND Status IN :statusesFilter
        query += ' Id IN :contractIds AND Status IN :statusesFilter AND Softship_Contract_Number__c !=  \'\' ';
      } else {
        query += ' WHERE Id IN :contractIds AND Status IN :statusesFilter AND Softship_Contract_Number__c != \'\' ';
      }
    } else {
      query += ' WHERE Id IN :contractIds AND Status IN :statusesFilter AND Softship_Contract_Number__c !=  \'\' ';
    }
    if (searchKeyWord != null) {
      query += CC_SharedUtility.getSearchKeywordFilter(
        searchKeyWord,
        'Contract',
        'Account_Detail_Search_Contract'
      );
    }
    System.debug(query);
    AggregateResult results = Database.query(query);
    Integer totalRecords = (Integer) results.get('Total');
    return totalRecords;
  }

  @AuraEnabled
  public static ContractMetaData getContractFilterMetaData() {
    ContractMetaData contractMetaData = new ContractMetaData();
    contractMetaData.contractStatuses = filterContractStatuses(
      CC_SharedUtility.getPicklistValuesList(Contract.Status.getDescribe())
    );
    contractMetaData.contractRegions = CC_SharedUtility.getPicklistValuesList(
      Contract.RegionTxt__c.getDescribe()
    );
    return contractMetaData;
  }

  private static List<Map<String, String>> filterContractStatuses(
    List<Map<String, String>> statuses
  ) {
    List<Map<String, String>> filteredList = new List<Map<String, String>>();
    for (Map<String, String> labelValue : statuses) {
      if (
        labelValue.get('label').equalsIgnoreCase('Signed') ||
        labelValue.get('label').equalsIgnoreCase('Expired')
      ) {
        filteredList.add(labelValue);
      }
    }
    return filteredList;
  }

  @AuraEnabled
  public static List<Id> getContractIds(List<Id> accountIds) {
    Set<Id> contractIds = new Set<Id>();
    List<Contract> contractRecords = new List<Contract>();
    List<Contract_Account__c> contractAccountRecords = new List<Contract_Account__c>();
    try {
      List<Account> accounts = [
        SELECT
          Id,
          (SELECT Id FROM Contracts),
          (SELECT Id, Contract__c FROM Contract_Accounts__r)
        FROM Account
        WHERE Id IN :accountIds
      ];
      if (accounts != null && !accounts.isEmpty()) {
        for (Account account : accounts) {
          contractRecords.addAll(account.Contracts);
          contractAccountRecords.addAll(account.Contract_Accounts__r);
        }
      }

      if (contractRecords != null && !contractRecords.isEmpty()) {
        for (Contract contract : contractRecords) {
          contractIds.add(contract.Id);
        }
      }

      if (contractRecords != null && !contractRecords.isEmpty()) {
        for (Contract_Account__c contractAccount : contractAccountRecords) {
          contractIds.add(contractAccount.Contract__c);
        }
      }
      List<Id> contractIdsList = new List<Id>(contractIds);
      return contractIdsList;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_AccountDetailController',
        'getContractIds',
        'Account Detail Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      return null;
    }
  }

  public class ContractMetaData {
    @AuraEnabled
    public List<Map<String, String>> contractRegions { get; set; }
    @AuraEnabled
    public List<Map<String, String>> contractStatuses { get; set; }

    ContractMetaData() {
      this.contractRegions = new List<Map<String, String>>();
      this.contractStatuses = new List<Map<String, String>>();
    }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : AccountDetailWrapper wrapper class to hold the Account Information
   * @history     : Version 1.0
   */
  public class AccountDetailWrapper {
    @AuraEnabled
    public Account account { get; set; }
    @AuraEnabled
    public List<Account> childAccounts { get; set; }
    @AuraEnabled
    public List<AccountTeamMember> accountTeamMembers { get; set; }
    @AuraEnabled
    public Boolean isParent { get; set; }
    @AuraEnabled
    public List<String> searchFieldSetChildAcc { get; set; }
    @AuraEnabled
    public List<String> searchFieldSetContacts { get; set; }
    @AuraEnabled
    public List<String> searchFieldSetBookings { get; set; }
    // @AuraEnabled public List<String> searchFieldSetQuotes{get; set;}
    @AuraEnabled
    public List<String> searchFieldSetContracts { get; set; }
    // @AuraEnabled public List<String> searchFieldSetBol{get; set;}

    /*
     * @purpose     : Constructor to initialized the values
     */
    AccountDetailWrapper() {
      this.account = new Account();
      this.accountTeamMembers = new List<AccountTeamMember>();
      this.childAccounts = new List<Account>();
      this.isParent = true;
      this.searchFieldSetChildAcc = new List<String>();
      this.searchFieldSetContacts = new List<String>();
      this.searchFieldSetBookings = new List<String>();
      // this.searchFieldSetQuotes = new List<String>();
      this.searchFieldSetContracts = new List<String>();
      // this.searchFieldSetBol = new List<String>();
    }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : ChildAccMetaData wrapper class to hold the Child Account Metadata Details
   * @history     : Version 1.0
   */
  public class ChildAccMetaData {
    @AuraEnabled
    public List<Map<String, String>> salesRegionsList { get; set; }
    @AuraEnabled
    public List<Map<String, String>> typesList { get; set; }

    ChildAccMetaData() {
      this.salesRegionsList = new List<Map<String, String>>();
      this.typesList = new List<Map<String, String>>();
    }
  }
}
