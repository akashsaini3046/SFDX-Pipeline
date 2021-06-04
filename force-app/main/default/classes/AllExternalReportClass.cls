public with sharing class AllExternalReportClass {
  @AuraEnabled
  public static List<External_Report_References__c> getReports() {
    integer num = 7;
    List<External_Report_References__c> externalReport = [
      SELECT Id, Name, Report_Name__c, External_URL__c
      FROM External_Report_References__c
      ORDER BY Report_Name__c
      LIMIT :(Integer.valueOf(Label.Number_of_records_to_retrieve) + 1)
    ];

    return externalReport;
  }

  @AuraEnabled
  public static id getListViews() {
    id listviews = [
      SELECT Id, Name
      FROM ListView
      WHERE SobjectType = 'External_Report_References__c' AND Name = 'All'
    ]
    .Id;
    system.debug('listviews--->' + listviews);
    // Perform isAccessible() check here
    return listviews;
  }
}
