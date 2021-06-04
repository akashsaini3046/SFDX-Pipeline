@isTest
public class CC_TableJsonUtilityTest {
  @isTest
  static void getTableJsonTest() {
    Test.startTest();

    String jsonName = 'Test';
    CC_TableJsonUtility.customJsonTableMap = TestDataUtility.getCustomJsonTableTestMap();
    CC_TableJsonUtility.customJsonTableNameVsFieldsMap = TestDataUtility.getCustomJsonTableNameVsFields();
    CC_TableJsonUtility.TableJsonWrapper jsonWrapper = CC_TableJsonUtility.getTableJson(
      jsonName
    );

    Test.stopTest();

    System.assertEquals(
      'row-data-repeat',
      jsonWrapper.cardClassName,
      'Card Class Name Mis-match'
    );
  }

  @isTest
  static void customJsonTableMetaDataCoverage() {
    Test.startTest();

    String jsonName = 'Test';
    CC_TableJsonUtility.TableJsonWrapper jsonWrapper = CC_TableJsonUtility.getTableJson(
      jsonName
    );

    Test.stopTest();

    System.assertEquals(
      null,
      jsonWrapper.cardClassName,
      'Card Class Name Mis-match'
    );
  }

  @isTest
  static void customJsonTableFieldMetaDataCoverage() {
    Test.startTest();

    String jsonName = 'Test';
    CC_TableJsonUtility.customJsonTableMap = TestDataUtility.getCustomJsonTableTestMap();
    CC_TableJsonUtility.TableJsonWrapper jsonWrapper = CC_TableJsonUtility.getTableJson(
      jsonName
    );

    Test.stopTest();

    System.assertEquals(
      0,
      jsonWrapper.fieldsToFetch.size(),
      'Field to Fetch List not Empty'
    );
  }
}
