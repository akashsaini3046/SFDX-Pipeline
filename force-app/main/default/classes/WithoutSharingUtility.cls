/*
 * Name: WithoutSharingUtility
 * Purpose: This class contain methods that needs to be executed in without sharing mode.
 * Author: Nagarro
 */
public without sharing class WithoutSharingUtility {
  public static void insertServiceRecords(
    List<OpportunityLineItem> serviceList
  ) {
    try {
      insert serviceList;
    } catch (Exception ex) {
      System.debug(
        'Exception ex insertServiceRecords-> ' +
        ex.getMessage() +
        ex.getLineNumber()
      );
    }
  }

  public static void insertOpportunityTeamMemberRecords(
    List<OpportunityTeamMember> oppMemberList
  ) {
    try {
      insert oppMemberList;
    } catch (Exception ex) {
      System.debug(
        'Exception ex insertOpportunityTeamMemberRecords-> ' +
        ex.getMessage() +
        ex.getLineNumber()
      );
    }
  }

  public static void insertAccountTeamMemberRecords(
    List<AccountTeamMember> accMemberList
  ) {
    try {
      insert accMemberList;
    } catch (Exception ex) {
      System.debug(
        'Exception ex insertOpportunityTeamMemberRecords-> ' +
        ex.getMessage() +
        ex.getLineNumber()
      );
    }
  }
  //Method to update account even in case the account is locked due to Approval Process.
  public static void updateUniqueServicesOnAccount(
    List<Account> accListToUpdate
  ) {
    update accListToUpdate;
  }

  public static List<AccountTeamMember> queryAccountTeamMember(
    Set<Id> accountIdSet
  ) {
    List<AccountTeamMember> accTeamList = [
      SELECT
        AccountId,
        TeamMemberRole,
        UserId,
        OpportunityAccessLevel,
        AccountAccessLevel
      FROM AccountTeamMember
      WHERE AccountId IN :accountIdSet
    ];
    return accTeamList;
  }
  public static void deleteAccountTeamMembers(
    List<AccountTeamMember> accMemList
  ) {
    if (!Test.isRunningTest())
      AccountTeamTriggerHandler.roleCheck = false;
    delete accMemList;
  }

  public static Map<Id, Account> queryforAccountOwnerChange(
    Set<Id> accountIdSet
  ) {
    Map<Id, Account> mapAccount = new Map<Id, Account>(
      [
        SELECT
          Id,
          OwnerId,
          Owner.Name,
          ParentId,
          (SELECT Id, Country__c, Account__c FROM Address__r)
        FROM Account
        WHERE Id IN :accountIdSet
      ]
    );
    return mapAccount;
  }

  public static void updateAccounts(List<Account> accList) {
    update accList;
  }

  /*
   * Method Name: shareleadRecords
   * Input Parameters: newLeadList
   * Return value: None
   * Purpose: To share lead records with Sales Agent for leads created by himself.
   * Comment : Used in LeadTriggerHandler in assignLeadsCreatedBySalesAgentToMarketManager()
   */
  public static void shareleadRecords(Set<Id> newLeadList) {
    Id currentUserId = UserInfo.getUserId();
    System.debug('currentUserId: ' + currentUserId);
    List<LeadShare> leadSharelist = new List<LeadShare>();

    for (Id salesAgentLead : newLeadList) {
      LeadShare salesLeadShare = new LeadShare();
      salesLeadShare.LeadId = salesAgentLead;
      salesLeadShare.LeadAccessLevel = 'Edit';
      salesLeadShare.UserOrGroupId = currentUserId;
      leadSharelist.add(salesLeadShare);
    }
    if (leadSharelist.size() > 0) {
      insert leadSharelist;
    }
  }
  public static void addTeamMembers(List<sObject> listOfSobject) {
    System.debug('listOfSobject: ' + listOfSobject);
    insert listOfSobject;
  }

  public static Map<Id, Account> fetchAccountMap(Set<Id> accountIds) {
    return new Map<Id, Account>(
      [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
    );
  }

  public static List<User> getUsersByNames(List<String> names) {
    return [SELECT Id, Name FROM User WHERE Name IN :names];
  }
}
