/*
 * Name: InitiativeTriggerHandler
 * Purpose: Handler class of Initiative trigger
 * Author: Nagarro
 * Created Date: 04-Feb-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class InitiativeTriggerHandler extends TriggerHandler {
  List<Initiative__c> newInitiativeList = new List<Initiative__c>();
  Map<Id, Initiative__c> oldInitiativeMap = new Map<Id, Initiative__c>();

  public InitiativeTriggerHandler() {
    newInitiativeList = (List<Initiative__c>) Trigger.New;
    oldInitiativeMap = (Map<Id, Initiative__c>) Trigger.OldMap;
  }

  public override void beforeDelete() {
    checkAndPreventDelete(oldInitiativeMap.values());
  }

  /*
   * Method Name: checkAndPreventDelete
   * Input Parameters:
   * List<Goal_Initiative__c> newList: This holds new Goal Initiative list.
   * Return value:
   * Purpose: check if related to any record then not allow delete.
   */
  private void checkAndPreventDelete(List<Initiative__c> oldList) {
    Set<Id> setInitiativeId = new Set<Id>();
    Map<Id, Initiative__c> mapInitiativeWithChilds = new Map<Id, Initiative__c>();
    String strErrorMessage = Label.AINI_INITIATIVE_DELETION_NOT_ALLOWED;

    for (Initiative__c objInitiative : oldList) {
      setInitiativeId.add(objInitiative.Id);
    }

    mapInitiativeWithChilds = new Map<Id, Initiative__c>(
      [
        SELECT
          Id,
          (SELECT Id FROM Activities__r),
          (SELECT Id FROM Account_Initiatives__r)
        FROM Initiative__c
        WHERE Id IN :setInitiativeId
      ]
    );

    for (Initiative__c objInitiative : oldList) {
      if (
        mapInitiativeWithChilds.containsKey(objInitiative.Id) &&
        (mapInitiativeWithChilds.get(objInitiative.Id).Activities__r.size() >
        0 ||
        mapInitiativeWithChilds.get(objInitiative.Id)
          .Account_Initiatives__r.size() > 0)
      ) {
        objInitiative.addError(strErrorMessage);
      }
    }
  }
}
