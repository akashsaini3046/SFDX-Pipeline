@isTest
public class AllExternalReportClassTest {
  @testSetup
  static void dataSetup() {
    External_Report_References__c err = TestDataUtility.createExternalReportReferences();
    insert err;
  }
  @isTest
  static void getReportsTest() {
    External_Report_References__c err = [
      SELECT Id
      FROM External_Report_References__c
      WHERE Name = 'Testing'
    ];

    AllExternalReportClass.getReports();
    List<External_Report_References__c> errList = [
      SELECT id
      FROM External_Report_References__c
      WHERE id = :err.id
    ];
    System.assertEquals(1, errList.size());

    List<External_Report_References__c> ListView = new List<External_Report_References__c>();
    for (Integer i = 0; i < 7; i++) {
      ListView.add(new External_Report_References__c(Name = 'ListView' + i));
    }
    insert ListView;

    test.startTest();
    update ListView;
    AllExternalReportClass.getListViews();
    test.stopTest();
  }
}
