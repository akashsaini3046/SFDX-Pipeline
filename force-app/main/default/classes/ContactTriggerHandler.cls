/*
 * Name: ContactTriggerHandler
 * Purpose: Handler class for Contact Trigger
 * Author: Nagarro
 * Created Date: 10/09/2018
 *
 *  Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public with sharing class ContactTriggerHandler extends TriggerHandler {
  List<Contact> newContactList;
  List<Contact> oldContactList;
  Map<Id, Contact> newContactMap;
  Map<Id, Contact> oldContactMap;

  //Constructor
  public ContactTriggerHandler() {
    this.newContactList = (List<Contact>) Trigger.new;
    this.oldContactList = (List<Contact>) Trigger.old;
    this.newContactMap = (Map<Id, Contact>) Trigger.newMap;
    this.oldContactMap = (Map<Id, Contact>) Trigger.oldMap;
  }
  //Override after insert method
  public override void afterInsert() {
    insertAddressRecord(newContactMap);
  }
  /*Override before insert method*/
  public override void beforeInsert() {
    ConvertUpperCase.convertToUpperCase('Contact', newContactList);

    toTitleCase(newContactList);
    copyPhone(newContactList);
    setAccountName(newContactList);
    updateParentAccount(newContactList, oldContactMap);
    validatePhoneFormat(newContactList, oldContactMap);
    validateMobileFormat(newContactList, oldContactMap);
  }

  public override void afterUpdate() {
    UpdateAccountonCase(newContactList, oldContactList, newContactMap);
  }
  /*Override before update method*/
  public override void beforeUpdate() {
    ConvertUpperCase.convertToUpperCase('Contact', newContactList);
    toTitleCase(newContactList);
    copyPhone(newContactList);
    updateParentAccount(newContactList, oldContactMap);
    validatePhoneFormat(newContactList, oldContactMap);
    validateMobileFormat(newContactList, oldContactMap);
  }

  /*Override before update method*/
  public override void beforeDelete() {
    stopContactDeletion(oldContactMap);
    //  sendDelNotToGovTeam(oldContactMap);
    preventContactDeletion(oldContactList);
  }

  /*
   * Method Name: insertAddressRecord
   * Input Parameters: Map<Id, Contact>
   * Return value: void
   * Purpose: insert the records in Address object by copying the information from Contact record at the time of record creation
   *          and adding the link to the contact object.
   */

  private void insertAddressRecord(Map<Id, Contact> newContactMap) {
    try {
      Map<String, Address__c> contactToAddressMap = new Map<String, Address__c>();
      List<Id> accIdList = new List<Id>();
      Set<Id> accIdtoUpdate = new Set<Id>();

      for (Contact contactobj : newContactMap.values()) {
        accIdList.add(contactobj.AccountId);
      }

      for (Account acc : [
        SELECT Id, Created_From_Lead_Conversion__c
        FROM Account
        WHERE Id IN :accIdList
      ]) {
        if (acc.Created_From_Lead_Conversion__c) {
          accIdtoUpdate.add(acc.Id);
        }
      }

      List<CountryRegionMapping__c> countryRegionMappingList = CountryRegionMapping__c.getAll()
        .values();
      Map<String, String> mapOriginCountryValAPI = new Map<String, String>();

      Schema.DescribeFieldResult countryField = Address__c.Country__c.getDescribe();
      List<Schema.PicklistEntry> countryPicklistValues = countryField.getPicklistValues();

      for (Schema.PicklistEntry pEntry : countryPicklistValues) {
        mapOriginCountryValAPI.put(pEntry.getLabel(), pEntry.getValue());
      }

      Set<Id> setAccountId = new Set<Id>();

      for (Id id : newContactMap.keySet()) {
        if (newContactMap.get(id).Contact_Created_From_Lead__c == true) {
          Address__c addressObj = new Address__c();
          String name = '';
          if (newContactMap.get(id).MailingCountry != null) {
            name = '1. ' + newContactMap.get(id).MailingCountry;
          } else {
            name = '1';
          }

          addressObj.Address_Line_1__c = newContactMap.get(id)
            .Address_Line_1__c;
          addressObj.Address_Line_2__c = newContactMap.get(id)
            .Address_Line_2__c;
          addressObj.Address_Line_3__c = newContactMap.get(id)
            .Address_Line_3__c;
          addressObj.City__c = newContactMap.get(id).City__c;
          addressObj.State_Picklist__c = newContactMap.get(id).State__c;
          addressObj.Country__c = newContactMap.get(id).Country__c;
          addressObj.Postal_Code__c = newContactMap.get(id).Postal_Code__c;

          addressObj.Account__c = newContactMap.get(id).AccountId;
          addressObj.Extn__c = newContactMap.get(id).Extn__c;
          addressObj.Phone__c = newContactMap.get(id).Phone;
          addressObj.Created_from_Lead_Conversion__c = true;
          contactToAddressMap.put(id, addressObj);
          if (newContactMap.get(Id).AccountId != null) {
            setAccountId.add(newContactMap.get(Id).AccountId);
          }
        }
      }
      //First we insert the address records since it's parent of account later we have to link it with the contact record
      if (contactToAddressMap.size() > 0) {
        insert contactToAddressMap.values();
      }

      //Now add the lookup on the contact of the address record inserted.
      //Update account with business location as well if required.
      Map<Id, Account> mapAccount = new Map<Id, Account>(
        [
          SELECT Id, Business_Location__c
          FROM Account
          WHERE Id IN :setAccountId AND Business_Location__c = NULL
        ]
      );
      List<Contact> contactsToUpdateList = new List<Contact>();
      for (String contactId : contactToAddressMap.keySet()) {
        Contact contactObj = new Contact();
        contactObj.Id = contactId;
        contactObj.Address__c = contactToAddressMap.get(contactId).Id;
        contactsToUpdateList.add(contactObj);
        if (
          mapAccount != null &&
          newContactMap.get(contactId) != null &&
          newContactMap.get(contactId).AccountId != null &&
          mapAccount.get(newContactMap.get(contactId).AccountId) != null &&
          mapAccount.get(newContactMap.get(contactId).AccountId)
            .Business_Location__c == null
        ) {
          mapAccount.get(newContactMap.get(contactId).AccountId)
            .Business_Location__c = contactToAddressMap.get(contactId).Id;
        }
      }

      update contactsToUpdateList;
      update mapAccount.values();
    } catch (Exception e) {
      System.debug(
        logginglevel.ERROR,
        'MESSAGE:' +
        e.getMessage() +
        'STACK TRACE:' +
        e.getStackTraceString()
      );
    }
  }

  private void sendDelNotToGovTeam(Map<Id, Contact> oldContactMap) {
    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;

    for (Contact conObj : oldContactMap.values()) {
      if (
        oldContactMap.size() == 1 &&
        String.ISBLANK(conObj.CDM_Org_Id__c) &&
        !profileName.contains(Label.PROFILE_DATA_STEWARD)
      ) {
        //Governance team will not receive email if the contact is deleted by user having profile "Data Steward"
      }
    }
  }

  private void stopContactDeletion(Map<Id, Contact> oldContactMap) {
    for (Contact conObj : oldContactMap.values()) {
      if (
        !String.ISBLANK(conObj.CDM_Contact_Id__c) ||
        !String.ISBLANK(conObj.CDM_Location_Id__c)
      ) {
        conObj.addError(
          'Record is already synchroinzed with CDM. Please contact governance team for any edits to this record.'
        );
      }
    }
  }

  private void setAccountName(List<Contact> newContactList) {
    List<Id> addressIds = new List<Id>();
    for (Contact conObj : newContactList) {
      if (conObj.Address__c != null) {
        addressIds.add(conObj.Address__c);
      }
    }
    if (!addressIds.isEmpty()) {
      Map<Id, Address__c> addressMap = new Map<Id, Address__c>(
        [SELECT id, Account__c FROM Address__c WHERE id IN :addressIds]
      );
      for (Contact conObj : newContactList) {
        if (
          conObj.Address__c != null &&
          addressMap.get(conObj.Address__c) != null &&
          addressMap.get(conObj.Address__c).Account__c != null
        ) {
          conObj.AccountId = addressMap.get(conObj.Address__c).Account__c;
        }
      }
    }
  }

  // Contact record cannot be deleted if
  //  -> opportunity is linked with it
  //  -> user profile is not Sales Manager or Sales Leader
  //  -> user is not the associated account's owner

  private void preventContactDeletion(List<Contact> oldContactList) {
    Set<Id> contactIdSet = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    for (Contact con : oldContactList) {
      contactIdSet.add(con.Id);
      if (con.AccountId != null)
        accountIdSet.add(con.AccountId);
    }

    List<Account> allAccList = new List<Account>();
    if (accountIdSet != null && !accountIdSet.isEmpty()) {
      allAccList = [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIdSet];
    }

    Map<Id, String> map_Id_AccOwnerId = new Map<Id, String>();
    if (allAccList != null && !allAccList.isEmpty()) {
      for (Account acc : allAccList) {
        map_Id_AccOwnerId.put(acc.Id, acc.OwnerId);
      }
    }

    List<Opportunity> allOppList = new List<Opportunity>();
    if (contactIdSet != null && !contactIdSet.isEmpty()) {
      allOppList = [
        SELECT Id, Contact__c
        FROM Opportunity
        WHERE Contact__c IN :contactIdSet
      ];
    }

    Map<Id, integer> map_conId_oppList = new Map<Id, integer>();
    if (allOppList != null && !allOppList.isEmpty()) {
      for (Opportunity opp : allOppList) {
        integer oppList = map_conId_oppList.get(opp.Contact__c);
        if (oppList == null) {
          oppList = 0;
        }
        oppList++;
        map_conId_oppList.put(opp.Contact__c, oppList);
      }
    }

    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;

    Map<String, ProfileNames__c> profileNames = ProfileNames__c.getall();

    if (oldContactList != null && !oldContactList.isEmpty()) {
      for (Contact con : oldContactList) {
        String accOwner;
        if (map_Id_AccOwnerId.containsKey(con.AccountId))
          accOwner = map_Id_AccOwnerId.get(con.AccountId);
        integer countOpp = 0;
        if (map_conId_oppList.containsKey(con.Id))
          countOpp = map_conId_oppList.get(con.Id);
        String name = '';
        if (con.FirstName != null && con.FirstName != '')
          name = name + con.FirstName + ' ';
        if (con.LastName != null && con.LastName != '')
          name = name + con.LastName;
        if (!Label.SYSTEM_ADMINISTRATOR.contains(profileName)) {
          if (countOpp > 0) {
            con.addError(
              'Your attempt to delete ' +
              name +
              ' could not be completed because it has associated opportunities.'
            );
          }
          if (
            UserInfo.getUserId() != accOwner &&
            !profileNames.containsKey(profileName)
          ) {
            con.addError(
              'Your attempt to delete ' +
              name +
              ' could not be completed, please contact your manager.'
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: updateParentAccount
   * Input Parameters:
   * List<Contact> listContact : This holds new contact list
   * Map<Id, Contact> mapOldContact : This holds old contact map
   * Return value: void
   * Purpose: pupulates parent account in the contact to maintain subsidiary contact.
   */
  private void updateParentAccount(
    List<Contact> listContact,
    Map<Id, Contact> mapOldContact
  ) {
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    Set<Id> setAccId = new Set<Id>();
    Map<Id, Account> mapTempAcc = new Map<Id, Account>();

    for (Contact con : listContact) {
      setAccId.add(con.AccountId);
    }
    if (!setAccId.isEmpty()) {
      mapTempAcc = new Map<Id, Account>(
        [SELECT Id, ParentId FROM Account WHERE Id IN :setAccId]
      );
      mapAccount = mapTempAcc;
    }

    for (Contact objContact : listContact) {
      if (
        (mapOldContact == null &&
        objContact.AccountId != null &&
        mapTempAcc.containsKey(objContact.AccountId) &&
        mapTempAcc.get(objContact.AccountId).ParentId != null) ||
        (mapOldContact != null &&
        mapOldContact.containsKey(objContact.Id) &&
        mapOldContact.get(objContact.Id).AccountId != objContact.accountId)
      ) {
        if (objContact.AccountId == null) {
          objContact.Parent_Account__c = null;
        } else if (mapTempAcc.containsKey(objContact.AccountId)) {
          objContact.Parent_Account__c = mapTempAcc.get(objContact.AccountId)
            .ParentId;
        }
      }
    }
  }

  private void validatePhoneFormat(
    List<Contact> newContactList,
    Map<Id, Contact> oldContactMap
  ) {
    for (Contact conObj : newContactList) {
      if (conObj.Phone != null || String.isNotBlank(conObj.Phone)) {
        //if(Trigger.isInsert || (oldContactMap!=null && conObj.Phone != oldContactMap.get(conObj.Id).Phone)){
        if (Trigger.isInsert || Trigger.isBefore) {
          String phoneString = conObj.Phone;
          if (
            String.isNotBlank(phoneString) && phoneString.containsAny('()-+')
          ) {
            phoneString = phoneString.replace('(', '');
            phoneString = phoneString.replace(')', '');
            phoneString = phoneString.replace('-', '');
            phoneString = phoneString.replace('+', '');
            if (
              !phoneString.IsNumeric() ||
              phoneString.length() < 7 ||
              phoneString.length() > 15
            ) {
              conObj.addError(
                'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Phone.'
              );
            } else {
              if (
                phoneString.length() == 10 ||
                (phoneString.length() == 11 && phoneString.startsWith('1'))
              ) {
                conObj.Phone = phoneString;
              }
            }
          } else if (!phoneString.IsNumeric()) {
            conObj.addError(
              'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Phone.'
            );
          } else if (phoneString.length() < 7 || phoneString.length() > 15) {
            conObj.addError(
              'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Phone.'
            );
          }
        }
      }
    }
  }
  public static void validateMobileFormat(
    List<Contact> contactList,
    Map<Id, Contact> MapIdToContact
  ) {
    for (Contact objCon : contactList) {
      if (objCon.MobilePhone != null || String.isNotBlank(objCon.MobilePhone)) {
        //if(Trigger.isInsert || (MapIdToContact!=NULL && objCon.MobilePhone != MapIdToContact.get(objCon.Id).MobilePhone)){
        if (Trigger.isInsert || Trigger.isBefore) {
          String mobileString = objCon.MobilePhone;
          if (
            String.isNotBlank(mobileString) && mobileString.containsAny('()-+')
          ) {
            mobileString = mobileString.replace('(', '');
            mobileString = mobileString.replace(')', '');
            mobileString = mobileString.replace('-', '');
            mobileString = mobileString.replace('+', '');
            if (
              !mobileString.isNumeric() ||
              mobileString.length() < 7 ||
              mobileString.length() > 15
            ) {
              objCon.addError(
                'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Mobile Phone.'
              );
            } else {
              if (
                mobileString.length() == 10 ||
                (mobileString.length() == 11 && mobileString.startsWith('1'))
              ) {
                objCon.MobilePhone = mobileString;
              }
            }
          } else if (!mobileString.isNumeric()) {
            objCon.addError(
              'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Mobile Phone.'
            );
          } else if (mobileString.length() < 7 || mobileString.length() > 15) {
            objCon.addError(
              'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Mobile Phone.'
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: toTitleCase
   * Input Parameters:
   * String
   * Return value: void
   * Purpose: set the static veriable that says lead is converted.
   */

  public void toTitleCase(List<Contact> newContactList) {
    for (Contact conObj : newContactList) {
      String phrase =
        (conObj.FirstName == null ? '' : (conObj.FirstName + ' ')) +
        (conObj.MiddleName == null ? '' : (conObj.MiddleName + ' ')) +
        conObj.LastName;
      System.debug('phrase----------------' + phrase);
      String titlePhrase = '';

      // Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};

      if (phrase != null && phrase.length() > 0) {
        String[] splitPhrase = phrase.trim().split(' ');
        System.debug('splitPhrase----------' + splitPhrase);
        for (integer i = 0; i < splitPhrase.size(); i++) {
          if (
            (i == 0 || i <= (splitPhrase.size() - 1)) &&
            splitPhrase[i].length() > 0
          ) {
            titlePhrase +=
              (splitPhrase[i].substring(0, 1).toUpperCase()) +
              (splitPhrase[i].length() > 1
                ? (splitPhrase[i].substring(1).toLowerCase())
                : '') +
              ' ';
          }
        }
      }
      System.debug('titlePhrase-----------' + titlePhrase);
      conObj.Contact_Name_Title__c = titlePhrase;
    }
  }

  public static void UpdateAccountonCase(
    List<Contact> newContactList,
    List<Contact> oldContactList,
    Map<Id, Contact> newContactMap
  ) {
    List<Case> caselst = new List<Case>();
    //system.debug('inside method');
    for (Contact con : oldContactList) {
      //system.debug('inside 1st for'+con.AccountID+'new account ID'+newContactMap.get(con.Id).AccountID);
      if (con.AccountID != newContactMap.get(con.Id).AccountID) {
        List<Case> caselst1 = [
          SELECT Id, AccountID, ContactId
          FROM Case
          WHERE ContactId = :con.Id
        ];
        // system.debug('list size'+caselst1[0].AccountId);
        for (case c : caselst1) {
          if (c.AccountId == null) {
            //system.debug('inside last if');
            c.AccountId = newContactMap.get(con.Id).AccountID;
            caselst.add(c);
          }
        }
      }
    }
    update caselst;
  }

  private void copyPhone(List<Contact> newContactList) {
    List<Id> locationIdList = new List<Id>();

    Map<String, CountryPhoneCodeMap__c> countryPhoneCodeMap = CountryPhoneCodeMap__c.getAll();

    for (Contact conObj : newContactList) {
      if (conObj.Address__c != null) {
        locationIdList.add(conObj.Address__c);
      }
    }

    Map<Id, Address__c> addressMap = new Map<Id, Address__c>(
      [SELECT Id, Country__c FROM Address__c WHERE Id IN :locationIdList]
    );

    for (Contact conObj : newContactList) {
      if (!String.IsBlank(conObj.Phone)) {
        String alphanumericPhone = conObj.Phone.replaceAll('\\D', '');
        if (
          addressMap.size() > 0 &&
          conObj.Address__c != null &&
          countryPhoneCodeMap.keySet()
            .contains(addressMap.get(conObj.Address__c).Country__c)
        ) {
          if (conObj.Phone != null && alphanumericPhone.Length() == 10) {
            conObj.Phone_Call_Center__c =
              '+' +
              countryPhoneCodeMap.get(
                  addressMap.get(conObj.Address__c).Country__c
                )
                .Country_Phone_Code__c +
              alphanumericPhone;
          } else {
            conObj.Phone_Call_Center__c = '+' + alphanumericPhone;
          }
        } else {
          conObj.Phone_Call_Center__c = '+' + alphanumericPhone;
        }
      }

      if (!String.IsBlank(conObj.MobilePhone)) {
        String alphanumericPhone = conObj.MobilePhone.replaceAll('\\D', '');
        if (
          addressMap.size() > 0 &&
          conObj.Address__c != null &&
          countryPhoneCodeMap.keySet()
            .contains(addressMap.get(conObj.Address__c).Country__c)
        ) {
          if (conObj.MobilePhone != null && alphanumericPhone.Length() == 10) {
            conObj.Mobile_Phone_Call_Center__c =
              '+' +
              countryPhoneCodeMap.get(
                  addressMap.get(conObj.Address__c).Country__c
                )
                .Country_Phone_Code__c +
              alphanumericPhone;
          } else {
            conObj.Mobile_Phone_Call_Center__c = '+' + alphanumericPhone;
          }
        } else {
          conObj.Mobile_Phone_Call_Center__c = '+' + alphanumericPhone;
        }
      }
    }
  }
}
