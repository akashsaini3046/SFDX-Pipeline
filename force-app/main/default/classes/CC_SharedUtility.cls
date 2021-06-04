/*
 * 05-09-2020 – Drupad Preenja – Created this class for handling functionality related to Booking List Page and Account Detail Page.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : Used in Booking List Page and Account Detail Page Controller classes
 * @history     : Version 1.0
 * @test class  : CC_SharedUtilityTest
 */
public with sharing class CC_SharedUtility {
  /*
   * @purpose     : Method to get LIMIT and OFFSET clause for the Query depending on the json provided
   * @parameter   : paginationParams - Map form of JSON having values for limit and offset
   * @return      : String - LIMIT and OFFSET clause for the Query
   */
  public static String getLimitOffest(Map<String, Object> paginationParams) {
    String query = CC_Constants.BLANK_STRING;
    String limitValue = CC_Constants.BLANK_STRING;
    String offset = CC_Constants.BLANK_STRING;
    if (paginationParams.get('limit') != null) {
      limitValue = String.valueOf((Integer) paginationParams.get('limit'));
    }
    if (paginationParams.get('offset') != null) {
      offset = String.valueOf((Integer) paginationParams.get('offset'));
    }
    if (limitValue != null && limitValue != CC_Constants.BLANK_STRING) {
      query +=
        CC_Constants.SPACE_STRING +
        CC_Constants.LIMIT_STRING +
        CC_Constants.SPACE_STRING +
        limitValue;
    }
    if (offset != null && offset != CC_Constants.BLANK_STRING) {
      query +=
        CC_Constants.SPACE_STRING +
        CC_Constants.OFFSET_STRING +
        CC_Constants.SPACE_STRING +
        offset;
    }
    System.debug(query);
    return query;
  }

  /*
   * @purpose     : Method to get WHERE clause for the Query depending on the filters provided
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : paramVsStringFieldAPI - Map of ui field as key and corresponding field API name as value for String fields
   * @parameter   : paramVsDateFieldAPI - Map of ui field as key and corresponding field API name as value for Date fields
   * @parameter   : paramVsRangeFieldAPI - Map of ui field as key and corresponding field API name as value for Range fields
   * @parameter   : paramVsLikeFieldAPI - Map of ui field as key and corresponding field API name as value for Like fields
   * @return      : String - WHERE clause for the Query
   */
  public static String getFilters(
    Map<String, Object> filterObject,
    Map<String, String> paramVsStringFieldAPI,
    Map<String, String> paramVsDateFieldAPI,
    Map<String, String> paramVsRangeFieldAPI,
    Map<String, String> paramVsLikeFieldAPI
  ) {
    System.debug('filterObject');
    System.debug(filterObject);
    String query = CC_Constants.SPACE_STRING;
    List<String> filters = new List<String>();
    // Can also create seperate method for multi picklist which contians 'INCLUDES'
    List<String> textFilters = getTextFilters(
      filterObject,
      paramVsStringFieldAPI
    );
    List<String> dateFilters = getDateFilters(
      filterObject,
      paramVsDateFieldAPI
    );
    List<String> rangeFilters = getRangeFilters(
      filterObject,
      paramVsRangeFieldAPI
    );
    List<String> likeFilters = getLikeFilters(
      filterObject,
      paramVsLikeFieldAPI
    );
    if (textFilters != null && !textFilters.isEmpty()) {
      filters.addAll(textFilters);
    }
    if (dateFilters != null && !dateFilters.isEmpty()) {
      filters.addAll(dateFilters);
    }
    if (rangeFilters != null && !rangeFilters.isEmpty()) {
      filters.addAll(rangeFilters);
    }
    if (likeFilters != null && !likeFilters.isEmpty()) {
      filters.addAll(likeFilters);
    }
    if (filters != null && !filters.isEmpty()) {
      query += String.join(filters, CC_Constants.AND_STRING);
    }
    return query;
  }

  /*
   * @purpose     : Method to getList of Like Filter string for the Query depending on the filters provided
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : paramVsLikeFieldAPI - Map of ui field as key and corresponding field API name as value for Like fields
   * @return      : String - WHERE clause for the Query
   */
  public static List<String> getLikeFilters(
    Map<String, Object> filterObject,
    Map<String, String> paramVsLikeFieldAPI
  ) {
    List<String> likeFilters = new List<String>();
    Map<String, String> filteredStringParams = new Map<String, String>();
    for (String key : paramVsLikeFieldAPI.keySet()) {
      if (
        filterObject.get(key) != null &&
        (String) filterObject.get(key) != CC_Constants.BLANK_STRING
      ) {
        filteredStringParams.put(key, paramVsLikeFieldAPI.get(key));
      }
    }
    for (String key : filteredStringParams.keySet()) {
      likeFilters.add(
        CC_Constants.SPACE_STRING +
        paramVsLikeFieldAPI.get(key) +
        ' LIKE \'' +
        (String) filterObject.get(key) +
        '%\' '
      );
    }
    return likeFilters;
  }

  /*
   * @purpose     : Method to getList of Text Filter string for the Query depending on the filters provided
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : paramVsStringFieldAPI - Map of ui field as key and corresponding field API name as value for String fields
   * @return      : List of String - List of Filter string for the Query
   */
  public static List<String> getTextFilters(
    Map<String, Object> filterObject,
    Map<String, String> paramVsStringFieldAPI
  ) {
    List<String> textfilters = new List<String>();
    Map<String, String> filteredStringParams = new Map<String, String>();
    for (String key : paramVsStringFieldAPI.keySet()) {
      if (
        filterObject.get(key) != null &&
        (String) filterObject.get(key) != CC_Constants.BLANK_STRING &&
        (String) filterObject.get(key) != 'all'
      ) {
        filteredStringParams.put(key, paramVsStringFieldAPI.get(key));
      }
    }
    for (String key : filteredStringParams.keySet()) {
      if (key == 'cvifId' || key == 'parentCvifId') {
        textfilters.add(
          CC_Constants.SPACE_STRING +
          paramVsStringFieldAPI.get(key) +
          ' LIKE \'' +
          (String) filterObject.get(key) +
          '%\''
        );
      } else if (key == 'BOLStatus') {
        textfilters.add(
          CC_Constants.SPACE_STRING +
          paramVsStringFieldAPI.get(key) +
          ' IN ' +
          (String) filterObject.get(key) +
          ''
        );
      } else {
        textfilters.add(
          CC_Constants.SPACE_STRING +
          paramVsStringFieldAPI.get(key) +
          ' = \'' +
          (String) filterObject.get(key) +
          '\''
        );
      }
    }
    return textfilters;
  }

  /*
   * @purpose     : Method to getList of Date Filter string for the Query depending on the filters provided
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : paramVsStringFieldAPI - Map of ui field as key and corresponding field API name as value for String fields
   * @return      : List of String - List of Filter string for the Query
   */
  public static List<String> getDateFilters(
    Map<String, Object> filterObject,
    Map<String, String> paramVsDateFieldAPI
  ) {
    List<String> datefilters = new List<String>();
    Map<String, String> filteredDateParams = new Map<String, String>();
    for (String key : paramVsDateFieldAPI.keySet()) {
      if (
        filterObject.get(key) != null &&
        (String) filterObject.get(key) != CC_Constants.BLANK_STRING &&
        (String) filterObject.get(key) != 'all'
      ) {
        filteredDateParams.put(key, paramVsDateFieldAPI.get(key));
      }
    }
    for (String key : filteredDateParams.keySet()) {
      datefilters.add(
        CC_Constants.SPACE_STRING +
        paramVsDateFieldAPI.get(key) +
        ' = ' +
        (String) filterObject.get(key) +
        CC_Constants.BLANK_STRING
      );
    }
    return datefilters;
  }

  /*
   * @purpose     : Method to getList of Range Filter string for the Query depending on the filters provided
   * @parameter   : filterObject - The JSON string containing the filters and corresponding values
   * @parameter   : paramVsStringFieldAPI - Map of ui field as key and corresponding field API name as value for String fields
   * @return      : List of String - List of Filter string for the Query
   */
  public static List<String> getRangeFilters(
    Map<String, Object> filterObject,
    Map<String, String> paramVsRangeFieldAPI
  ) {
    List<String> dateFilters = new List<String>();
    Map<String, String> filteredStringParams = new Map<String, String>();
    for (String key : paramVsRangeFieldAPI.keySet()) {
      if (
        filterObject.get(key) != null &&
        ((String) filterObject.get(key)).trim() != CC_Constants.BLANK_STRING
      ) {
        filteredStringParams.put(key, paramVsRangeFieldAPI.get(key));
      }
    }
    for (String key : filteredStringParams.keySet()) {
      if (key.containsIgnoreCase('from') || key.containsIgnoreCase('start')) {
        dateFilters.add(
          CC_Constants.SPACE_STRING +
          paramVsRangeFieldAPI.get(key) +
          ' >= ' +
          (String) filterObject.get(key) +
          CC_Constants.SPACE_STRING
        );
      } else if (
        key.containsIgnoreCase('to') || key.containsIgnoreCase('end')
      ) {
        dateFilters.add(
          CC_Constants.SPACE_STRING +
          paramVsRangeFieldAPI.get(key) +
          ' <= ' +
          (String) filterObject.get(key) +
          CC_Constants.SPACE_STRING
        );
      }
    }
    return dateFilters;
  }

  /*
   * @purpose     : Method to get List of fields api name for the given object name and fieldset
   * @parameter   : objectName - The API Name of the Object whose fields to fetched
   * @parameter   : fieldSetName - Name of the field set
   * @return      : List of String - List of Filter string for the Query
   */
  public static List<String> getFieldSetList(
    String objectName,
    String fieldSetName
  ) {
    List<String> strFilterQuery = new List<String>();
    List<Schema.FieldSetMember> fieldMemberList = fetchFieldSetMembers(
      objectName,
      fieldSetName
    );
    for (Schema.FieldSetMember fieldMember : fieldMemberList) {
      strFilterQuery.add(fieldMember.getFieldPath());
    }
    return strFilterQuery;
  }

  /*
   * @purpose     : Method to get List of Fields Set Member for the given object name and fieldset
   * @parameter   : objectName - The API Name of the Object whose fields to fetched
   * @parameter   : fieldSetName - Name of the field set
   * @return      : List of Schema.FieldsSetMember - List of Fields Set Member
   */
  public static List<Schema.FieldSetMember> fetchFieldSetMembers(
    String objectName,
    String fieldSetName
  ) {
    Schema.DescribeSObjectResult DescribeSObjectResultObj = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe();
    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap()
      .get(fieldSetName);
    return fieldSetObj.getFields();
  }

  /*
   * @purpose     : Method to get List of Map of picklist value as value and picklist label as label for the given DescribeFieldResult
   * @parameter   : Schema.DescribeFieldResult - DescribeFieldResult for the corresponding picklist of the object
   * @return      : List of Map of key string and value String - List of Map of picklist value as value and picklist label as label
   */
  public static List<Map<String, String>> getPicklistValuesList(
    Schema.DescribeFieldResult fieldResult
  ) {
    List<Map<String, String>> picklistValuesList = new List<Map<String, String>>();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      if (pickListVal.isActive()) {
        Map<String, String> picklistMap = convertToLabelValue(
          pickListVal.getLabel(),
          pickListVal.getValue()
        );
        picklistValuesList.add(picklistMap);
      }
    }
    return picklistValuesList;
  }

  /*
   * @purpose     : Method to convert label and value into 2 enteries of Map respectively
   * @parameter   : label - String value of the label
   * @parameter   : value - String value of the value
   * @return      : Map of key string and value String - Map containing seperate enteries for label and key
   */
  public static Map<String, String> convertToLabelValue(
    String label,
    String value
  ) {
    Map<String, String> picklistMap = new Map<String, String>();
    picklistMap.put('label', label);
    picklistMap.put('value', value);
    return picklistMap;
  }

  /*
   * @purpose     : Method to get String  for the given object name, fieldset and searchKeyword
   * @parameter   : searchKeyword - Search Keyword
   * @parameter   : objectName - The API Name of the Object whose fields to fetched
   * @parameter   : fieldSetName - Name of the field set
   * @return      : List of String - List of Filter string for the Query
   */
  public static String getSearchKeywordFilter(
    String searchKeyword,
    String objectName,
    String fieldSetName
  ) {
    String strQuery = CC_Constants.BLANK_STRING;
    List<String> strFilterQuery = new List<String>();
    List<Schema.FieldSetMember> fieldMemberList = fetchFieldSetMembers(
      objectName,
      fieldSetName
    );
    String keyword = CC_Constants.BLANK_STRING;
    if (searchKeyword != null && searchKeyword != CC_Constants.BLANK_STRING) {
      keyword = '\'%' + searchKeyword + '%\' ';
    } else {
      keyword = '\'%\' ';
    }
    for (Schema.FieldSetMember fieldMember : fieldMemberList) {
      if (fieldMember.getType() == Schema.DisplayType.Picklist) {
        strFilterQuery.add(
          ' toLabel(' +
          fieldMember.getFieldPath() +
          ') LIKE ' +
          keyword
        );
      } else {
        strFilterQuery.add(
          CC_Constants.SPACE_STRING +
          fieldMember.getFieldPath() +
          ' LIKE ' +
          keyword
        );
      }
    }
    if (strFilterQuery != null && !strFilterQuery.isEmpty()) {
      strQuery += ' AND (';
      strQuery += String.join(strFilterQuery, ' OR ');
      strQuery += ')';
    }
    return strQuery;
  }

  /*
   * @purpose     : Method to get the record type Id of the provided object and corresponding recordtype name
   * @parameter   : recTypeName - In the form (ObjectName:RecordTypeName)
   * @return      : Id - RecordType Id
   */
  public static Id getRecordTypeId(String recTypeName) {
    if (recordTypesMap != null && recordTypesMap.containsKey(recTypeName)) {
      return recordTypesMap.get(recTypeName);
    }
    return null;
  }

  // Getter and Setter for Map of ObjectName:RecordType as key and Record Type Id as value
  private static Map<String, ID> recordTypesMap {
    get {
      if (recordTypesMap == null) {
        recordTypesMap = new Map<String, Id>();
        for (RecordType aRecordType : [
          SELECT SobjectType, DeveloperName
          FROM RecordType
          WHERE isActive = TRUE
        ]) {
          recordTypesMap.put(
            aRecordType.SobjectType +
            ':' +
            aRecordType.DeveloperName,
            aRecordType.Id
          );
        }
      }
      return recordTypesMap;
    }
    set;
  }
  /*
   * @CreatedDate : 18-12-2020
   * @purpose     : Method to get pickilist values of multiple fields from multiple objects
   * @parameter   : mapFieldValuestoGet - {'objectName1',List<fieldNames>,'objectName2',List<fieldNames>}
   * @return      : Map<String,Map<String,String>> - Map<'ObjectName~fieldName',Map<picklistLabel,picklistvalue>>
   */
  public static Map<String, Map<String, String>> fetchMultiplePickListValues(
    map<String, Object> mapFieldValuestoGet
  ) {
    Map<String, String> pickLabelValueMap = new Map<String, String>();
    Map<String, Map<String, String>> mapFieldNameVsValues = new Map<String, Map<String, String>>();
    Map<String, List<Schema.PicklistEntry>> picklistSchema = new Map<String, List<Schema.PicklistEntry>>();

    if (!mapFieldValuestoGet.isEmpty()) {
      for (String objectName : mapFieldValuestoGet.keySet()) {
        List<Object> reqs = (List<Object>) mapFieldValuestoGet.get(objectName);
        List<string> lstFieldName = new List<string>();
        for (Object req : reqs) {
          lstFieldName.add((string) req);
        }
        for (String fieldName : lstFieldName) {
          mapFieldNameVsValues.put(
            objectName +
            '~' +
            fieldName,
            fetchPickListValues(objectName, fieldName)
          );
        }
      }
    }
    return mapFieldNameVsValues;
  }

  /*
   * @CreatedDate : 18-12-2020
   * @purpose     : Method to get picklist values of a field
   * @parameter   : objectName- object API name and fieldName - field API name
   * @return      : Map<String,String> - Map<picklistLabel,picklistvalue>
   */
  public static Map<String, String> fetchPickListValues(
    String objectName,
    String fieldName
  ) {
    Map<String, String> pickLabelValueMap = new Map<String, String>();
    Map<String, List<Schema.PicklistEntry>> picklistSchema = new Map<String, List<Schema.PicklistEntry>>();

    SObjectType objTyp = Schema.getGlobalDescribe().get(objectName);
    DescribeSObjectResult objDescribe = objTyp.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    if (fieldMap.containsKey(fieldName)) {
      list<Schema.PicklistEntry> values = fieldMap.get(fieldName)
        .getDescribe()
        .getPickListValues();
      for (Schema.PicklistEntry pickListVal : values) {
        if (pickListVal.isActive()) {
          pickLabelValueMap.put(pickListVal.getLabel(), pickListVal.getValue());
        }
      }
    }
    return pickLabelValueMap;
  }
}
