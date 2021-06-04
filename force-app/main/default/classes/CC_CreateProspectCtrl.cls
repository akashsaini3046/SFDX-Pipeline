public without sharing class CC_CreateProspectCtrl {
  @AuraEnabled
  public static InitValWrapper fetchInitialValues() {
    InitValWrapper initValWrapper = new InitValWrapper();
    initValWrapper.marketSegments = CC_SharedUtility.getPicklistValuesList(
      Account.Industry.getDescribe()
    );
    initValWrapper.cityNames = CC_SharedUtility.getPicklistValuesList(
      Address__c.Country__c.getDescribe()
    );
    initValWrapper.stateNames = CC_SharedUtility.getPicklistValuesList(
      Address__c.State_Picklist__c.getDescribe()
    );
    return initValWrapper;
  }

  @AuraEnabled
  public static Account getAccountDetails(String accountId) {
    return [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId][0];
  }

  @AuraEnabled
  public static List<Map<String, Object>> createProspectRecords(
    String objValues
  ) {
    List<Map<String, Object>> createdRecordList = new List<Map<String, Object>>();
    Savepoint objSavepoint;
    objSavepoint = Database.setSavepoint();
    if (objValues != null) {
      Map<String, Object> values = (Map<String, Object>) JSON.deserializeUntyped(
        objValues
      );
      System.debug(values);
      Map<String, Object> accountMap = new Map<String, Object>();
      Boolean createAddress = (Boolean) values.get('createAddress');
      Boolean createContact = (Boolean) values.get('createContact');
      if ((createContact || createAddress) && values.get('accountId') != null) {
        accountMap = new Map<String, Object>{
          'Account' => new Account(Id = (Id) values.get('accountId'))
        };
        createdRecordList.add(accountMap);
      } else {
        accountMap = createAccount(values);
        createdRecordList.add(accountMap);
      }
      if (accountMap != null && accountMap.get('Account') != null) {
        Map<String, Object> businessLocationMap = new Map<String, Object>();
        if (createContact) {
          if (
            values.get('selectedAddressId') != null &&
            values.get('selectedAddressId') != ''
          ) {
            Id addressId = (Id) values.get('selectedAddressId');
            businessLocationMap = new Map<String, Object>{
              'Location' => new Address__c(Id = addressId)
            };
          } else {
            businessLocationMap = createBusinessLocation(
              values,
              (Account) accountMap.get('Account')
            );
          }
          //createdRecordList.add(businessLocationMap);
          if (
            businessLocationMap != null &&
            businessLocationMap.get('Location') != null
          ) {
            Map<String, Object> contactMap = createContact(
              values,
              (Address__c) businessLocationMap.get('Location'),
              ((Account) accountMap.get('Account')).Id
            );
            createdRecordList.add(contactMap);
          }
        } else if (createAddress) {
          businessLocationMap = createBusinessLocation(
            values,
            (Account) accountMap.get('Account')
          );
          createdRecordList.add(businessLocationMap);
        } else {
          businessLocationMap = createBusinessLocation(
            values,
            (Account) accountMap.get('Account')
          );
          createdRecordList.add(businessLocationMap);
          if (
            businessLocationMap != null &&
            businessLocationMap.get('Location') != null
          ) {
            Map<String, Object> contactMap = createContact(
              values,
              (Address__c) businessLocationMap.get('Location'),
              ((Account) accountMap.get('Account')).Id
            );
            createdRecordList.add(contactMap);
          }
        }
      }
    }
    for (Map<String, Object> objectMaps : createdRecordList) {
      if (objectMaps.get('ErrorContact') != null) {
        Database.rollback(objSavepoint);
      }
    }
    return createdRecordList;
  }

  private static Map<String, Object> createAccount(Map<String, Object> values) {
    Map<String, Object> accountVsRecord = new Map<String, Object>();
    Account account = null;
    if (
      values != null &&
      values.get('accountName') != null &&
      (String) values.get('accountName') != ''
    ) {
      account = new Account();
      account.Name = (String) values.get('accountName');
      account.Type = 'Prospect';
      account.Industry = (String) values.get('marketSegment');
      Database.DMLOptions dmlOption = getDMLOptionsBypassDuplicateRules();
      Database.SaveResult sr = Database.insert(account, dmlOption);
      if (!sr.isSuccess()) {
        account = null;
        System.debug(sr.getErrors().get(0).getMessage());
      }
    }
    accountVsRecord.put('Account', account);
    return accountVsRecord;
  }

  private static Map<String, Object> createBusinessLocation(
    Map<String, Object> values,
    Account account
  ) {
    Map<String, Object> locationVsRecord = new Map<String, Object>();
    Address__c businessLocation = null;
    if (values != null) {
      businessLocation = new Address__c();
      businessLocation.City__c = values.get('cityName') != null &&
        (String) values.get('cityName') != null
        ? (String) values.get('cityName')
        : '';
      businessLocation.Country__c = values.get('countryName') != null &&
        (String) values.get('countryName') != null
        ? (String) values.get('countryName')
        : '';
      businessLocation.Address_Line_1__c = values.get('address') != null &&
        (String) values.get('address') != null
        ? (String) values.get('address')
        : '';
      businessLocation.Postal_Code__c = values.get('zipCode') != null &&
        (String) values.get('zipCode') != null
        ? (String) values.get('zipCode')
        : '';
      businessLocation.State_Picklist__c = values.get('stateSelected') !=
        null &&
        (String) values.get('stateSelected') != null
        ? (String) values.get('stateSelected')
        : '';
      businessLocation.Account__c = account.Id;
      businessLocation.Account_Type__c = 'Prospect';
      Database.DMLOptions dmlOption = getDMLOptionsBypassDuplicateRules();
      Database.SaveResult sr = Database.insert(businessLocation, dmlOption);
      if (!sr.isSuccess()) {
        System.debug(sr.getErrors().get(0).getMessage());
      }
    }
    locationVsRecord.put('Location', businessLocation);
    return locationVsRecord;
  }

  private static Map<String, Object> createContact(
    Map<String, Object> values,
    Address__c businessLocation,
    Id accountId
  ) {
    Map<String, Object> contactVsRecord = new Map<String, Object>();
    Contact contact = null;
    if (values != null) {
      contact = new Contact();
      contact.Address__c = businessLocation.Id;
      contact.FirstName = values.get('firstName') != null &&
        (String) values.get('firstName') != null
        ? (String) values.get('firstName')
        : '';
      contact.LastName = values.get('lastName') != null &&
        (String) values.get('lastName') != null
        ? (String) values.get('lastName')
        : '';
      contact.Email = values.get('emailAddress') != null &&
        (String) values.get('emailAddress') != null
        ? (String) values.get('emailAddress')
        : '';
      contact.Phone = values.get('contactNumber') != null &&
        (String) values.get('contactNumber') != null
        ? (String) values.get('contactNumber')
        : '';
      contact.Id = null;
      Database.DMLOptions dmlOption = getDMLOptionsBypassDuplicateRules();
      Database.SaveResult sr = Database.insert(contact, dmlOption);
      if (!sr.isSuccess()) {
        if (
          sr.getErrors()
            .get(0)
            .getMessage()
            .equalsIgnoreCase('This contact already exist under this account')
        ) {
          List<Contact> existingContact = CC_WithoutSharingUtility.getContactsDetailByFirstNLastNPhoneEmail(
            contact.FirstName,
            contact.LastName,
            contact.Phone,
            contact.Email,
            accountId
          );
          if (existingContact != null && !existingContact.isEmpty()) {
            contactVsRecord.put('ErrorContact', existingContact[0]);
          }
        }
      } else {
        contactVsRecord.put('Contact', contact);
      }
    } else {
      contactVsRecord.put('Contact', contact);
    }
    return contactVsRecord;
  }

  private static Database.DMLOptions getDMLOptionsBypassDuplicateRules() {
    Database.DMLOptions dmlOption = new Database.DMLOptions();
    dmlOption.DuplicateRuleHeader.AllowSave = true;
    return dmlOption;
  }

  public class InitValWrapper {
    @AuraEnabled
    public List<Map<String, String>> marketSegments { get; set; }
    @AuraEnabled
    public List<Map<String, String>> cityNames { get; set; }
    @AuraEnabled
    public List<Map<String, String>> stateNames { get; set; }
  }
}
