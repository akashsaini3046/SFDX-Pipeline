/*
 * 05-09-2020 – Drupad Preenja – Created this class for handling functionality related to Custom Table.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : Used as controller for CC_CustomTable Lightning Component
 * @history     : Version 1.0
 * @test class  : CC_CustomTableCtrlTest
 */
public with sharing class CC_CustomTableCtrl {
  /*
   * @purpose     : Method to get List of sObject Records corresponding to the jsonString name provided
   * @parameter   : jsonString - json containing the information for the Query to be processed
   * @return      : List<sObject> - List of sObject records
   */
  @AuraEnabled
  public static List<sObject> fetchRecords(String jsonString) {
    try {
      QueryMetaData queryMetaData = (QueryMetaData) JSON.deserialize(
        jsonString,
        QueryMetaData.class
      );
      return processQuery(queryMetaData);
    } catch (Exception e) {
      LogFactory.error(
        'CC_CustomTableCtrl',
        'fetchRecords',
        'Custom Table Community',
        e.getLineNumber() +
        ' ' +
        e.getMessage()
      );
      LogFactory.saveLog();
    }
    return null;
  }

  /*
   * @purpose     : Method to get List of sObject Records corresponding to the QueryMetaData provided
   * @parameter   : queryMetaData - Inner class containing the Query Metadata
   * @return      : List<sObject> - List of sObject records
   */
  private static List<sObject> processQuery(QueryMetaData queryMetaData) {
    Map<String, List<sObject>> refIdVsValuesList = new Map<String, List<sObject>>();
    String whereClause = '';
    String limitClause = '';
    String sortClause = '';
    String offsetClause = '';
    if (
      queryMetaData.filterLogic != null &&
      queryMetaData.filterLogic.trim() != ''
    ) {
      whereClause = getWhereClause(queryMetaData);
    }
    if (queryMetaData.limitRecords != null) {
      limitClause = ' LIMIT ' + queryMetaData.limitRecords;
    }
    if (queryMetaData.offset != null) {
      offsetClause = ' OFFSET ' + queryMetaData.offset;
    }
    if (queryMetaData.sortBy != null) {
      sortClause = ' ORDER BY ';
      List<String> sortByList = new List<String>();
      for (SortByWrapper sortBy : queryMetaData.sortBy) {
        sortByList.add(sortBy.fieldName + ' ' + sortBy.order);
      }
      sortClause += String.join(sortByList, ',');
    }
    String fieldsToQuery = getFields(queryMetaData);
    System.debug(queryMetaData);
    String finalQuery =
      'SELECT ' +
      fieldsToQuery +
      ' FROM ' +
      queryMetaData.sObjectApiName +
      whereClause +
      sortClause +
      limitClause +
      offsetClause;
    System.debug('finalQuery ' + finalQuery);
    if (queryMetaData.sObjectApiName.equalsIgnoreCase('Contact')) {
      return CC_WithoutSharingUtility.getsObjectData(finalQuery);
    } else {
      return SobjectDAO.getsObjectData(finalQuery);
    }
  }

  /*
   * @purpose     : Method to get String value of the fields for the query
   * @parameter   : queryMetaData - Inner class containing the Query Metadata
   * @return      : String - String having the fields comma seperated
   */
  private static String getFields(QueryMetadata queryMetadata) {
    String fieldsToQuery = 'Id';
    List<FieldWrapper> fieldWrapperList = queryMetaData.fieldsToFetch;
    fieldWrapperList.sort();
    for (FieldWrapper fieldWrapper : fieldWrapperList) {
      System.debug(fieldWrapper);
      if (fieldWrapper.isRef == null || !fieldWrapper.isRef) {
        if (fieldWrapper.dataType.equalsIgnoreCase('picklist')) {
          fieldsToQuery += ', toLabel(' + fieldWrapper.fieldName + ') ';
        } else {
          fieldsToQuery += ', ' + fieldWrapper.fieldName;
        }
      }
    }
    return fieldsToQuery;
  }

  /*
   * @purpose     : Method to get where clause for the query
   * @parameter   : queryMetaData - Inner class containing the Query Metadata
   * @return      : String - String having the where clause for the query
   */
  private static String getWhereClause(QueryMetaData queryMetaData) {
    Map<String, String> refIdVsClause = new Map<String, String>();
    String whereClause =
      ' WHERE ' +
      (queryMetaData.filterLogic != null ? queryMetaData.filterLogic : '');
    SObjectType ref = ((SObject) (Type.forName(
          'Schema.' + queryMetaData.sObjectApiName
        )
        .newInstance()))
      .getSObjectType();
    DescribeSObjectResult describe = ref.getDescribe();
    System.debug(queryMetaData.filters);
    for (FilterWrapper filter : queryMetaData.filters) {
      System.debug(filter);
      String value = '';
      if (filter.operator.contains('LIKE')) {
        value = '\'' + String.join(filter.values, '\',\'') + '\'';
      } else {
        Schema.DisplayType fieldType;
        if (filter.fieldName.contains('.')) {
          fieldType = getFieldType(filter.fieldName);
        } else {
          fieldType = describe.fields.getMap()
            .get(filter.fieldName)
            .getDescribe()
            .getType();
        }
        System.debug(fieldType + ' - ' + filter.fieldName);
        if (
          fieldType == Schema.DisplayType.Double ||
          fieldType == Schema.DisplayType.Integer
        ) {
          value = '(' + String.join(filter.values, ',') + ')';
        } else if (
          fieldType == Schema.DisplayType.DATE ||
          fieldType == Schema.DisplayType.DATETIME
        ) {
          value = filter.values[0];
        } else {
          value = '(\'' + String.join(filter.values, '\',\'') + '\')';
        }
      }
      String clause = filter.fieldName + ' ' + filter.operator + ' ' + value;
      refIdVsClause.put('{' + filter.refId + '}', clause);
    }
    System.debug(refIdVsClause);
    for (String refId : refIdVsClause.keySet()) {
      whereClause = whereClause.replace(refId, refIdVsClause.get(refId));
    }
    return whereClause;
  }

  /*
   * @purpose     : Method to get field type of the hierarchical Field
   * @parameter   : fieldName - Name of the field
   * @return      : Schema.DisplayType - Field Type of the field
   */
  private static Schema.DisplayType getFieldType(String fieldName) {
    String sObjectApiName = '';
    sObjectApiName = fieldName.replace('__r', '__c').substringBefore('.');
    if (sObjectApiName.equalsIgnoreCase('Owner')) {
      sObjectApiName = 'User';
    }
    SObjectType ref = ((SObject) (Type.forName('Schema.' + sObjectApiName)
        .newInstance()))
      .getSObjectType();
    DescribeSObjectResult describe = ref.getDescribe();
    return describe.fields.getMap()
      .get(fieldName.substringAfterLast('.'))
      .getDescribe()
      .getType();
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : QueryMetaData wrapper class to hold the Query Metadata
   * @history     : Version 1.0
   */
  public class QueryMetaData {
    @AuraEnabled
    public String sObjectApiName;
    @AuraEnabled
    public List<FieldWrapper> fieldsToFetch;
    @AuraEnabled
    public List<FilterWrapper> filters;
    @AuraEnabled
    public String filterLogic;
    @AuraEnabled
    public Integer limitRecords;
    @AuraEnabled
    public Integer offset;
    @AuraEnabled
    public List<SortByWrapper> sortBy;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : FieldWrapper wrapper class to hold the Filter Metadata
   * @history     : Version 1.0
   */
  public class FieldWrapper implements Comparable {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public String dataType;
    @AuraEnabled
    public Integer order;
    @AuraEnabled
    public boolean isRef;

    public Integer compareTo(Object compareTo) {
      FieldWrapper other = (FieldWrapper) compareTo;
      if (this.order > other.order) {
        return 1;
      } else if (this.order == other.order) {
        return 0;
      }
      return -1;
    }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : FilterWrapper wrapper class to hold the Filter Metadata
   * @history     : Version 1.0
   */
  public class FilterWrapper {
    @AuraEnabled
    public String refId;
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public List<String> values;
    @AuraEnabled
    public String operator;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : SortByWrapper wrapper class to hold the Sorting Metadata
   * @history     : Version 1.0
   */
  public class SortByWrapper {
    @AuraEnabled
    public String fieldName;
    @AuraEnabled
    public String order;
  }
}
