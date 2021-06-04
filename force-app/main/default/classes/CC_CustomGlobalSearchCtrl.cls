public without sharing class CC_CustomGlobalSearchCtrl {
  @AuraEnabled
  public static Map<String, String> getSObjects() {
    Map<String, String> mapSobjects = new Map<String, String>();
    List<Global_Search_Community__mdt> listmetaRecords = [
      SELECT Label, SObject_Name__r.QualifiedApiName
      FROM Global_Search_Community__mdt
    ];
    for (Global_Search_Community__mdt metaRecord : listmetaRecords) {
      mapSobjects.put(
        metaRecord.Label,
        metaRecord.SObject_Name__r.QualifiedApiName
      );
    }
    return mapSobjects;
  }
  @AuraEnabled
  public static List<CC_CustomGlobalSearchCtrl.SObjectResult> searchAllObjects(
    String searchKeyWord,
    String selValueLabel,
    String selValApiName
  ) {
    List<Global_Search_Community__mdt> mappingRecords = [
      SELECT Label, SObject_Name__r.QualifiedApiName
      FROM Global_Search_Community__mdt
    ];
    Map<String, List<String>> mapObjectFields = new Map<String, List<String>>();
    List<String> listObjName = new List<String>();
    Map<String, String> mapObjectApiLabel = new Map<String, String>();
    if (selValueLabel == 'All') {
      for (Global_Search_Community__mdt mapRecord : mappingRecords) {
        List<String> listObjFields = mapObjectsWithFields(
          mapRecord.SObject_Name__r.QualifiedApiName
        );
        listObjName.add(mapRecord.Label);
        mapObjectApiLabel.put(
          mapRecord.Label,
          mapRecord.SObject_Name__r.QualifiedApiName
        );
        mapObjectFields.put(
          mapRecord.SObject_Name__r.QualifiedApiName,
          listObjFields
        );
      }
    } else {
      List<String> listObjFields = mapObjectsWithFields(selValApiName);
      listObjName.add(selValueLabel);
      mapObjectApiLabel.put(selValueLabel, selValApiName);
      mapObjectFields.put(selValApiName, listObjFields);
    }
    List<String> queryObjects = new List<String>();
    String query = '';

    for (String currentObj : mapObjectFields.keySet()) {
      queryObjects.add(
        ' ' +
        currentObj +
        ' (' +
        String.join(mapObjectFields.get(currentObj), ',') +
        ') '
      );
      System.debug('qObject-- ' + queryObjects);
    }
    query = String.join(queryObjects, ',');
    String searchkw = '*' + searchKeyWord + '*';
    System.debug('query-- ' + query);
    System.debug('kw ' + searchkw);
    List<List<sObject>> sobList = search.query(
      'find :searchkw in sidebar fields returning ' +
      query +
      ' LIMIT 5'
    );
    System.debug('sobList@@@' + sobList);

    List<SObjectResult> listObjectResults = new List<SObjectResult>();

    for (Integer count = 0; count < listObjName.size(); count++) {
      if (sobList[count].size() > 0) {
        listObjectResults.add(
          new SObjectResult(
            listObjName[count],
            mapObjectApiLabel.get(listObjName[count]),
            sobList[count]
          )
        );
      }
    }
    System.debug('listObjectResults@@@' + listObjectResults);
    return listObjectResults;
  }
  public static List<String> mapObjectsWithFields(String objectApiName) {
    List<String> listcurrentObjFields = new List<String>();
    Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectApiName);
    Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
    Set<String> currentObjFields = describeSObjectResultObj.fields.getMap()
      .KeySet();
    listcurrentObjFields.addAll(currentObjFields);
    return listcurrentObjFields;
  }
  public class SObjectResult {
    @AuraEnabled
    public String objLabel;
    @AuraEnabled
    public String objectApiName;
    @AuraEnabled
    public List<sObject> recordList;

    public SObjectResult(
      String objLabel,
      String objectApiName,
      List<sObject> recordList
    ) {
      this.recordList = recordList;
      this.objLabel = objLabel;
      this.objectApiName = objectApiName;
    }
  }
}
