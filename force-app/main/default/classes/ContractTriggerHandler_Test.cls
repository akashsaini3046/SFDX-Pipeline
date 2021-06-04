/*
 * Name: ContractTriggerHandler_Test
 * Purpose: Test class for ContractTriggerHandler, UpdateContractStatusToExpireBatchSch, UpdateContractStatusToExpireBatch
 * Author: Nagarro
 * Created Date: 17-Dec-2020
 * Modification History
 * Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest
public class ContractTriggerHandler_Test {
  @testSetup
  static void setup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> accObj1 = TestDataUtility.createAccount(
      'Account 123',
      null,
      null,
      null,
      false,
      1
    );
    insert accObj1;

    List<Address__c> businessLocationObj = TestDataUtility.createBusinessLocation(
      accObj1,
      'BL1',
      'City1',
      'CA',
      '1111111',
      '88888888888',
      'US',
      1
    );
    insert businessLocationObj;
    List<Contact> con = TestDataUtility.createContact(
      null,
      accObj1,
      businessLocationObj,
      'Test',
      ' con1',
      'contact@email.com',
      '99999999999',
      false,
      null,
      1
    );
    insert con;

    List<Product2> lstProducts = TestDataUtility.createProduct(
      new List<String>{ 'CrowleyFresh', 'Air', 'Asset Management' }
    );

    List<ProfileNames__c> plist = TestDataUtility.ProfileNames();
    insert plist;

    List<Opportunity> opp1 = TestDataUtility.createOpportunity(
      null,
      null,
      'Opp1',
      con,
      accObj1,
      ConstantClass.PROSPECTING_OPP_STAGE,
      null,
      System.today(),
      null,
      'CrowleyFresh;',
      null,
      true,
      1
    );
    insert opp1;
    List<Contract> contractObj = TestDataUtility.createContract(
      accObj1,
      null,
      2,
      System.today(),
      opp1,
      'Pricing Team Review',
      [SELECT Id FROM Pricebook2 LIMIT 1]
      .Id,
      1
    );
    insert contractObj;
  }

  static testMethod void updateContractTestMethod() {
    Contract cont = [SELECT Id, Status FROM Contract][0];
    cont.Status = 'Out for Signature';
    Test.startTest();
    update cont;
    Test.stopTest();
  }

  static testMethod void updateContractStatusTestMethod() {
    Contract cont = [
      SELECT Id, Status, Contract_Expiration_Date__c
      FROM Contract
    ][0];
    cont.Status = 'Out for Signature';
    Date dt = Date.newInstance(2020, 12, 27);
    cont.Contract_Expiration_Date__c = dt;
    Test.startTest();
    update cont;
    UpdateContractStatusToExpireBatch testBatch = new UpdateContractStatusToExpireBatch();
    Database.executeBatch(testBatch);
    Test.stopTest();
  }

  static testMethod void updateRecordTypeTestMethod() {
    Account acc = [SELECT Id FROM Account][0];
    Id amendmentRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    Map<String, Schema.RecordTypeInfo> mapsTest = Schema.SObjectType.Contract.getRecordTypeInfosByName();
    System.debug('mapsTest' + mapsTest);
    Id amendmentRORecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
      .get('Standard - Read Only')
      .getRecordTypeId();
    Contract c = new Contract();
    c.AccountId = acc.Id;
    c.Contract_Paper__c = 'Crowley Paper';
    c.FMC_Amendment_Number__c = '12';
    c.StartDate = date.today();
    c.RecordTypeId = amendmentRecordTypeId;
    c.Status = 'Pricing Team Review';
    Test.startTest();
    insert c;
    Test.stopTest();
  }

  static testMethod void testschedule() {
    Test.StartTest();
    String sch = '00 59 13 19 11 ? 2021';
    String jobID = System.schedule(
      'Test status Check',
      sch,
      new UpdateContractStatusToExpireBatchSch()
    );
    system.debug('***' + jobID);
    Test.stopTest();
  }
}
