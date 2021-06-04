/*
 * Name: ADAccountDashboardUtil
 * Purpose: Utility class which contains utility methods which are used by various component controllers of account dashboard
 * Author: Nagarro
 * Created Date: 08-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADAccountDashboardUtil {
  public static List<Opportunity> opportunityList;

  /*
   * This is constructor.
   */
  public ADAccountDashboardUtil() {
  }

  /*
   * Method Name: getAllRelatedAccount
   * Input Parameters:
   * Id accountId: This holds parent/current account Id.
   * Return value: Map<Id, Account>
   * Purpose: This method returns id of all clild accounts along with extreem parent(account itself).
   */
  public static Map<Id, Account> getAllRelatedAccount(Id accountId) {
    Map<Id, Account> mapAccount = new Map<Id, Account>();
    if (null != accountId) {
      mapAccount = new Map<Id, Account>(
        [
          SELECT Id, Name, OwnerId, Owner.Name
          FROM Account
          WHERE
            Id = :accountId
            OR Parent.Id = :accountId
            OR Parent.Parent.Id = :accountId
            OR Parent.Parent.Id = :accountId
            OR Parent.Parent.Parent.Id = :accountId
            OR Parent.Parent.Parent.Parent.Id = :accountId
            OR Parent.Parent.Parent.Parent.Parent.Id = :accountId
          ORDER BY Name
        ]
      );
    }
    return mapAccount;
  }

  /*
   * Method Name: getAllRelatedOpportunities
   * Input Parameters:
   * List<Id> listAccountId: This holds accounts ids of current/parent accounf along with their children.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: List<Opportunity>
   * Purpose: This method returns opportunities which are related to accounts(passed in listAccountId).
   */
  public static List<Opportunity> getAllRelatedOpportunities(
    List<Id> listAccountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    opportunityList = new List<Opportunity>();

    if (objMasterFilter.strSelectedYear == Label.AD_PICKLIST_VAL_ALL_YEAR) {
      opportunityList = [
        SELECT
          Id,
          StageName,
          Amount,
          Probability,
          isClosed,
          NormalisedRevenue__c,
          CloseDate,
          Est_Decision_Year__c
        FROM Opportunity
        WHERE AccountId IN :listAccountId
      ];
    } else if (String.isNotBlank(objMasterFilter.strSelectedYear)) {
      opportunityList = [
        SELECT
          Id,
          StageName,
          Amount,
          Probability,
          isClosed,
          NormalisedRevenue__c,
          CloseDate,
          Est_Decision_Year__c
        FROM Opportunity
        WHERE
          AccountId IN :listAccountId
          AND CALENDAR_YEAR(CloseDate) = :Integer.valueOf(
            objMasterFilter.strSelectedYear
          )
      ];
    } else {
      opportunityList = [
        SELECT
          Id,
          StageName,
          Amount,
          Probability,
          isClosed,
          NormalisedRevenue__c,
          CloseDate,
          Est_Decision_Year__c
        FROM Opportunity
        WHERE
          AccountId IN :listAccountId
          AND CALENDAR_YEAR(CloseDate) = :Date.today().year()
      ];
    }

    return opportunityList;
  }

  /*
   * Method Name: getAllRelatedOpenOpportunities
   * Input Parameters:
   * List<Id> listAccountId: This holds accounts ids of current/parent accounf along with their children.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: List<Opportunity>
   * Purpose: This method returns open opportunities which are related to accounts(passed in listAccountId).
   */
  public static List<Opportunity> getAllRelatedOpenOpportunities(
    List<Id> listAccountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    opportunityList = new List<Opportunity>();

    if (objMasterFilter.strSelectedYear == Label.AD_PICKLIST_VAL_ALL_YEAR) {
      opportunityList = [
        SELECT
          Id,
          StageName,
          Amount,
          Probability,
          isClosed,
          NormalisedRevenue__c,
          CloseDate,
          Est_Decision_Year__c
        FROM Opportunity
        WHERE AccountId IN :listAccountId AND isClosed = :false
      ];
    } else if (String.isNotBlank(objMasterFilter.strSelectedYear)) {
      opportunityList = [
        SELECT
          Id,
          StageName,
          Amount,
          Probability,
          isClosed,
          NormalisedRevenue__c,
          CloseDate,
          Est_Decision_Year__c
        FROM Opportunity
        WHERE
          AccountId IN :listAccountId
          AND CALENDAR_YEAR(CloseDate) = :Integer.valueOf(
            objMasterFilter.strSelectedYear
          )
          AND isClosed = :false
      ];
    } else {
      opportunityList = [
        SELECT
          Id,
          StageName,
          Amount,
          Probability,
          isClosed,
          NormalisedRevenue__c,
          CloseDate,
          Est_Decision_Year__c
        FROM Opportunity
        WHERE
          AccountId IN :listAccountId
          AND CALENDAR_YEAR(CloseDate) = :Date.today().year()
          AND isClosed = :false
      ];
    }

    return opportunityList;
  }

  /*
   * Method Name: getAllRelatedOpportunitiesWithoutFilter
   * Input Parameters:
   * List<Id> listAccountId: This holds accounts ids of current/parent accounf along with their children.
   * Return value: List<Opportunity>
   * Purpose: This method returns opportunities which are related to accounts(passed in listAccountId) without applying filters.
   */
  public static List<Opportunity> getAllRelatedOpportunitiesWithoutFilter(
    List<Id> listAccountId
  ) {
    opportunityList = new List<Opportunity>();
    opportunityList = [
      SELECT
        Id,
        StageName,
        Amount,
        Probability,
        isClosed,
        NormalisedRevenue__c,
        CloseDate,
        Est_Decision_Year__c
      FROM Opportunity
      WHERE AccountId IN :listAccountId
    ];
    return opportunityList;
  }

  /*
   * Method Name: getOpportunityStage
   * Input Parameters:
   * Return value: List<String>
   * Purpose: This method returns opportunity stages by querying opportunity metadata.
   */
  public static List<String> getOpportunityStage() {
    List<String> lstOpportunityStage = new List<String>();
    Schema.DescribeFieldResult opportunityStageDescribeResult = Opportunity.StageName.getDescribe();
    for (
      Schema.PicklistEntry objPicklistEntry : opportunityStageDescribeResult.getPicklistValues()
    ) {
      lstOpportunityStage.add(objPicklistEntry.getLabel());
    }
    return lstOpportunityStage;
  }

  /*
   * Method Name: getOpportunityStageMap
   * Input Parameters:
   * Return value: Map<String, String>
   * Purpose: This method returns opportunity stage map(stage label and value map) by querying opportunity metadata.
   */
  public static Map<String, String> getOpportunityStageMap() {
    Map<String, String> mapOpportunityStage = new Map<String, String>();
    Schema.DescribeFieldResult opportunityStageDescribeResult = Opportunity.StageName.getDescribe();
    for (
      Schema.PicklistEntry objPicklistEntry : opportunityStageDescribeResult.getPicklistValues()
    ) {
      mapOpportunityStage.put(
        objPicklistEntry.getValue(),
        objPicklistEntry.getLabel()
      );
    }
    return mapOpportunityStage;
  }

  /*
   * Method Name: getAllChildAccounts
   * Input Parameters:
   * Id accountId: This holds parent/current account Id.
   * Return value: List<Account>
   * Purpose: This method returns list of child account(to maintain order of entry) with alphabetical order.
   */
  public static List<Account> getAllChildAccounts(Id accountId) {
    List<Account> lstAccounts = new List<Account>();
    if (null != accountId) {
      lstAccounts = [
        SELECT Id, Name
        FROM Account
        WHERE
          Parent.Id = :accountId
          OR Parent.Parent.Id = :accountId
          OR Parent.Parent.Id = :accountId
          OR Parent.Parent.Parent.Id = :accountId
          OR Parent.Parent.Parent.Parent.Id = :accountId
          OR Parent.Parent.Parent.Parent.Parent.Id = :accountId
        ORDER BY Name
      ];
    }
    return lstAccounts;
  }

  /*
   * Method Name: getAllChildAccountsWithParent
   * Input Parameters:
   * Id accountId: This holds parent/current account Id.
   * Return value: List<Account>
   * Purpose: This method returns list of chiild account(to maintain order of entry) where first entry is the parent and remaining are
   * children with alphabetical order.
   */
  public static List<Account> getAllChildAccountsWithParent(Id accountId) {
    List<Account> lstAccounts = new List<Account>();
    lstAccounts = [SELECT Id, Name FROM Account WHERE Id = :accountId];
    lstAccounts.addAll(getAllChildAccounts(accountId));
    return lstAccounts;
  }

  /*
   * Method Name: getAllActiveUsers
   * Input Parameters:
   * Return value: List<User>
   * Purpose: This method returns list of active users.
   */
  public static List<User> getAllActiveUsers() {
    return [SELECT Id, Name FROM User WHERE isActive = TRUE ORDER BY Name];
  }

  /*
   * Method Name: getPicklistYear
   * Input Parameters:
   * Return value: List<String>
   * Purpose: This method returns list of years to be shown on dropdown UI.
   */
  public static List<String> getPicklistYear() {
    List<String> strYearList = new List<String>();
    Date dateToday = Date.today();
    for (
      Integer yearIndex = Integer.valueOf(Label.AD_YEAR_START);
      yearIndex <=
      dateToday.year() + Integer.valueOf(Label.AD_NEXT_HOW_MANY_YEAR);
      yearIndex++
    ) {
      strYearList.add(String.valueOf(yearIndex));
    }
    return strYearList;
  }

  /*
   * Method Name: getCurrentYear
   * Input Parameters:
   * Return value: String
   * Purpose: This method returns current year.
   */
  public static String getCurrentYear() {
    return String.valueOf(Date.today().year());
  }

  /*
   * Method Name: applyAccountFilter
   * Input Parameters:
   * Map<Id, Account> mapAccount: This holds account on which filter will be applied.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: List<Id>
   * Purpose: This method applies account name/owner filter and returns the filtered records.
   */
  public static List<Id> applyAccountFilter(
    Map<Id, Account> mapAccount,
    ADMasterFilterWrapper objMasterFilter
  ) {
    List<Id> lstFilteredAccounts = new List<Id>();
    List<Id> lstAllAccountIds = new List<Id>();
    lstAllAccountIds.addAll(mapAccount.keySet());
    //If no account level filter is selected or no account/owner has been selected then no filter applied
    if (
      null == objMasterFilter ||
      objMasterFilter.strSelectedTopFilter == Label.AD_PICKLIST_VAL_NONE ||
      objMasterFilter.strSelectedTopFilter ==
      Label.AD_PICKLIST_VAL_ALL_ACCOUNTS ||
      String.isBlank(objMasterFilter.strSelectedTopFilter) ||
      (objMasterFilter.strSelectedTopFilter ==
      Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME &&
      objMasterFilter.lstSelectedAccounts.size() == 0) ||
      (objMasterFilter.strSelectedTopFilter ==
      Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER &&
      objMasterFilter.lstSelectedOwners.size() == 0)
    ) {
      return lstAllAccountIds;
    } else {
      if (
        null != objMasterFilter &&
        objMasterFilter.strSelectedTopFilter ==
        Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_NAME
      ) {
        if (
          null != objMasterFilter.lstSelectedAccounts &&
          objMasterFilter.lstSelectedAccounts.size() > 0
        ) {
          for (Account objAccount : mapAccount.values()) {
            if (objMasterFilter.lstSelectedAccounts.contains(objAccount.Id)) {
              lstFilteredAccounts.add(objAccount.Id);
            }
          }
        }
      } else if (
        null != objMasterFilter &&
        objMasterFilter.strSelectedTopFilter ==
        Label.AD_PICKLIST_VAL_FILTER_BY_ACCOUNT_OWNER
      ) {
        if (
          null != objMasterFilter.lstSelectedOwners &&
          objMasterFilter.lstSelectedOwners.size() > 0
        ) {
          for (Account objAccount : mapAccount.values()) {
            if (
              objMasterFilter.lstSelectedOwners.contains(objAccount.OwnerId)
            ) {
              lstFilteredAccounts.add(objAccount.Id);
            }
          }
        }
      }

      return lstFilteredAccounts;
    }
  }

  /*
   * Method Name: applyOpportunityFilter
   * Input Parameters:
   * List<Opportunity> lstOpportunities: This holds opportunities on which filter will be applied.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: List<Opportunity>
   * Purpose: This method applies opportunity size and year filter and returns the filtered records.
   */
  public static List<Opportunity> applyOpportunityFilter(
    List<Opportunity> lstOpportunities,
    ADMasterFilterWrapper objMasterFilter
  ) {
    //If no opportunity level filter is applied then return all opportunities
    if (
      null == objMasterFilter ||
      (String.isBlank(objMasterFilter.strOppSizeVal) &&
      String.isBlank(objMasterFilter.strSelectedYear))
    ) {
      return lstOpportunities;
    } else {
      if (
        String.isNotBlank(objMasterFilter.strOppSizeVal) &&
        String.isNotBlank(objMasterFilter.strSelectedOppSizeFilterOperator) &&
        objMasterFilter.strSelectedOppSizeFilterOperator !=
        Label.AD_PICKLIST_VAL_NONE
      ) {
        lstOpportunities = applyOpportunitySizeFilter(
          lstOpportunities,
          objMasterFilter
        );
      }
      if (
        String.isNotBlank(objMasterFilter.strSelectedYear) &&
        objMasterFilter.strSelectedYear != Label.AD_PICKLIST_VAL_NONE &&
        objMasterFilter.strSelectedYear != Label.AD_PICKLIST_VAL_ALL_YEAR
      ) {
        lstOpportunities = applyOpportunityYearFilter(
          lstOpportunities,
          objMasterFilter
        );
      }
      return lstOpportunities;
    }
  }

  /*
   * Method Name: applyOpportunitySizeFilter
   * Input Parameters:
   * List<Opportunity> lstOpportunities: This holds opportunities on which filter will be applied.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: List<Opportunity>
   * Purpose: This method applies opportunity size filter and returns the filtered records.
   */
  public static List<Opportunity> applyOpportunitySizeFilter(
    List<Opportunity> lstOpportunities,
    ADMasterFilterWrapper objMasterFilter
  ) {
    List<Opportunity> lstFilteredOpportunities = new List<Opportunity>();

    for (Opportunity objOpportunity : lstOpportunities) {
      if (objMasterFilter.strSelectedOppSizeFilterOperator == '>') {
        if (
          objOpportunity.Amount >
          (Decimal.valueOf(objMasterFilter.strOppSizeVal) *
          Integer.valueOf(Label.AD_AMOUNT_CONVERTER))
        ) {
          lstFilteredOpportunities.add(objOpportunity);
        }
      } else if (objMasterFilter.strSelectedOppSizeFilterOperator == '>=') {
        if (
          objOpportunity.Amount >=
          (Decimal.valueOf(objMasterFilter.strOppSizeVal) *
          Integer.valueOf(Label.AD_AMOUNT_CONVERTER))
        ) {
          lstFilteredOpportunities.add(objOpportunity);
        }
      } else if (objMasterFilter.strSelectedOppSizeFilterOperator == '=') {
        if (
          objOpportunity.Amount ==
          (Decimal.valueOf(objMasterFilter.strOppSizeVal) *
          Integer.valueOf(Label.AD_AMOUNT_CONVERTER))
        ) {
          lstFilteredOpportunities.add(objOpportunity);
        }
      } else if (objMasterFilter.strSelectedOppSizeFilterOperator == '<') {
        if (
          objOpportunity.Amount <
          (Decimal.valueOf(objMasterFilter.strOppSizeVal) *
          Integer.valueOf(Label.AD_AMOUNT_CONVERTER))
        ) {
          lstFilteredOpportunities.add(objOpportunity);
        }
      } else if (objMasterFilter.strSelectedOppSizeFilterOperator == '<=') {
        if (
          objOpportunity.Amount <=
          (Decimal.valueOf(objMasterFilter.strOppSizeVal) *
          Integer.valueOf(Label.AD_AMOUNT_CONVERTER))
        ) {
          lstFilteredOpportunities.add(objOpportunity);
        }
      }
    }
    return lstFilteredOpportunities;
  }

  /*
   * Method Name: applyOpportunityYearFilter
   * Input Parameters:
   * List<Opportunity> lstOpportunities: This holds opportunities on which filter will be applied.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: List<Opportunity>
   * Purpose: This method applies opportunity year filter and returns the filtered records.
   */
  public static List<Opportunity> applyOpportunityYearFilter(
    List<Opportunity> lstOpportunities,
    ADMasterFilterWrapper objMasterFilter
  ) {
    List<Opportunity> lstFilteredOpportunities = new List<Opportunity>();
    for (Opportunity objOpportunity : lstOpportunities) {
      if (
        null != objOpportunity.CloseDate &&
        (objOpportunity.CloseDate.year() ==
        Integer.valueOf(objMasterFilter.strSelectedYear))
      ) {
        lstFilteredOpportunities.add(objOpportunity);
      }
    }
    return lstFilteredOpportunities;
  }

  /*
   * Method Name: fetchLookUpValues
   * Input Parameters:
   * String searchKeyWord: This holds search keys by which user records will be queried.
   * List<sObject> ExcludeitemsList: This holds records which has to be excluded while querying user.
   * List<Id> ownerIdList: This holds the owner list
   * Return value: List<sObject>
   * Purpose: This method quries users as per search key workd.
   */
  @AuraEnabled
  public static List<sObject> fetchLookUpValues(
    String searchKeyWord,
    List<sObject> ExcludeitemsList,
    List<Id> ownerIdList
  ) {
    String searchKey = '%' + searchKeyWord + '%';
    List<sObject> returnList = new List<sObject>();

    //Items to exclude from the list from showing
    List<string> lstExcludeitems = new List<string>();
    if (null != ExcludeitemsList && !ExcludeitemsList.isEmpty()) {
      for (sObject item : ExcludeitemsList) {
        lstExcludeitems.add(item.Id);
      }
    }

    // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
    String sQuery = 'select id, Name from User where Name LIKE: searchKey AND Id IN: ownerIdList AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';

    List<sObject> lstOfRecords = Database.query(sQuery);

    for (sObject obj : lstOfRecords) {
      returnList.add(obj);
    }

    return returnList;
  }
}
