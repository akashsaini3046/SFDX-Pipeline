public with sharing class routeDetailsController {
  @AuraEnabled
  public static List<Vessel_Flag__c> fetchVesselData(String vesselId) {
    List<Vessel_Flag__c> vesselList = new List<Vessel_Flag__c>();
    vesselList = [
      SELECT Name, Flag__c
      FROM Vessel_Flag__c
      WHERE ID = :vesselId
      LIMIT 1
    ];
    return vesselList;
  }
}
