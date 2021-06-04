public without sharing class CC_AccountController {
  public static Map<String, String> paramVsStringFieldAPI = new Map<String, String>{
    'cvifId' => 'CVIF__c',
    'parentCvifId' => 'Parent_CVIF_Id__c',
    'searchRegion' => 'Region__c',
    'accountType' => 'Type',
    'searchAccountId' => 'Id',
    'searchparentAccountId' => 'ParentId'
  };
  public static Map<String, String> paramVsLikeFieldAPI = new Map<String, String>{};
  public static Map<String, String> paramVsRangeFieldAPI = new Map<String, String>{};
  public static Map<String, String> paramVsDateFieldAPI = new Map<String, String>{};
  @AuraEnabled
  public static CC_TableJsonUtility.TableJsonWrapper getTableJson(
    String jsonName
  ) {
    return CC_TableJsonUtility.getTableJson(jsonName);
  }
  @AuraEnabled
  public static ChildAccMetaData getChildAccFilterMetaData() {
    ChildAccMetaData childAccMetaData = new ChildAccMetaData();
    childAccMetaData.typesList = CC_SharedUtility.getPicklistValuesList(
      Account.Type.getDescribe()
    );
    childAccMetaData.salesRegionsList = CC_SharedUtility.getPicklistValuesList(
      Account.Region__c.getDescribe()
    );
    return childAccMetaData;
  }
  @AuraEnabled
  public static Integer fetchTotalAccounts(String filtersList) {
    Map<String, Object> filterObject = new Map<String, Object>();
    String query = 'SELECT Count(Id) Total From Account ';
    String whereClause = '';
    Boolean combineFilter = false;
    if (filtersList != null && filtersList != CC_Constants.BLANK_STRING) {
      filterObject = (Map<String, Object>) JSON.deserializeUntyped(filtersList);
      if (filterObject != null && !filterObject.isEmpty()) {
        whereClause += ' WHERE ';
        String filter = CC_SharedUtility.getFilters(
          filterObject,
          paramVsStringFieldAPI,
          paramVsDateFieldAPI,
          paramVsRangeFieldAPI,
          paramVsLikeFieldAPI
        );
        System.debug('filters@@' + filter);
        if (filter != null && filter.trim() != CC_Constants.BLANK_STRING) {
          whereClause += filter;
          combineFilter = true;
        }
        String customFilters = getCustomFilters(filterObject);
        if (
          customFilters != null &&
          customFilters.trim() != null &&
          customFilters.trim() != CC_Constants.BLANK_STRING
        ) {
          if (combineFilter) {
            whereClause += ' AND ';
          }
          whereClause += customFilters + CC_Constants.SPACE_STRING;
        }
      }
    }
    if (!whereClause.trim().equals('WHERE')) {
      query += whereClause;
    }
    System.debug('query@@' + query);
    return AccountDAO.getTotalChildAccountsByQuery(query, null);
  }
  public static String getCustomFilters(Map<String, Object> filterObject) {
    String query = CC_Constants.BLANK_STRING;
    List<String> filters = new List<String>();
    if (filterObject != null) {
      filters = getOwnerFilters(filterObject, filters);
    }
    if (filters != null && !filters.isEmpty()) {
      query += String.join(filters, ' AND ');
    }
    return query;
  }
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
