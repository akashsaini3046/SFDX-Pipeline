@isTest
public class CC_CargoControllerTest {
  @TestSetup
  static void setup() {
    Container__c newContainer = TestDataUtility.CreateContainer(
      '53MA',
      'FM808',
      '53 Mafi',
      'CTR',
      'Container'
    );
    insert newContainer;
    Substance__c sub = new Substance__c();
    sub.Name = 'test substance';
    sub.Variation__c = 'test substance';
    sub.Prefix__c = 'test substance';
    sub.Substance_Name__c = 'test substance';
    insert sub;
  }

  @isTest
  static void getContainerByIdsTest() {
    Container__c containerObj = [SELECT Id FROM Container__c LIMIT 1];
    Test.startTest();
    List<Container__c> listContainers = CC_CargoController.getContainerByIds(
      containerObj.Id
    );
    Test.stopTest();
    system.debug(listContainers.size());
  }

  @isTest
  static void getContainerByNamesTest() {
    Container__c containerObj = [
      SELECT Id, Name
      FROM Container__c
      WHERE Name = '53MA'
      LIMIT 1
    ];
    Test.startTest();
    List<Container__c> listContainers = CC_CargoController.getContainerByNames(
      containerObj.Name
    );
    Test.stopTest();
    system.debug(listContainers.size());
  }

  @isTest
  static void getOpenTariffCommoditiesTest() {
    Test.startTest();
    List<Open_Tariff_Commodities__mdt> listOTC = CC_CargoController.getOpenTariffCommodities();
    Test.stopTest();
    system.assert(listOTC.size() != null, 'This list must contain data');
  }

  @isTest
  static void getOpenTariffVehicleCommoditiesTest() {
    Test.startTest();
    List<Open_Tariff_Commodities__mdt> listOTC = CC_CargoController.getOpenTariffVehicleCommodities();
    Test.stopTest();
    system.assert(listOTC.size() != null, 'This list must contain data');
  }

  @isTest
  static void getAllContainersTest() {
    Test.startTest();
    List<Container__c> listOTC = CC_CargoController.getAllContainers();
    Test.stopTest();
    system.assert(listOTC.size() != null, 'This list must contain data');
  }

  @isTest
  static void getVehiclesTest() {
    Test.startTest();
    List<Substance__c> listSubstance = CC_CargoController.getVehicles();
    Test.stopTest();
    system.assertEquals(
      0,
      listSubstance.size(),
      'The size should be 0 as there are no records of Substance'
    );
  }

  @isTest
  static void getHazardSubstanceTest() {
    Test.startTest();
    List<CC_BookingWrapper.HazardousSubstanceWrapper> listSubstance = CC_CargoController.getHazardSubstance(
      'test substance'
    );
    Test.stopTest();
    system.assertEquals(
      1,
      listSubstance.size(),
      'The size should be 0 as there are no records of Substance'
    );
  }
  @isTest
  static void fetchYearListTest() {
    Test.startTest();
    Map<String, String> listSubstance = CC_CargoController.fetchYearList();
    Test.stopTest();
    system.assertEquals(
      17,
      listSubstance.size(),
      'The size should be 0 as there are no records of Substance'
    );
  }

  @isTest
  static void fetchIMDGClassesList() {
    Test.startTest();
    Map<String, String> listSubstance = CC_CargoController.fetchIMDGClassesList();
    Test.stopTest();
    system.assertEquals(
      24,
      listSubstance.size(),
      'The size should be 0 as there are no records of Substance'
    );
  }
  @isTest
  static void fetchMultiplePickListValues() {
    Map<String, String> pickLabelValueMap = new Map<String, String>();
    pickLabelValueMap.put('Substance__c', 'Height__c');
    map<String, Object> mapFieldValuestoGet = new Map<String, Object>();
    mapFieldValuestoGet.put('Substance__c', pickLabelValueMap);
    for (String objectName : mapFieldValuestoGet.keySet()) {
      System.debug(objectName);
      System.debug(mapFieldValuestoGet.get(objectName));
    }
    Test.startTest();
    // Map<String,Map<String,String>> listSubstance=CC_CargoController.fetchMultiplePickListValues(mapFieldValuestoGet);
    Test.stopTest();
    //system.assertEquals(24, listSubstance.size(), 'The size should be 0 as there are no records of Substance');
  }
}
