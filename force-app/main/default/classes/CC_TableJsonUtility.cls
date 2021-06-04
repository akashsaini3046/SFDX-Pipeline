/*
 * 05-09-2020 – Drupad Preenja – Created this class for handling functionality related to Custom Table Component, CC_CustomTable.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : Utility for Custom Table
 * @history     : Version 1.0
 * @test class  : CC_TableJsonUtilityTest
 */
public with sharing class CC_TableJsonUtility {
  /*
   * @purpose     : Method to get TableJsonWrapper corresponding to the jsonName provided for the Custom_Table_Json__mdt
   * @parameter   : jsonName - The name of the MasterLabel from the Custom_Table_Json__mdt Custom Metadata
   * @return      : TableJsonWrapper - Inner class containing the information for the Custom Table
   */
  public static TableJsonWrapper getTableJson(String jsonName) {
    TableJsonWrapper tableJsonWrapper = new TableJsonWrapper();
    Custom_Table_Json__mdt customtableJson = customJsonTableMap.get(jsonName);
    if (customtableJson != null) {
      List<TableJsonFieldWrapper> fieldsToFetch = new List<TableJsonFieldWrapper>();
      List<Custom_Table_Json_Field__mdt> customJsonFieldsList = customJsonTableNameVsFieldsMap.get(
        customtableJson.MasterLabel
      );
      if (customJsonFieldsList != null && !customJsonFieldsList.isEmpty()) {
        for (Custom_Table_Json_Field__mdt field : customJsonFieldsList) {
          TableJsonFieldWrapper tableJsonFieldWrapper = new TableJsonFieldWrapper();
          tableJsonFieldWrapper = getTableFieldWrapper(field);
          fieldsToFetch.add(tableJsonFieldWrapper);
        }
      }
      tableJsonWrapper.fieldsToFetch = fieldsToFetch;
      tableJsonWrapper.cardClassName = customtableJson.Card_Class_Name__c;
    }
    return tableJsonWrapper;
  }

  /*
   * @purpose     : Method to get the TableJsonFieldWrapper corresponding to the Custom_Table_Json_Field__mdt provided
   * @parameter   : field - The Custom_Table_Json_Field__mdt metadata for which the wrapper to be formed
   * @return      : TableJsonFieldWrapper - Inner class containing the information for the Custom Table Field
   */
  private static TableJsonFieldWrapper getTableFieldWrapper(
    Custom_Table_Json_Field__mdt field
  ) {
    TableJsonFieldWrapper tableJsonFieldWrapper = new TableJsonFieldWrapper();
    if (field.Label__c != null && field.Label__c != CC_Constants.BLANK_STRING) {
      tableJsonFieldWrapper.label = field.Label__c;
    }
    if (field.Data_type__c != CC_Constants.BLANK_STRING) {
      tableJsonFieldWrapper.dataType = field.Data_type__c;
    }
    if (field.Field_Name__c != CC_Constants.BLANK_STRING) {
      tableJsonFieldWrapper.fieldName = field.Field_Name__c;
    }
    if (
      field.Redirect_Url__c != null &&
      field.Redirect_Url__c != CC_Constants.BLANK_STRING
    ) {
      tableJsonFieldWrapper.redirectUrl = field.Redirect_Url__c;
    }
    if (
      field.Date_Format__c != null &&
      field.Date_Format__c != CC_Constants.BLANK_STRING
    ) {
      tableJsonFieldWrapper.dateFormat = field.Date_Format__c;
    }
    tableJsonFieldWrapper.order = Integer.valueOf(field.Order__c);
    tableJsonFieldWrapper.isRef = field.Is_Reference__c;
    tableJsonFieldWrapper.isTableColumn = field.Is_Table_Column__c;
    tableJsonFieldWrapper.classNameRow = field.Class_Name__c;
    return tableJsonFieldWrapper;
  }

  // Getter and Setter for Map of Masterlabel of Custom_Table_Json__mdt as key and Custom_Table_Json__mdt as value
  public static Map<String, Custom_Table_Json__mdt> customJsonTableMap {
    get {
      if (customJsonTableMap == null) {
        customJsonTableMap = new Map<String, Custom_Table_Json__mdt>();
        for (Custom_Table_Json__mdt metadataRecord : [
          SELECT Id, MasterLabel, Card_Class_Name__c, SObjectApiName__c
          FROM Custom_Table_Json__mdt
        ]) {
          customJsonTableMap.put(metadataRecord.MasterLabel, metadataRecord);
        }
      }
      return customJsonTableMap;
    }
    set;
  }

  // Getter and Setter for Map of Masterlabel of Custom_Table_Json__mdt as key and List of corresponding child Custom_Table_Json_Field__mdt as value
  public static Map<String, List<Custom_Table_Json_Field__mdt>> customJsonTableNameVsFieldsMap {
    get {
      if (customJsonTableNameVsFieldsMap == null) {
        customJsonTableNameVsFieldsMap = new Map<String, List<Custom_Table_Json_Field__mdt>>();
        for (Custom_Table_Json_Field__mdt metadataRecord : [
          SELECT
            Id,
            MasterLabel,
            Class_Name__c,
            Custom_Table_Json__r.MasterLabel,
            Data_type__c,
            Field_Name__c,
            Is_Reference__c,
            Is_Table_Column__c,
            Label__c,
            Order__c,
            Redirect_Url__c,
            Date_Format__c
          FROM Custom_Table_Json_Field__mdt
        ]) {
          if (
            customJsonTableNameVsFieldsMap != null &&
            customJsonTableNameVsFieldsMap.get(
              metadataRecord.Custom_Table_Json__r.MasterLabel
            ) != null
          ) {
            List<Custom_Table_Json_Field__mdt> metaRecords = customJsonTableNameVsFieldsMap.get(
              metadataRecord.Custom_Table_Json__r.MasterLabel
            );
            metaRecords.add(metadataRecord);
            customJsonTableNameVsFieldsMap.put(
              metadataRecord.Custom_Table_Json__r.MasterLabel,
              metaRecords
            );
          } else {
            customJsonTableNameVsFieldsMap.put(
              metadataRecord.Custom_Table_Json__r.MasterLabel,
              new List<Custom_Table_Json_Field__mdt>{ metadataRecord }
            );
          }
        }
      }
      return customJsonTableNameVsFieldsMap;
    }
    set;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : TableJsonWrapper wrapper class to hold the Custom Table Metadata Information
   * @history     : Version 1.0
   */
  public class TableJsonWrapper {
    @AuraEnabled
    public String cardClassName { get; set; }
    @AuraEnabled
    public List<TableJsonFieldWrapper> fieldsToFetch { get; set; }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 05-09-2020
   * @author      : Nagarro
   * @description : TableJsonFieldWrapper wrapper class to hold the Custom Table Field Metadata Information
   * @history     : Version 1.0
   */
  public class TableJsonFieldWrapper {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String fieldName { get; set; }
    @AuraEnabled
    public String dataType { get; set; }
    @AuraEnabled
    public Boolean isTableColumn { get; set; }
    @AuraEnabled
    public Integer order { get; set; }
    @AuraEnabled
    public Boolean isRef { get; set; }
    @AuraEnabled
    public String dateFormat { get; set; }
    @AuraEnabled
    public String redirectUrl { get; set; }
    @AuraEnabled
    public String classNameRow { get; set; }
  }
}
