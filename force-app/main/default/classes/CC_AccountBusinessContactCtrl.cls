public with sharing class CC_AccountBusinessContactCtrl {
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
        LocationCode__c,
        Location_Code__c
      FROM Address__c
      WHERE Id = :addressId
    ][0];
  }
}
