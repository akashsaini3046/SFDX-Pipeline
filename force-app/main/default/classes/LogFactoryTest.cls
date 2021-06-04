@isTest
public with sharing class LogFactoryTest {
  @isTest
  static void errorTest() {
    Test.startTest();
    LogFactory.error(
      'LogFactoryTest',
      'errorTest',
      'Test',
      'This is a Test Message'
    );
    LogFactory.saveLog();
    Test.stopTest();

    Log__c log = [SELECT Source_Class__c FROM Log__c LIMIT 1];
    System.assertEquals(
      'LogFactoryTest',
      log.Source_Class__c,
      'Class name inserted equals check'
    );
  }

  @isTest
  static void infoTest() {
    Test.startTest();
    LogFactory.info(
      'LogFactoryTest',
      'errorTest',
      'Test',
      'This is a Test Message'
    );
    LogFactory.saveLog();
    Test.stopTest();

    Log__c log = [SELECT Source_Class__c FROM Log__c LIMIT 1];
    System.assertEquals(
      'LogFactoryTest',
      log.Source_Class__c,
      'Class name inserted equals check'
    );
  }

  @isTest
  static void errorFutureTest() {
    Test.startTest();
    Account[] accts = new List<Account>{ new Account() };
    Database.SaveResult[] srList = Database.insert(accts, false);
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        LogFactory.logDatabaseErrors(
          'LogFactoryTest',
          'errorTest',
          sr.getErrors()
        );
      }
    }
    Test.stopTest();

    Log__c log = [SELECT Source_Class__c FROM Log__c LIMIT 1];
    System.assertEquals(
      'LogFactoryTest',
      log.Source_Class__c,
      'Class name inserted equals check'
    );
  }
}
