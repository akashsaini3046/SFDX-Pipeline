/*
 * Name: ConvertUpperCase
 * Purpose: Convert text fields on all objects to upper case
 * Author: Nagarro
 * Created Date: 13/09/2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public with sharing class ConvertUpperCase {
  /*Method Name: convertToUpperCase
   * Purpose: Convert text fields on all objects to upper case
   * Created By:  Nagarro
   */

  public static void convertToUpperCase(
    String sObjectType,
    List<sObject> sObjectRecords
  ) {
    List<String> sObjectTypes = new List<String>();
    sObjectTypes.add(sObjectType);

    Schema.DescribeSobjectResult[] results = Schema.describeSObjects(
      sObjectTypes
    );
    Map<String, Schema.SObjectField> fieldMap;

    for (Schema.DescribeSobjectResult res : results) {
      fieldMap = new Map<String, Schema.SObjectField>(res.fields.getMap());
    }

    for (sObject s : sObjectRecords) {
      for (String fieldName : fieldMap.keySet()) {
        Schema.DisplayType fielddataType = fieldMap.get(fieldName)
          .getDescribe()
          .getType();
        String names = '';
        if (
          fieldName != 'lastvieweddate' &&
          fieldName != 'lastreferenceddate'
        ) {
          names = String.valueOf(s.get(fieldName));
        }

        if (
          (fielddataType == Schema.DisplayType.String ||
          fielddataType == Schema.DisplayType.Email) &&
          !String.IsBlank(names) &&
          fieldMap.get(fieldName).getDescribe().isUpdateable()
        ) {
          s.put(fieldName, names.toUpperCase());
        }
      }
    }
  }
}
