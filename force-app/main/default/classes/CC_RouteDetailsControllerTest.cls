@isTest
private class CC_RouteDetailsControllerTest {
  @TestSetup
  static void setup() {
    Vessel_Flag__c vesselFlag = new Vessel_Flag__c();
    vesselFlag.Name = 'Test';
    vesselFlag.Flag__c = 'US';
    insert vesselFlag;
  }

  @isTest
  static void testFetchVesselData() {
    Vessel_Flag__c vesselFlag = [SELECT id FROM Vessel_Flag__c LIMIT 1];
    String vesselId = vesselFlag.id;
    test.startTest();
    List<Vessel_Flag__c> flag = routeDetailsController.fetchVesselData(
      vesselId
    );
    test.stopTest();
    System.assertEquals(flag[0].Flag__c, 'US', 'returned flag is not matching');
  }
}
