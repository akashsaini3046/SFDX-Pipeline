public without sharing class CC_CustomLookupCtrl {
  @AuraEnabled
  public static List<Account> fetchAccounts(String searchKeyWord) {
    List<Account> listAccount = new List<Account>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Account> listAccounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    for (Account AccountRecord : listAccounts) {
      listAccount.add(AccountRecord);
    }
    return listAccount;
  }
  @AuraEnabled
  public static List<Account> fetchParentAccounts(String searchKeyWord) {
    List<Account> listAccount = new List<Account>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Account> listAccounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name LIKE :searchKey AND Primary_Account__c = TRUE
      ORDER BY NAME
      LIMIT 5
    ];
    for (Account AccountRecord : listAccounts) {
      listAccount.add(AccountRecord);
    }
    return listAccount;
  }

  @AuraEnabled
  public static List<Contact> fetchContacts(String searchKeyWord) {
    List<Contact> listContact = new List<Contact>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Contact> listContacts = [
      SELECT Id, Name
      FROM Contact
      WHERE Name LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    for (Contact ContactRecord : listContacts) {
      listContact.add(ContactRecord);
    }
    return listContact;
  }

  @AuraEnabled
  public static List<Contract> getContracts(String searchKeyWord) {
    List<Contract> listContract = new List<Contract>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Contract> listContracts = [
      SELECT Id, Name, Softship_Contract_Number__c
      FROM Contract
      WHERE Softship_Contract_Number__c LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    for (Contract ContractRecord : listContracts) {
      listContract.add(ContractRecord);
    }
    return listContract;
  }

  @AuraEnabled
  public static List<Account> fetchAccountsBooking(String searchKeyWord) {
    List<Account> listAccount = new List<Account>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Account> listAccounts = [
      SELECT Id, Name, ParentId
      FROM Account
      WHERE Name LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    for (Account AccountRecord : listAccounts) {
      listAccount.add(AccountRecord);
    }
    return listAccount;
  }

  @AuraEnabled
  public static List<Contract> fetchContractsBooking(
    String searchKeyWord,
    Id accountId
  ) {
    List<Contract> listContract = new List<Contract>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Contract> listContracts = [
      SELECT Id, Name
      FROM Contract
      WHERE Name LIKE :searchKey AND AccountId = :accountId
      ORDER BY NAME
      LIMIT 5
    ];
    for (Contract ContractRecord : listContracts) {
      listContract.add(ContractRecord);
    }
    return listContract;
  }

  @AuraEnabled
  public static List<Location__c> fetchDoorOrPort(
    String searchKeyWord,
    String originOrDestination
  ) {
    List<Location__c> listLocation = new List<Location__c>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    Id recTypeId;
    String type;
    if (originOrDestination.containsIgnoreCase('D')) {
      recTypeId = CC_SharedUtility.getRecordTypeId('Location__c:ZipCode');
      type = CC_Constants.DOOR_STRING.toUpperCase();
    }
    if (originOrDestination.containsIgnoreCase('P')) {
      recTypeId = CC_SharedUtility.getRecordTypeId('Location__c:Location');
      type = CC_Constants.PORT_STRING.toUpperCase();
    }
    if (originOrDestination.containsIgnoreCase('R')) {
      recTypeId = CC_SharedUtility.getRecordTypeId('Location__c:Location');
      type = CC_Constants.RAIL_RAMP_STRING.toUpperCase();
    }
    listLocation = [
      SELECT
        Id,
        Name,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c
      FROM Location__c
      WHERE
        RecordTypeId = :recTypeId
        AND Location_Type__c = :type
        AND (Name LIKE :searchKey
        OR City__c LIKE :searchKey)
      LIMIT 8
    ];
    return listLocation;
  }

  @AuraEnabled
  public static List<Location__c> fetchOriginDestination(String searchKeyWord) {
    List<Location__c> listLocation = new List<Location__c>();
    String searchKey = '%' + searchKeyWord.toUpperCase() + '%';
    system.debug('--->>' + searchKey);
    listLocation = [
      SELECT
        Id,
        Name,
        Location_Type__c,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c,
        RecordType.DeveloperName
      FROM Location__c
      WHERE
        RecordType.DeveloperName IN ('Zipcode', 'Location')
        AND Location_Type__c != 'CITY'
        AND (Name LIKE :searchKey
        OR City__c LIKE :searchKey
        OR Location_Name__c LIKE :searchKey)
      ORDER BY
        RecordType.DeveloperName,
        Location_Type__c,
        Location_Name__c,
        Name ASC
      LIMIT 100
    ];
    return listLocation;
  }

  @AuraEnabled
  public static List<Location__c> fetchLoadPortDestinationPort(
    String searchKeyWord
  ) {
    List<Location__c> listLocation = new List<Location__c>();
    String searchKey = '%' + searchKeyWord.toUpperCase() + '%';
    system.debug('--->>' + searchKey);
    listLocation = [
      SELECT
        Id,
        Name,
        Location_Type__c,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c,
        RecordType.DeveloperName
      FROM Location__c
      WHERE
        RecordType.DeveloperName IN ('Location')
        AND Location_Type__c = 'PORT'
        AND (Name LIKE :searchKey
        OR City__c LIKE :searchKey
        OR Location_Name__c LIKE :searchKey)
      ORDER BY Location_Name__c, Name ASC
      LIMIT 100
    ];
    return listLocation;
  }

  @AuraEnabled
  public static List<Location__c> fetchBOLLocation(String searchKeyWord) {
    List<Location__c> listLocation = new List<Location__c>();
    String searchKey = '%' + searchKeyWord.toUpperCase() + '%';
    system.debug('--->>' + searchKey);
    listLocation = [
      SELECT
        Id,
        Name,
        Location_Type__c,
        LcCode__c,
        Location_Name__c,
        Country_Name__c,
        Country_Code__c,
        City__c,
        State__c,
        RecordType.DeveloperName
      FROM Location__c
      WHERE
        RecordType.DeveloperName IN ('Zipcode', 'Location')
        AND (Name LIKE :searchKey
        OR City__c LIKE :searchKey
        OR Location_Name__c LIKE :searchKey)
      ORDER BY
        RecordType.DeveloperName,
        Location_Type__c,
        Location_Name__c,
        Name ASC
      LIMIT 5
    ];
    return listLocation;
  }

  @AuraEnabled
  public static List<Vessel_Flag__c> fetchVesselName(String searchKeyWord) {
    List<Vessel_Flag__c> listVesselFlag = new List<Vessel_Flag__c>();
    String searchKey = '%' + searchKeyWord.toUpperCase() + '%';
    system.debug('--->>' + searchKey);
    listVesselFlag = [
      SELECT Id, Name, Flag__c
      FROM Vessel_Flag__c
      WHERE Name LIKE :searchKey
      ORDER BY Name ASC
      LIMIT 5
    ];
    return listVesselFlag;
  }

  @AuraEnabled
  public static List<Container__c> getContainer(String searchKeyWord) {
    List<Container__c> listContainer = new List<Container__c>();
    String searchKey = '%' + searchKeyWord.toUpperCase() + '%';
    listContainer = [
      SELECT Name, CICS_ISO_Code__c, Description__c
      FROM Container__c
      WHERE Description__c LIKE :searchKey
      ORDER BY Description__c ASC
    ];
    return listContainer;
  }

  @AuraEnabled
  public static List<Account> fetchBOLAccounts(String searchKeyWord) {
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Account> listAccounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    return listAccounts;
  }

  @AuraEnabled
  public static List<Booking__c> fetchBOLBookings(String searchKeyWord) {
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Booking__c> listBookings = [
      SELECT Id, Name, Booking_Number__c
      FROM Booking__c
      WHERE Booking_Number__c LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    return listBookings;
  }

  @AuraEnabled
  public static List<User> fetchBOLCreatedByUsers(String searchKeyWord) {
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<User> listUsers = [
      SELECT Id, Full_Name__c
      FROM User
      WHERE Full_Name__c LIKE :searchKey
      ORDER BY Full_Name__c
      LIMIT 5
    ];
    return listUsers;
  }

  @AuraEnabled
  public static List<Account> fetchAccountsCombo(String searchKeyWord) {
    List<Account> listAccount = new List<Account>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Account> listAccounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    for (Account accountRecord : listAccounts) {
      listAccount.add(accountRecord);
    }
    return listAccount;
  }
  @AuraEnabled
  public static List<Address__c> fetchAddressesCombo(
    String searchKeyWord,
    Id accountId
  ) {
    List<Address__c> listAddresses = new List<Address__c>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Address__c> listAddress = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name LIKE :searchKey AND Account__c = :accountId
      ORDER BY NAME
      LIMIT 5
    ];
    for (Address__c addressRecord : listAddress) {
      listAddresses.add(addressRecord);
    }
    return listAddresses;
  }
  @AuraEnabled
  public static List<Contact> fetchContactsCombo(
    String searchKeyWord,
    Id accountId
  ) {
    List<Contact> listContact = new List<Contact>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Contact> listContacts = [
      SELECT Id, Name
      FROM Contact
      WHERE Name LIKE :searchKey AND AccountId = :accountId
      ORDER BY NAME
      LIMIT 5
    ];
    for (Contact contactRecord : listContacts) {
      listContact.add(contactRecord);
    }
    return listContact;
  }
  @AuraEnabled
  public static List<Address__c> fetchBusinessLocations(String searchKeyWord) {
    List<Address__c> listAddresses = new List<Address__c>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Address__c> listAddress = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name LIKE :searchKey
      ORDER BY NAME
      LIMIT 5
    ];
    for (Address__c addressRecord : listAddress) {
      listAddresses.add(addressRecord);
    }
    return listAddresses;
  }
  @AuraEnabled
  public static List<Address__c> fetchBusinessLocationsByAccount(
    String searchKeyWord,
    Id accountId
  ) {
    List<Address__c> listAddresses = new List<Address__c>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Address__c> listAddress = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name LIKE :searchKey AND Account__c = :accountId
      ORDER BY NAME
      LIMIT 5
    ];
    for (Address__c addressRecord : listAddress) {
      listAddresses.add(addressRecord);
    }
    return listAddresses;
  }
  @AuraEnabled
  public static List<Contact> fetchContactsByAccount(
    String searchKeyWord,
    Id accountId
  ) {
    List<Contact> listContact = new List<Contact>();
    String searchKey = '' + searchKeyWord.toUpperCase() + '%';
    List<Contact> listContacts = [
      SELECT Id, Name
      FROM Contact
      WHERE Name LIKE :searchKey AND AccountId = :accountId
      ORDER BY NAME
      LIMIT 5
    ];
    for (Contact contactRecord : listContacts) {
      listContact.add(contactRecord);
    }
    return listContact;
  }

  @AuraEnabled
  public static List<HTS_Master__c> fetchHts(String searchKeyWord) {
    List<HTS_Master__c> lstHTSNumber = new List<HTS_Master__c>();
    String searchKey = '%' + searchKeyWord + '%';
    lstHTSNumber = [
      SELECT Id, Name, Type__c, Description__c
      FROM HTS_Master__c
      WHERE Name LIKE :searchKey OR Description__c LIKE :searchKey
      LIMIT 5
    ];
    return lstHTSNumber;
  }

  @AuraEnabled
  public static List<User> fetchUsers(String searchKeyWord) {
    List<User> users = new List<User>();
    String searchKey = '%' + searchKeyWord + '%';
    users = [
      SELECT Id, Name, Full_Name__c
      FROM User
      WHERE Name LIKE :searchKey
      LIMIT 5
    ];
    return users;
  }
}
