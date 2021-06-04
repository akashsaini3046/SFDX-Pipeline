public without sharing class SubstanceDAO {
  @AuraEnabled
  public static List<Substance__c> getVehicles() {
    return [
      SELECT
        Id,
        Name,
        Model__c,
        Type__c,
        Model_Year__c,
        Length__c,
        Width__c,
        Weight__c,
        Model_Name__c,
        Height__c,
        RecordType.DeveloperName,
        Model_Code__c,
        Length_Inch__c,
        Height_Inch__c,
        Width_Inch__c
      FROM Substance__c
      WHERE RecordType.DeveloperName = 'Vehicle'
      ORDER BY Model__c, Model_Name__c ASC
    ];
  }
}
