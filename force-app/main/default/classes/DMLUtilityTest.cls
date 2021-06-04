@isTest
public with sharing class DMLUtilityTest {
  @testSetup
  static void setup() {
    List<Contact> contacts = TestDataUtility.getContactRecords(
      'Test Contact',
      2,
      true
    );
  }

  @isTest
  static void insertRecordsTest() {
    Test.startTest();

    List<Contact> contacts = TestDataUtility.getContactRecords(
      'Test Contact Insert',
      2,
      false
    );
    DMLUtility.insertRecords(contacts, true);

    Test.stopTest();

    List<Contact> insertedContacts = [SELECT Id, LastName FROM Contact];
    System.assertEquals(4, insertedContacts.size(), 'Records inserted check');
  }

  @isTest
  static void insertRecordsNegativeTest() {
    Test.startTest();

    List<Contact> contacts = TestDataUtility.getContactRecords(null, 1, false);
    DMLUtility.insertRecords(contacts, false);

    Test.stopTest();

    List<Contact> insertedContacts = [SELECT Id, LastName FROM Contact];
    System.assertEquals(
      2,
      insertedContacts.size(),
      'No Records gets inserted check'
    );
  }

  @isTest
  static void updateRecordsTest() {
    Test.startTest();
    List<Contact> contactsToUpdate = new List<Contact>();
    for (Contact contact : [SELECT Id, LastName FROM Contact]) {
      contact.LastName = contact.LastName + 'UPDATE';
      contactsToUpdate.add(contact);
    }
    DMLUtility.updateRecords(contactsToUpdate, true);

    Test.stopTest();
    List<Contact> contactsUpdated = new List<Contact>();
    for (Contact contact : [SELECT Id, LastName FROM Contact]) {
      if (contact.LastName.toUpperCase().contains('UPDATE')) {
        contactsUpdated.add(contact);
      }
    }
    System.assertEquals(2, contactsUpdated.size(), 'Records update check');
  }

  @isTest
  static void updateRecordsNegativeTest() {
    Test.startTest();
    List<Contact> contactsToUpdate = new List<Contact>();
    for (Contact contact : [SELECT Id, LastName FROM Contact]) {
      contact.LastName = null;
      contactsToUpdate.add(contact);
    }
    DMLUtility.updateRecords(contactsToUpdate, false);

    Test.stopTest();
    List<Contact> contactsUpdated = new List<Contact>();
    for (Contact contact : [SELECT Id, LastName FROM Contact]) {
      if (contact.LastName.toUpperCase().contains('UPDATE')) {
        contactsUpdated.add(contact);
      }
    }
    System.assertEquals(0, contactsUpdated.size(), 'No Records gets updated');
  }
  /*
    @isTest
    static void upsertRecordsTest() {
        Test.startTest();
        List<Contact> contactsToUpsert = new List<Contact>();
        for(Contact contact : [SELECT Id, LastName, Email FROM Contact]){
            contact.LastName = contact.LastName + 'Upsert';
            contactsToUpsert.add(contact);
        }
        Schema.SObjectField externalField = Contact.Fields.Email;
        DMLUtility.upsertRecords(contactsToUpsert, externalField, false);
        
        Test.stopTest();
        
        List<Contact> contactsUpserted = new List<Contact>();
        for(Contact contact : [SELECT Id, LastName FROM Contact]){
            if(contact.LastName.toUpperCase().contains('UPSERT')){
                contactsUpserted.add(contact);
            }
        }
        System.assertEquals(2, contactsUpserted.size() , 'Records upsert check');
    }
    
    @isTest
    static void upsertRecordsNegativeTest() {
        Test.startTest();
        List<Contact> contactsToUpsert = new List<Contact>();
        for(Contact contact : [SELECT Id, LastName, Email FROM Contact]){
            contact.LastName = null;
            contact.Email = 'dummy@example.com';
            contactsToUpsert.add(contact);
        }
        Schema.SObjectField externalField = Contact.Fields.Email;
        DMLUtility.upsertRecords(contactsToUpsert, externalField, false);
        
        Test.stopTest();
        List<Contact> contactsUpserted = new List<Contact>();
        for(Contact contact : [SELECT Id, LastName FROM Contact]){
            if(contact.LastName.toUpperCase().contains('UPSERT')){
                contactsUpserted.add(contact);
            }
        }
        System.assertEquals(0, contactsUpserted.size() , 'No Records gets upserted');
    }
    */
  @isTest
  static void deleteRecordsTest() {
    Test.startTest();
    List<Contact> contactsToDelete = [SELECT Id, LastName FROM Contact];
    DMLUtility.deleteRecords(contactsToDelete, true);

    Test.stopTest();

    List<Contact> existingContacts = [SELECT Id, LastName FROM Contact];
    System.assertEquals(0, existingContacts.size(), 'Records deleted check');
  }

  @isTest
  static void deleteRecordsNegativeTest() {
    Test.startTest();

    List<Contact> contactsToDelete = [SELECT Id, LastName FROM Contact];
    DMLUtility.deleteRecords(contactsToDelete, false);
    DMLUtility.deleteRecords(contactsToDelete, false);
    Test.stopTest();

    List<Contact> existingContacts = [SELECT Id, LastName FROM Contact];
    System.assertEquals(0, existingContacts.size(), 'No Records gets upserted');
  }

  @isTest
  static void unDeleteRecordsTest() {
    Test.startTest();
    List<Contact> contactsToDelete = [SELECT Id, LastName FROM Contact];
    DMLUtility.deleteRecords(contactsToDelete, true);
    DMLUtility.unDeleteRecords(contactsToDelete, true);
    Test.stopTest();

    List<Contact> existingContacts = [SELECT Id, LastName FROM Contact];
    System.assertEquals(2, existingContacts.size(), 'Records undeleted check');
  }

  @isTest
  static void unDeleteRecordsNegativeTest() {
    Test.startTest();
    List<Contact> contactsToUnDelete = [SELECT Id, LastName FROM Contact];
    DMLUtility.unDeleteRecords(contactsToUnDelete, false);
    Test.stopTest();

    List<Contact> existingContacts = [SELECT Id, LastName FROM Contact];
    System.assertEquals(2, existingContacts.size(), 'No Records gets upserted');
  }
}
