public class AuditAlertController {
  @AuraEnabled
  public static boolean showAuditAlert(Id caseId) {
    List<Case> cases = [SELECT Id, Show_Popup__c FROM Case WHERE Id = :caseId];
    if (!cases.isEmpty() && cases[0].Show_Popup__c) {
      cases[0].Show_Popup__c = false;
      update cases;
      return true;
    }
    return false;
  }
}
