public without sharing class OwnerChangeLoggerUtility {
  public static Owner_Change_Logger__c createLogger(
    DateTime objActionStartTime,
    Id recordId,
    Id userId,
    String result,
    Id accountId,
    Id blId,
    Id contactId,
    Id opportunityId,
    Id oldUserId,
    Id newUserId,
    String objectType,
    String description
  ) {
    return new Owner_Change_Logger__c(
      Time__c = objActionStartTime,
      Record_Id__c = recordId,
      Performed_By__c = userId,
      Execution_Result__c = result,
      Account__c = accountId,
      Business_Location__c = blId,
      Contact__c = contactId,
      Opportunity__c = opportunityId,
      Old_User__c = oldUserId,
      New_User__c = newUserId,
      Object_Type__c = objectType,
      Detail_Description__c = description
    );
  }
}
