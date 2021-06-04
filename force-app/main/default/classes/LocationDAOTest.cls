@isTest
public class LocationDAOTest {
  @testSetup
  static void setup() {
    List<Location__c> listlocations = TestDataUtility.CreateLocation(
      'Test Location',
      'BERTH',
      1,
      false
    );
    insert listlocations;
  }

  @isTest
  static void TestgetLocationsByIds() {
    Location__c location = [SELECT Id FROM Location__c];
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = LocationDAO.getLocationsByIds(new Set<Id>{ location.Id });
    Test.stopTest();
    System.assertEquals(
      1,
      listLocations.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void NegativeTestgetLocationsByIds() {
    Location__c location = new Location__c();
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = LocationDAO.getLocationsByIds(new Set<Id>{ location.Id });
    Test.stopTest();
    System.assertEquals(0, listLocations.size(), 'This List is empty');
  }

  @isTest
  static void TestgetSubLocationsByUNLocCode() {
    Location__c location = [
      SELECT Id, UN_Location_Code__c, Sub_Location_Type__c
      FROM Location__c
    ];
    System.debug('Location-- ' + location);
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = LocationDAO.getSubLocationsByUNLocCode(
      location.UN_Location_Code__c,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assertEquals(
      1,
      listLocations.size(),
      'This list contains one record'
    );
  }

  @isTest
  static void NegativeTestgetSubLocationsByUNLocCode() {
    Location__c location = new Location__c();
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = LocationDAO.getSubLocationsByUNLocCode(
      location.UN_Location_Code__c,
      location.Sub_Location_Type__c
    );
    Test.stopTest();
    System.assertEquals(0, listLocations.size(), 'This list is empty');
  }
  @isTest
  static void TestgetLocationByTypeAndCity() {
    Location__c location = [
      SELECT
        Id,
        UN_Location_Code__c,
        Sub_Location_Type__c,
        Location_Type__c,
        City__c
      FROM Location__c
    ];
    System.debug('Location-- ' + location);
    List<Location__c> listLocations;
    Test.startTest();
    listLocations = LocationDAO.getLocationByTypeAndCity(
      'SELECT Id, Name,Location_Type__c, LcCode__c,Location_Name__c, Country_Name__c, Country_Code__c, City__c, State__c,RecordType.DeveloperName,ZipCode__c FROM Location__c WHERE Location_Type__c=\'' +
      location.Location_Type__c +
      '\' AND City__c=\'' +
      location.City__c +
      '\''
    );
    Test.stopTest();
    System.assertEquals(
      1,
      listLocations.size(),
      'This list contains one record'
    );
  }

  /*@isTest
    static void TestgetMapLocationsByPort(){
        Location__c location=[Select Id,Name,UN_Location_Code__c,Sub_Location_Type__c,Location_Type__c,City__c from Location__c];
        MAP<String, Location__c> mapLocation= new MAP<String, Location__c>();
        Test.startTest();
        mapLocation=LocationDAO.getMapLocationsByPort(new Set<String>{location.Name});
        Test.stopTest();
        System.assertEquals(1,mapLocation.size(),'This list contains one record');
    }*/
}
