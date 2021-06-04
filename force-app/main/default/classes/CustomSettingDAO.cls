public without sharing class CustomSettingDAO {
  public static List<Container__c> getContainerByIds(Set<Id> Ids) {
    return [
      SELECT
        Id,
        Name,
        CICS_ISO_Code__c,
        Description__c,
        EBR__c,
        Genset_Type__c,
        Genset__c,
        Group__c,
        Handle_As__c,
        Height__c,
        Hide__c,
        Reefer__c,
        Size__c,
        Softship_ISO_Code__c,
        Tare__c,
        Type__c,
        Width__c,
        Used_For__c,
        Is_Open_Tariff__c,
        Unit_Type__c
      FROM Container__c
      WHERE Id = :Ids
      ORDER BY NAME ASC
    ];
  }

  public static List<Container__c> getAllContainer() {
    return [
      SELECT
        Id,
        Name,
        CICS_ISO_Code__c,
        Description__c,
        EBR__c,
        Genset_Type__c,
        Genset__c,
        Group__c,
        Handle_As__c,
        Height__c,
        Hide__c,
        Reefer__c,
        Size__c,
        Softship_ISO_Code__c,
        Tare__c,
        Type__c,
        Width__c,
        Used_For__c,
        Is_Open_Tariff__c,
        Unit_Type__c
      FROM Container__c
      ORDER BY NAME ASC
    ];
  }

  public static List<Optional_Service__c> getOptionalService() {
    return [
      SELECT
        Id,
        Name,
        Tariff_Code__c,
        FieldMapping_Name__c,
        Basis_Field_Name__c,
        FieldMapping_Type__c
      FROM Optional_Service__c
      ORDER BY Tariff_Code__c ASC
    ];
  }

  public static List<Container__c> getContainerByNames(Set<String> name) {
    return [
      SELECT
        Id,
        Name,
        CICS_ISO_Code__c,
        Description__c,
        EBR__c,
        Genset_Type__c,
        Genset__c,
        Group__c,
        Handle_As__c,
        Height__c,
        Hide__c,
        Reefer__c,
        Size__c,
        Softship_ISO_Code__c,
        Tare__c,
        Type__c,
        Width__c,
        Used_For__c,
        Is_Open_Tariff__c,
        Unit_Type__c
      FROM Container__c
      WHERE Name = :name
      ORDER BY NAME ASC
    ];
  }
}
