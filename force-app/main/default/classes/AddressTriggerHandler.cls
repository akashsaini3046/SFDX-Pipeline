public with sharing class AddressTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarAfterDelete = true;
  List<Address__c> oldBusinessLocationList;
  List<Address__c> newAddressList;
  Map<Id, Address__c> oldAddressMap;
  Map<Id, Address__c> newAddressMap;
  String profileName;

  public AddressTriggerHandler() {
    this.oldBusinessLocationList = (List<Address__c>) Trigger.old;
    this.newAddressList = (List<Address__c>) Trigger.New;
    this.oldAddressMap = (Map<Id, Address__c>) Trigger.oldMap;
    this.newAddressMap = (Map<Id, Address__c>) Trigger.newMap;
    profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()]
    .Name;
  }

  /* Override before insert method*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      updateAccountNameOnBL(newAddressList, oldAddressMap); // Do not change the order of this method. This will always be the first method to be called.
      updateNameFieldWithAccountName(newAddressList, oldAddressMap); // Do not change the order of this method. This will always be the second method to be called.
      ConvertUpperCase.convertToUpperCase('Address__c', newAddressList);
      validatePhoneFormat(newAddressList, oldAddressMap);
      populateAccountType(newAddressList);
      populateBusinessLocationText(newAddressList, oldAddressMap);
      recursionVarBeforeInsert = false;
    }
  }

  /* Override after insert method*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      setOwnerBasedOnCountryMapping(newAddressList);
      createTrackHistoryRecord(
        newAddressList,
        newAddressMap,
        new List<Address__c>(),
        new Map<Id, Address__c>(),
        Label.GTR_OPERATION_TYPE_CREATED
      );
      recursionVarAfterInsert = false;
    }
  }

  /* Override before update method*/
  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      updateAccountNameOnBL(newAddressList, oldAddressMap); // Do not change the order of this method. This will always be the first method to be called.
      updateNameFieldWithAccountName(newAddressList, oldAddressMap); // Do not change the order of this method. This will always be the second method to be called.
      ConvertUpperCase.convertToUpperCase('Address__c', newAddressList);
      validatePhoneFormat(newAddressList, oldAddressMap);
      populateBusinessLocationText(newAddressList, oldAddressMap);
      recursionVarBeforeUpdate = false;
      validateBusinessLocationDeactivation(newAddressList, oldAddressMap);
    }
  }

  /* Override after update method*/
  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      //This method will create a record in the Track History object whenever an Address is modified.
      createTrackHistoryRecord(
        newAddressList,
        newAddressMap,
        oldBusinessLocationList,
        oldAddressMap,
        Label.GTR_OPERATION_MODIFIED
      );
      recursionVarAfterUpdate = false;
    }
  }

  /*Override before delete method*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      stopAddressDeletion(oldAddressMap);
      preventBusinessLocationDeletion(oldBusinessLocationList);
      recursionVarBeforeDelete = false;
    }
  }

  /*Override after delete method*/
  public override void afterDelete() {
  }

  /*
   * Method Name: updateAccountNameOnBL
   * Purpose: This method will udpate the Account Name field with the Account Name on business location record whenever a BL record is updated or created.
   * Created By:  Anuj Garg(25th Sept, 2019)
   * Last Modified By: Anuj Garg(25th Sept, 2019)
   */
  private void updateAccountNameOnBL(
    List<Address__c> newAddressList,
    Map<Id, Address__c> oldAddressMap
  ) {
    if (newAddressList != null && !newAddressList.isEmpty()) {
      Set<Id> accountIds = new Set<Id>();
      //Logic if the Account on BL is updated.
      if (
        oldAddressMap != null &&
        oldAddressMap.keySet() != null &&
        !oldAddressMap.keySet().isEmpty()
      ) {
        for (Address__c add : newAddressList) {
          if (
            add.Account__c != null &&
            add.Account__c != oldAddressMap.get(add.Id).Account__c
          ) {
            accountIds.add(add.Account__c);
          }
        }
      } else {
        //Logic if the Account on BL is inserted.
        for (Address__c add : newAddressList) {
          if (
            add.Account__c != null &&
            (add.Account_Name__c == null ||
            add.Account_Name__c == '')
          ) {
            accountIds.add(add.Account__c);
          }
        }
      }

      //Update the Account Name on BL with the Account name on Account
      if (accountIds != null && !accountIds.isEmpty()) {
        Map<Id, Account> accountMap = WithoutSharingUtility.fetchAccountMap(
          accountIds
        );
        if (accountMap.keySet() != null && !accountMap.keySet().isEmpty()) {
          for (Address__c add : newAddressList) {
            if (
              add.Account__c != null &&
              accountMap.keySet().contains(add.Account__c)
            ) {
              add.Account_Name__c = (accountMap.get(add.Account__c)).Name;
            }
          }
        }
      }
    }
  }

  /*
   * Method Name: updateNameFieldWithAccountName
   * Purpose: This method will udpate the standard Name field with the Account Name on business location record so that it helps in the
   *           search of the record.
   * Created By:  Anuj Garg(18th Sept, 2019)
   * Last Modified By: Anuj Garg(24th Sept, 2019)
   */
  private void updateNameFieldWithAccountName(
    List<Address__c> newAddressList,
    Map<Id, Address__c> oldAddressMap
  ) {
    if (newAddressList != null && !newAddressList.isEmpty()) {
      //Logic if the Account on BL is updated.
      if (
        oldAddressMap != null &&
        oldAddressMap.keySet() != null &&
        !oldAddressMap.keySet().isEmpty()
      ) {
        for (Address__c add : newAddressList) {
          if (add.Name != oldAddressMap.get(add.Id).Name) {
            if (profileName != System.Label.INTEGRATION_USER) {
              add.addError(
                System.Label.Name_Change_Error_Message_1 +
                oldAddressMap.get(add.Id).Name +
                System.Label.Name_Change_Error_Message_2
              );
            } else {
              add.Address_Line_1__c = add.Name;
              add.Name = returnConcatenatedString(add);
            }
          }

          if (
            (add.Account__c != null &&
            (add.Account__c != oldAddressMap.get(add.Id).Account__c ||
            add.Account_Name__c !=
            oldAddressMap.get(add.Id).Account_Name__c)) ||
            (add.Address_Line_1__c != null &&
            add.Address_Line_1__c != '' &&
            add.Address_Line_1__c !=
            oldAddressMap.get(add.Id).Address_Line_1__c) ||
            (add.City__c != null &&
            add.City__c != oldAddressMap.get(add.Id).City__c)
          ) {
            add.Name = returnConcatenatedString(add);
          }
        }
      } else {
        //Logic for insertion of BL.
        for (Address__c add : newAddressList) {
          //if(profileName != System.Label.INTEGRATION_USER && add.Name!=null){
          if (add.Name != null) {
            add.Address_Line_1__c = add.Name;
          }
          add.Name = returnConcatenatedString(add);
        }
      }
    }
  }

  /*
   * Method Name: returnConcatenatedString
   * Purpose: This method will help in getting the concatenated struing consisting of Account name(first 20 chars),
   *            Address Line1(first 20 chars), City, Country, Zipcode
   * Created By:  Anuj Garg(18th Sept, 2019)
   * Last Modified By: Anuj Garg(18th Sept, 2019)
   */
  private String returnConcatenatedString(Address__c add) {
    String addressLine1 = '';
    String city = '';
    String accountName = '';

    //Get the first certain chars of Address Line 1
    if (add.Address_Line_1__c != null) {
      if (
        add.Address_Line_1__c.length() >
        Integer.valueOf(System.Label.Address_Line1_Length)
      ) {
        addressLine1 =
          add.Address_Line_1__c.subString(
            0,
            Integer.valueOf(System.Label.Address_Line1_Length)
          ) + System.Label.String_Separator;
      } else {
        addressLine1 = add.Address_Line_1__c + System.Label.String_Separator;
      }
    }

    //Get the City on Business Location record
    if (add.City__c != null) {
      if (add.City__c.length() > Integer.valueOf(System.Label.City_Length)) {
        city =
          add.City__c.subString(0, Integer.valueOf(System.Label.City_Length)) +
          System.Label.String_Separator;
      } else {
        city = add.City__c + System.Label.String_Separator;
      }
    }

    //Get the first certain chars of account name
    if (add.Account__c != null) {
      if (
        add.Account_Name__c.length() >
        Integer.valueOf(System.Label.Account_Name_Length)
      ) {
        accountName =
          add.Account_Name__c.subString(
            0,
            Integer.valueOf(System.Label.Account_Name_Length)
          ) + System.Label.String_Separator;
      } else {
        accountName = add.Account_Name__c + System.Label.String_Separator;
      }
    }

    String concatenatedString = addressLine1 + city + accountName;

    // To remove the string separator at the end of the String.
    if (concatenatedString.endsWith(System.Label.String_Separator)) {
      concatenatedString = concatenatedString.substring(
        0,
        (concatenatedString.length() - 1)
      );
    }

    //If the length of the string is exceeding 80 chars then we need to trim it to 80 chars
    //as the standard name field can only hold 80 characters.
    if (concatenatedString.length() > 80) {
      concatenatedString = concatenatedString.substring(0, 80);
    }

    return concatenatedString;
  }

  /*
   * Method Name: createTrackHistoryRecord
   * Purpose: This method will create a record in the Track History object whenever an Address is created/modified/deleted.
   * Created By:  Anuj Garg(06th Aug, 2019)
   * Last Modified By: Anuj Garg(06th Aug, 2019)
   */
  private void createTrackHistoryRecord(
    List<Address__c> addressList1,
    Map<Id, Address__c> addressMap1,
    List<Address__c> addressList2,
    Map<Id, Address__c> addressMap2,
    String operation
  ) {
    Map<Id, String> mapRecordIdToName = new Map<Id, String>();
    Map<String, Governance_Team_Fields__c> allFields = Governance_Team_Fields__c.getAll();
    Set<Id> setLookupRecordIds = new Set<Id>();
    List<Track_History__c> listTrackHistory = new List<Track_History__c>();
    List<List<sObject>> lstObjResults = new List<List<sObject>>();

    if (
      !profileName.equals(Label.GTR_PROFILE_DATA_STEWARD) &&
      !profileName.equals(Label.GTR_PROFILE_INTEGRATION_USER)
    ) {
      if (addressMap1.keySet() != null && !addressMap1.keySet().isEmpty()) {
        if (operation == Label.GTR_OPERATION_MODIFIED) {
          for (Governance_Team_Fields__c fld : allFields.values()) {
            if (
              fld.Object_Name__c == Label.GTR_OBJECT_NAME_BUSINESS_LOCATION &&
              (fld.Data_Type__c == Label.GTR_DATA_TYPE_LOOKUP ||
              fld.Data_Type__c == Label.GTR_DATA_TYPE_LOOK_UP)
            ) {
              for (Address__c addr : addressList1) {
                if (
                  addressMap1.get(addr.Id).get(fld.Field_API_Name__c) !=
                  addressMap2.get(addr.Id).get(fld.Field_API_Name__c)
                ) {
                  setLookupRecordIds.add(
                    String.valueOf(
                      addressMap1.get(addr.Id).get(fld.Field_API_Name__c)
                    )
                  );
                  setLookupRecordIds.add(
                    String.valueOf(
                      addressMap2.get(addr.Id).get(fld.Field_API_Name__c)
                    )
                  );
                }
              }
            }
          }

          if (setLookupRecordIds.size() > 0) {
            lstObjResults = new List<List<sObject>>{
              [SELECT Id, Name FROM Account WHERE Id IN :setLookupRecordIds],
              [SELECT Id, Name FROM Address__c WHERE Id IN :setLookupRecordIds],
              [SELECT Id, Name FROM Contact WHERE Id IN :setLookupRecordIds],
              [
                SELECT Id, Name
                FROM Opportunity
                WHERE Id IN :setLookupRecordIds
              ],
              [SELECT Id, Name FROM Lead WHERE Id IN :setLookupRecordIds]
            };
            for (List<sObject> lstObj : lstObjResults) {
              for (sObject objItr : lstObj) {
                mapRecordIdToName.put(
                  String.valueOf(objItr.get('Id')),
                  String.valueOf(objItr.get('Name'))
                );
              }
            }
          }
        }
        for (Address__c address : addressList1) {
          //If Address created or deleted
          if (address.Account_Type__c != Label.GTR_ACCOUT_TYPE_PROSPECT) {
            if (
              (operation == Label.GTR_OPERATION_TYPE_CREATED &&
              !address.Created_from_Lead_Conversion__c) ||
              operation == Label.GTR_OPERATION_TYPE_DELETED
            ) {
              listTrackHistory.add(
                new Track_History__c(
                  Object_Name__c = Label.GTR_OBJECT_NAME_BUSINESS_LOCATION,
                  Operation__c = operation,
                  Attribute_Name__c = '',
                  New_Value__c = '',
                  Previous_Value__c = '',
                  Operator_Name__c = UserInfo.getName(),
                  Record_Name__c = address.Business_Location_With_Address_Line__c,
                  Salesforce_Record_Id__c = address.Id,
                  Operation_Time__c = System.now(),
                  CVIF_Id__c = address.CVIF_Location_Id__c
                )
              );
            } else if (Trigger.isUpdate) {
              //If Address is updated
              if (allFields.keySet() != null && !allFields.isEmpty()) {
                for (Governance_Team_Fields__c fields : allFields.values()) {
                  if (
                    fields.Object_Name__c ==
                    Label.GTR_OBJECT_NAME_BUSINESS_LOCATION
                  ) {
                    if (
                      addressMap1.get(address.Id)
                        .get(fields.Field_API_Name__c) !=
                      addressMap2.get(address.Id).get(fields.Field_API_Name__c)
                    ) {
                      listTrackHistory.add(
                        new Track_History__c(
                          Object_Name__c = fields.Object_Name__c,
                          Operation__c = operation,
                          Attribute_Name__c = fields.Field_Label_Name__c,
                          New_Value__c = ((fields.Data_Type__c ==
                            Label.GTR_DATA_TYPE_LOOKUP ||
                            fields.Data_Type__c ==
                            Label.GTR_DATA_TYPE_LOOK_UP) &&
                            mapRecordIdToName.containsKey(
                              String.valueOf(
                                (addressMap1.get(address.Id))
                                  .get(fields.Field_API_Name__c)
                              )
                            ))
                            ? mapRecordIdToName.get(
                                String.valueOf(
                                  (addressMap1.get(address.Id))
                                    .get(fields.Field_API_Name__c)
                                )
                              )
                            : String.valueOf(
                                (addressMap1.get(address.Id))
                                  .get(fields.Field_API_Name__c)
                              ),
                          Previous_Value__c = ((fields.Data_Type__c ==
                            Label.GTR_DATA_TYPE_LOOKUP ||
                            fields.Data_Type__c ==
                            Label.GTR_DATA_TYPE_LOOK_UP) &&
                            mapRecordIdToName.containsKey(
                              String.valueOf(
                                (addressMap2.get(address.Id))
                                  .get(fields.Field_API_Name__c)
                              )
                            ))
                            ? mapRecordIdToName.get(
                                String.valueOf(
                                  (addressMap2.get(address.Id))
                                    .get(fields.Field_API_Name__c)
                                )
                              )
                            : String.valueOf(
                                (addressMap2.get(address.Id))
                                  .get(fields.Field_API_Name__c)
                              ),
                          Operator_Name__c = UserInfo.getName(),
                          Record_Name__c = String.valueOf(
                            (addressMap2.get(address.Id))
                              .get('Business_Location_With_Address_Line__c')
                          ),
                          Salesforce_Record_Id__c = address.Id,
                          Operation_Time__c = System.now(),
                          CVIF_Id__c = address.CVIF_Location_Id__c
                        )
                      );
                    }
                  }
                }
              }
            }
          }
        }

        if (listTrackHistory != null && !listTrackHistory.isEmpty()) {
          try {
            insert listTrackHistory;
          } catch (Exception objEx) {
            System.debug(
              'AddressTriggerHandler >> createTrackHistoryRecord ' +
              objEx.getMessage()
            );
          }
        }
      }
    }
  }

  private void stopAddressDeletion(Map<Id, Address__c> oldAddressMap) {
    for (Address__c addObj : oldAddressMap.values()) {
      if (!String.ISBLANK(addObj.CDM_Location_Id__c)) {
        addObj.addError(
          'Record is already synchroinzed with CDM. Please contact governance team for any edits to this record.'
        );
      }
    }
  }

  /*
   * Method Name: setOwnerBasedOnCountryMapping
   * Purpose: This method sets the owner of account based on the business location using custom setting CountryCodeMapping__c
   * Created By:  Nagarro(14th Aug, 2020)
   * Last Modified By: Nagarro(17th Aug, 2020)
   */
  private void setOwnerBasedOnCountryMapping(
    List<Address__c> newBusinessLocationList
  ) {
    Map<Id, Account> mapAccount;
    Set<Id> accountIdSet = new Set<Id>();
    String UserName;
    Map<String, String> accToUserNameMap = new Map<String, String>();
    Map<String, String> countryToAdminAssgnment = new Map<String, String>();

    for (
      CountryCodeMapping__c countryCodeMapObj : CountryCodeMapping__c.getAll()
        .values()
    ) {
      countryToAdminAssgnment.put(
        countryCodeMapObj.Country_Code__c,
        countryCodeMapObj.System_Admin_Assignment__c
      );
    }

    for (Address__c address : newBusinessLocationList) {
      accountIdSet.add(address.Account__c);
    }
    System.debug('accountIdSet--------------------' + accountIdSet);
    if (!accountIdSet.isEmpty()) {
      mapAccount = WithOutSharingUtility.queryforAccountOwnerChange(
        accountIdSet
      );
    }

    for (Address__c address : newBusinessLocationList) {
      if (
        mapAccount != null &&
        !mapAccount.isEmpty() &&
        mapAccount.get(address.Account__c).ParentId == null &&
        mapAccount.get(address.Account__c).Owner.Name != null &&
        mapAccount.get(address.Account__c).Owner.Name ==
        ConstantClass.Account_Owner_Name &&
        mapAccount.get(address.Account__c).Address__r.size() == 1
      ) {
        if (countryToAdminAssgnment.containsKey(address.Country__c)) {
          System.debug('username-------------' + username);
          accToUserNameMap.put(
            address.Account__c,
            countryToAdminAssgnment.get(address.Country__c)
          );
        }
      }
    }
    System.debug('accToUserNameMap----------------' + accToUserNameMap);
    map<String, Id> UserMap = new Map<String, Id>();
    for (
      User u : WithoutSharingUtility.getUsersByNames(accToUserNameMap.values())
    ) {
      UserMap.put(u.name, u.id);
    }

    List<Account> listOfAcc = new List<Account>();
    for (Account a : mapAccount.values()) {
      //String ownername = ;
      if (
        a.ParentId == null && UserMap.containsKey(accToUserNameMap.get(a.Id))
      ) {
        a.OwnerId = UserMap.get(accToUserNameMap.get(a.Id));
        listOfAcc.add(a);
      }
    }
    if (listOfAcc != null && !listOfAcc.isEmpty()) {
      TriggerHandler.bypass('AccountTriggerHandler');
      //AccountOwnerChangeHelper_V2.abortRunningJobsofOwnerChange();
      WithoutSharingUtility.updateAccounts(listOfAcc);
      //update listOfAcc ;
      TriggerHandler.clearBypass('AccountTriggerHandler');
    }
  }

  /*
   * Method Name: populateBusinessLocationText
   * Purpose: This method will populate the account Business_Location_Text on Business Location
   * Created By: Dhruv Raisinghani
   * Last Modified By:
   */

  private void populateBusinessLocationText(
    List<Address__c> businessLocationList,
    Map<Id, Address__c> oldAddressMap
  ) {
    if (businessLocationList != null) {
      for (Address__c add : businessLocationList) {
        if (
          Trigger.isInsert ||
          add.LocationType__c != oldAddressMap.get(add.Id).LocationType__c
        ) {
          if (add.LocationType__c != null) {
            add.Business_Location_Text__c = add.LocationType__c.replaceAll(
              ';',
              ','
            );
          } else {
            add.Business_Location_Text__c = '';
          }
        }
      }
    }
  }
  /*
   * Method Name: populateAccountType
   * Purpose: This method will populate the account type on Account_Type__c field of Business Location
   * Created By:
   * Last Modified By:
   */

  private void populateAccountType(List<Address__c> businessLocationList) {
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    Set<Id> accountIdSet = new Set<Id>();

    if (businessLocationList != null && !businessLocationList.isEmpty()) {
      for (Address__c address : businessLocationList) {
        accountIdSet.add(address.Account__c);
      }

      if (!accountIdSet.isEmpty()) {
        Map<Id, Account> mapTempAcc = new Map<Id, Account>(
          [SELECT Id, Type FROM Account WHERE Id IN :accountIdSet]
        );
        mapAccount = mapTempAcc;
      }

      for (Address__c address : businessLocationList) {
        if (
          address.Account__c != null &&
          mapAccount.containsKey(address.Account__c)
        ) {
          address.Account_Type__c = mapAccount.get(address.Account__c).Type;
        }
      }
    }
  }

  // Business location record cannot be deleted if
  //  -> contact is linked with it
  //  -> user profile is not Sales Manager or Sales Leader
  //  -> user is not the associated account's owner

  private void preventBusinessLocationDeletion(
    List<Address__c> oldBusinessLocationList
  ) {
    Set<Id> businessLocationIdSet = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    if (oldBusinessLocationList != null && !oldBusinessLocationList.isEmpty()) {
      for (Address__c address : oldBusinessLocationList) {
        businessLocationIdSet.add(address.Id);
        if (address.Account__c != null)
          accountIdSet.add(address.Account__c);
      }
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

    List<Contact> allConList = new List<Contact>();
    if (businessLocationIdSet != null && !businessLocationIdSet.isEmpty())
      allConList = [
        SELECT Id, Address__c
        FROM Contact
        WHERE Address__c IN :businessLocationIdSet
      ];

    Map<Id, integer> map_businessLocationId_ContactList = new Map<Id, integer>();
    if (allConList != null && !allConList.isEmpty()) {
      for (Contact con : allConList) {
        integer contactSize = map_businessLocationId_ContactList.get(
          con.Address__c
        );
        if (contactSize == null) {
          contactSize = 0;
        }
        contactSize++;
        map_businessLocationId_ContactList.put(con.Address__c, contactSize);
      }
    }

    List<Messaging.SingleEmailMessage> list_singleEmails = new List<Messaging.SingleEmailMessage>();
    List<String> sendTo = new List<String>();
    sendTo.addAll(GovernanceTeamEmail__c.getAll().keySet());
    EmailTemplate emailTemplate = [
      SELECT id
      FROM EmailTemplate
      WHERE name = 'Notification - Business Location Deleted'
      LIMIT 1
    ];

    Id profileId = UserInfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;

    Map<String, ProfileNames__c> profileNames = ProfileNames__c.getall();

    if (oldBusinessLocationList != null && !oldBusinessLocationList.isEmpty()) {
      for (Address__c add : oldBusinessLocationList) {
        String accOwner;
        if (map_Id_AccOwnerId.containsKey(add.Account__c))
          accOwner = map_Id_AccOwnerId.get(add.Account__c);
        integer countContact = 0;
        if (map_businessLocationId_ContactList.containsKey(add.Id))
          countContact = map_businessLocationId_ContactList.get(add.Id);

        if (countContact > 0) {
          add.addError(
            'Your attempt to delete ' +
            add.Address_Line_1__c +
            ' could not be completed because it has associated contact records. Kindly reassign them to some other business location or delete the contacts.'
          );
        }
        if (
          UserInfo.getUserId() != accOwner &&
          !profileNames.containsKey(profileName)
        ) {
          add.addError(
            'Your attempt to delete ' +
            add.Address_Line_1__c +
            ' could not be completed, please contact your manager.'
          );
        } else {
          if (
            emailTemplate != null &&
            !profileName.contains(Label.PROFILE_DATA_STEWARD) &&
            add.Account_Type__c != 'Prospect' &&
            !profileName.contains(Label.INTEGRATION_USER)
          ) {
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setWhatId(add.Id);
            singleEmail.setTemplateID(emailTemplate.Id);
            singleEmail.setToAddresses(sendTo);
            singleEmail.setTargetObjectId(UserInfo.getUserId());
            singleEmail.saveAsActivity = false;
            if (singleEmail != null) {
              list_singleEmails.add(singleEmail);
            }
          }
        }
      }
    }
    if (!list_singleEmails.isEmpty()) {
      try {
        //This method will create a record in the Track History object whenever an Address is deleted from SF.
        createTrackHistoryRecord(
          oldBusinessLocationList,
          oldAddressMap,
          new List<Address__c>(),
          new Map<Id, Address__c>(),
          Label.GTR_OPERATION_TYPE_DELETED
        );
        Messaging.sendEmail(list_singleEmails);
      } catch (Exception e) {
        System.debug('Exception has come@@@@@');
      }
    }
  }

  private void validatePhoneFormat(
    List<Address__c> addressList,
    Map<Id, Address__c> mapIdToAddress
  ) {
    for (Address__c objAddress : addressList) {
      if (
        objAddress.Phone__c != null || String.isNotBlank(objAddress.Phone__c)
      ) {
        if (
          Trigger.isInsert ||
          (mapIdToAddress != null &&
          objAddress.Phone__c != mapIdToAddress.get(objAddress.Id).Phone__c)
        ) {
          String phoneString = objAddress.Phone__c;
          if (
            String.isNotBlank(phoneString) && phoneString.containsAny('()-+')
          ) {
            phoneString = phoneString.replace('(', '');
            phoneString = phoneString.replace(')', '');
            phoneString = phoneString.replace('-', '');
            phoneString = phoneString.replace('+', '');
            if (
              !phoneString.isNumeric() ||
              phoneString.length() < 7 ||
              phoneString.length() > 15
            ) {
              objAddress.addError(
                'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Phone.'
              );
            } else {
              if (
                phoneString.length() == 10 ||
                (phoneString.length() == 11 && phoneString.startsWith('1'))
              ) {
                objAddress.Phone__c = phoneString;
              }
            }
          } else if (!phoneString.isNumeric()) {
            objAddress.addError(
              'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Phone.'
            );
          } else if (phoneString.length() < 7 || phoneString.length() > 15) {
            objAddress.addError(
              'Please enter 7 to 15 digits and also check that no alphabets or special characters were entered and no space is added in Phone.'
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: validateBusinessLocationDeactivation
   * Parameters :
   * List<Address__c> lstNewAddress  - This holds new address list.
   * Map<Id, Address__c> mapOldAddress - This holds old address map.
   * Returns : void
   * Purpose: This method check if contacts are associated with business and it is deactivating then show a validation message.
   * Last Modified By: Yogesh Pal (4th Feb 2020)
   * Modification: If BL has inactive contacts then BL can be deactivated with reason.
   */

  private void validateBusinessLocationDeactivation(
    List<Address__c> lstNewAddress,
    Map<Id, Address__c> mapOldAddress
  ) {
    Map<Id, Address__c> mapLocationMap = new Map<Id, Address__c>();
    Set<Id> setLocationId = new Set<Id>();
    String strBLDeactivationErrorMessage = Label.BL_DEACTIVATION_ERROR_MESSAGE;
    Business_Location_Validation_Constant__mdt objBusinessLocationValidationMetadata;
    Set<String> strProfilesToByPassValidation = new Set<String>();
    String currentUserProfileName;

    objBusinessLocationValidationMetadata = [
      SELECT
        Deactivate_Location_Validation_Flag__c,
        Bypass_Profile_for_Validation__c
      FROM Business_Location_Validation_Constant__mdt
      WHERE DeveloperName = 'Business_Location_Validation_Constant'
      LIMIT 1
    ];
    if (
      objBusinessLocationValidationMetadata.Deactivate_Location_Validation_Flag__c ==
      false
    ) {
      return;
    }
    for (
      String strProfileToBypass : objBusinessLocationValidationMetadata.Bypass_Profile_for_Validation__c.split(
        ConstantClass.STRING_SPLITTER_OPPORTUNITY_SPLIT_TRIGGER_HANDLER
      )
    ) {
      strProfilesToByPassValidation.add(strProfileToBypass);
    }
    for (Profile objProfile : [
      SELECT Id, Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ]) {
      currentUserProfileName = objProfile.Name;
    }
    if (strProfilesToByPassValidation.contains(currentUserProfileName)) {
      return;
    }
    for (Address__c objAddress : lstNewAddress) {
      setLocationId.add(objAddress.Id);
    }

    mapLocationMap = new Map<Id, Address__c>(
      [
        SELECT Id, (SELECT Id, Active__c FROM Contacts__r)
        FROM Address__c
        WHERE Id IN :setLocationId
      ]
    );

    for (Address__c objAddress : lstNewAddress) {
      if (
        objAddress.Active__c == false &&
        mapOldAddress != null &&
        mapOldAddress.containsKey(objAddress.Id) &&
        mapOldAddress.get(objAddress.Id).Active__c != objAddress.Active__c &&
        mapLocationMap.get(objAddress.Id).Contacts__r.size() > 0
      ) {
        for (
          Contact contactObj : mapLocationMap.get(objAddress.Id).Contacts__r
        ) {
          if (contactObj.Active__c) {
            //Check if BL has active contacts.
            objAddress.addError(strBLDeactivationErrorMessage);
          }
        }
      }
    }
  }
}
