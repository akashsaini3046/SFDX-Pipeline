public without sharing class CustomMetadataTypeDAO {
  public static List<Open_Tariff_Commodities__mdt> getOpenTariffCommodities() {
    return [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Commodity_Code__c,
        Commodity_Name__c
      FROM Open_Tariff_Commodities__mdt
      WHERE isContainer__c = TRUE
      ORDER BY Commodity_Name__c ASC
    ];
  }

  public static List<Open_Tariff_Commodities__mdt> getOpenTariffCommoditiesVehicle() {
    return [
      SELECT
        Id,
        DeveloperName,
        MasterLabel,
        Commodity_Code__c,
        Commodity_Name__c
      FROM Open_Tariff_Commodities__mdt
      WHERE isVehicle__c = TRUE
      ORDER BY Commodity_Name__c ASC
    ];
  }
}
