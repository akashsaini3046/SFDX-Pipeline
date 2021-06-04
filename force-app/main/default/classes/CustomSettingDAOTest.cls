@isTest
public class CustomSettingDAOTest {
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
  }

  @isTest
  static void getContainerByIdsTest() {
    Container__c containerObj = [SELECT Id FROM Container__c LIMIT 1];
    Test.startTest();
    List<Container__c> listContainers = CustomSettingDAO.getContainerByIds(
      new Set<Id>{ containerObj.Id }
    );
    Test.stopTest();
    system.debug(listContainers.size());
    system.assertEquals(
      1,
      listContainers.size(),
      'This list contains one record'
    );
  }
  @isTest
  static void getAllContainerTest() {
    Test.startTest();
    List<Container__c> listContainers = CustomSettingDAO.getAllContainer();
    Test.stopTest();
    system.debug(listContainers.size());
    system.assertEquals(
      1,
      listContainers.size(),
      'This list contains one record'
    );
  }
  @isTest
  static void getContainerByNamesTest() {
    Container__c containerObj = [SELECT Id, Name FROM Container__c LIMIT 1];
    Test.startTest();
    List<Container__c> listContainers = CustomSettingDAO.getContainerByNames(
      new Set<String>{ containerObj.Name }
    );
    Test.stopTest();
    system.debug(listContainers.size());
    system.assertEquals(
      1,
      listContainers.size(),
      'This list contains one record'
    );
  }
  @isTest
  static void getOptionalServiceTest() {
    Test.startTest();
    List<Optional_Service__c> listContainers = CustomSettingDAO.getOptionalService();
    Test.stopTest();
    system.debug(listContainers.size());
    system.assertEquals(
      0,
      listContainers.size(),
      'This list contains zero record'
    );
  }
}
