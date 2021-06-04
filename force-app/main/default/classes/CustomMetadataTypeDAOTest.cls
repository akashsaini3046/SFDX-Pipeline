@isTest
public class CustomMetadataTypeDAOTest {
  @isTest
  static void getOpenTariffCommoditiesTest() {
    Test.startTest();
    List<Open_Tariff_Commodities__mdt> listOTC = CustomMetadataTypeDAO.getOpenTariffCommodities();
    Test.stopTest();
    system.assert(listOTC.size() != null, 'This list must contain data');
  }

  @isTest
  static void getOpenTariffCommoditiesVehicleTest() {
    Test.startTest();
    List<Open_Tariff_Commodities__mdt> listOTC = CustomMetadataTypeDAO.getOpenTariffCommoditiesVehicle();
    Test.stopTest();
    system.assert(listOTC.size() != null, 'This list must contain data');
  }
}
