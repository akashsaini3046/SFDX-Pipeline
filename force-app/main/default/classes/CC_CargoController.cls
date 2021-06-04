public without sharing class CC_CargoController {
  @AuraEnabled
  public static List<Open_Tariff_Commodities__mdt> getOpenTariffCommodities() {
    return CustomMetadataTypeDAO.getOpenTariffCommodities();
  }

  @AuraEnabled
  public static List<Container__c> getAllContainers() {
    return CustomSettingDAO.getAllContainer();
  }

  @AuraEnabled
  public static List<Substance__c> getVehicles() {
    return SubstanceDAO.getVehicles();
  }

  @AuraEnabled
  public static List<Container__c> getContainerByIds(String recordId) {
    return CustomSettingDAO.getContainerByIds(new Set<Id>{ recordId });
  }

  @AuraEnabled
  public static List<Container__c> getContainerByNames(String name) {
    return CustomSettingDAO.getContainerByNames(new Set<String>{ name });
  }

  /*
   * @purpose     : Method to get Hazardous Substance using search string
   * @parameter   : searchKeyWord - search string
   * @return      : List of CC_BookingWrapper.HazardousSubstanceWrapper
   */
  @AuraEnabled
  public static List<CC_BookingWrapper.HazardousSubstanceWrapper> getHazardSubstance(
    String searchKeyWord
  ) {
    List<CC_BookingWrapper.HazardousSubstanceWrapper> lstHazSubstanceWrapper = new List<CC_BookingWrapper.HazardousSubstanceWrapper>();
    List<Substance__c> listSubstance = new List<Substance__c>();
    String searchKey = '%' + searchKeyWord.toUpperCase() + '%';
    listSubstance = [
      SELECT
        Id,
        Name,
        Primary_Class__c,
        Variation__c,
        Packing_Group__c,
        Secondary_Class__c,
        Tertiary_Class__c,
        Marine_Pollutant__c,
        Limited_Quantity__c,
        Substance_Name__c,
        Prefix__c,
        Suffix__c,
        UN_Number__c
      FROM Substance__c
      WHERE
        (UN_Number__c LIKE :searchKey
        OR Name LIKE :searchKey
        OR Substance_Name__c LIKE :searchKey
        OR Prefix__c LIKE :searchKey
        OR Variation__c LIKE :searchKey)
        AND RecordType.DeveloperName = 'Substance'
      ORDER BY Name ASC
    ];
    if (!listSubstance.isEmpty()) {
      for (Substance__c substance : listSubstance) {
        CC_BookingWrapper.HazardousSubstanceWrapper hazSubstance = new CC_BookingWrapper.HazardousSubstanceWrapper();
        hazSubstance.Code = substance.Name;
        hazSubstance.UnNumber = substance.UN_Number__c;
        hazSubstance.Prefix = substance.Prefix__c;
        hazSubstance.Suffix = substance.Suffix__c;
        hazSubstance.SubstanceName = substance.Substance_Name__c;
        hazSubstance.PrimaryClass = substance.Primary_Class__c;
        hazSubstance.Variation = substance.Variation__c != '' &&
          substance.Variation__c != null
          ? substance.Variation__c.left(substance.Variation__c.length() - 1)
          : '';
        hazSubstance.PackingGroup = substance.Packing_Group__c;
        hazSubstance.SecondaryClass = substance.Secondary_Class__c;
        hazSubstance.TertiaryClass = substance.Tertiary_Class__c;
        hazSubstance.MarinePollutant = substance.Marine_Pollutant__c;
        hazSubstance.LimitedQuantity = String.valueOf(
          substance.Limited_Quantity__c
        );
        hazSubstance.SubstanceId = substance.Id;
        lstHazSubstanceWrapper.add(hazSubstance);
      }
    }

    return lstHazSubstanceWrapper;
  }
  @AuraEnabled
  public static Map<String, String> fetchYearList() {
    return CC_SharedUtility.fetchPickListValues('FreightDetail__c', 'Year__c');
  }

  @AuraEnabled
  public static Map<String, String> fetchIMDGClassesList() {
    return CC_SharedUtility.fetchPickListValues(
      'Requirement__c',
      'IMDG_Class__c'
    );
  }
  @AuraEnabled
  public static List<Open_Tariff_Commodities__mdt> getOpenTariffVehicleCommodities() {
    return CustomMetadataTypeDAO.getOpenTariffCommoditiesVehicle();
  }

  @AuraEnabled
  public static Map<String, Map<String, String>> fetchMultiplePickListValues(
    map<String, Object> mapFieldValuestoGet
  ) {
    return CC_SharedUtility.fetchMultiplePickListValues(mapFieldValuestoGet);
  }
}
