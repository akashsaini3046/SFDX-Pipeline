public with sharing class AllCrowleyNotificationClass {
  @AuraEnabled
  public static List<Crowley_Notification__c> getNotifications() {
    return [
      SELECT Id, Name, Course_Name__c, Notification_URL__c, Cloud__c
      FROM Crowley_Notification__c
      ORDER BY Name
      LIMIT :Integer.valueOf(Label.Number_of_records_to_retrieve)
    ];
  }

  @AuraEnabled
  public static id getCNAllListView() {
    return [
      SELECT Id, Name
      FROM ListView
      WHERE SobjectType = 'Crowley_Notification__c' AND Name = 'All'
    ]
    .Id;
  }
}
