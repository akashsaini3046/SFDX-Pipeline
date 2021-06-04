/*
 * Name: ADMasterFilterController
 * Purpose: Controller class for Master Filter component
 * Author: Nagarro
 * Created Date: 10-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADMasterFilterController {
  @AuraEnabled
  public static List<Account> getAllChildAccount(Id idAccountId) {
    return ADAccountDashboardUtil.getAllChildAccounts(idAccountId);
  }

  @AuraEnabled
  public static List<Account> getAllChildAndParent(Id idAccountId) {
    return ADAccountDashboardUtil.getAllChildAccountsWithParent(idAccountId);
  }

  @AuraEnabled
  public static List<User> getAllActiveUsers() {
    return ADAccountDashboardUtil.getAllActiveUsers();
  }

  @AuraEnabled
  public static List<User> getAllActiveUsersRelatedToAccount(
    String strAccountId
  ) {
    Set<Id> setUsers = new Set<Id>();
    List<User> lstUser = new List<User>();
    for (
      Account objAccount : ADAccountDashboardUtil.getAllRelatedAccount(
          strAccountId
        )
        .values()
    ) {
      setUsers.add(objAccount.OwnerId);
    }
    lstUser = [SELECT Id, Name FROM User WHERE Id IN :setUsers ORDER BY Name];
    return lstUser;
  }

  @AuraEnabled
  public static List<String> getPicklistYear() {
    List<String> lstPicklistYearValues = new List<String>();
    lstPicklistYearValues.add(Label.AD_PICKLIST_VAL_ALL_YEAR);
    lstPicklistYearValues.addAll(ADAccountDashboardUtil.getPicklistYear());
    return lstPicklistYearValues;
  }
}
