public with sharing class CC_OriginDestinationCtrl {
  @AuraEnabled
  public static List<Location__c> fetchLocation(String recordId) {
    recordId = String.escapeSingleQuotes(recordId);
    List<Location__c> listLocation = new List<Location__c>();
    listLocation = LocationDAO.getLocationsByIds(new Set<Id>{ recordId });
    return listLocation;
  }

  @AuraEnabled
  public static List<Location__c> fetchSubLocation(
    String locCode,
    String locType
  ) {
    List<Location__c> listLocation = new List<Location__c>();
    String subLocType = '';
    if (locType == 'PORT') {
      subLocType = 'BERTH';
    }
    if (locType == 'RAIL RAMP') {
      subLocType = 'RAIL';
    }

    listLocation = LocationDAO.getSubLocationsByUNLocCode(locCode, subLocType);
    return listLocation;
  }

  @AuraEnabled
  public static List<Contract> fetchContractsList(String accountId) {
    List<Contract> listContract = new List<Contract>();
    List<Id> contractIds = getContractIds(new List<Id>{ accountId });
    if (contractIds != null && !contractIds.isEmpty()) {
      listContract = [
        SELECT Id, Name, ContractNumber, RegionTxt__c
        FROM Contract
        WHERE Id IN :contractIds
      ];
    }
    return listContract;
  }

  private static List<Id> getContractIds(List<Id> accountIds) {
    Set<Id> contractIds = new Set<Id>();
    List<Contract> contractRecords = new List<Contract>();
    List<Contract_Account__c> contractAccountRecords = new List<Contract_Account__c>();
    try {
      List<Account> accounts = [
        SELECT
          Id,
          (SELECT Id FROM Contracts),
          (SELECT Id, Contract__c FROM Contract_Accounts__r)
        FROM Account
        WHERE Id IN :accountIds
      ];
      if (accounts != null && !accounts.isEmpty()) {
        for (Account account : accounts) {
          contractRecords.addAll(account.Contracts);
          contractAccountRecords.addAll(account.Contract_Accounts__r);
        }
      }

      if (contractRecords != null && !contractRecords.isEmpty()) {
        for (Contract contract : contractRecords) {
          contractIds.add(contract.Id);
        }
      }

      if (contractRecords != null && !contractRecords.isEmpty()) {
        for (Contract_Account__c contractAccount : contractAccountRecords) {
          contractIds.add(contractAccount.Contract__c);
        }
      }
      List<Id> contractIdsList = new List<Id>(contractIds);
      return contractIdsList;
    } catch (Exception ex) {
      LogFactory.error(
        'CC_QuoteController',
        'getContractIds',
        'Account Detail Community',
        ex.getLineNumber() +
        ' ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      return null;
    }
  }

  @AuraEnabled
  public static List<Map<String, String>> getCommodities(String contractId) {
    List<Map<String, String>> listOpenTariffCommodities = new List<Map<String, String>>();
    if (contractId != null && contractId != '') {
      //List<Contract> listContract = [SELECT Id, Contracted_Commodities__c FROM Contract WHERE Id = :contractId];
      List<Contract> listContract = ContractDAO.getContract(contractId);
      if (
        listContract != null &&
        !listContract.isEmpty() &&
        listContract[0].Contracted_Commodities__c != null &&
        listContract[0].Contracted_Commodities__c != ''
      ) {
        String picklistValues = listContract[0].Contracted_Commodities__c;
        List<String> picklistValuesList = picklistValues.split(';');
        List<Map<String, String>> allTariffs = CC_SharedUtility.getPicklistValuesList(
          Contract.Contracted_Commodities__c.getDescribe()
        );
        for (Map<String, String> labelValue : allTariffs) {
          if (picklistValuesList.contains(labelValue.get('value'))) {
            listOpenTariffCommodities.add(
              new Map<String, String>{
                'Commodity_Code__c' => labelValue.get('value'),
                'Commodity_Name__c' => labelValue.get('label')
              }
            );
          }
        }
      }
    }
    return listOpenTariffCommodities;
  }

  @AuraEnabled
  public static List<Map<String, String>> getCommoditiesVehicle(
    String contractId
  ) {
    List<Map<String, String>> listVehicleCommodities = new List<Map<String, String>>();
    if (contractId != null && contractId != '') {
      //List<Contract> listContract = [SELECT Id, Contracted_Commodities_Vehicle__c FROM Contract WHERE Id = :contractId];
      List<Contract> listContract = ContractDAO.getContract(contractId);
      if (
        listContract != null &&
        !listContract.isEmpty() &&
        listContract[0].Contracted_Commodities_Vehicle__c != null &&
        listContract[0].Contracted_Commodities_Vehicle__c != ''
      ) {
        String picklistValues = listContract[0]
          .Contracted_Commodities_Vehicle__c;
        List<String> picklistValuesList = picklistValues.split(';');
        List<Map<String, String>> allVehCom = CC_SharedUtility.getPicklistValuesList(
          Contract.Contracted_Commodities_Vehicle__c.getDescribe()
        );
        for (Map<String, String> labelValue : allVehCom) {
          if (picklistValuesList.contains(labelValue.get('value'))) {
            listVehicleCommodities.add(
              new Map<String, String>{
                'Commodity_Code__c' => labelValue.get('value'),
                'Commodity_Name__c' => labelValue.get('label')
              }
            );
          }
        }
      }
    }
    return listVehicleCommodities;
  }

  @AuraEnabled
  public static List<Map<String, String>> getEquipments(String contractId) {
    List<Map<String, String>> listOpenTariffEquipments = new List<Map<String, String>>();
    if (contractId != null && contractId != '') {
      //List<Contract> listContract = [SELECT Id, Contracted_Commodities__c, Contracted_Equipments__c FROM Contract WHERE Id = :contractId];
      List<Contract> listContract = ContractDAO.getContract(contractId);
      if (
        listContract != null &&
        !listContract.isEmpty() &&
        listContract[0].Contracted_Equipments__c != null &&
        listContract[0].Contracted_Equipments__c != ''
      ) {
        String picklistValues = listContract[0].Contracted_Equipments__c;
        List<String> picklistValuesList = picklistValues.split(';');
        List<Map<String, String>> allTariffs = CC_SharedUtility.getPicklistValuesList(
          Contract.Contracted_Equipments__c.getDescribe()
        );
        for (Map<String, String> labelValue : allTariffs) {
          if (picklistValuesList.contains(labelValue.get('value'))) {
            listOpenTariffEquipments.add(
              new Map<String, String>{
                'Container_Code__c' => labelValue.get('value'),
                'Container_Name__c' => labelValue.get('label')
              }
            );
          }
        }
      }
    }
    return listOpenTariffEquipments;
  }

  @AuraEnabled
  public static List<Location__c> fetchOriginDestinationLocation(
    String bookingWrap,
    String locType
  ) {
    system.debug('bookingWrapper->' + bookingWrap);
    system.debug('locType->' + locType);
    CC_BookingWrapper bookingWrapObj = (CC_BookingWrapper) JSON.deserialize(
      bookingWrap,
      CC_BookingWrapper.class
    );
    String query = 'SELECT Id, Name,Location_Type__c, LcCode__c, Location_Name__c, Country_Name__c, Country_Code__c, City__c, State__c,RecordType.DeveloperName,ZipCode__c FROM Location__c';
    if (locType == 'origin') {
      if (
        String.isNotEmpty(bookingWrapObj.booking.Description__c) &&
        String.isNotBlank(bookingWrapObj.booking.Description__c)
      ) {
        if (bookingWrapObj.booking.Description__c.left(1) == 'P') {
          query = query + ' WHERE Location_Type__c=\'PORT\'';
          if (
            String.isNotBlank(bookingWrapObj.booking.Customer_Origin_Code__c) &&
            String.isNotEmpty(bookingWrapObj.booking.Customer_Origin_Code__c)
          ) {
            query =
              query +
              ' AND Name=\'' +
              bookingWrapObj.booking.Customer_Origin_Code__c +
              '\'';
          }
        } else if (bookingWrapObj.booking.Description__c.left(1) == 'R') {
          query = query + ' WHERE Location_Type__c=\'RAIL RAMP\'';
          if (
            String.isNotBlank(bookingWrapObj.booking.Customer_Origin_Code__c) &&
            String.isNotEmpty(bookingWrapObj.booking.Customer_Origin_Code__c)
          ) {
            query =
              query +
              ' AND Name=\'' +
              bookingWrapObj.booking.Customer_Origin_Code__c +
              '\'';
          }
        } else if (bookingWrapObj.booking.Description__c.left(1) == 'D') {
          query = query + ' WHERE Location_Type__c=\'DOOR\'';
          if (
            String.isNotBlank(bookingWrapObj.booking.Customer_Origin_Zip__c) &&
            String.isNotEmpty(bookingWrapObj.booking.Customer_Origin_Zip__c)
          ) {
            query =
              query +
              ' AND Name=\'' +
              bookingWrapObj.booking.Customer_Origin_Zip__c +
              '\'';
          }
          if (
            String.isNotEmpty(bookingWrapObj.booking.Customer_Origin_City__c) &&
            String.isNotBlank(bookingWrapObj.booking.Customer_Origin_City__c)
          ) {
            query =
              query +
              ' AND City__c=\'' +
              bookingWrapObj.booking.Customer_Origin_City__c +
              '\'';
          }
        }
      }
    } else if (locType == 'destination') {
      if (
        String.isNotEmpty(bookingWrapObj.booking.Description__c) &&
        String.isNotBlank(bookingWrapObj.booking.Description__c)
      ) {
        if (bookingWrapObj.booking.Description__c.right(1) == 'P') {
          query = query + ' WHERE Location_Type__c=\'PORT\'';
          if (
            String.isNotBlank(
              bookingWrapObj.booking.Customer_Destination_Code__c
            ) &&
            String.isNotEmpty(
              bookingWrapObj.booking.Customer_Destination_Code__c
            )
          ) {
            query =
              query +
              ' AND Name=\'' +
              bookingWrapObj.booking.Customer_Destination_Code__c +
              '\'';
          }
        } else if (bookingWrapObj.booking.Description__c.right(1) == 'R') {
          query = query + ' WHERE Location_Type__c=\'RAIL RAMP\'';
          if (
            String.isNotBlank(
              bookingWrapObj.booking.Customer_Destination_Code__c
            ) &&
            String.isNotEmpty(
              bookingWrapObj.booking.Customer_Destination_Code__c
            )
          ) {
            query =
              query +
              ' AND Name=\'' +
              bookingWrapObj.booking.Customer_Destination_Code__c +
              '\'';
          }
        } else if (bookingWrapObj.booking.Description__c.right(1) == 'D') {
          query = query + ' WHERE Location_Type__c=\'DOOR\'';
          if (
            String.isNotBlank(
              bookingWrapObj.booking.Customer_Destination_Zip__c
            ) &&
            String.isNotEmpty(
              bookingWrapObj.booking.Customer_Destination_Zip__c
            )
          ) {
            query =
              query +
              ' AND Name=\'' +
              bookingWrapObj.booking.Customer_Destination_Zip__c +
              '\'';
          }
          if (
            String.isNotEmpty(
              bookingWrapObj.booking.Customer_Destination_City__c
            ) &&
            String.isNotBlank(
              bookingWrapObj.booking.Customer_Destination_City__c
            )
          ) {
            query =
              query +
              ' AND City__c=\'' +
              bookingWrapObj.booking.Customer_Destination_City__c +
              '\'';
          }
        }
      }
    }
    System.debug('query->' + query);
    return LocationDAO.getLocationByTypeAndCity(query);
  }

  @AuraEnabled
  public static Account fetchAccountDetails(String accountId) {
    return AccountDAO.getAccountByAccountId(accountId);
  }

  @AuraEnabled
  public static Contact fetchContactDetails(String contactId) {
    return CC_WithoutSharingUtility.fetchContactDetailsById(
      new Set<Id>{ contactId }
    )[0];
  }

  @AuraEnabled
  public static Address__c fetchAddressDetails(String addressId) {
    return [
      SELECT
        Id,
        Name,
        Address__c,
        Address_Line_2__c,
        City__c,
        Country__c,
        State_Picklist__c,
        Postal_Code__c,
        LocationCode__c
      FROM Address__c
      WHERE Id = :addressId
    ][0];
  }
  @AuraEnabled
  public static Map<Id, Account> fetchAccountDetailsByIds(
    List<String> accountIds
  ) {
    Set<Id> accIds = new Set<Id>();
    for (String accountId : accountIds) {
      accIds.add(accountId);
    }
    return new Map<Id, Account>(
      AccountDAO.getAccountDetailsByAccountIds(accIds)
    );
  }
  @AuraEnabled
  public static Map<Id, Contact> fetchContactDetailsByIds(
    List<String> contactIds
  ) {
    Set<Id> conIds = new Set<Id>();
    for (String contactId : contactIds) {
      conIds.add(contactId);
    }
    return new Map<Id, Contact>(
      CC_WithoutSharingUtility.fetchContactDetailsById(conIds)
    );
  }
  @AuraEnabled
  public static Map<Id, Address__c> fetchAddressDetailsByIds(
    List<String> addressIds
  ) {
    Set<Id> addIds = new Set<Id>();
    for (String addressId : addressIds) {
      addIds.add(addressId);
    }
    return new Map<Id, Address__c>(
      [
        SELECT
          Id,
          Name,
          Address__c,
          Address_Line_2__c,
          City__c,
          Country__c,
          State_Picklist__c,
          Postal_Code__c,
          LocationCode__c
        FROM Address__c
        WHERE Id IN :addIds
      ]
    );
  }
}
