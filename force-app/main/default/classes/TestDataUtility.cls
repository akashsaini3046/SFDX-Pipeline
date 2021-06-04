/*
 * Name: TestDataUtility
 * Purpose: Utility class to create test data
 * Author: Nagarro
 * Created Date: 15-May-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class TestDataUtility {
  /*
   * Method Name: GovernanceTeamEmail
   * Return value: GovernanceTeamEmail__c
   * Purpose: This method creates GovernanceTeamEmail and returns the created GovernanceTeamEmail.
   */
  public static GovernanceTeamEmail__c GovernanceTeamEmail() {
    GovernanceTeamEmail__c govEmail = new GovernanceTeamEmail__c();
    govEmail.Name = 'test@test.com';
    return govEmail;
  }

  /*
   * Method Name: GovernanceTeamFields
   * Input Fields:
   * Name : Name of GovernanceTeamFields
   * FieldLabel : FieldLabel name of GovernanceTeamFields
   * FieldAPI : FieldAPIname of GovernanceTeamFields
   * ObjectName : ObjectName of GovernanceTeamFields
   * Datatype : Datatype of GovernanceTeamFields
   * LookupRelation : LookupRelation of GovernanceTeamFields
   * Return value: Governance_Team_Fields__c
   * Purpose: This method creates GovernanceTeamFields and returns the created GovernanceTeamFields.
   */
  public static Governance_Team_Fields__c GovernanceTeamFields(
    String Name,
    String FieldLabel,
    String FieldAPI,
    String ObjectName,
    String Datatype,
    String LookupRelation
  ) {
    Governance_Team_Fields__c objGTF = new Governance_Team_Fields__c();
    objGTF.name = Name;
    objGTF.Field_Label_Name__c = FieldLabel;
    objGTF.Field_API_Name__c = FieldAPI;
    objGTF.Object_Name__c = ObjectName;
    objGTF.Data_Type__c = Datatype;
    objGTF.Lookup_Relationship_With__c = LookupRelation;
    return objGTF;
  }
  /*
   * Method Name: CDMTeamEmailAddresses
   * Return value: CDM_Team_Email_Addresses__c
   * Purpose: This method creates CDMTeamEmailAddresses and returns the created CDMTeamEmailAddresses.
   */
  public static CDM_Team_Email_Addresses__c CDMTeamEmailAddresses() {
    CDM_Team_Email_Addresses__c objCDMTeamEmailAddress = new CDM_Team_Email_Addresses__c();
    objCDMTeamEmailAddress.Name = 'prateek.goel@nagarro.com.invalid';
    return objCDMTeamEmailAddress;
  }
  /*
   * Method Name: createDestinationEmailList
   * Input Fields:
   * country : country of Destination Team Email
   * region : region name of Destination Team Email
   * intNumOfEmails : Number of Destination Team Emails
   * Return value: List<Destination_Team_Email__c>
   * Purpose: This method creates Destination Team Email List and returns the created List of Destination Team Email.
   */
  public static List<Destination_Team_Email__c> createDestinationEmailList(
    string country,
    string region,
    integer intNumOfEmails
  ) {
    List<Destination_Team_Email__c> destEmails = new List<Destination_Team_Email__c>();
    for (integer i = 0; i < intNumOfEmails; i++) {
      destEmails.add(
        new Destination_Team_Email__c(
          Name = i + '',
          Country__c = country,
          Is_Hacienda_Destination__c = true,
          Email__c = 'test' + i + '@abc.com',
          Region__c = region
        )
      );
    }
    return destEmails;
  }
  /*
   * Method Name: ProfileNames
   * Return value: List<ProfileNames__c>
   * Purpose: This method creates ProfileNames and returns the created List of ProfileNames.
   */

  public static List<ProfileNames__c> ProfileNames() {
    List<ProfileNames__c> Profiles = new List<ProfileNames__c>();

    ProfileNames__c p1 = new ProfileNames__c();
    p1.Name = 'Sales Leader';
    Profiles.add(p1);

    ProfileNames__c p2 = new ProfileNames__c();
    p2.Name = 'System Administrator';
    Profiles.add(p2);

    ProfileNames__c p3 = new ProfileNames__c();
    p3.Name = 'Data Steward';
    Profiles.add(p3);

    return Profiles;
  }
  /*
   * Method Name: ProfilesHavingCheckboxAccess
   * Return value: ProfilesHavingCheckboxAccess__c
   * Purpose: This method creates ProfilesHavingCheckboxAccess and returns the created ProfilesHavingCheckboxAccess.
   */
  public static ProfilesHavingCheckboxAccess__c ProfilesHavingCheckboxAccess() {
    ProfilesHavingCheckboxAccess__c obj1 = new ProfilesHavingCheckboxAccess__c();
    obj1.Name = 'System Administrator';
    return obj1;
  }

  public static void ProfiletoGroupMap() {
  }
  /*
   * Method Name: CountryRegionMapping
   * Return value: CountryRegionMapping__c
   * Purpose: This method creates CountryRegionMapping and returns the created CountryRegionMapping.
   */
  public static CountryRegionMapping__c CountryRegionMapping() {
    CountryRegionMapping__c crm = new CountryRegionMapping__c();
    crm.Name = '1';
    crm.Country_Name__c = 'Anguilla';
    crm.Region__c = 'Caribbean';
    return crm;
  }
  /*
   * Method Name: ServicesSubservices
   * Return value: List<Services_Subservices__c>
   * Purpose: This method creates ServicesSubservices and returns the created list of ServicesSubservices.
   */
  public static List<Services_Subservices__c> ServicesSubservices() {
    List<Services_Subservices__c> serviceSubserviceList = new List<Services_Subservices__c>();

    Services_Subservices__c subServiceobj = new Services_Subservices__c();
    subServiceobj.Port_Required__c = true;
    subServiceobj.Sub_service_present__c = true;
    subServiceobj.Name = 'Air';
    serviceSubserviceList.add(subServiceobj);
    subServiceobj = new Services_Subservices__c();
    subServiceobj.Port_Required__c = true;
    subServiceobj.Sub_service_present__c = true;
    subServiceobj.Name = 'LCL';
    serviceSubserviceList.add(subServiceobj);
    subServiceobj = new Services_Subservices__c();
    subServiceobj.Port_Required__c = true;
    subServiceobj.Sub_service_present__c = true;
    subServiceobj.Name = 'FCL';
    serviceSubserviceList.add(subServiceobj);
    //insert serviceSubserviceList;
    return serviceSubserviceList;
  }
  /*
   * Method Name: UserRegiontoOppRole
   * Return value: List<User_Region_to_Opp_Role__c>
   * Purpose: This method creates UserRegiontoOppRole and returns the created list of UserRegiontoOppRole.
   */
  public static List<User_Region_to_Opp_Role__c> UserRegiontoOppRole() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = new List<User_Region_to_Opp_Role__c>();

    User_Region_to_Opp_Role__c urr1 = new User_Region_to_Opp_Role__c();
    urr1.Name = 'CAM - Central America';
    urr1.Opp_Role__c = 'CAM - Sales Rep';
    UserRegionRole.add(urr1);
    //insert UserRegionRole;

    User_Region_to_Opp_Role__c urr2 = new User_Region_to_Opp_Role__c();
    urr2.Name = 'PRT - Puerto Rico';
    urr2.Opp_Role__c = 'PRT - Sales Rep';
    UserRegionRole.add(urr2);
    //insert UserRegionRole;

    User_Region_to_Opp_Role__c urr3 = new User_Region_to_Opp_Role__c();
    urr3.Name = 'CAR - Caribbean';
    urr3.Opp_Role__c = 'CAR - Sales Rep';
    UserRegionRole.add(urr3);
    //insert UserRegionRole;

    User_Region_to_Opp_Role__c urr4 = new User_Region_to_Opp_Role__c();
    urr4.Name = 'TRK - Trucking Team';
    urr4.Opp_Role__c = 'TRK - Sales Rep';
    UserRegionRole.add(urr4);
    // insert UserRegionRole;

    User_Region_to_Opp_Role__c urr5 = new User_Region_to_Opp_Role__c();
    urr5.Name = 'USA - United States';
    urr5.Opp_Role__c = 'USA - Sales Rep';
    UserRegionRole.add(urr5);

    //insert UserRegionRole;
    return UserRegionRole;

    /* Access_Level_MM_SA__c accessLevels = new Access_Level_MM_SA__c();
accessLevels.MM_Account_Level__c ='Edit';
accessLevels.MM_Opp_Level__c ='Edit';
accessLevels.MM_Case_Level__c='None';
accessLevels.SA_Account_Level__c='Read';
accessLevels.SA_Opp_Level__c='None';
accessLevels.SA_Case_Level__c='None';        
insert accessLevels;*/
  }

  /*
   * Method Name: createAccount
   * Input Parameters:
   * String strAccountName: This holds account name.
   * String strType : this holds Account type.
   * String strIndustry : This holds industry name.
   * Id idParent : This holds parent account id.
   * Boolean boolCreatedFromLeadConversion : Specifies whether account has been created by lead conversion.
   * Integer intNumberOfAccounts : This holds number of accounts to be created.
   * Return value: List<Account>
   * Purpose: This method creates accounts as per parameters provided and returns the created accounts list.
   */
  public static List<Account> createAccount(
    String strAccountName,
    String strType,
    String strIndustry,
    Id idParent,
    Boolean boolCreatedFromLeadConversion,
    Integer intNumberOfAccounts
  ) {
    List<Account> listTestAccount = new List<Account>();
    for (Integer intIndex = 0; intIndex < intNumberOfAccounts; intIndex++) {
      Account objAccount = new Account();
      objAccount.name = (intIndex == 0
        ? strAccountName
        : strAccountName + intIndex);
      objAccount.Industry = strIndustry;
      objAccount.ParentId = idParent;
      objAccount.Created_From_Lead_Conversion__c = boolCreatedFromLeadConversion;
      objAccount.Type = strType;
      objAccount.Address_Line_1__c = 'Address_Line 1';
      objAccount.City__c = 'City';
      objAccount.Country__c = 'AF';
      objAccount.Phone = '-123456789(01)';
      listTestAccount.add(objAccount);
    }
    return listTestAccount;
  }

  /*
   * Method Name: createAccountforApprovalProcess
   * Input Parameters:
   * String strAccountName: This holds account name.
   * Id idOwner : This holds owner id.
   * Id idProposedOwner : This holds proposed owner id.
   * String strApprovalProccessAction : This holds approval process action.
   * Integer intNumberOfAccounts : This holds number of accounts to be created.
   * Return value: List<Account>
   * Purpose: This overloaded method creates accounts as per parameters provided and returns the created accounts list.
   */
  public static List<Account> createAccountforApprovalProcess(
    String strAccountName,
    Id idOwner,
    Id idProposedOwner,
    String strApprovalProccessAction,
    Integer intNumberOfAccounts
  ) {
    List<Account> listTestAccount = new List<Account>();
    for (Integer intIndex = 0; intIndex < intNumberOfAccounts; intIndex++) {
      Account objAccount = new Account();
      objAccount.name = (intIndex == 0
        ? strAccountName
        : strAccountName + intIndex);
      objAccount.OwnerId = (idOwner != null ? idOwner : UserInfo.getUserId());
      objAccount.Phone = '-123456789(0)';
      objAccount.Address_Line_1__c = 'Address_Line 1';
      objAccount.City__c = 'City';
      objAccount.Country__c = 'AF';
      objAccount.userWhoProposedNewOwner__c = idOwner;
      objAccount.Proposed_Account_Owner__c = idProposedOwner;
      objAccount.Transfer_Closed_Opportunities__c = true;
      objAccount.Transfer_Not_Owned_Opportunities__c = true;
      objAccount.Transfer_Open_Cases__c = true;
      objAccount.Transfer_Closed_Cases__c = true;
      objAccount.Keep_Account_Team__c = true;
      objAccount.Keep_Opportunity_Team__c = true;
      objAccount.Approval_Process_Action__c = strApprovalProccessAction;
      objAccount.TimeofStep1Approval__c = System.now();
      objAccount.TimeofStep2Approval__c = System.now() + 1;
      objAccount.TimeofStep3Approval__c = null;
      listTestAccount.add(objAccount);
    }
    return listTestAccount;
  }

  /*
   * Method Name: createBusinessLocation
   * Input Parameters:
   * List<Account> listAccounts: This holds accounts.
   * String strBlName : This holds business location name.
   * String strCity : This holds business location city.
   * String strState : This holds business location state.
   * String strPostalCode : This holds business location postal code.
   * String strPhone : This holds phone number.
   * String strCountry : This holds business location country.
   * Integer intNumberOfAccounts : This holds number of BL to be created.
   * Return value: List<Address__c>
   * Purpose: This method creates Business location as per parameters provided and returns the created BL list.
   */
  public static List<Address__c> createBusinessLocation(
    List<Account> listAccounts,
    String strBlName,
    String strCity,
    String strState,
    String strPostalCode,
    String strPhone,
    String strCountry,
    Integer intNumberOfBusinessLocations
  ) {
    List<Address__c> listTestAddress = new List<Address__c>();
    for (Account objAccount : listAccounts) {
      System.debug('TestDataUtility = ');
      System.debug('objAccount = ' + objAccount);
      System.debug('objAccount.Id = ' + objAccount.Id);
      System.debug('objAccount.Name = ' + objAccount.Name);
      for (
        Integer intIndex = 0;
        intIndex < intNumberOfBusinessLocations;
        intIndex++
      ) {
        Address__c objAddress = new Address__c();
        objAddress.Account__c = objAccount.Id;
        objAddress.Name = (intIndex == 0 ? strBlName : strBlName + intIndex);
        objAddress.City__c = strCity;
        objAddress.State_Picklist__c = strState;
        objAddress.Postal_Code__c = strPostalCode;
        objAddress.Country__c = strCountry;
        objAddress.Phone__c = strPhone;
        listTestAddress.add(objAddress);
      }
    }
    return listTestAddress;
  }

  /*
   * Method Name: createContact
   * Input Parameters:
   * Id idRecordType : This holds record type id.
   * Id idAccount : This holds account id.
   * List<Address__c> listBusinessLocations: This holds business locations.
   * String strFirstName : This holds contact first name.
   * String strLastName : This holds contact last name.
   * String strEmail : This holds contact email.
   * String strPhone : This holds phone number.
   * Boolean boolContactCreatedFromLead : Specifies whether contact has been created by lead conversion.
   * Id IdOwner : This holds contact owner id.
   * Integer intNumberOfContacts : This holds number of contacts to be created.
   * Return value: List<Contact>
   * Purpose: This method creates Contact as per parameters provided and returns the created Contact list.
   */
  public static List<Contact> createContact(
    Id idRecordType,
    List<Account> listAccounts,
    List<Address__c> listBusinessLocations,
    String strFirstName,
    String strLastName,
    String strEmail,
    String strPhone,
    Boolean boolContactCreatedFromLead,
    Id IdOwner,
    Integer intNumberOfContacts
  ) {
    List<Contact> listTestContact = new List<Contact>();
    for (Account objAccount : listAccounts) {
      for (Address__c objAddress : listBusinessLocations) {
        for (Integer intIndex = 0; intIndex < intNumberOfContacts; intIndex++) {
          Contact objContact = new Contact();
          objContact.Address__c = objAddress.Id;
          objContact.FirstName = (intIndex == 0
            ? strFirstName
            : strFirstName + intIndex);
          objContact.LastName = strLastName;
          objContact.Email = strEmail;
          objContact.Title = 'testTitle';
          objContact.MailingCountry = null;
          objContact.Phone = '-123456789(01)';
          objContact.MobilePhone = '-123456789(01)';
          objContact.Locations_Served__c = 'UNITED STATES';
          objContact.Contact_Created_From_Lead__c = boolContactCreatedFromLead;
          if (idRecordType != null) {
            objContact.RecordTypeId = idRecordType;
          }
          if (IdOwner != null) {
            objContact.OwnerId = IdOwner;
          }
          objContact.AccountId = objAccount.Id;
          listTestContact.add(objContact);
        }
      }
    }
    return listTestContact;
  }

  /*
   * Method Name: createOpportunity
   * Input Parameters:
   * Id idRecordType: This holds Opportunity recordType.
   * String strOppName : This holds Opportunity name.
   * Contact objContact : This holds contact to be associated with opportunity.
   * Account objAccount : This holds account to be associated with opportunity.
   * String strStageName : This holds opportunity stage name.
   * String strRegion : This holds opportunity region.
   * Date dateClose : This holds opportunity close date.
   * String strServiceType : This holds opportunity service types.
   * String strPricingTeamEmailPicklist : This holds pricing team email picklist.
   * Boolean boolCreatedFromLeadConversion : This specifies whether opportunity is created from lead conversion or not.
   * Integer intNumberOfOpportunities : This holds number of opportunities to be created.
   * Return value: List<Opportunity>
   * Purpose: This method creates Opportunities as per parameters provided and returns the created Opportunities list.
   */
  public static List<Opportunity> createOpportunity(
    Id idRecordType,
    Id idOwner,
    String strOppName,
    List<Contact> listContacts,
    List<Account> listAccounts,
    String strStageName,
    String strRegion,
    Date dateClose,
    Date dateProposalSubmission,
    String strServiceType,
    String strPricingTeamEmailPicklist,
    Boolean boolCreatedFromLeadConversion,
    Integer intNumberOfOpportunities
  ) {
    List<Opportunity> listTestOpportunity = new List<Opportunity>();
    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;
    for (Account objAccount : listAccounts) {
      for (Contact objContact : listContacts) {
        for (
          Integer intIndex = 0; intIndex < intNumberOfOpportunities; intIndex++
        ) {
          Opportunity objOpportunity = new Opportunity();
          if (idRecordType != null) {
            objOpportunity.RecordTypeId = idRecordType;
          }
          if (objContact != null) {
            objOpportunity.Contact__c = objContact.Id;
          }
          objOpportunity.AccountId = objAccount.Id;
          objOpportunity.StageName = strStageName;
          objOpportunity.Region_Picklist__c = strRegion;
          objOpportunity.Name = (intIndex == 0
            ? strOppName
            : strOppName + intIndex);
          objOpportunity.CloseDate = dateClose;
          objOpportunity.Proposal_Submission_Due_Date__c = dateProposalSubmission;
          objOpportunity.Service_Type__c = strServiceType;
          objOpportunity.OwnerId = (idOwner != null
            ? idOwner
            : UserInfo.getUserId());
          objOpportunity.PricingTeamEmailPicklist__c = strPricingTeamEmailPicklist;
          objOpportunity.Opportunity_Created_from_Lead__c = boolCreatedFromLeadConversion;
          listTestOpportunity.add(objOpportunity);
        }
      }
    }
    return listTestOpportunity;
  }

  /*
   * Method Name: createProduct
   * Input Parameters:
   * List<String> listProductName: This holds products name.
   * Return value: List<Product2>
   * Purpose: This method creates Products and related PricebookEntry.
   */
  public static List<Product2> createProduct(List<String> listProductName) {
    List<Product2> listTestProducts = new List<Product2>();
    List<PricebookEntry> listStandardPrice = new List<PricebookEntry>();
    Id pricebookId;

    for (String strProductName : listProductName) {
      Product2 objProduct = new Product2();
      objProduct.Name = strProductName;
      objProduct.ProductCode = strProductName;
      objProduct.IsActive = true;
      listTestProducts.add(objProduct);
    }
    insert listTestProducts;

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;

    pricebookId = Test.getStandardPricebookId();
    for (Product2 objProduct : listTestProducts) {
      PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = objProduct.Id,
        UnitPrice = 10000,
        IsActive = true
      );
      listStandardPrice.add(standardPrice);
    }
    insert listStandardPrice;
    return listTestProducts;
  }

  /*
   * Method Name: createOpportunityLineItem
   * Input Parameters:
   * Opportunity objOpportunity : This holds Opportunity.
   * List<Product2> listProducts : This holds Product list.
   * Integer intQuantity : This holds product quantity.
   * Integer intUnitPrice : This holds product unit price.
   * Return value: List<OpportunityLineItem>
   * Purpose: This method creates OpportunityLineItem as per parameters provided and returns the created OpportunityLineItems list.
   */
  public static List<OpportunityLineItem> createOpportunityLineItem(
    Opportunity objOpportunity,
    List<Product2> listProducts,
    Integer intQuantity,
    Integer intUnitPrice
  ) {
    List<OpportunityLineItem> listOpportunityLineItem = new List<OpportunityLineItem>();
    Map<Id, PricebookEntry> mapProductPricebookEntry = new Map<Id, PricebookEntry>();

    //Create map of product and PricebookEntry
    for (PricebookEntry objPricebookEntry : [
      SELECT Id, Product2Id
      FROM PricebookEntry
    ]) {
      mapProductPricebookEntry.put(
        objPricebookEntry.Product2Id,
        objPricebookEntry
      );
    }

    //Create Opportunity LineItems
    for (Product2 objProduct2 : listProducts) {
      OpportunityLineItem objOpportunityLineItem = new OpportunityLineItem();
      objOpportunityLineItem.OpportunityId = objOpportunity.Id;
      objOpportunityLineItem.Product2Id = objProduct2.Id;
      objOpportunityLineItem.Quantity = intQuantity;
      objOpportunityLineItem.UnitPrice = intUnitPrice;
      objOpportunityLineItem.Sub_Services__c = 'Air';
      objOpportunityLineItem.PricebookEntryId = mapProductPricebookEntry.get(
          objProduct2.Id
        )
        .Id;
      listOpportunityLineItem.add(objOpportunityLineItem);
    }

    return listOpportunityLineItem;
  }

  /*
   * Method Name: createTask
   * Input Parameters:
   * String strType : This holds task type.
   * String strSubtype : This holds task subtype.
   * String strDescription : This holds task description.
   * String strPriority : This holds task priority.
   * String strStatus : This holds task status.
   * Id IdWhatId : This holds tasks what id.
   * String strSubject : This holds tasks subject.
   * Date dateActivityDate : This holds tasks date.
   * Id idWhoId : This holds whod id.
   * Id idOwnerId : This holds owner id.
   * Integer intNumberOfTasks : This holds number of tasks to be created.
   * Return value: List<Task>
   * Purpose: This method creates Task as per parameters provided and returns the created Tasks list.
   */
  public static List<Task> createTask(
    String strType,
    String strSubtype,
    String strDescription,
    String strPriority,
    String strStatus,
    Id IdWhatId,
    String strSubject,
    Date dateActivityDate,
    Id initiativeid,
    Id idWhoId,
    Id idOwnerId,
    Integer intNumberOfTasks
  ) {
    List<Task> listTasks = new List<Task>();

    for (Integer intIndex = 0; intIndex < intNumberOfTasks; intIndex++) {
      Task objTask = new Task();
      objTask.Type = strType;
      objTask.TaskSubtype = strSubtype;
      objTask.Description = strDescription;
      objTask.Priority = strPriority;
      objTask.Status = strStatus;
      objTask.WhatId = IdWhatId;
      objTask.WhoId = idWhoId;
      if (idOwnerId != null) {
        objTask.OwnerId = idOwnerId;
      }
      if (initiativeid != null) {
        objTask.Initiative__c = initiativeid;
      }
      objTask.Subject = (intIndex == 0 ? strSubject : strSubject + intIndex);
      objTask.ActivityDate = dateActivityDate;
      listTasks.add(objTask);
    }
    return listTasks;
  }

  /*
   * Method Name: createEvent
   * Input Parameters:
   * String strType : This holds event type.
   * String strSubtype : This holds event subtype.
   * String strDescription : This holds task description.
   * Id IdWhatId : This holds event's what id.
   * String strSubject : This holds tasks subject.
   * Date dateActivityDate : This holds tasks date.
   * Id idWhoId : This holds whod id.
   * Id idOwnerId : This holds owner id.
   * Integer intNumberOfTasks : This holds number of tasks to be created.
   * Return value: List<Task>
   * Purpose: This method creates Task as per parameters provided and returns the created Tasks list.
   */
  public static List<Event> createEvent(
    String strType,
    String strSubtype,
    String strDescription,
    Id IdWhatId,
    String strSubject,
    Date dateActivityDate,
    Datetime activityDateTime,
    Id idWhoId,
    Id idOwnerId,
    Integer minutes,
    Integer intNumberOfEvents
  ) {
    List<Event> listEvents = new List<Event>();

    for (Integer intIndex = 0; intIndex < intNumberOfEvents; intIndex++) {
      Event objEvent = new Event();
      objEvent.Type = strType;
      objEvent.EventSubtype = strSubtype;
      objEvent.Description = strDescription;
      objEvent.DurationInMinutes = minutes;
      objEvent.WhatId = IdWhatId;
      objEvent.WhoId = idWhoId;

      if (idOwnerId != null) {
        objEvent.OwnerId = idOwnerId;
      }
      objEvent.Subject = (intIndex == 0 ? strSubject : strSubject + intIndex);
      objEvent.ActivityDate = dateActivityDate;
      objEvent.ActivityDateTime = activityDateTime;
      listEvents.add(objEvent);
    }
    return listEvents;
  }

  /*
   * Method Name: createContentNote
   * Input Parameters:
   * String strTitle : This holds note title.
   * String strContent : This holds note content.
   * Integer intNumberOfTasks : This holds number of content notes to be created.
   * Return value: List<ContentNote>
   * Purpose: This method creates content notes as per parameters provided and returns the created note list.
   */
  public static List<ContentNote> createContentNote(
    String strTitle,
    String strContent,
    Integer intNumberOfContentNotes
  ) {
    List<ContentNote> listContentNote = new List<ContentNote>();

    for (Integer intIndex = 0; intIndex < intNumberOfContentNotes; intIndex++) {
      ContentNote objNote = new ContentNote();
      objNote.Title = (intIndex == 0 ? strTitle : strTitle + intIndex);
      objNote.Content = Blob.valueOf(strContent);
      listContentNote.add(objNote);
    }
    //insert listContentNote;
    return listContentNote;
  }
  /*
   * Method Name: createContentVersion
   * Input Parameters:
   * String strTitle : This holds version title.
   * String strPathOnClient : This holds version Path.
   * string strVersionData : This holds version content.
   * Integer intNumOfDocs : This holds number of content versions to be created.
   * Return value: List<ContentVersion>
   * Purpose: This method creates content version as per parameters provided and returns the created version list.
   */
  public static List<ContentVersion> createContentVersion(
    string strTitle,
    string strPathOnClient,
    string strVersionData,
    integer intNumOfDocs
  ) {
    List<ContentVersion> versions = new List<ContentVersion>();
    for (integer i = 0; i < intNumOfDocs; i++) {
      ContentVersion contentVersion_1 = new ContentVersion(
        Title = strTitle,
        PathOnClient = strPathOnClient,
        VersionData = Blob.valueOf(strVersionData),
        IsMajorVersion = true
      );
      versions.add(contentVersion_1);
    }
    return versions;
  }

  /*
   * Method Name: createContentDocumentLink
   * Input Parameters:
   * List<Id> listContentDocumentId : This holds content document id list.
   * Id idParent : This holds parent id.
   * Return value: List<ContentDocumentLink>
   * Purpose: This method creates content document link as per parameters provided and returns the created list.
   */
  public static List<ContentDocumentLink> createContentDocumentLink(
    List<Id> listContentDocumentId,
    Id idParent
  ) {
    List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
    for (Id idItr : listContentDocumentId) {
      ContentDocumentLink contentDocumentLinkObj = new ContentDocumentLink();
      contentDocumentLinkObj.contentdocumentid = idItr;
      contentDocumentLinkObj.LinkedEntityId = idParent;
      contentDocumentLinkObj.ShareType = 'V';
      listContentDocumentLink.add(contentDocumentLinkObj);
    }
    //insert listContentDocumentLink;
    return listContentDocumentLink;
  }
  /*
   * Method Name: createAttachment
   * Input Parameters:
   * String strData : This holds Attachment Data.
   * String strName : This holds Attachment name.
   * Id idParent : This holds Attachment Parent Id.
   * Integer intNumOfAttach : This holds number of Attachments to be created.
   * Return value: List<Attachment>
   * Purpose: This method creates Attachments as per parameters provided and returns the created list.
   */
  public static List<Attachment> createAttachment(
    Id idParent,
    String strData,
    string strName,
    integer intNumOfAttach
  ) {
    List<Attachment> atts = new List<Attachment>();
    for (integer i = 0; i < intNumOfAttach; i++) {
      Attachment objAttachment = new Attachment();
      objAttachment.Body = Blob.valueOf(strData);
      objAttachment.Name = strName;
      objAttachment.ParentId = idParent;
      atts.add(objAttachment);
    }
    return atts;
  }
  /*
   * Method Name: createExternalReportReferences
   * Return value: External_Report_References__c
   * Purpose: This method creates ExternalReportReferences and returns the created ExternalReportReferences.
   */
  public static External_Report_References__c createExternalReportReferences() {
    External_Report_References__c err = new External_Report_References__c();
    err.Name = 'Testing';
    err.External_URL__c = 'https://test.salesforce.com/';
    return err;
  }

  /*
   * Method Name: createUser
   * Input Parameters:
   * Id idRoleId : This holds user role id.
   * Id idProfId : This holds user profile id.
   * String strFirstName : This holds user first name.
   * String strLastName : This holds user last name.
   * String strEmail : This holds user email.
   * String strLocaleSidKey : This holds user locale sid key.
   * String strLanguageLocale : This holds user language locale.
   * String strEmailEncoding : This holds email encoding key.
   * String strTimeZone : This holds user time zone.
   * Id IdManager : This holds user manager Id.
   * Return value: User
   * Purpose: This method creates User as per parameters provided and returns the created User.
   */
  public static User createUser(
    Id idRoleId,
    Id idProfId,
    String strFirstName,
    String strLastName,
    String strEmail,
    String strLocaleSidKey,
    String strLanguageLocale,
    String strEmailEncoding,
    String strTimeZone,
    Id contactId,
    Id IdManager
  ) {
    User objUser = new User();
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(' ', '')
      .replace(':', '')
      .replace('-', '');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    objUser.FirstName = strFirstName;
    objUser.LastName = strLastName;
    objUser.Email = strEmail;
    objUser.Username = uniqueName + '@test' + orgId + '.org';
    objUser.CompanyName = 'TEST';
    objUser.Title = 'title';
    objUser.Alias = uniqueName.substring(18, 23);
    objUser.TimeZoneSidKey = strTimeZone;
    objUser.EmailEncodingKey = strEmailEncoding;
    objUser.LanguageLocaleKey = strLanguageLocale;
    objUser.LocaleSidKey = strLocaleSidKey;
    objUser.ProfileId = idProfId;
    objUser.UserRoleId = idRoleId;
    objUser.ContactId = contactId;
    objUser.ManagerId = IdManager;

    //insert objUser;
    return objUser;
  }

  /*
   * Method Name: createAccountTeamMember
   * Input Parameters:
   * String strAccountAccessLevel : This holds account access level.
   * String strCaseAccessLevel : This holds case access level.
   * String strContactAccessLevel : This holds contact access level.
   * String strOpportunityAccessLevel : This holds Opportunity access level.
   * List<Account> listAccount : This holds account list.
   * List<User> listUser : This holds user list.
   * List<String> listTeamMemberRole : This holds team member role list.
   * Return value: AccountTeamMember
   * Purpose: This method creates Account team member as per parameters provided and returns the created Account team member.
   */
  public static List<AccountTeamMember> createAccountTeamMember(
    String strAccountAccessLevel,
    String strCaseAccessLevel,
    String strContactAccessLevel,
    String strOpportunityAccessLevel,
    List<Account> listAccount,
    List<User> listUser,
    List<String> listTeamMemberRole
  ) {
    List<AccountTeamMember> listAccountTeamMember = new List<AccountTeamMember>();

    for (Account objAccount : listAccount) {
      for (User objUser : listUser) {
        for (String strTeamMemberRole : listTeamMemberRole) {
          AccountTeamMember objAccountTeamMember = new AccountTeamMember();
          objAccountTeamMember.AccountAccessLevel = strAccountAccessLevel;
          objAccountTeamMember.CaseAccessLevel = strCaseAccessLevel;
          objAccountTeamMember.ContactAccessLevel = strContactAccessLevel;
          objAccountTeamMember.OpportunityAccessLevel = strOpportunityAccessLevel;
          objAccountTeamMember.AccountId = objAccount.Id;
          objAccountTeamMember.UserId = objUser.Id;
          objAccountTeamMember.TeamMemberRole = strTeamMemberRole;
          listAccountTeamMember.add(objAccountTeamMember);
        }
      }
    }
    return listAccountTeamMember;
  }

  /*
   * Method Name: createContract
   * Input Parameters:
   * Id IdAccount : This holds account Id.
   * Id idOwner : This holds owner id.
   * Integer intContractTerm : This holds Contract term.
   * Date dateStart : This holds contract start date.
   * List<Opportunity> listOpportunity : This holds opportunity list.
   * String strStatus : This holds contract status.
   * Id idPricebook2 : This holds pricebook id.
   * Integer intNumberOfContract : This holds number of Contract to be created.
   * Return value: List<Contract>
   * Purpose: This method creates Contracts as per parameters provided and returns the created cases list.
   */
  public static List<Contract> createContract(
    List<Account> listAccounts,
    Id idOwner,
    Integer intContractTerm,
    Date dateStart,
    List<Opportunity> listOpportunity,
    String strStatus,
    Id idPricebook2,
    Integer intNumberOfContract
  ) {
    List<Contract> listContract = new List<Contract>();

    for (Opportunity objOpportunity : listOpportunity) {
      for (Integer intIndex = 0; intIndex < intNumberOfContract; intIndex++) {
        Contract objContract = new Contract();
        if (listAccounts.size() > 0) {
          for (Account acc : listAccounts) {
            objContract.AccountId = acc.Id;
          }
        }
        if (idOwner != null) {
          objContract.OwnerId = idOwner;
        }
        objContract.ContractTerm = intContractTerm;
        objContract.Opportunity__c = objOpportunity.id;
        objContract.StartDate = dateStart;
        objContract.Status = strStatus;
        objContract.Pricebook2Id = idPricebook2;

        listContract.add(objContract);
      }
    }
    return listContract;
  }

  /*
   * Method Name: createOpportunityTeamMember
   * Input Parameters:
   * String strOpportunityAccessLevel : This holds opportunity access level.
   * List<Opportunity> listOpportunity : This holds Opportunities list.
   * List<User> listUser : This holds user list.
   * List<String> listTeamMemberRole : This holds team member role list.
   * Return value: List<OpportunityTeamMember>
   * Purpose: This method creates Opportunity team member as per parameters provided and returns the created Opportunity team member.
   */
  public static List<OpportunityTeamMember> createOpportunityTeamMember(
    String strOpportunityAccessLevel,
    List<Opportunity> listOpportunity,
    List<User> listUser,
    List<String> listTeamMemberRole
  ) {
    List<OpportunityTeamMember> listOpportunityTeamMember = new List<OpportunityTeamMember>();

    for (Opportunity objOpportunity : listOpportunity) {
      for (User objUser : listUser) {
        for (String strTeamMemberRole : listTeamMemberRole) {
          OpportunityTeamMember objOpportunityTeamMember = new OpportunityTeamMember();
          objOpportunityTeamMember.OpportunityAccessLevel = strOpportunityAccessLevel;
          objOpportunityTeamMember.OpportunityId = objOpportunity.Id;
          objOpportunityTeamMember.UserId = objUser.Id;
          objOpportunityTeamMember.TeamMemberRole = strTeamMemberRole;
          listOpportunityTeamMember.add(objOpportunityTeamMember);
        }
      }
    }
    return listOpportunityTeamMember;
  }

  /*
   * Method Name: createEmailMessage
   * Input Parameters:
   * String strFromaddress : This holds from email id.
   * String strToAddress :  This holds to email id.
   * String strSubject : This holds subject.
   * String strTextBody : This holds email body.
   * Id idRelatedTo : This holds related to body.
   * Return value: createEmailMessage
   * Purpose: This method creates email message as per parameters provided and returns the created email message.
   */
  public static EmailMessage createEmailMessage(
    String strFromaddress,
    String strToAddress,
    String strSubject,
    String strTextBody,
    Id idRelatedTo
  ) {
    EmailMessage objOutGoingMail = new EmailMessage();
    objOutGoingMail.fromaddress = strFromaddress;
    objOutGoingMail.toAddress = strToAddress;
    objOutGoingMail.subject = strSubject;
    objOutGoingMail.TextBody = strTextBody;
    objOutGoingMail.RelatedToId = idRelatedTo;

    return objOutGoingMail;
  }
  public static EmailMessage createIncomingEmailMessage(
    String strFromaddress,
    String strToAddress,
    String strSubject,
    String strTextBody,
    Id idRelatedTo
  ) {
    EmailMessage objInComingMail = new EmailMessage();
    objInComingMail.fromaddress = strFromaddress;
    objInComingMail.toAddress = strToAddress;
    objInComingMail.subject = strSubject;
    objInComingMail.TextBody = strTextBody;
    objInComingMail.RelatedToId = idRelatedTo;
    objInComingMail.incoming = true;

    return objInComingMail;
  }
  /*
   * Method Name: createLead
   * Input Parameters:
   * String strFirstName : This holds lead first name.
   * String strLastName : This holds loead last name.
   * String strEmail : This holds lead email id.
   * String strCompany : This holds lead compony.
   * String strLeadSource : This holds lead source.
   * String strIndustry : This holds lead industry.
   * String strServices : This holds lead service.
   * String strTitle : This holds lead title.
   * Boolean boolFollowup : This specifies whether followup to be taken care for lead or not.
   * Id idOwner : This holds lead owner id.
   * String strCountry : This holds lead country.
   * String strCity : This holds lead city.
   * String strState : This holds lead state.
   * String strPostalCode : This holds lead postal code.
   * String strAddressLine1 : This holds lead address line 1.
   * Integer intNumberOfLead : This holds number of lead to be created.
   * Return value: List<Lead>
   * Purpose: This method creates lead as per parameters provided and returns the created leads list.
   */
  public static List<Lead> createLead(
    String strFirstName,
    String strLastName,
    String strEmail,
    String strCompany,
    String strLeadSource,
    String strIndustry,
    String strServices,
    String strTitle,
    Boolean boolFollowup,
    Id idOwner,
    String strCountry,
    String strCity,
    String strState,
    String strPostalCode,
    String strAddressLine1,
    Integer intNumberOfLead
  ) {
    List<Lead> listLeads = new List<Lead>();

    for (Integer intIndex = 0; intIndex < intNumberOfLead; intIndex++) {
      Lead objLead = new Lead();
      objLead.FirstName = strFirstName;
      objLead.LastName = (intIndex == 0 ? strLastName : strLastName + intIndex);
      objLead.Email = strEmail;
      objLead.Company = strCompany;
      objLead.LeadSource = strLeadSource;
      objLead.Industry = strIndustry;
      objLead.Service__c = strServices;
      objLead.Title = strTitle;
      objLead.Followup__c = boolFollowup;
      objLead.OwnerId = idOwner;
      objLead.Country__c = strCountry;
      objLead.City__c = strCity;
      objLead.State__c = strState;
      objLead.Postal_Code__c = strPostalCode;
      objLead.Address_Line_1__c = strAddressLine1;
      objLead.Phone = '(23456789';
      objLead.MobilePhone = '(23456789';
      listLeads.add(objLead);
    }
    return listLeads;
  }

  /*
   * Method Name: createInitiative
   * Input Parameters:
   * String strInitiativeName : This holds initiative name.
   * Integer intNumberOfRecords :  This holds number of records to be created.
   * Return value: List<Initiative__c>
   * Purpose: This method creates initiatives and returns records.
   */
  public static List<Initiative__c> createInitiative(
    String strInitiativeName,
    Integer intNumberOfRecords
  ) {
    List<Initiative__c> lstInitiative = new List<Initiative__c>();
    for (Integer intIndex = 0; intIndex < intNumberOfRecords; intIndex++) {
      lstInitiative.add(new Initiative__c(Name = strInitiativeName + intIndex));
    }
    return lstInitiative;
  }

  /*
   * Method Name: createInitiativeRelationship
   * Input Parameters:
   * Id idInitiative : This holds initiative id.
   * Id idAccount :  This holds account id.
   * Return value: Goal_Initiative__c
   * Purpose: This method creates initiatives relationship and returns record.
   */
  public static Goal_Initiative__c createInitiativeRelationship(
    Id idInitiative,
    Id idAccount
  ) {
    Goal_Initiative__c objGoalInitiative = new Goal_Initiative__c(
      Name = 'Test',
      Initiative__c = idInitiative,
      Account__c = idAccount
    );
    return objGoalInitiative;
  }
  /*
   * Method Name: createEntitlement
   * Input Parameters:
   * String strEntitlementName : This holds entitlement name.
   * Id idAccount :  This holds account id.
   * Integer intNumOfEntitlements : This holds number of entitlements to be created.
   * Return value: List<Entitlement>
   * Purpose: This method creates entitlements and returns list.
   */
  public static List<Entitlement> createEntitlement(
    String strEntitlementName,
    Id idAccount,
    Integer intNumOfEntitlements
  ) {
    List<Entitlement> entitlements = new List<Entitlement>();
    for (Integer intIndex = 0; intIndex < intNumOfEntitlements; intIndex++) {
      Entitlement entObj = new Entitlement();
      entObj.AccountId = idAccount;
      entObj.Name = strEntitlementName;
      entitlements.add(entObj);
    }
    return entitlements;
  }
  /*
   * Method Name: createCustomerInquiryCase
   * Input Parameters:
   * Id idAccount : This holds Account Id.
   * Id idContact : This holds Contact Id.
   * Id idParentCase : This holds Parent case id.
   * string strSubject : This holds Case Subject.
   * string strDescription : This holds Case Description.
   * String strOrigin : This holds Case Origin.
   * Id idOwner : This holds Case owner id.
   * String strStatus : This holds Case Status.
   * Integer intNumberOfCases : This holds number of Cases to be created.
   * Return value: List<Case>
   * Purpose: This method creates Case as per parameters provided and returns the created Case list.
   */
  public static List<Case> createCustomerInquiryCase(
    Id idAccount,
    Id idContact,
    Id idParentCase,
    string strSubject,
    string strDescription,
    String strOrigin,
    Id idOwner,
    String strStatus,
    Integer intNumberOfCases
  ) {
    List<Case> cases = new List<Case>();
    for (integer i = 0; i < intNumberOfcases; i++) {
      List<RecordType> recTypes = [
        SELECT Id, Name
        FROM RecordType
        WHERE Name = 'Create Customer Inquiry'
        LIMIT 1
      ];

      Case cs = new Case();
      cs.RecordTypeId = recTypes[0].Id;
      cs.AccountId = idAccount;
      cs.Subject = strSubject;
      cs.Description = strDescription;
      cs.Origin = strOrigin;
      cs.Request_Type__c = 'NBK';
      cs.SuppliedEmail = 'test@yopmail.com';
      cs.ContactId = idContact;
      cs.Status = 'Open';
      cs.ParentId = idParentCase;
      cs.Resolution__c = 'Information Provided';
      if (string.isNotBlank(idOwner))
        cs.OwnerId = idOwner;
      cases.add(cs);
    }
    return cases;
  }

  /*
   * Method Name: createBLRevisionCase
   * Input Parameters:
   * List<Account> accounts : This holds Account List.
   * List<Contact> contacts : This holds Contact List.
   * List<Case> parentCases : This holds Parent case List.
   * string strSubject : This holds Case Subject.
   * string strDescription : This holds Case Description.
   * String strOrigin : This holds Case Origin.
   * Id idOwner : This holds Case owner id.
   * String strStatus : This holds Case Status.
   * Integer intNumberOfCases : This holds number of Cases to be created.
   * Return value: List<Case>
   * Purpose: This method creates Case as per parameters provided and returns the created Case list.
   */

  public static List<Case> createBLRevisionCase(
    List<Account> accounts,
    List<Contact> contacts,
    List<Case> parentCases,
    string strSubject,
    string strDescription,
    String strOrigin,
    Id idOwner,
    String strStatus,
    Integer intNumberOfCases
  ) {
    List<Case> cases = new List<Case>();
    for (integer i = 0; i < intNumberOfcases; i++) {
      Case cs = new Case();
      cs.RecordTypeId = System.Label.Create_BL_Revision_Record_Type;
      cs.Subject = strSubject;
      cs.Description = strDescription;
      cs.Origin = strOrigin;
      cs.BOL_Number__c = 'ABCD1234EFGH';
      cs.Destination_Country__c = 'AF';
      cs.Status = 'Open';
      cs.Origin_Country__c = 'AF';
      cs.Voyage__c = '12345678';
      cs.Assignee_Pricing_Location__c = 'US /Canada To/From Central America';
      cs.Equipment_Type_Size__c = '20\' Dry';

      if (string.isNotBlank(idOwner))
        cs.OwnerId = idOwner;
      cases.add(cs);
    }

    if (accounts != null && !accounts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Account acc : accounts) {
          Case newCase = cs.clone(false);
          newCase.Shipper_Name__c = acc.Id;
          newCase.Consignee_Name__c = acc.Id;
          newCase.Bill_to_Party__c = acc.Id;
          newCase.AccountId = acc.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (contacts != null && !contacts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Contact ct : contacts) {
          Case newCase = cs.clone(false);
          newCase.ContactId = ct.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (parentCases != null && !parentCases.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Case pcs : parentCases) {
          Case newCase = cs.clone(false);
          newCase.ParentId = pcs.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    return cases;
  }
  /*
   * Method Name: createPricingRateIssueCase
   * Input Parameters:
   * List<Account> accounts : This holds Account List.
   * List<Contact> contacts : This holds Contact List.
   * List<Case> parentCases : This holds Parent case List.
   * string strSubject : This holds Case Subject.
   * string strDescription : This holds Case Description.
   * String strOrigin : This holds Case Origin.
   * Id idOwner : This holds Case owner id.
   * String strStatus : This holds Case Status.
   * Integer intNumberOfCases : This holds number of Cases to be created.
   * Return value: List<Case>
   * Purpose: This method creates Case as per parameters provided and returns the created Case list.
   */
  public static List<Case> createPricingRateIssueCase(
    List<Account> accounts,
    List<Contact> contacts,
    List<Case> parentCases,
    string strSubject,
    string strDescription,
    String strOrigin,
    Id idOwner,
    String strStatus,
    Integer intNumberOfCases
  ) {
    List<Case> cases = new List<Case>();
    for (integer i = 0; i < intNumberOfcases; i++) {
      List<RecordType> recordTypes = [
        SELECT Id, Name
        FROM RecordType
        WHERE Name = 'Create Pricing Rate Issue'
        LIMIT 1
      ];

      Case cs = new Case();
      cs.RecordTypeId = recordTypes[0].Id;
      cs.Subject = strSubject;
      cs.Description = strDescription;
      cs.Origin = strOrigin;
      cs.BOL_Number__c = 'ABCD1234EFGH';
      cs.Status = 'Open';
      cs.Assignee_Pricing_Location__c = 'US /Canada To/From Central America';
      cs.Equipment_Type_Size__c = '20\' Dry';
      cs.Freight_Type__c = 'BBULK';
      cs.Non_Containerized_Comments__c = '1234567890 1234567890 1234567890 1234567890 1234567890';
      if (string.isNotBlank(idOwner))
        cs.OwnerId = idOwner;
      cs.Issue_Type__c = 'Pricing Issue';
      cs.Resolution_Category__c = 'Contract Renewed';
      cases.add(cs);
    }

    if (accounts != null && !accounts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Account acc : accounts) {
          Case newCase = cs.clone(false);
          newCase.AccountId = acc.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (contacts != null && !contacts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Contact ct : contacts) {
          Case newCase = cs.clone(false);
          newCase.ContactId = ct.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (parentCases != null && !parentCases.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Case pcs : parentCases) {
          Case newCase = cs.clone(false);
          newCase.ParentId = pcs.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    return cases;
  }

  /*
   * Method Name: createCustomerInquiryCase
   * Input Parameters:
   * List<Account> accounts : This holds Account List.
   * List<Contact> contacts : This holds Contact List.
   * List<Case> parentCases : This holds Parent case List.
   * string strSubject : This holds Case Subject.
   * string strDescription : This holds Case Description.
   * String strOrigin : This holds Case Origin.
   * Id idOwner : This holds Case owner id.
   * String strStatus : This holds Case Status.
   * Integer intNumberOfCases : This holds number of Cases to be created.
   * Return value: List<Case>
   * Purpose: This method creates Case as per parameters provided and returns the created Case list.
   */

  public static List<Case> createCustomerInquiryCase(
    List<Account> accounts,
    List<Contact> contacts,
    List<Case> parentCases,
    string strSubject,
    string strDescription,
    String strOrigin,
    Id idOwner,
    String strStatus,
    Integer intNumberOfCases
  ) {
    List<Case> cases = new List<Case>();
    for (integer i = 0; i < intNumberOfcases; i++) {
      Case cs = new Case();
      cs.RecordTypeId = System.Label.Customer_Inquiry_Record_Type;
      cs.Subject = strSubject;
      cs.Description = strDescription;
      cs.Origin = strOrigin;
      cs.BOL_Number__c = 'ABCD1234EFGH';
      cs.Status = 'Open';
      cs.Request_Type__c = 'NBK';
      cs.Customer_Inquiry_Resolution__c = 'FCL';
      cs.Date_Time_Assigned__c = system.now();
      cs.Direction__c = 'Northbound';
      cs.Services__c = 'Caribbean';
      if (string.isNotBlank(idOwner))
        cs.OwnerId = idOwner;
      cases.add(cs);
    }

    if (accounts != null && !accounts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Account acc : accounts) {
          Case newCase = cs.clone(false);
          newCase.Shipper_Name__c = acc.Id;
          newCase.Consignee_Name__c = acc.Id;
          newCase.Bill_to_Party__c = acc.Id;
          newCase.AccountId = acc.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (contacts != null && !contacts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Contact ct : contacts) {
          Case newCase = cs.clone(false);
          newCase.ContactId = ct.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (parentCases != null && !parentCases.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Case pcs : parentCases) {
          Case newCase = cs.clone(false);
          newCase.ParentId = pcs.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    return cases;
  }

  /*
   * Method Name: createBookingRequestCase
   * Input Parameters:
   * List<Account> accounts : This holds Account List.
   * List<Contact> contacts : This holds Contact List.
   * List<Case> parentCases : This holds Parent case List.
   * string strSubject : This holds Case Subject.
   * string strDescription : This holds Case Description.
   * String strOrigin : This holds Case Origin.
   * Id idOwner : This holds Case owner id.
   * String strStatus : This holds Case Status.
   * Integer intNumberOfCases : This holds number of Cases to be created.
   * Return value: List<Case>
   * Purpose: This method creates Case as per parameters provided and returns the created Case list.
   */

  public static List<Case> createBookingRequestCase(
    List<Account> accounts,
    List<Contact> contacts,
    List<Case> parentCases,
    string strSubject,
    string strDescription,
    String strOrigin,
    Id idOwner,
    String strStatus,
    Integer intNumberOfCases
  ) {
    List<Case> cases = new List<Case>();
    for (integer i = 0; i < intNumberOfcases; i++) {
      Case cs = new Case();
      cs.RecordTypeId = System.Label.Create_Booking_Request_Record_type;
      cs.Subject = strSubject;
      cs.Description = strDescription;
      cs.Origin = strOrigin;
      cs.BOL_Number__c = 'ABCD1234EFGH';
      cs.Status = 'Open';
      cs.Request_Type__c = 'NBK';
      cs.Customer_Inquiry_Resolution__c = 'FCL';
      cs.Date_Time_Assigned__c = system.now();
      cs.Direction__c = 'Northbound';
      cs.Services__c = 'Caribbean';
      if (string.isNotBlank(idOwner))
        cs.OwnerId = idOwner;
      cases.add(cs);
    }

    if (accounts != null && !accounts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Account acc : accounts) {
          Case newCase = cs.clone(false);
          newCase.Shipper_Name__c = acc.Id;
          newCase.Consignee_Name__c = acc.Id;
          newCase.Bill_to_Party__c = acc.Id;
          newCase.AccountId = acc.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (contacts != null && !contacts.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Contact ct : contacts) {
          Case newCase = cs.clone(false);
          newCase.ContactId = ct.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    if (parentCases != null && !parentCases.isEmpty()) {
      List<Case> newCases = new List<Case>();
      for (Case cs : cases) {
        for (Case pcs : parentCases) {
          Case newCase = cs.clone(false);
          newCase.ParentId = pcs.Id;
          newCases.add(newCase);
        }
      }
      cases = newCases;
    }

    return cases;
  }

  /*
   * Method Name: assignPermissionSet
   * Return value: boolean
   * Purpose: This method Assigns Market Manager Permission Set.
   */
  public static boolean assignPermissionSet(User singleUser) {
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Permission_Set_For_Marketing_Managers'
      LIMIT 1
    ];
    try {
      insert new PermissionSetAssignment(
        AssigneeId = singleUser.id,
        PermissionSetId = ps.Id
      );
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  public static List<Feedback_Release__c> createFeedbackRelease() {
    List<Feedback_Release__c> feedbackReleaseList = new List<Feedback_Release__c>();
    Feedback_Release__c feedbackRelease = new Feedback_Release__c();
    feedbackRelease.Name = 'xyz';
    feedbackReleaseList.add(feedbackRelease);
    return feedbackReleaseList;
  }

  /** Community Cloud **/

  public static List<Booking__c> getBookingRecords(
    String description,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Booking__c> bookings = new List<Booking__c>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Booking__c booking = new Booking__c(
        Booked_Date__c = Date.valueOf('2020-06-09'),
        Description__c = description,
        Is_Hazardous__c = true,
        Booking_Number__c = 'BK000' +
          i +
          String.valueOf(Datetime.now().formatGMT('yyyyMMddHHmmssSSS'))
      );
      bookings.add(booking);
    }
    if (isInsert) {
      insert bookings;
    }
    return bookings;
  }

  public static List<Party__c> getPartyRecords(
    List<Booking__c> bookings,
    String partyType,
    Integer numOfRecForEachPartyType,
    Boolean isInsert
  ) {
    List<Party__c> parties = new List<Party__c>();
    for (Booking__c booking : bookings) {
      for (Integer i = 0; i < numOfRecForEachPartyType; i++) {
        Party__c party = new Party__c(
          Name = (i == 0
            ? booking.Name + ':' + partyType
            : booking.Name + ':' + partyType + ' ' + i),
          Booking__c = booking.Id,
          Type__c = partyType,
          REF_Number__c = '12345'
        );
        parties.add(party);
      }
    }
    if (isInsert) {
      insert parties;
    }
    return parties;
  }

  public static List<Transport__c> getTransportRecords(
    List<Booking__c> bookings,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Transport__c> transports = new List<Transport__c>();
    for (Booking__c booking : bookings) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Transport__c transport = new Transport__c(
          Name = (i == 0 ? booking.Name : booking.Name + i),
          Booking__c = booking.Id
        );
        transports.add(transport);
      }
    }
    if (isInsert) {
      insert transports;
    }
    return transports;
  }

  public static List<Stop__c> getStopRecords(
    List<Transport__c> transports,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Stop__c> stops = new List<Stop__c>();
    for (Transport__c transport : transports) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Stop__c stop = new Stop__c(
          Name = (i == 0 ? transport.Name : transport.Name + i),
          Transport__c = transport.Id
        );
        stops.add(stop);
      }
    }
    if (isInsert) {
      insert stops;
    }
    return stops;
  }

  public static List<Shipment__c> getShipmentRecords(
    List<Booking__c> bookings,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Shipment__c> shipments = new List<Shipment__c>();
    for (Booking__c booking : bookings) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Shipment__c shipment = new Shipment__c(
          Name = (i == 0 ? booking.Name : booking.Name + i),
          Booking__c = booking.Id,
          Origin_Code__c = 'Loc Dummy',
          Destination_Code__c = 'Loc Dummy 1'
        );
        shipments.add(shipment);
      }
    }
    if (isInsert) {
      insert shipments;
    }
    return shipments;
  }

  public static List<Voyage__c> getVoyageRecords(
    List<Shipment__c> shipments,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Voyage__c> voyages = new List<Voyage__c>();
    for (Shipment__c shipment : shipments) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Voyage__c voyage = new Voyage__c(
          Name = (i == 0 ? shipment.Name : shipment.Name + i),
          Shipment__c = shipment.Id
        );
        voyages.add(voyage);
      }
    }
    if (isInsert) {
      insert voyages;
    }
    return voyages;
  }

  public static List<FreightDetail__c> getFreightDetailRecords(
    List<Shipment__c> shipments,
    String cargoType,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<FreightDetail__c> freightDetails = new List<FreightDetail__c>();
    for (Shipment__c shipment : shipments) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        FreightDetail__c freightDetail = new FreightDetail__c(
          Name = (i == 0 ? shipment.Name : shipment.Name + i),
          Shipment__c = shipment.Id,
          Freight_Reference_Number__c = '12345',
          Cargo_Type__c = cargoType
        );
        freightDetail.Commodity_Name__c = 'Cargo, NOS';
        freightDetails.add(freightDetail);
      }
    }
    if (isInsert) {
      insert freightDetails;
    }
    return freightDetails;
  }

  public static List<Requirement__c> getRequirementRecords(
    List<FreightDetail__c> freightDetails,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Requirement__c> requirements = new List<Requirement__c>();
    for (FreightDetail__c freightDetail : freightDetails) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Requirement__c requirement = new Requirement__c(
          Name = (i == 0 ? freightDetail.Name : freightDetail.Name + i),
          Freight__c = freightDetail.Id
        );
        requirement.Commodity_Name__c = 'Cargo, NOS';
        requirements.add(requirement);
      }
    }
    if (isInsert) {
      insert requirements;
    }
    return requirements;
  }

  public static List<Commodity__c> getCommodityRecords(
    List<FreightDetail__c> freightDetails,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Commodity__c> commodities = new List<Commodity__c>();
    for (FreightDetail__c freightDetail : freightDetails) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Commodity__c commodity = new Commodity__c(
          Name = (i == 0 ? freightDetail.Name : freightDetail.Name + i),
          Freight__c = freightDetail.Id
        );
        commodities.add(commodity);
      }
    }
    if (isInsert) {
      insert commodities;
    }
    return commodities;
  }

  public static List<Equipment__c> getEquipmentRecords(
    List<Requirement__c> requirements,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Equipment__c> equipments = new List<Equipment__c>();
    for (Requirement__c requirement : requirements) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Equipment__c equipment = new Equipment__c(
          Name = (i == 0 ? requirement.Name : requirement.Name + i),
          Requirement__c = requirement.Id
        );
        equipments.add(equipment);
      }
    }
    if (isInsert) {
      insert equipments;
    }
    return equipments;
  }

  public static List<Booking__c> getBookingWithChildren(
    String description,
    String cargoType,
    Integer numberOfRecords
  ) {
    List<Booking__c> bookings = new List<Booking__c>();

    bookings = getBookingRecords(description, numberOfRecords, true);
    List<Party__c> shipperParties = getPartyRecords(bookings, 'SHP', 1, true);
    List<Party__c> consigneeParties = getPartyRecords(bookings, 'CON', 1, true);
    List<Party__c> forwarderParties = getPartyRecords(bookings, 'FOR', 1, true);
    List<Party__c> supplierParties = getPartyRecords(bookings, 'SUP', 1, true);
    List<Party__c> notifyParties = getPartyRecords(bookings, 'NOT', 1, true);

    List<Transport__c> transports = getTransportRecords(bookings, 1, true);
    List<Stop__c> stops = getStopRecords(transports, 2, true);

    List<Shipment__c> shipments = getShipmentRecords(bookings, 1, true);
    List<Voyage__c> voyages = getVoyageRecords(shipments, 1, true);
    List<FreightDetail__c> freightDetails = getFreightDetailRecords(
      shipments,
      cargoType,
      1,
      true
    );
    List<Requirement__c> requirements = getRequirementRecords(
      freightDetails,
      1,
      true
    );
    List<Commodity__c> commodities = getCommodityRecords(
      freightDetails,
      1,
      true
    );
    List<Equipment__c> equipments = getEquipmentRecords(requirements, 1, true);
    return bookings;
  }

  public static List<Contact> getContactRecords(
    String lastName,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Contact contact = new Contact(
        LastName = (i == 0 ? lastName : lastName + i),
        Email = 'dummy' +
          (i == 0 ? '' : i + '') +
          (lastName != null ? lastName.deleteWhitespace().trim() : '') +
          '@example.com'
      );
      contacts.add(contact);
    }
    if (isInsert) {
      insert contacts;
    }
    return contacts;
  }

  public static Map<String, Integration_Service__mdt> getIntegrationServiceTestMap() {
    String data = '{';
    String getService = '{"MasterLabel" : "GetService", "Service__c":"/getservice","Request_Type__c":"GET", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String postService = '{"MasterLabel" : "PostService", "Service__c":"/postservice","Request_Type__c":"POST", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String putService = '{"MasterLabel" : "PutService", "Service__c":"/putservice","Request_Type__c":"PUT", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String deleteService = '{"MasterLabel" : "DeleteService", "Service__c":"/deleteservice","Request_Type__c":"DELETE", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String errorService = '{"MasterLabel" : "ErrorService", "Service__c":"/errorservice","Request_Type__c":"GET", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    data += '"GetService" : ' + getService + ',';
    data += '"PostService" : ' + postService + ',';
    data += '"PutService" : ' + putService + ',';
    data += '"DeleteService" : ' + deleteService + ',';
    data += '"ErrorService" : ' + errorService;
    data += '}';

    return (Map<String, Integration_Service__mdt>) JSON.deserialize(
      data,
      Map<String, Integration_Service__mdt>.class
    );
  }

  public static Map<String, Service_Environment__c> getServiceEnvironmentTestMap() {
    String data = '{';
    String testEnvironment = '{"Name" : "Service", "Environment__c":"Test"}';
    data += '"service" : ' + testEnvironment;
    data += '}';

    return (Map<String, Service_Environment__c>) JSON.deserialize(
      data,
      Map<String, Service_Environment__c>.class
    );
  }

  public static Map<String, Service_Environment_Param__mdt> getServiceParamsTestMap() {
    String data = '{';
    String testService = '{"MasterLabel" : "ServiceTest", "Baseurl__c":"https://test.com","Client_Id__c":"ABC", "Client_Secret__c":"ABC", "Certificate_Name__c":null}';
    data += '"servicetest" : ' + testService;
    data += '}';

    return (Map<String, Service_Environment_Param__mdt>) JSON.deserialize(
      data,
      Map<String, Service_Environment_Param__mdt>.class
    );
  }

  public static List<User> getUser(
    String profileName,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    UserRole userRole = new UserRole(
      DeveloperName = 'DummyDeveloper',
      Name = 'DummyName'
    );
    insert userRole;
    List<User> usersList = new List<User>();
    Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].id;
    for (integer i = 0; i < numberOfRecords; i++) {
      User u = new User(
        ProfileId = profileId,
        LastName = (i == 0 ? 'Last' : 'Last ' + i),
        Email = 'dummyUser000@abc.com',
        Username = (i == 0
          ? 'dummyUser000@abc.com' + System.currentTimeMillis()
          : 'dummyUser000@abc' + i + '.com' + System.currentTimeMillis()),
        Alias = (i == 0 ? 'alias' : 'alias ' + i),
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        UserRoleId = userRole.Id
      );
      usersList.add(u);
    }
    if (isInsert)
      insert usersList;
    return usersList;
  }

  public static List<Idea> getIdeaRecords(
    Id zoneId,
    String category,
    Integer numberOfRecords,
    boolean isInsert
  ) {
    List<Idea> ideasList = new List<Idea>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Idea idea = new Idea(
        Title = (i == 0 ? 'Test Idea' : 'Test Idea ' + i),
        Body = 'This Body',
        Categories = category,
        Status = 'Open',
        CommunityId = zoneId
      );
      ideasList.add(idea);
    }
    if (isInsert) {
      insert ideasList;
    }
    return ideasList;
  }
  public static List<IdeaComment> getIdeaComment(
    Set<Id> ideaIds,
    String comment,
    Integer numberOfRecords,
    boolean isInsert
  ) {
    List<IdeaComment> ideaCommentsList = new List<IdeaComment>();
    for (Id ideaId : ideaIds) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        IdeaComment ideaComment = new IdeaComment(
          IdeaId = ideaId,
          CommentBody = (i == 0 ? comment : comment + i)
        );
        ideaCommentsList.add(ideaComment);
      }
    }
    if (isInsert) {
      insert ideaCommentsList;
    }
    return ideaCommentsList;
  }

  public static List<Vote> getIdeaCommentVote(
    Set<Id> ideaCommentIds,
    Boolean isInsert
  ) {
    List<Vote> votesList = new List<Vote>();
    for (Id ideaCommentId : ideaCommentIds) {
      Vote vote = new Vote(ParentId = ideaCommentId, Type = 'Up');
      votesList.add(vote);
    }
    if (isInsert) {
      insert votesList;
    }
    return votesList;
  }

  public static Map<String, Integration_Service__mdt> getIntegrationServiceMapForTest() {
    String data = '{';
    String describeLayoutService = '{"MasterLabel" : "DescribeLayoutGET", "Service__c":"/service","Request_Type__c":"GET", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": null}';
    String findARouteService = '{"MasterLabel" : "FindARoutePOST", "Service__c":"/service","Request_Type__c":"POST", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": null}';
    data += '"DescribeLayoutGET" : ' + describeLayoutService + ',';
    data += '"FindARoutePOST" : ' + findARouteService;
    data += '}';

    return (Map<String, Integration_Service__mdt>) JSON.deserialize(
      data,
      Map<String, Integration_Service__mdt>.class
    );
  }

  public static List<Group> getPublicGroup(
    String name,
    Integer size,
    Boolean isInsert
  ) {
    List<Group> groups = new List<Group>();
    for (integer i = 0; i < size; i++) {
      Group grp = new Group(Name = (i == 0 ? name : name + ' ' + i));
      groups.add(grp);
    }
    if (isInsert)
      insert groups;
    return groups;
  }

  public static List<GroupMember> getGroupMember(
    Id groupId,
    Set<Id> userIds,
    Boolean isInsert
  ) {
    List<GroupMember> groupMembers = new List<GroupMember>();
    for (Id userId : userIds) {
      GroupMember member = new GroupMember(
        UserOrGroupId = userId,
        GroupId = groupId
      );
      groupMembers.add(member);
    }
    if (isInsert)
      insert groupMembers;
    return groupMembers;
  }

  public static List<EmailTemplate> getEmailTemplate(
    String name,
    Integer size,
    Boolean isInsert
  ) {
    List<EmailTemplate> emailTemps = new List<EmailTemplate>();
    for (integer i = 0; i < size; i++) {
      EmailTemplate emailTemp = new EmailTemplate(
        Name = (i == 0 ? name : name + ' ' + i),
        DeveloperName = (i == 0 ? name : name + ' ' + i),
        IsActive = true,
        TemplateType = 'text',
        FolderId = UserInfo.getUserId(),
        Body = ''
      );
      emailTemps.add(emailTemp);
    }
    if (isInsert)
      insert emailTemps;
    return emailTemps;
  }

  public static List<Location__c> getLocations(
    String name,
    Integer size,
    Boolean isInsert
  ) {
    List<Location__c> locationsList = new List<Location__c>();
    for (integer i = 0; i < size; i++) {
      Location__c loc = new Location__c(
        Name = (i == 0 ? name : name + ' ' + i)
      );
      locationsList.add(loc);
    }
    if (isInsert)
      insert locationsList;
    return locationsList;
  }

  /**** Manaswini ***/

  public static List<Contract> getContract(
    List<Account> listAccounts,
    Id idOwner,
    Integer intContractTerm,
    Date dateStart,
    List<Opportunity> listOpportunity,
    String strStatus,
    Id idPricebook2,
    Integer intNumberOfContract
  ) {
    List<Contract> listContract = new List<Contract>();
    for (Account acc : listAccounts) {
      for (Opportunity objOpportunity : listOpportunity) {
        for (Integer intIndex = 0; intIndex < intNumberOfContract; intIndex++) {
          Contract objContract = new Contract();
          objContract.AccountId = acc.Id;
          if (idOwner != null) {
            objContract.OwnerId = idOwner;
          }
          objContract.ContractTerm = intContractTerm;
          objContract.Opportunity__c = objOpportunity.id;
          objContract.StartDate = dateStart;
          objContract.Status = strStatus;
          objContract.Pricebook2Id = idPricebook2;
          objContract.Name = '20-0032' + intIndex;
          listContract.add(objContract);
        }
      }
    }
    return listContract;
  }

  public static List<Booking__c> CreateBooking(
    List<Id> accountIds,
    String contractNumber,
    Integer intNumberOfBooking
  ) {
    List<Booking__c> listBookings = new List<Booking__c>();
    for (Id idVar : accountIds) {
      for (Integer intIndex = 0; intIndex < intNumberOfBooking; intIndex++) {
        Booking__c newBooking = new Booking__c();
        newBooking.Account__c = idVar;
        newBooking.Booking_Number__c =
          'CAT' +
          intIndex +
          String.valueOf(Datetime.now().formatGMT('yyyyMMddHHmmssSSS'));
        newBooking.Contract_Number__c = contractNumber;
        listBookings.add(newBooking);
      }
    }
    return listBookings;
  }

  public static List<Party__c> CreateParty(
    List<Id> accountIds,
    String PartyName,
    Integer intNumberOfParty
  ) {
    List<Party__c> listParties = new List<Party__c>();
    for (Id idVar : accountIds) {
      for (Integer intIndex = 0; intIndex < intNumberOfParty; intIndex++) {
        Party__c newparty = new Party__c();
        newparty.Account__c = idVar;
        newparty.Name = (intIndex == 0 ? PartyName : PartyName + intIndex);
        newparty.Type__c = 'SHP';
        listParties.add(newparty);
      }
    }
    return listParties;
  }

  public static List<Location__c> CreateLocation(
    String LocationName,
    String subLocType,
    Integer intNumberOfLocation,
    Boolean isInsert
  ) {
    List<Location__c> listLocations = new List<Location__c>();
    for (Integer intIndex = 0; intIndex < intNumberOfLocation; intIndex++) {
      Location__c newLocation = new Location__c();
      newLocation.Name = (intIndex == 0
        ? LocationName
        : LocationName + intIndex);
      newLocation.UN_Location_Code__c = 'USQAT';
      newLocation.Sub_Location_Type__c = subLocType;
      newLocation.Location_Type__c = 'PORT';
      newLocation.City__c = 'San Jose';
      newLocation.RecordTypeId = CC_SharedUtility.getRecordTypeId(
        'Location__c:Location'
      );
      listLocations.add(newLocation);
    }
    if (isInsert)
      insert listLocations;
    return listLocations;
  }

  public static List<Shipment__c> CreateShipment(
    List<Quote__c> listquotes,
    Integer intNumberofshipments
  ) {
    List<Shipment__c> listshipments = new List<Shipment__c>();
    for (Quote__c q : listquotes) {
      for (Integer intIndex = 0; intIndex < intNumberofshipments; intIndex++) {
        Shipment__c newshipment = new Shipment__c();
        newshipment.Name = q.Name + '-0' + intIndex;
        newshipment.Quote__c = q.Id;
        newshipment.Destination_City__c = q.Customer_Destination_City__c;
        newshipment.Destination_Code__c = q.Customer_Destination_Code__c;
        newshipment.Destination_Country__c = q.Customer_Destination_Country__c;
        newshipment.Destination_State__c = q.Customer_Destination_State__c;
        newshipment.Destination_Zip__c = q.Customer_Destination_Zip__c;
        newshipment.Origin_City__c = q.Customer_Origin_City__c;
        newshipment.Origin_Code__c = q.Customer_Origin_Code__c;
        newshipment.Origin_Country__c = q.Customer_Origin_Country__c;
        newshipment.Origin_State__c = q.Customer_Origin_State__c;
        newshipment.Origin_Zip__c = q.Customer_Origin_Zip__c;
        listshipments.add(newshipment);
      }
    }
    return listshipments;
  }

  public static List<FreightDetail__c> CreateFreightDetail(
    List<Shipment__c> listShipments,
    Integer intNumberofFreightDetail
  ) {
    List<FreightDetail__c> listfds = new List<FreightDetail__c>();
    for (Shipment__c shp : listShipments) {
      for (
        Integer intIndex = 0; intIndex < intNumberofFreightDetail; intIndex++
      ) {
        FreightDetail__c newfd = new FreightDetail__c();
        newfd.Name = shp.Name + intIndex;
        newfd.Declared_Weights_Unit_of_Measure__c = 'Kg';
        newfd.Declared_Weight_Value__c = 1200;
        newfd.Cargo_Type__c = 'AUTO';
        newfd.Height_Major__c = 40;
        newfd.Length_Major__c = 60;
        newfd.Width_Major__c = 45;
        newfd.Package_Quantity__c = 30;
        newfd.Shipment__c = shp.Id;
        newfd.Commodity_Name__c = 'NIT/Break Bulk, Vehicles';
        listfds.add(newfd);
      }
    }
    return listfds;
  }

  public static List<Requirement__c> CreateRequirement(
    List<FreightDetail__c> listfds,
    Integer intNumberofRequirement
  ) {
    List<Requirement__c> listreq = new List<Requirement__c>();
    for (FreightDetail__c fd : listfds) {
      if (fd.Cargo_Type__c == 'EQUIP') {
        for (
          Integer intIndex = 0; intIndex < intNumberofRequirement; intindex++
        ) {
          Requirement__c newreq = new Requirement__c();
          newreq.Name = fd.Name + intIndex;
          newreq.Freight__c = fd.Id;
          newreq.Category__c = 'DRY';
          newreq.Length__c = 45;
          newreq.Quantity__c = 25;
          newreq.Commodity_Code__c = '0000100000';
          newreq.Container_Code__c = '53MA';
          newreq.Container_Type__c = 'FM808';
          newreq.Commodity_Name__c = 'Cargo, NOS';
          listreq.add(newreq);
        }
      }
    }
    return listreq;
  }

  public static Container__c CreateContainer(
    String Name,
    String CICS_Code,
    String Description,
    String GroupString,
    String UsedFor
  ) {
    Container__c containerobj = new Container__c();
    containerobj.Name = Name;
    containerobj.CICS_ISO_Code__c = CICS_Code;
    containerobj.Description__c = Description;
    containerobj.Group__c = GroupString;
    containerobj.Used_For__c = UsedFor;
    return containerobj;
  }
  /*** Saurabh ***/

  public static String bookingwrapper() {
    String bookingwrap =
      '{"transportOrigin":{"transport":{"attributes":{"type":"Transport__c"}},"listStop":[{"attributes":{"type":"Stop__c"}}]},"transportDestination":{"transport":{"attributes":{"type":"Transport__c"}},"listStop":[{"attributes":{"type":"Stop__c"}}]},"shipmentMap":{"CONTAINER":{"shipment":{"attributes":{"type":"Shipment__c"}},"listVogage":[],"listCargo":[{"measureUnit":"lb/ft","listFreightDetailWrapper":[{"typeOfPackage":"","packageDesc":"","listRequirementWrapper":[{"requirement":{"attributes":{"type":"Requirement__c"},"Running_Reefer__c":false,"Container_Type__c":"BB0C","Quantity__c":1.0},"containerType":"20DS","containerDesc":"20 Dry Container","commodityDesc":"","commodityCode":"' +
      System.label.CC_CargoNOS_Code +
      '"}],"listCommodityWrapper":[],"freightDetail":{"attributes":{"type":"FreightDetail__c"}},"commodityDesc":"NIT/Break Bulk, Vehicles","commodityCode":"' +
      System.label.CC_NitBBCode +
      '"}],"isHazardous":false,"cargoType":"container"}],"isSelected":true,"cargoType":"container"},"BREAKBULK":{"shipment":{"attributes":{"type":"Shipment__c"}},"listVogage":[],"listCargo":[{"measureUnit":"lb/ft","listFreightDetailWrapper":[{"typeOfPackage":"","packageDesc":"","listRequirementWrapper":[{"requirement":{"attributes":{"type":"Requirement__c"}},"containerType":"","containerDesc":"","commodityDesc":"","commodityCode":""}],"listCommodityWrapper":[],"freightDetail":{"attributes":{"type":"FreightDetail__c"},"Length_Major__c":0.0},"commodityDesc":"NIT/Break Bulk, Vehicles","commodityCode":"' +
      System.label.CC_NitBBCode +
      '"}],"isHazardous":false,"cargoType":"BBULK"}],"isSelected":false,"cargoType":"breakbulk"},"VEHICLE":{"shipment":{"attributes":{"type":"Shipment__c"}},"listVogage":[],"listCargo":[{"measureUnit":"kg/m","listFreightDetailWrapper":[{"typeOfPackage":"CVEH","packageDesc":"","listRequirementWrapper":[{"requirement":{"attributes":{"type":"Requirement__c"}},"containerType":"","containerDesc":"","commodityDesc":"","commodityCode":""}],"listCommodityWrapper":[],"freightDetail":{"attributes":{"type":"FreightDetail__c"},"Length_Minor__c":111.0,"Length_Major__c":11.0,"Height_Minor__c":0.0,"Declared_Weight_Value__c":0.0,"Freight_Quantity__c":11.0,"Width_Minor__c":0.0,"Width_Major__c":0.0,"Manufacturer__c":"other","Model__c":"other","Height_Major__c":0.0},"commodityDesc":"NIT/Break Bulk, Vehicles","commodityCode":"' +
      System.label.CC_NitBBCode +
      '"}],"isHazardous":false,"cargoType":"AUTO"}],"isSelected":false,"cargoType":"vehicle"},"RORO":{"shipment":{"attributes":{"type":"Shipment__c"}},"listVogage":[],"listCargo":[{"measureUnit":"lb/ft","listFreightDetailWrapper":[{"typeOfPackage":"","packageDesc":"","listRequirementWrapper":[{"requirement":{"attributes":{"type":"Requirement__c"}},"containerType":"","containerDesc":"","commodityDesc":"","commodityCode":""}],"listCommodityWrapper":[],"freightDetail":{"attributes":{"type":"FreightDetail__c"}},"commodityDesc":"NIT/Break Bulk, Vehicles","commodityCode":"' +
      System.label.CC_NitBBCode +
      '"}],"isHazardous":false,"cargoType":""}],"isSelected":false,"cargoType":"roro"}},"shipment":{"shipment":{"attributes":{"type":"Shipment__c"}},"listVogage":[],"listCargo":[{"measureUnit":"lb/ft","listFreightDetailWrapper":[{"typeOfPackage":"","packageDesc":"","listRequirementWrapper":[{"requirement":{"attributes":{"type":"Requirement__c"}},"containerType":"","containerDesc":"","commodityDesc":"","commodityCode":""}],"listCommodityWrapper":[],"freightDetail":{"attributes":{"type":"FreightDetail__c"}},"commodityDesc":"NIT/Break Bulk, Vehicles","commodityCode":"' +
      System.label.CC_NitBBCode +
      '"}],"isHazardous":false,"cargoType":"container"}],"isSelected":null,"cargoType":null},"selectedRouteId":1,"mapParty":{"forwarder":[],"notify":[],"consignee":[{"attributes":{"type":"Party__c"},"Type__c":"CON"}],"shiper":[{"attributes":{"type":"Party__c"},"Type__c":"SHP"}],"Customer":[{"attributes":{"type":"Party__c"},"Type__c":"CUST"}]},"listQuote":[],"isError":false,"errorMessage":null,"booking":{"attributes":{"type":"Booking__c"},"Customer_Destination_Country__c":"PR","Customer_Email__c":"test@gmail.com","Customer_Destination_City__c":"San Juan","Origin_Drayage__c":"","Customer_Origin_Zip__c":"32206","Customer_Origin_City__c":"Jacksonville","Customer_Origin_Country__c":"United States","Customer_Origin_State__c":"Florida","Description__c":"DP","Ready_Date__c":"2020-10-08","Pickup_Location__c":"","Customer_Destination_Code__c":"PRSJU","Customer_Origin_Code__c":"$026E","Transportation_Management_System_Origin__c":"A"}}';
    return bookingwrap;
  }

  public static String responsewrapper() {
    String responsewrap = '{"success":true,"result":[{"Success":false,"Schedules":[{"TotalDuration":"3.11:30:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-08T03:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-08T03:00:00"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"NZV0108"},"VesselName":"Paradero","VesselCode":{"Code":"PAR"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-12T00:00:00"},"Arrival":{"Utc":"2020-09-11T11:30:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":false,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-08T03:00:00"},"Arrival":{"Utc":"2020-09-07T11:00:00"}}]},"FromSubDisplayName":"PortEvergladesTerm,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-08T03:00:00"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-11T16:30:00"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-11T16:30:00"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-11T16:30:00"},"addedHours":null},{"TotalDuration":"3.11:30:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-15T03:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-15T03:00:00"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"NZV0111"},"VesselName":"Paradero","VesselCode":{"Code":"PAR"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-19T00:00:00"},"Arrival":{"Utc":"2020-09-18T11:30:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-15T03:00:00"},"Arrival":{"Utc":"2020-09-14T11:00:00"}}]},"FromSubDisplayName":"PortEvergladesTerm,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-15T03:00:00"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-18T16:30:00"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-18T16:30:00"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-18T16:30:00"},"addedHours":null},{"TotalDuration":"3.12:00:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-11T03:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-11T03:00:00"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"NZV0109"},"VesselName":"PegasusJ","VesselCode":{"Code":"PEJ"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-14T23:00:00"},"Arrival":{"Utc":"2020-09-14T12:00:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-11T03:00:00"},"Arrival":{"Utc":"2020-09-10T07:00:00"}}]},"FromSubDisplayName":"PortEvergladesTerm,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-11T03:00:00"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-14T17:00:00"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-14T17:00:00"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-14T17:00:00"},"addedHours":null},{"TotalDuration":"3.12:00:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-18T03:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-18T03:00:00"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"NZV0112"},"VesselName":"PegasusJ","VesselCode":{"Code":"PEJ"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-21T23:00:00"},"Arrival":{"Utc":"2020-09-21T12:00:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-18T03:00:00"},"Arrival":{"Utc":"2020-09-17T07:00:00"}}]},"FromSubDisplayName":"PortEvergladesTerm,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-18T03:00:00"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-21T17:00:00"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-21T17:00:00"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-21T17:00:00"},"addedHours":null}],"RouteId":1,"Legs":[{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":2.5,"Amount":2.5}}],"IsSelectedRoute":false,"ExpectedTimeOfDeparture":"2020-09-05T11:57:37.4077396Z","Duration":{"TimeUnit":"m","AmountinMinuteRounded":5010.0,"AmountinHours":83.5,"AmountInDays":3.4791666666666666666666666667,"Amount":5010.0},"CalculatedContributionResult":{"Success":true,"ItemValues":[{"ValuesDataRevenue":[{"ValuesGroup":[{"TotalSum":4186.0,"SumOfVat":0.0,"SumOfValues":4186.0,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":24217.0,"TargetCurCode":"USD","Rate":3982.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"OceanFreight","CurrencyCode":"USD","ChargeCode":"NTFR","Basis":1.0,"AmountTarget":3982.0},{"ItemNumber":"1","Unit":"1","TariffManr":15638.0,"TargetCurCode":"USD","Rate":100.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"VesselFuelSurcharge","CurrencyCode":"USD","ChargeCode":"VFS","Basis":1.0,"AmountTarget":100.0},{"ItemNumber":"1","Unit":"1","TariffManr":7835.0,"TargetCurCode":"USD","Rate":104.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"TerminalHandlingCharge-Destination","CurrencyCode":"USD","ChargeCode":"THCD","Basis":1.0,"AmountTarget":104.0}]}],"TargetCurrency":"USD"}],"ValuesDataCost":[{"ValuesGroup":[{"TotalSum":777.91,"SumOfVat":0.0,"SumOfValues":777.91,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":8659.0,"TargetCurCode":"USD","Rate":124.93,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-Admin","CurrencyCode":"USD","ChargeCode":"SCAD","Basis":1.0,"AmountTarget":124.93},{"ItemNumber":"1","Unit":"1","TariffManr":8668.0,"TargetCurCode":"USD","Rate":257.68,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PurchaseServices","CurrencyCode":"USD","ChargeCode":"SCPC","Basis":1.0,"AmountTarget":257.68},{"ItemNumber":"1","Unit":"1","TariffManr":8650.0,"TargetCurCode":"USD","Rate":53.92,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PortofDischarge","CurrencyCode":"USD","ChargeCode":"SCPD","Basis":1.0,"AmountTarget":53.92},{"ItemNumber":"1","Unit":"1","TariffManr":8641.0,"TargetCurCode":"USD","Rate":42.8,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PortofLoad","CurrencyCode":"USD","ChargeCode":"SCPL","Basis":1.0,"AmountTarget":42.8},{"ItemNumber":"1","Unit":"1","TariffManr":8623.0,"TargetCurCode":"USD","Rate":137.24,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-VesselCharter","CurrencyCode":"USD","ChargeCode":"SCVC","Basis":1.0,"AmountTarget":137.24},{"ItemNumber":"1","Unit":"1","TariffManr":8632.0,"TargetCurCode":"USD","Rate":161.34,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-VesselFuel","CurrencyCode":"USD","ChargeCode":"SCVF","Basis":1.0,"AmountTarget":161.34}]}],"TargetCurrency":"USD"}],"ItemNumber":1,"ContributionData":[{"TargetCurrency":"USD","SumRevenue":4186.0,"SumCost":777.91,"ContributionAmount":3408.09}]}],"Errors":[]},"BookingRouteResult":{"RouteId":1,"AllSalesTariffIds":[24217,15638,7835],"AllPurchaseTariffIds":[8659,8668,8650,8641,8623,8632]}},{"Success":false,"Schedules":[{"TotalDuration":"8.05:00:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-07T11:00:00Z"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-07T11:00:00Z"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"ManzanilloTerm,Panama","ToLocation":{"Code":"PAMIT"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-10T23:00:00Z"},"Arrival":{"Utc":"2020-09-10T23:00:00Z"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":969,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"MITT007"},"LocationCode":{"Code":"PAMIT"},"DisplayName":"Manzanillo,Panama"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":5040.00,"AmountinHours":84.00,"AmountInDays":3.5,"Amount":3.5}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-07T11:00:00Z"},"Arrival":{"Utc":"2020-09-07T11:00:00Z"}}]},"FromSubDisplayName":"PortEvergladesTerm,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-07T11:00:00Z"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-11T23:00:00Z"}},{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"F","Code":"FEED"},"ToSubDisplayName":"KingstonTerm,Jamaica","ToLocation":{"Code":"JMKIN"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-13T11:00:00Z"},"Arrival":{"Utc":"2020-09-13T11:00:00Z"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":857,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"MITT007"},"LocationCode":{"Code":"PAMIT"},"DisplayName":"Manzanillo,Panama"},"LegSeqNumber":2,"EndPosition":{"SubLocationCode":{"Code":"KINT001"},"LocationCode":{"Code":"JMKIN"},"DisplayName":"Kingston,Jamaica"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":2160.00,"AmountinHours":36.00,"AmountInDays":1.5,"Amount":1.5}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-11T23:00:00Z"},"Arrival":{"Utc":"2020-09-11T23:00:00Z"}}]},"FromSubDisplayName":"ManzanilloTerm,Panama","FromLocation":{"Code":"PAMIT"},"DepartureTime":{"Utc":"2020-09-11T23:00:00Z"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-13T11:00:00Z"}},{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"F","Code":"FEED"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-15T11:00:00Z"},"Arrival":{"Utc":"2020-09-15T11:00:00Z"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":945,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"KINT001"},"LocationCode":{"Code":"JMKIN"},"DisplayName":"Kingston,Jamaica"},"LegSeqNumber":3,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":2880.0,"AmountinHours":48.0,"AmountInDays":2.0,"Amount":2.0}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-13T11:00:00Z"},"Arrival":{"Utc":"2020-09-13T11:00:00Z"}}]},"FromSubDisplayName":"KingstonTerm,Jamaica","FromLocation":{"Code":"JMKIN"},"DepartureTime":{"Utc":"2020-09-13T11:00:00Z"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-15T16:00:00Z"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-15T16:00:00Z"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-15T16:00:00Z"},"addedHours":null}],"RouteId":2,"Legs":[{"TransshipmentMatrixDetailId":969,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"MITT007"},"LocationCode":{"Code":"PAMIT"},"DisplayName":"Manzanillo,Panama"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":3.5,"Amount":3.5}},{"TransshipmentMatrixDetailId":857,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"MITT007"},"LocationCode":{"Code":"PAMIT"},"DisplayName":"Manzanillo,Panama"},"LegSeqNumber":2,"EndPosition":{"SubLocationCode":{"Code":"KINT001"},"LocationCode":{"Code":"JMKIN"},"DisplayName":"Kingston,Jamaica"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":1.5,"Amount":1.5}},{"TransshipmentMatrixDetailId":945,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"KINT001"},"LocationCode":{"Code":"JMKIN"},"DisplayName":"Kingston,Jamaica"},"LegSeqNumber":3,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":2.0,"Amount":2.0}}],"IsSelectedRoute":false,"ExpectedTimeOfDeparture":"2020-09-05T11:57:37.4077396Z","Duration":{"TimeUnit":"m","AmountinMinuteRounded":11820.0,"AmountinHours":197.0,"AmountInDays":8.208333333333333333333333333,"Amount":11820.0},"CalculatedContributionResult":{"Success":true,"ItemValues":[{"ValuesDataRevenue":[{"ValuesGroup":[{"TotalSum":4186.0,"SumOfVat":0.0,"SumOfValues":4186.0,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":24217.0,"TargetCurCode":"USD","Rate":3982.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"OceanFreight","CurrencyCode":"USD","ChargeCode":"NTFR","Basis":1.0,"AmountTarget":3982.0},{"ItemNumber":"1","Unit":"1","TariffManr":15638.0,"TargetCurCode":"USD","Rate":100.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"VesselFuelSurcharge","CurrencyCode":"USD","ChargeCode":"VFS","Basis":1.0,"AmountTarget":100.0},{"ItemNumber":"1","Unit":"1","TariffManr":7835.0,"TargetCurCode":"USD","Rate":104.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"TerminalHandlingCharge-Destination","CurrencyCode":"USD","ChargeCode":"THCD","Basis":1.0,"AmountTarget":104.0}]}],"TargetCurrency":"USD"}],"ValuesDataCost":[{"ValuesGroup":[{"TotalSum":1122.73,"SumOfVat":0.0,"SumOfValues":1122.73,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":8988.0,"TargetCurCode":"USD","Rate":124.93,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-Admin","CurrencyCode":"USD","ChargeCode":"SCAD","Basis":1.0,"AmountTarget":124.93},{"ItemNumber":"1","Unit":"1","TariffManr":8997.0,"TargetCurCode":"USD","Rate":257.68,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PurchaseServices","CurrencyCode":"USD","ChargeCode":"SCPC","Basis":1.0,"AmountTarget":257.68},{"ItemNumber":"1","Unit":"1","TariffManr":8979.0,"TargetCurCode":"USD","Rate":42.58,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PortofDischarge","CurrencyCode":"USD","ChargeCode":"SCPD","Basis":1.0,"AmountTarget":42.58},{"ItemNumber":"1","Unit":"1","TariffManr":8970.0,"TargetCurCode":"USD","Rate":87.11,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PortofLoad","CurrencyCode":"USD","ChargeCode":"SCPL","Basis":1.0,"AmountTarget":87.11},{"ItemNumber":"1","Unit":"1","TariffManr":8952.0,"TargetCurCode":"USD","Rate":244.16,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-VesselCharter","CurrencyCode":"USD","ChargeCode":"SCVC","Basis":1.0,"AmountTarget":244.16},{"ItemNumber":"1","Unit":"1","TariffManr":8961.0,"TargetCurCode":"USD","Rate":366.27,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-VesselFuel","CurrencyCode":"USD","ChargeCode":"SCVF","Basis":1.0,"AmountTarget":366.27}]}],"TargetCurrency":"USD"}],"ItemNumber":1,"ContributionData":[{"TargetCurrency":"USD","SumRevenue":4186.0,"SumCost":1122.73,"ContributionAmount":3063.27}]}],"Errors":[]},"BookingRouteResult":{"RouteId":2,"AllSalesTariffIds":[24217,15638,7835],"AllPurchaseTariffIds":[8988,8997,8979,8970,8952,8961]}},{"Success":false,"Schedules":[{"TotalDuration":"10.15:00:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-13T20:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-13T20:00:00"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"DOM0037"},"VesselName":"KStorm","VesselCode":{"Code":"KSM"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"RioHainaTerm,DomRep","ToLocation":{"Code":"DOHAI"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-17T01:00:00"},"Arrival":{"Utc":"2020-09-16T12:00:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":829,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-13T20:00:00"},"Arrival":{"Utc":"2020-09-13T11:00:00"}}]},"FromSubDisplayName":"PortEvergladesTerm,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-13T20:00:00"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-17T12:00:00"}},{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"F","Code":"FEED"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-24T00:00:00"},"Arrival":{"Utc":"2020-09-24T00:00:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":956,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"LegSeqNumber":2,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":9360.00,"AmountinHours":156.00,"AmountInDays":6.5,"Amount":6.5}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-17T12:00:00"},"Arrival":{"Utc":"2020-09-17T12:00:00"}}]},"FromSubDisplayName":"RioHainaTerm,DomRep","FromLocation":{"Code":"DOHAI"},"DepartureTime":{"Utc":"2020-09-17T12:00:00"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-24T11:00:00"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-24T11:00:00"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-24T11:00:00"},"addedHours":null}],"RouteId":3,"Legs":[{"TransshipmentMatrixDetailId":829,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":2.5,"Amount":2.5}},{"TransshipmentMatrixDetailId":956,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"LegSeqNumber":2,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":6.5,"Amount":6.5}}],"IsSelectedRoute":false,"ExpectedTimeOfDeparture":"2020-09-05T11:57:37.4077396Z","Duration":{"TimeUnit":"m","AmountinMinuteRounded":15300.0,"AmountinHours":255.0,"AmountInDays":10.625,"Amount":15300.0},"CalculatedContributionResult":{"Success":true,"ItemValues":[{"ValuesDataRevenue":[{"ValuesGroup":[{"TotalSum":4186.0,"SumOfVat":0.0,"SumOfValues":4186.0,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":24217.0,"TargetCurCode":"USD","Rate":3982.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"OceanFreight","CurrencyCode":"USD","ChargeCode":"NTFR","Basis":1.0,"AmountTarget":3982.0},{"ItemNumber":"1","Unit":"1","TariffManr":15638.0,"TargetCurCode":"USD","Rate":100.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"VesselFuelSurcharge","CurrencyCode":"USD","ChargeCode":"VFS","Basis":1.0,"AmountTarget":100.0},{"ItemNumber":"1","Unit":"1","TariffManr":7835.0,"TargetCurCode":"USD","Rate":104.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"TerminalHandlingCharge-Destination","CurrencyCode":"USD","ChargeCode":"THCD","Basis":1.0,"AmountTarget":104.0}]}],"TargetCurrency":"USD"}],"ValuesDataCost":[{"ValuesGroup":[{"TotalSum":1864.69,"SumOfVat":0.0,"SumOfValues":1864.69,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":8328.0,"TargetCurCode":"USD","Rate":124.93,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-Admin","CurrencyCode":"USD","ChargeCode":"SCAD","Basis":1.0,"AmountTarget":124.93},{"ItemNumber":"1","Unit":"1","TariffManr":8337.0,"TargetCurCode":"USD","Rate":257.68,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PurchaseServices","CurrencyCode":"USD","ChargeCode":"SCPC","Basis":1.0,"AmountTarget":257.68},{"ItemNumber":"1","Unit":"1","TariffManr":8319.0,"TargetCurCode":"USD","Rate":50.31,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PortofDischarge","CurrencyCode":"USD","ChargeCode":"SCPD","Basis":1.0,"AmountTarget":50.31},{"ItemNumber":"1","Unit":"1","TariffManr":8310.0,"TargetCurCode":"USD","Rate":38.29,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-PortofLoad","CurrencyCode":"USD","ChargeCode":"SCPL","Basis":1.0,"AmountTarget":38.29},{"ItemNumber":"1","Unit":"1","TariffManr":8292.0,"TargetCurCode":"USD","Rate":174.67,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-VesselCharter","CurrencyCode":"USD","ChargeCode":"SCVC","Basis":1.0,"AmountTarget":174.67},{"ItemNumber":"1","Unit":"1","TariffManr":8301.0,"TargetCurCode":"USD","Rate":253.81,"Per":"P","MinMaxFlag":"N","GroupName":"OCEANADD","Description":"StandardCost-VesselFuel","CurrencyCode":"USD","ChargeCode":"SCVF","Basis":1.0,"AmountTarget":253.81},{"ItemNumber":"1","Unit":"1","TariffManr":2898.0,"TargetCurCode":"USD","Rate":965.0,"Per":"P","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"ContractCarrierSlotCharges","CurrencyCode":"USD","ChargeCode":"SLOT","Basis":1.0,"AmountTarget":965.0}]}],"TargetCurrency":"USD"}],"ItemNumber":1,"ContributionData":[{"TargetCurrency":"USD","SumRevenue":4186.0,"SumCost":1864.69,"ContributionAmount":2321.31}]}],"Errors":[]},"BookingRouteResult":{"RouteId":3,"AllSalesTariffIds":[24217,15638,7835],"AllPurchaseTariffIds":[8328,8337,8319,8310,8292,8301,2898]}},{"Success":false,"Schedules":[{"TotalDuration":"14.00:00:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-07T11:00:00Z"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-07T11:00:00Z"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"F","Code":"FEED"},"ToSubDisplayName":"CampdenParkTerm,StVincent","ToLocation":{"Code":"VCCRP"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-11T05:00:00Z"},"Arrival":{"Utc":"2020-09-11T05:00:00Z"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":1263,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT006"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"CRPT001"},"LocationCode":{"Code":"VCCRP"},"DisplayName":"CampdenPark,SaintVincent"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":5400.00,"AmountinHours":90.000,"AmountInDays":3.75,"Amount":3.75}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-07T11:00:00Z"},"Arrival":{"Utc":"2020-09-07T11:00:00Z"}}]},"FromSubDisplayName":"KOSTerm,PortEverglades,FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-07T11:00:00Z"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-11T05:00:00Z"}},{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"F","Code":"FEED"},"ToSubDisplayName":"RioHainaTerm,DomRep","ToLocation":{"Code":"DOHAI"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-12T18:00:00Z"},"Arrival":{"Utc":"2020-09-12T18:00:00Z"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":896,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"CRPT001"},"LocationCode":{"Code":"VCCRP"},"DisplayName":"CampdenPark,SaintVincent"},"LegSeqNumber":2,"EndPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":2220.00,"AmountinHours":37.000000000000080,"AmountInDays":1.54166666666667,"Amount":1.54166666666667}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-11T05:00:00Z"},"Arrival":{"Utc":"2020-09-11T05:00:00Z"}}]},"FromSubDisplayName":"CampdenParkTerm,StVincent","FromLocation":{"Code":"VCCRP"},"DepartureTime":{"Utc":"2020-09-11T05:00:00Z"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-12T18:00:00Z"}},{"VoyageNumber":{"NumberX":"TBN"},"VesselName":"TBN","VesselCode":{"Code":"TBN"},"TransportModeCode":{"Type":"F","Code":"FEED"},"ToSubDisplayName":"PuertoCortesTerm,Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-19T06:00:00Z"},"Arrival":{"Utc":"2020-09-19T06:00:00Z"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":956,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"LegSeqNumber":3,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":9360.00,"AmountinHours":156.00,"AmountInDays":6.5,"Amount":6.5}},"IsTBN":true,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-12T18:00:00Z"},"Arrival":{"Utc":"2020-09-12T18:00:00Z"}}]},"FromSubDisplayName":"RioHainaTerm,DomRep","FromLocation":{"Code":"DOHAI"},"DepartureTime":{"Utc":"2020-09-12T18:00:00Z"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-21T11:00:00Z"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-21T11:00:00Z"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-21T11:00:00Z"},"addedHours":null}],"RouteId":4,"Legs":[{"TransshipmentMatrixDetailId":1263,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT006"},"LocationCode":{"Code":"USPEF"},"DisplayName":"PortEverglades,FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"CRPT001"},"LocationCode":{"Code":"VCCRP"},"DisplayName":"CampdenPark,SaintVincent"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":3.75,"Amount":3.75}},{"TransshipmentMatrixDetailId":896,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"CRPT001"},"LocationCode":{"Code":"VCCRP"},"DisplayName":"CampdenPark,SaintVincent"},"LegSeqNumber":2,"EndPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":1.54166666666667,"Amount":1.54166666666667}},{"TransshipmentMatrixDetailId":956,"TransportMode":{"Type":"F","Code":"FEED"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"HAIT001"},"LocationCode":{"Code":"DOHAI"},"DisplayName":"RioHaina,DomRep"},"LegSeqNumber":3,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"PuertoCortes,Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":null,"AmountinHours":null,"AmountInDays":6.5,"Amount":6.5}}],"IsSelectedRoute":false,"ExpectedTimeOfDeparture":"2020-09-05T11:57:37.4077396Z","Duration":{"TimeUnit":"m","AmountinMinuteRounded":20160.0,"AmountinHours":336.0,"AmountInDays":14.0,"Amount":20160.0},"CalculatedContributionResult":{"Success":true,"ItemValues":[{"ValuesDataRevenue":[{"ValuesGroup":[{"TotalSum":4186.0,"SumOfVat":0.0,"SumOfValues":4186.0,"DocValuesData":[{"ItemNumber":"1","Unit":"1","TariffManr":24217.0,"TargetCurCode":"USD","Rate":3982.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"OceanFreight","CurrencyCode":"USD","ChargeCode":"NTFR","Basis":1.0,"AmountTarget":3982.0},{"ItemNumber":"1","Unit":"1","TariffManr":15638.0,"TargetCurCode":"USD","Rate":100.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"VesselFuelSurcharge","CurrencyCode":"USD","ChargeCode":"VFS","Basis":1.0,"AmountTarget":100.0},{"ItemNumber":"1","Unit":"1","TariffManr":7835.0,"TargetCurCode":"USD","Rate":104.0,"Per":"C","MinMaxFlag":"N","GroupName":"OTHERADD","Description":"TerminalHandlingCharge-Destination","CurrencyCode":"USD","ChargeCode":"THCD","Basis":1.0,"AmountTarget":104.0}]}],"TargetCurrency":"USD"}],"ValuesDataCost":[],"ItemNumber":1,"ContributionData":[{"TargetCurrency":"USD","SumRevenue":4186.0,"SumCost":0.0,"ContributionAmount":4186.0}]}],"Errors":[]},"BookingRouteResult":{"RouteId":4,"AllSalesTariffIds":[24217,15638,7835],"AllPurchaseTariffIds":[]}}]}';
    return responsewrap;
  }

  public static String selectedroutes() {
    String routes = '[{"routeId":"1"}]';
    return routes;
  }

  public static String rateMapping() {
    String ratemap = '[{"itemNum":1,"containerName":"20 Dry Container","quantity":"11","containerCode":"20DS"}]';
    return ratemap;
  }

  public static Map<String, Integration_Service__mdt> FindARoute_getIntegrationServiceTestMap() {
    String data = '{';
    String findARoutePost = '{"MasterLabel" : "FindARoutePOST", "Service__c":"/service","Request_Type__c":"POST", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String getService = '{"MasterLabel" : "GetService", "Service__c":"/getservice","Request_Type__c":"GET", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String postService = '{"MasterLabel" : "PostService", "Service__c":"/postservice","Request_Type__c":"POST", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String putService = '{"MasterLabel" : "PutService", "Service__c":"/putservice","Request_Type__c":"PUT", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String deleteService = '{"MasterLabel" : "DeleteService", "Service__c":"/deleteservice","Request_Type__c":"DELETE", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    String errorService = '{"MasterLabel" : "ErrorService", "Service__c":"/errorservice","Request_Type__c":"GET", "Timeout__c":"12000", "Related_Service_Environment_Name__c":"Service", "Content_Type__c": "application/json"}';
    data += '"FindARoutePOST" : ' + findARoutePost + ',';
    data += '"GetService" : ' + getService + ',';
    data += '"PostService" : ' + postService + ',';
    data += '"PutService" : ' + putService + ',';
    data += '"DeleteService" : ' + deleteService + ',';
    data += '"ErrorService" : ' + errorService;
    data += '}';

    return (Map<String, Integration_Service__mdt>) JSON.deserialize(
      data,
      Map<String, Integration_Service__mdt>.class
    );
  }

  /*** Drupad ***/

  public static Map<String, Custom_Table_Json__mdt> getCustomJsonTableTestMap() {
    String data = '{';
    data += '"Test":{"MasterLabel":"Test","Card_Class_Name__c":"row-data-repeat","SObjectApiName__c":"Account","Id":"123456"},';
    data += '"Error":{"MasterLabel" : "Error", "Card_Class_Name__c":"row-data-repeat", "SObjectApiName__c":"Account","Id":"00000"}';
    data += '}';
    return (Map<String, Custom_Table_Json__mdt>) JSON.deserialize(
      data,
      Map<String, Custom_Table_Json__mdt>.class
    );
  }

  public static Map<String, List<Custom_Table_Json_Field__mdt>> getCustomJsonTableNameVsFields() {
    String data = '{';
    String testField = '[{"MasterLabel" : "Test", "Label__c":"Test", "Data_type__c" : "Test", "Field_Name__c" : "Test", "Redirect_Url__c" : "Test", "Date_Format__c" : "Test","Is_Table_Column__c" : true, "Is_Reference__c" : false, "Order__c" : 1 }]';
    data += '"Test" : ' + testField;
    data += '}';
    return (Map<String, List<Custom_Table_Json_Field__mdt>>) JSON.deserialize(
      data,
      Map<String, List<Custom_Table_Json_Field__mdt>>.class
    );
  }

  public static String getTableJsonTest(Boolean isError) {
    String jsonString = '{';
    String obj = '';
    if (!isError) {
      obj = 'Account';
    }
    jsonString += '"sObjectApiName":"' + obj + '",';
    jsonString += '"filters":[{"refId":"1","fieldName":"Type","values":["Customer"],"operator":"IN"},{"refId":"2","fieldName":"Name","values":["Test%"],"operator":"LIKE"},{"refId":"3","fieldName":"Owner.Name","values":["Test"],"operator":"NOT IN"}],';
    jsonString += '"filterLogic":"{1} AND {2} AND {3}","limitRecords":10,"offset":0,';
    jsonString += '"fieldsToFetch":[';
    jsonString += '{"classNameRow":"acc-col","dataType":"text","fieldName":"Owner.LastName","isRef":false,"isTableColumn":false,"label":"Owner Last Name","order":2},';
    jsonString += '{"classNameRow":"acc-col","dataType":"text","fieldName":"{Owner First Name} {Owner Last Name}","isRef":true,"isTableColumn":true,"label":"Owner","order":3},';
    jsonString += '{"classNameRow":"acc-col account-name-col","dataType":"url","fieldName":"Name","isRef":false,"isTableColumn":true,"label":"Account Name","order":1,"redirectUrl":"/accountDetail/{Id}"},';
    jsonString += '{"classNameRow":"acc-col","dataType":"picklist","fieldName":"Type","isRef":false,"isTableColumn":true,"label":"Record Type","order":4},';
    jsonString += '{"classNameRow":"acc-col","dataType":"text","fieldName":"Owner.FirstName","isRef":false,"isTableColumn":false,"label":"Owner First Name","order":5},';
    jsonString += '{"classNameRow":"acc-col","dataType":"text","fieldName":"AccountNumber","isRef":false,"isTableColumn":false,"label":"AccountNumber","order":6},';
    jsonString += '{"classNameRow":"acc-col","dataType":"text","fieldName":"AccountSource","isRef":false,"isTableColumn":false,"label":"AccountSource","order":7}';
    jsonString += '],';
    jsonString += '"sortBy":[{"fieldName":"Name","order":"asc"}]';
    jsonString += '}';
    return jsonString;
  }

  /*** Richa ***/

  public static List<Account> getAccountData(
    String parentAccountId,
    String nameInitial,
    Integer numberOfRecords,
    boolean isInsert
  ) {
    List<Account> accountList = new List<Account>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      if (parentAccountId == 'NA') {
        Account acc = new Account(
          Name = (i == 0 ? nameInitial : nameInitial + ' ' + i),
          Type = 'Customer',
          Address_Line_1__c = 'Test Address',
          City__c = 'Test',
          Country__c = 'IN'
        );
        accountList.add(acc);
      } else {
        Account acc = new Account(
          Name = (i == 0 ? nameInitial : nameInitial + ' ' + i),
          ParentId = (Id) parentAccountId,
          Address_Line_1__c = 'Test Address',
          City__c = 'Test',
          Country__c = 'IN'
        );
        accountList.add(acc);
      }
    }
    if (isInsert)
      insert accountList;
    return accountList;
  }

  public static List<Contract> getContracts(
    String nameInitial,
    Id accountId,
    Integer numberOfRecords,
    boolean isInsert
  ) {
    List<Contract> contracts = new List<Contract>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Contract contract = new Contract(
        Name = (i == 0 ? nameInitial : nameInitial + ' ' + i),
        AccountId = accountId
      );
      contracts.add(contract);
    }
    if (isInsert) {
      insert contracts;
    }
    return contracts;
  }

  public static List<Booking__c> getBookingWithContractNumber(
    String ContractNumber,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Booking__c> bookings = new List<Booking__c>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Booking__c booking = new Booking__c(
        Contract_Number__c = ContractNumber,
        Booked_Date__c = Date.valueOf('2020-06-09')
      );
      bookings.add(booking);
    }
    if (isInsert) {
      insert bookings;
    }
    return bookings;
  }

  public static List<Booking__c> getBookingWithChildren(
    Id accountId,
    String description,
    String cargoType,
    String containerType,
    Integer numberOfRecords
  ) {
    List<Booking__c> bookings = new List<Booking__c>();

    bookings = getBookingRecords(accountId, description, numberOfRecords, true);
    List<Party__c> shipperParties = getPartyRecords(bookings, 'SHP', 1, true);
    List<Party__c> consigneeParties = getPartyRecords(bookings, 'CON', 1, true);
    List<Party__c> forwarderParties = getPartyRecords(bookings, 'FOR', 1, true);
    List<Party__c> supplierParties = getPartyRecords(bookings, 'SUP', 1, true);
    List<Party__c> notifyParties = getPartyRecords(bookings, 'NOT', 1, true);

    List<Transport__c> transports = getTransportRecords(bookings, 1, true);
    List<Stop__c> stops = getStopRecords(transports, 2, true);

    List<Shipment__c> shipments = getShipmentRecords(bookings, 2, true);
    List<Voyage__c> voyages = getVoyageRecords(shipments, 2, true);
    List<FreightDetail__c> freightDetails = getFreightDetailRecords(
      shipments,
      cargoType,
      1,
      true
    );
    List<Requirement__c> requirements = getRequirementRecords(
      containerType,
      freightDetails,
      1,
      true
    );
    List<Commodity__c> commodities = getCommodityRecords(
      freightDetails,
      2,
      true
    );
    List<Equipment__c> equipments = getEquipmentRecords(requirements, 1, true);
    return bookings;
  }

  public static List<Booking__c> getBookingRecords(
    Id accountId,
    String description,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    System.debug('accountId in utility ' + accountId);
    List<Booking__c> bookings = new List<Booking__c>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Booking__c booking = new Booking__c(
        Booked_Date__c = Date.valueOf('2020-06-09'),
        Description__c = description,
        Account__c = accountId,
        Is_Hazardous__c = true,
        Booking_Number__c = 'BKCAT' +
          i +
          String.valueOf(Datetime.now().formatGMT('yyyyMMddHHmmssSSS'))
      );
      bookings.add(booking);
    }
    if (isInsert) {
      insert bookings;
    }
    return bookings;
  }

  public static List<Requirement__c> getRequirementRecords(
    String containerType,
    List<FreightDetail__c> freightDetails,
    Integer numberOfRecords,
    Boolean isInsert
  ) {
    List<Requirement__c> requirements = new List<Requirement__c>();
    for (FreightDetail__c freightDetail : freightDetails) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Requirement__c requirement = new Requirement__c(
          Name = (i == 0 ? freightDetail.Name : freightDetail.Name + i),
          Freight__c = freightDetail.Id,
          Container_Type__c = containerType
        );
        requirements.add(requirement);
      }
    }
    if (isInsert) {
      insert requirements;
    }
    return requirements;
  }

  public static List<Quote__c> CreateQuote(Integer intNumberofQuotes) {
    List<Quote__c> listquotes = new List<Quote__c>();
    for (Integer intIndex = 0; intIndex < intNumberofQuotes; intIndex++) {
      Quote__c newquote = new Quote__c();
      newquote.Status__c = 'Active';
      listquotes.add(newquote);
    }
    return listquotes;
  }

  public static List<Charge_Line__c> CreateChargeLine(
    Id quoteId,
    Integer intNumberofChargeLines
  ) {
    List<Charge_Line__c> listChargeLines = new List<Charge_Line__c>();
    for (Integer intIndex = 0; intIndex < intNumberofChargeLines; intIndex++) {
      Charge_Line__c newChargeLine = new Charge_Line__c();
      newChargeLine.Name = (intIndex == 0
        ? 'ChargeLine'
        : 'ChargeLine' + intIndex);
      newChargeLine.Quote__c = quoteId;
      newChargeLine.Item_Code__c = '20DS';
      newChargeLine.Amount_Target__c = 100;
      listChargeLines.add(newChargeLine);
    }
    return listChargeLines;
  }

  public static Bill_Of_Lading__c getBillOfLading(
    Booking__c booking,
    String billOfLadingNumber,
    Integer numberOfRecords
  ) {
    Bill_Of_Lading__c bol = new Bill_Of_Lading__c();
    bol.Name = billOfLadingNumber;
    bol.Bill_Of_Lading_Number__c = billOfLadingNumber;
    bol.Bill_of_lading_Status__c = 'IN PROCESS';
    insert bol;
    List<Party__c> shipperParties = getPartyRecordsBOL(
      booking,
      bol.Id,
      'SHP',
      1,
      true
    );
    List<Party__c> consigneeParties = getPartyRecordsBOL(
      booking,
      bol.Id,
      'CON',
      1,
      true
    );
    List<Party__c> forwarderParties = getPartyRecordsBOL(
      booking,
      bol.Id,
      'FOR',
      1,
      true
    );
    List<Party__c> supplierParties = getPartyRecordsBOL(
      booking,
      bol.Id,
      'SUP',
      1,
      true
    );
    List<Party__c> notifyParties = getPartyRecordsBOL(
      booking,
      bol.Id,
      'NOT',
      1,
      true
    );
    CreateChargeLineBOL(bol.Id, 1);
    return bol;
  }

  public static List<Party__c> getPartyRecordsBOL(
    Booking__c booking,
    String bolId,
    String partyType,
    Integer numOfRecForEachPartyType,
    Boolean isInsert
  ) {
    List<Party__c> parties = new List<Party__c>();
    for (Integer i = 0; i < numOfRecForEachPartyType; i++) {
      Party__c party = new Party__c(
        Name = (i == 0
          ? booking.Name + ':' + partyType
          : booking.Name + ':' + partyType + ' ' + i),
        Booking__c = booking.Id,
        Type__c = partyType,
        Reference_Number__c = '12345',
        Destination_Tax_Id_Number__c = '78965',
        Bill_Of_Lading_Number__c = bolId
      );
      parties.add(party);
    }
    if (isInsert) {
      insert parties;
    }
    return parties;
  }

  public static List<Charge_Line__c> CreateChargeLineBOL(
    Id bolId,
    Integer intNumberofChargeLines
  ) {
    List<Charge_Line__c> listChargeLines = new List<Charge_Line__c>();
    for (Integer intIndex = 0; intIndex < intNumberofChargeLines; intIndex++) {
      Charge_Line__c newChargeLine = new Charge_Line__c();
      newChargeLine.Name = (intIndex == 0
        ? 'ChargeLine'
        : 'ChargeLine' + intIndex);
      newChargeLine.Bill_Of_Lading_Number__c = bolId;
      newChargeLine.Item_Code__c = '20DS';
      newChargeLine.Amount_Target__c = 100;
      listChargeLines.add(newChargeLine);
    }
    insert listChargeLines;
    return listChargeLines;
  }
}
