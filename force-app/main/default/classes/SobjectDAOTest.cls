@isTest
public class SobjectDAOTest {
  @testSetup
  static void setup() {
    TestDataUtility.getAccountData('NA', 'DummyAcc', 10, true);
  }

  @isTest
  static void getsObjectData() {
    String query = 'SELECT id FROM Account';

    Test.startTest();
    List<sObject> sObjectList = SobjectDAO.getsObjectData(query);
    Test.stopTest();

    System.assertEquals(
      10,
      sObjectList.size(),
      'There should be total 10 records'
    );
  }

  @isTest
  static void getsObjectDataNegative() {
    String query = '*SELECT id FROM Account';

    Test.startTest();
    List<sObject> sObjectList = SobjectDAO.getsObjectData(query);
    Test.stopTest();

    System.assertEquals(null, sObjectList, 'Value should be null');
  }
}
