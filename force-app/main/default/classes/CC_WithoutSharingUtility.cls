/*
 * @company     : Nagarro Inc.
 * @date        : 05-09-2020
 * @author      : Nagarro
 * @description : This class contain methods that needs to be executed in without sharing mode.
 * @history     : Version 1.0
 * @test class  : CC_WithoutSharingUtilityTest
 */
public without sharing class CC_WithoutSharingUtility {
  /*
   * @purpose     : Method to get List of AccountTeamMember by Account Id
   * @parameter   : accountId - Account Id
   * @return      : List<AccountTeamMember> - List of AccountTeamMember
   */
  public static List<AccountTeamMember> getAccountTeamMembers(Id accountId) {
    return AccountDAO.getAccountTeamMembersByAccountId(accountId);
  }

  /*
   * @purpose     : Method to get Total Contacts by List of Account Id.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : Integer - Number of Contacts
   */
  public static Integer getTotalContactsByQueryAccountIds(
    String query,
    List<Id> accountIds
  ) {
    return ContactDAO.getTotalContactsByQueryAccountIds(query, accountIds);
  }

  /*
   * @purpose     : Method to get sObject detail.
   * @parameter   : query - Query to Execute
   * @return      : List<sObject> - List of sObject Records.
   */
  public static List<sObject> getsObjectData(String query) {
    return SobjectDAO.getsObjectData(query);
  }

  /*
   * @purpose     : Method to get Quote__c detail.
   * @parameter   : quoteIds - Set<Id> - Set of Quote Ids
   * @return      : List<Quote__c> - List of sObject Records.
   */
  public static List<Quote__c> getQuoteWithChargeLineByQuoteIds(
    Set<Id> quoteIds
  ) {
    return QuoteDAO.getQuoteWithChargeLineByQuoteIds(quoteIds);
  }

  /*
   * @purpose     : Method to get Quote__c detail.
   * @parameter   : quoteIds - Set<Id> - Set of Quote Ids
   * @return      : List<Quote__c> - List of sObject Records.
   */
  public static List<Contact> fetchContactDetailsById(Set<Id> contactIds) {
    return ContactDAO.getContactsByIds(contactIds);
  }

  /*
   * @purpose     : Method to get Total Contacts by List of Account Id.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : Integer - Number of Contacts
   */
  public static List<Contact> getContactsDetailByFirstNLastNPhoneEmail(
    String firstName,
    String lastname,
    String phone,
    String email,
    Id accountId
  ) {
    return ContactDAO.getContactsDetailByFirstNLastNPhoneEmail(
      firstName,
      lastname,
      phone,
      email,
      accountId
    );
  }

  /*
   * Method Name: getVisibleTabsMasterLabel
   * Input Parameters: strUserId
   * Return value: List<String>
   * Purpose: get the visible tabs master label
   */
  public static List<String> getVisibleTabsMasterLabel(String strUserId) {
    List<String> lstVisibleTabsMasterLabel = new List<String>();
    for (User objUser : [
      SELECT Id, Visible_Community_Tabs__c
      FROM User
      WHERE Id = :strUserId
    ]) {
      if (String.isNotBlank(objUser.Visible_Community_Tabs__c)) {
        for (
          String strTabMasterLabel : objUser.Visible_Community_Tabs__c.split(
            ';'
          )
        ) {
          lstVisibleTabsMasterLabel.add(strTabMasterLabel);
        }
      }
    }

    return lstVisibleTabsMasterLabel;
  }
}
