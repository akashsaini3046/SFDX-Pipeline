/*
 * Name: InitiativeRelationshipAddCmpController
 * Purpose: Controller class for Initiave relationship add  Component.
 * Author: Nagarro
 * Created Date: 07-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public without sharing class InitiativeRelationshipAddCmpController {
  /*
   * Method Name: getAccounts
   * Input Parameters:
   * String strSearchString: This holds search string.
   * String strInitiative: This holds initiative.
   * String strSelectedAccountValue : This holds accouts which are already selected.
   * String strSelectedAccFieldToSearch: This holds field on which search will preform.
   * Boolean boolSearchParentWithChild : This specified search type, i.e. search by parent or not.
   * Return value: List<AccountInitiativeWrapper>
   * Purpose: get accounts based on search string. Account should not be linked with same initiative.
   */
  @AuraEnabled
  public static List<AccountInitiativeWrapper> getAccounts(
    String strSearchString,
    String strInitiative,
    String strSelectedAccountValue,
    String strSelectedAccFieldToSearch,
    Boolean boolSearchParentWithChild
  ) {
    Map<Id, AccountInitiativeWrapper> mapAccountInitiativeWrapper = new Map<Id, AccountInitiativeWrapper>();
    Set<Id> setAccountsId = new Set<Id>();
    Integer intLimitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
    Integer intLimitRecords = Integer.valueOf(Label.AINI_LIMIT_RECORDS) + 1;
    List<String> lstSelectedAccounts = new List<String>();
    String strQueryString = '';
    Map<Id, Account> mapParentAccount = new Map<Id, Account>();
    Map<Id, List<Account>> mapParentToChildAccount = new Map<Id, List<Account>>();

    if (String.isBlank(strSelectedAccFieldToSearch)) {
      strSelectedAccFieldToSearch = ConstantClass.AINI_ACCOUNT_DEFAULT_SEARCH_FIELD;
    }

    if (String.isNotBlank(strSelectedAccountValue)) {
      lstSelectedAccounts = (List<String>) JSON.deserialize(
        strSelectedAccountValue,
        List<String>.class
      );
    }

    for (Goal_Initiative__c objGoalInitiative : [
      SELECT Id, Account__c
      FROM Goal_Initiative__c
      WHERE Initiative__c = :strInitiative
      LIMIT :intLimitRows
    ]) {
      setAccountsId.add(objGoalInitiative.Account__c);
    }

    intLimitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
    if (intLimitRows < intLimitRecords) {
      intLimitRecords = intLimitRows;
    }

    if (String.isNotBlank(strSearchString)) {
      strSearchString = '%' + strSearchString.trim() + '%';
      //Handle the case when Parent with Child account search
      if (boolSearchParentWithChild) {
        strQueryString =
          'SELECT Id, Name, Industry, Parent.Name, Owner.Name FROM Account WHERE (' +
          strSelectedAccFieldToSearch +
          ' LIKE :strSearchString AND Id NOT IN :setAccountsId AND Primary_Account__c = TRUE) OR Id IN :lstSelectedAccounts ORDER BY Name LIMIT :intLimitRecords';
        for (
          Account objAccount : (List<Account>) Database.query(strQueryString)
        ) {
          AccountInitiativeWrapper objAccountInitiativeWrapper = new AccountInitiativeWrapper();
          objAccountInitiativeWrapper.label = objAccount.Name;
          objAccountInitiativeWrapper.value = objAccount.Id;
          mapParentAccount.put(objAccount.Id, objAccount);
        }

        intLimitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        //Create parent child map
        for (Account objChildAccount : [
          SELECT Id, Name, Industry, ParentId, Parent.Name, Owner.Name
          FROM Account
          WHERE
            ParentId IN :mapParentAccount.keySet()
            AND Id NOT IN :setAccountsId
          ORDER BY Name
          LIMIT :intLimitRows
        ]) {
          if (mapParentToChildAccount.containsKey(objChildAccount.ParentId)) {
            mapParentToChildAccount.get(objChildAccount.ParentId)
              .add(objChildAccount);
          } else {
            mapParentToChildAccount.put(
              objChildAccount.ParentId,
              new List<Account>{ objChildAccount }
            );
          }
        }

        //Create wrapper for response order by parent and then relected children
        for (Id objAccountId : mapParentAccount.keySet()) {
          AccountInitiativeWrapper objAccountInitiativeWrapper = new AccountInitiativeWrapper();
          objAccountInitiativeWrapper.label = mapParentAccount.get(objAccountId)
            .Name;
          objAccountInitiativeWrapper.value = objAccountId;
          mapAccountInitiativeWrapper.put(
            objAccountId,
            objAccountInitiativeWrapper
          );
          if (mapParentToChildAccount.containsKey(objAccountId)) {
            for (
              Account objAccount : mapParentToChildAccount.get(objAccountId)
            ) {
              objAccountInitiativeWrapper = new AccountInitiativeWrapper();
              objAccountInitiativeWrapper.label = objAccount.Name;
              objAccountInitiativeWrapper.value = objAccount.Id;
              mapAccountInitiativeWrapper.put(
                objAccount.Id,
                objAccountInitiativeWrapper
              );
            }
          }
        }
      } else {
        strQueryString =
          'SELECT Id, Name, Industry, Parent.Name, Owner.Name FROM Account WHERE (' +
          strSelectedAccFieldToSearch +
          ' LIKE :strSearchString AND Id NOT IN :setAccountsId) OR Id IN :lstSelectedAccounts ORDER BY Name LIMIT :intLimitRecords';
        for (
          Account objAccount : (List<Account>) Database.query(strQueryString)
        ) {
          AccountInitiativeWrapper objAccountInitiativeWrapper = new AccountInitiativeWrapper();
          objAccountInitiativeWrapper.label = objAccount.Name;
          objAccountInitiativeWrapper.value = objAccount.Id;
          mapAccountInitiativeWrapper.put(
            objAccount.Id,
            objAccountInitiativeWrapper
          );
        }
      }
    } else {
      for (Account objAccount : [
        SELECT Id, Name, Industry, Parent.Name, Owner.Name
        FROM Account
        WHERE Id IN :lstSelectedAccounts
        ORDER BY Name
        LIMIT :intLimitRows
      ]) {
        AccountInitiativeWrapper objAccountInitiativeWrapper = new AccountInitiativeWrapper();
        objAccountInitiativeWrapper.label = objAccount.Name;
        objAccountInitiativeWrapper.value = objAccount.Id;
        mapAccountInitiativeWrapper.put(
          objAccount.Id,
          objAccountInitiativeWrapper
        );
      }
    }
    return mapAccountInitiativeWrapper.values();
  }

  /*
   * Method Name: getLeads
   * Input Parameters:
   * String strSearchString: This holds search string.
   * String strInitiative: This holds initiative.
   * String strSelectedLeadValue : This holds leads which are already selected.
   * String strSelectedLeadFieldToSearch: This holds field on which search will preform.
   * Return value: List<LeadInitiativeWrapper>
   * Purpose: get Lead based on search string and lead not linked to any initiative.
   */
  @AuraEnabled
  public static List<LeadInitiativeWrapper> getLeads(
    String strSearchString,
    String strInitiative,
    String strSelectedLeadValue,
    String strSelectedLeadFieldToSearch
  ) {
    List<LeadInitiativeWrapper> lstLeadInitiativeWrapper = new List<LeadInitiativeWrapper>();
    Integer intLimitRecords = Integer.valueOf(Label.AINI_LIMIT_RECORDS) + 1;
    List<String> lstSelectedLeads = new List<String>();
    String strQueryString = '';

    if (String.isBlank(strSelectedLeadFieldToSearch)) {
      strSelectedLeadFieldToSearch = ConstantClass.AINI_LEAD_DEFAULT_SEARCH_FIELD;
    }

    if (String.isNotBlank(strSelectedLeadValue)) {
      lstSelectedLeads = (List<String>) JSON.deserialize(
        strSelectedLeadValue,
        List<String>.class
      );
    }

    if (String.isNotBlank(strSearchString)) {
      strSearchString = '%' + strSearchString.trim() + '%';
      strQueryString =
        'SELECT Id, Name, Company, Industry, Status, Owner.Name, Lead_Full_Name__c FROM Lead WHERE (IsConverted = false AND (' +
        strSelectedLeadFieldToSearch +
        ' LIKE :strSearchString) AND Initiative__c = null) OR Id IN :lstSelectedLeads ORDER BY Company LIMIT :intLimitRecords';
      for (Lead objLead : (List<Lead>) Database.query(strQueryString)) {
        LeadInitiativeWrapper objLeadInitiativeWrapper = new LeadInitiativeWrapper();
        objLeadInitiativeWrapper.value = objLead.Id;
        objLeadInitiativeWrapper.label = objLead.Company;
        lstLeadInitiativeWrapper.add(objLeadInitiativeWrapper);
      }
    } else {
      for (Lead objLead : [
        SELECT
          Id,
          Name,
          Company,
          Industry,
          Status,
          Owner.Name,
          Lead_Full_Name__c
        FROM Lead
        WHERE Id IN :lstSelectedLeads
        ORDER BY Company
        LIMIT :intLimitRecords
      ]) {
        LeadInitiativeWrapper objLeadInitiativeWrapper = new LeadInitiativeWrapper();
        objLeadInitiativeWrapper.value = objLead.Id;
        objLeadInitiativeWrapper.label = objLead.Company;
        lstLeadInitiativeWrapper.add(objLeadInitiativeWrapper);
      }
    }
    return lstLeadInitiativeWrapper;
  }

  /*
   * Method Name: saveInitiativeAccount
   * Input Parameters:
   * String strSelectedAccounts: This holds selected accounts id.
   * String strInitiative: This holds initiative id.
   * Return value: Map<String, String>
   * Purpose: based on selected accounts and initiative, create Goal Initiative and insert.
   */
  @AuraEnabled
  public static Map<String, String> saveInitiativeAccount(
    String strSelectedAccounts,
    String strInitiative
  ) {
    String strSaveResult = ConstantClass.AINI_SAVE_RESULT_TRUE;
    String strErrorMessage = '';
    List<String> lstSelectedAccounts = new List<String>();
    List<Goal_Initiative__c> lstGoalInitiative = new List<Goal_Initiative__c>();
    List<Initiative__c> lstInitiative = [
      SELECT Id, Name
      FROM Initiative__c
      WHERE Id = :strInitiative
    ];

    if (
      String.isNotBlank(strSelectedAccounts) &&
      String.isNotBlank(strInitiative) &&
      lstInitiative != null &&
      lstInitiative.size() > 0
    ) {
      lstSelectedAccounts = (List<String>) JSON.deserialize(
        strSelectedAccounts,
        List<String>.class
      );
      if (lstSelectedAccounts != null) {
        for (String strAccountId : lstSelectedAccounts) {
          lstGoalInitiative.add(
            new Goal_Initiative__c(
              Name = lstInitiative[0].Name,
              Account__c = strAccountId,
              Initiative__c = strInitiative
            )
          );
        }
      }
    }

    if (lstGoalInitiative.size() > 0) {
      try {
        insert lstGoalInitiative;
      } catch (Exception objEx) {
        strSaveResult = ConstantClass.AINI_SAVE_RESULT_FALSE;
        strErrorMessage = objEx.getMessage();
        System.debug(
          'Error occured in InitiativeRelationshipAddCmpController->saveInitiativeAccount ' +
          objEx.getMessage()
        );
      }
    }

    return new Map<String, String>{
      'SAVE_RESULT' => strSaveResult,
      'ERROR_MESSAGE' => strErrorMessage
    };
  }

  /*
   * Method Name: saveInitiativeLead
   * Input Parameters:
   * String strSelectedAccounts: This holds selected accounts id.
   * String strInitiative: This holds initiative id.
   * Return value: Map<String, String>
   * Purpose: based on selected Leads and initiative, relate lead with initiative.
   */
  @AuraEnabled
  public static Map<String, String> saveInitiativeLead(
    String strSelectedLeads,
    String strInitiative
  ) {
    String strSaveResult = ConstantClass.AINI_SAVE_RESULT_TRUE;
    String strErrorMessage = '';
    List<String> lstSelectedLeads = new List<String>();
    List<Initiative__c> lstInitiative = [
      SELECT Id, Name
      FROM Initiative__c
      WHERE Id = :strInitiative
    ];
    List<Lead> lstLeadToLinkInitiative = new List<Lead>();

    if (
      String.isNotBlank(strSelectedLeads) &&
      String.isNotBlank(strInitiative) &&
      lstInitiative != null &&
      lstInitiative.size() > 0
    ) {
      lstSelectedLeads = (List<String>) JSON.deserialize(
        strSelectedLeads,
        List<String>.class
      );
      if (lstSelectedLeads != null) {
        for (String strLeadId : lstSelectedLeads) {
          lstLeadToLinkInitiative.add(
            new Lead(Id = strLeadId, Initiative__c = strInitiative)
          );
        }
      }
    }

    if (lstLeadToLinkInitiative.size() > 0) {
      try {
        update lstLeadToLinkInitiative;
      } catch (DmlException objDmlEx) {
        strSaveResult = ConstantClass.AINI_SAVE_RESULT_FALSE;
        strErrorMessage =
          Label.AINI_LEAD_ADD_ERROR_MESSAGE +
          '\n\n' +
          objDmlEx.getDmlMessage(0);
        System.debug(
          'Error occured in InitiativeRelationshipAddCmpController->saveInitiativeLead ' +
          objDmlEx.getMessage() +
          ' ' +
          objDmlEx.getStackTraceString()
        );
      } catch (Exception objEx) {
        strSaveResult = ConstantClass.AINI_SAVE_RESULT_FALSE;
        strErrorMessage = objEx.getMessage();
        System.debug(
          'Error occured in InitiativeRelationshipAddCmpController->saveInitiativeLead ' +
          objEx.getMessage() +
          ' ' +
          objEx.getStackTraceString()
        );
      }
    }

    return new Map<String, String>{
      'SAVE_RESULT' => strSaveResult,
      'ERROR_MESSAGE' => strErrorMessage
    };
  }

  /*
   * Method Name: isInitiativeActive
   * Input Parameters:
   * String strInitiative: This holds initiative.
   * Return value: Boolean
   * Purpose: checks if initiative active or not.
   */
  @AuraEnabled
  public static Boolean isInitiativeActive(String strInitiative) {
    Boolean isActive = true;
    if (String.isNotBlank(strInitiative)) {
      for (Initiative__c objInitiative : [
        SELECT Id, IsActive__c
        FROM Initiative__c
        WHERE Id = :strInitiative
      ]) {
        isActive = objInitiative.IsActive__c;
      }
    }
    return isActive;
  }

  /*
   * Method Name: getAccountById
   * Input Parameters:
   * String strAccountId: This holds account id.
   * Return value: Account
   * Purpose: return account by id.
   */
  @AuraEnabled
  public static Account getAccountById(String strAccountId) {
    Account objAccount = new Account();

    if (String.isNotBlank(strAccountId)) {
      objAccount = [SELECT Id, Name FROM Account WHERE Id = :strAccountId];
    }
    return objAccount;
  }

  /*
   * Method Name: getAllInitiative
   * Input Parameters:
   * String strAccountId : This holds account id.
   * Return value: List<InitiativeWrapper>
   * Purpose: return all Initiative. Initiative should not be linked with same account.
   */
  @AuraEnabled
  public static List<InitiativeWrapper> getAllInitiative(String strAccountId) {
    Integer intLimitRows;
    Set<Id> setInitiativeAssociatedToAccount = new Set<Id>();
    List<InitiativeWrapper> lstInitiativeWrapper = new List<InitiativeWrapper>();

    for (Goal_Initiative__c objGI : [
      SELECT Id, Initiative__c
      FROM Goal_Initiative__c
      WHERE Account__c = :strAccountId
    ]) {
      setInitiativeAssociatedToAccount.add(objGI.Initiative__c);
    }

    intLimitRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
    lstInitiativeWrapper.add(
      new InitiativeWrapper(
        Label.AINI_OPTION_SELECT_INITIATIVE,
        Label.AINI_OPTION_SELECT_INITIATIVE
      )
    );
    for (Initiative__c objInitiative : [
      SELECT Id, Name
      FROM Initiative__c
      WHERE
        IsActive__c = TRUE
        AND Initiative_Type__c = 'Open'
        AND Id NOT IN :setInitiativeAssociatedToAccount
      ORDER BY Name ASC
      LIMIT :intLimitRows
    ]) {
      lstInitiativeWrapper.add(
        new InitiativeWrapper(objInitiative.Name, objInitiative.Id)
      );
    }

    return lstInitiativeWrapper;
  }

  /*
   * Method Name: saveAccountInitiative
   * Input Parameters:
   * String strAccountId: This holds account id.
   * String strInitiativeId: This holds initiative id.
   * Return value: Map<String, String>
   * Purpose: This method will be called when initaitve is linked to Account from Account side. It will create goal initiative for account and initiative.
   */
  @AuraEnabled
  public static Map<String, String> saveAccountInitiative(
    String strAccountId,
    String strInitiativeId
  ) {
    String strSaveResult = ConstantClass.AINI_SAVE_RESULT_TRUE;
    String strErrorMessage = '';
    List<Goal_Initiative__c> objGI = new List<Goal_Initiative__c>();
    if (String.isNotBlank(strAccountId) && String.isNotBlank(strInitiativeId)) {
      objGI = [
        SELECT Id
        FROM Goal_Initiative__c
        WHERE Account__c = :strAccountId AND Initiative__c = :strInitiativeId
      ];
      if (objGI != null && objGI.size() > 0) {
        strSaveResult = ConstantClass.AINI_SAVE_RESULT_FALSE;
        strErrorMessage = Label.AINI_GOAL_INITIATIVE_UNIQUE_KEY_MESSAGE;
      } else {
        try {
          insert new Goal_Initiative__c(
            Account__c = strAccountId,
            Initiative__c = strInitiativeId
          );
        } catch (Exception objEx) {
          strSaveResult = ConstantClass.AINI_SAVE_RESULT_FALSE;
          strErrorMessage = objEx.getMessage();
          System.debug(
            'Error occured in InitiativeRelationshipAddCmpController->saveInitiativeLead ' +
            objEx.getMessage() +
            ' ' +
            objEx.getStackTraceString()
          );
        }
      }
    } else {
      strSaveResult = ConstantClass.AINI_SAVE_RESULT_FALSE;
      strErrorMessage = 'Initiative and Account is required';
    }

    return new Map<String, String>{
      'SAVE_RESULT' => strSaveResult,
      'ERROR_MESSAGE' => strErrorMessage
    };
  }

  /*
   * Method Name: getSearchFiled
   * Input Parameters:
   * String strObjectType : This holds object type.
   * Return value: List<SearchFieldWrapper>
   * Purpose: return field on which search can be performed.
   */
  @AuraEnabled
  public static List<SearchFieldWrapper> getSearchFiled(String strObjectType) {
    List<SearchFieldWrapper> lstSearchFieldWrapper = new List<SearchFieldWrapper>();

    for (Initiative_Search_Field_Metadata__mdt objSFM : [
      SELECT MasterLabel, API_Name__c, Field_Name__c
      FROM Initiative_Search_Field_Metadata__mdt
      WHERE MasterLabel = :strObjectType
      ORDER BY Field_Name__c ASC
    ]) {
      SearchFieldWrapper objSearchFieldWrapper = new SearchFieldWrapper();
      objSearchFieldWrapper.label = objSFM.Field_Name__c;
      objSearchFieldWrapper.value = objSFM.API_Name__c;
      lstSearchFieldWrapper.add(objSearchFieldWrapper);
    }

    return lstSearchFieldWrapper;
  }
}
