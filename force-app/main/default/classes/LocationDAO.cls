/*
 * @company     : Nagarro Inc.
 * @date        : 31-08-2020
 * @author      : Nagarro
 * @description : DAO for Location. and Related Objects
 * @history     : Version 1.0
 * @test class  : LocationDAOTest
 */
public without sharing class LocationDAO {
  public static List<Location__c> getLocationsByIds(Set<Id> recordIds) {
    return [
      SELECT
        Id,
        Name,
        Location_Type__c,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c,
        RecordType.DeveloperName,
        ZipCode__c,
        Port__c,
        LocationCode__c
      FROM Location__c
      WHERE Id = :recordIds
    ];
  }

  public static MAP<String, Location__c> getMapLocationsByPort(
    Set<String> locationCode
  ) {
    MAP<String, Location__c> mapPortLocation = new Map<String, Location__c>();
    for (Location__c location : [
      SELECT
        Id,
        Name,
        Location_Type__c,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c,
        RecordType.DeveloperName,
        ZipCode__c,
        Port__c,
        LocationCode__c
      FROM Location__c
      WHERE
        Name = :locationCode
        AND Name != ''
        AND RecordType.DeveloperName = 'Location'
        AND Location_Type__c = 'PORT'
    ]) {
      mapPortLocation.put(location.Name, location);
    }
    return mapPortLocation;
  }

  public static List<Location__c> getSubLocationsByUNLocCode(
    String locCode,
    String locType
  ) {
    return [
      SELECT Id, Name, RecordType.DeveloperName, SubLocation_Name__c
      FROM Location__c
      WHERE UN_Location_Code__c = :locCode AND Sub_Location_Type__c = :locType
      ORDER BY Name
    ];
  }

  public static List<Location__c> getLocationByTypeAndCity(String Query) {
    return Database.query(Query);
  }
}
