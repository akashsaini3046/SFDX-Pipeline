@isTest
public class SubstanceDAOTest {
  @isTest
  static void getVehiclesTest() {
    Test.startTest();
    List<Substance__c> listSubstance = SubstanceDAO.getVehicles();
    Test.stopTest();
    system.assertEquals(
      0,
      listSubstance.size(),
      'The size should be 0 as there are no records of Substance'
    );
  }
}
