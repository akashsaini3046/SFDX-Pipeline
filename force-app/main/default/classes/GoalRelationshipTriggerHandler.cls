/*
 * Name: GoalRelationshipTriggerHandler
 * Purpose: Handler class of GoalRelationship trigger
 * Author: Nagarro
 * Created Date: 22-Jan-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public without sharing class GoalRelationshipTriggerHandler extends TriggerHandler {
  List<Goal_Initiative__c> newGoalRelationshipList = new List<Goal_Initiative__c>();
  Map<Id, Goal_Initiative__c> oldGoalRelationshipMap = new Map<Id, Goal_Initiative__c>();

  public GoalRelationshipTriggerHandler() {
    newGoalRelationshipList = (List<Goal_Initiative__c>) Trigger.New;
    oldGoalRelationshipMap = (Map<Id, Goal_Initiative__c>) Trigger.OldMap;
  }

  public override void beforeInsert() {
    setGoalRelationshipNameAsInitiativeName(newGoalRelationshipList);
    createPrimaryKey(newGoalRelationshipList, oldGoalRelationshipMap);
  }

  public override void beforeUpdate() {
    setGoalRelationshipNameAsInitiativeName(newGoalRelationshipList);
    createPrimaryKey(newGoalRelationshipList, oldGoalRelationshipMap);
  }

  public override void afterInsert() {
    createTaskForAccountOwner(newGoalRelationshipList);
  }

  public override void beforeDelete() {
    checkAndPreventDelete(oldGoalRelationshipMap.values());
  }

  /*
   * Method Name: setGoalRelationshipNameAsInitiativeName
   * Input Parameters:
   * List<Goal_Initiative__c> newList: This holds new Goal Initiative list.
   * Return value:
   * Purpose: Set goal relationship name as initiative name.
   */
  private void setGoalRelationshipNameAsInitiativeName(
    List<Goal_Initiative__c> newList
  ) {
    Set<Id> setInitiativeId = new Set<Id>();
    Set<Id> setAccountId = new Set<Id>();

    for (Goal_Initiative__c objGoalInitiative : newList) {
      setInitiativeId.add(objGoalInitiative.Initiative__c);
      setAccountId.add(objGoalInitiative.Account__c);
    }
    Map<Id, Initiative__c> mapInitiative = new Map<Id, Initiative__c>(
      [SELECT Id, Name FROM Initiative__c WHERE Id IN :setInitiativeId]
    );
    Map<Id, Account> mapAccount = new Map<Id, Account>(
      [SELECT Id, Name FROM Account WHERE Id IN :setAccountId]
    );

    for (Goal_Initiative__c objGoalInitiative : newList) {
      if (mapInitiative.containsKey(objGoalInitiative.Initiative__c)) {
        objGoalInitiative.Name = mapInitiative.get(
            objGoalInitiative.Initiative__c
          )
          .Name;
      }
      if (mapAccount.containsKey(objGoalInitiative.Account__c)) {
        objGoalInitiative.Account_Name__c = mapAccount.get(
            objGoalInitiative.Account__c
          )
          .Name;
      }
    }
  }

  /*
   * Method Name: createTaskForAccountOwner
   * Input Parameters:
   * List<Goal_Initiative__c> lstNew: This holds new Goal Initiative list.
   * Return value:
   * Purpose: Create task for account owner.
   */
  private void createTaskForAccountOwner(List<Goal_Initiative__c> lstNew) {
    List<Task> lstTask = new List<Task>();
    Set<Id> setAccountId = new Set<Id>();
    Map<Id, Account> mapAccount;
    String strGoalInitiativeAutoTaskSubject =
      Label.Automated_Follow_Up_Task_Prefix +
      ' ' +
      Label.AINI_NEW_AUTO_TASK_SUBJECT +
      ' ';
    String strGoalInitiativeAutoTaskPriority = Label.AINI_NEW_AUTO_TASK_PRIORITY;
    String strGoalInitiativeAutoTaskStatus = Label.AINI_NEW_AUTO_TASK_STATUS;
    Integer intGoalInitiativeAutoTaskDueDate = Integer.valueOf(
      Label.AINI_NEW_AUTO_TASK_DUE_DATE
    );
    String strGoalInitiativeAutoTaskType = Label.AINI_NEW_AUTO_TASK_TYPE;
    String strTaskDescriptionPost = Label.AINI_TASK_DESCRIPTION_POST;
    String strTaskDescriptionPree = Label.AINI_TASK_DESCRIPTION_PREE;
    String strTaskDescriptionPreeThe = Label.AINI_TASK_DESCRIPTION_PREE_THE;

    for (Goal_Initiative__c objGoalInitiative : lstNew) {
      setAccountId.add(objGoalInitiative.Account__c);
    }
    mapAccount = new Map<Id, Account>(
      [SELECT Id, OwnerId, Name FROM Account WHERE Id IN :setAccountId]
    );

    for (Goal_Initiative__c objGoalInitiative : lstNew) {
      if (
        objGoalInitiative.Account__c != null &&
        mapAccount.containsKey(objGoalInitiative.Account__c) &&
        objGoalInitiative.Active__c &&
        objGoalInitiative.Is_Converted_from_Lead__c == false
      ) {
        lstTask.add(
          new Task(
            Subject = strGoalInitiativeAutoTaskSubject + objGoalInitiative.Name,
            Priority = strGoalInitiativeAutoTaskPriority,
            Status = strGoalInitiativeAutoTaskStatus,
            Type = strGoalInitiativeAutoTaskType,
            OwnerId = mapAccount.get(objGoalInitiative.Account__c).OwnerId,
            ActivityDate = Date.today() + intGoalInitiativeAutoTaskDueDate,
            WhatId = mapAccount.get(objGoalInitiative.Account__c).Id,
            Goal_Initiative__c = objGoalInitiative.Id,
            Description = strTaskDescriptionPreeThe +
              mapAccount.get(objGoalInitiative.Account__c).Name +
              strTaskDescriptionPree +
              objGoalInitiative.Name +
              '".' +
              strTaskDescriptionPost
          )
        );
      }
    }

    if (lstTask.size() > 0) {
      List<Database.SaveResult> lstSaveResult = Database.insert(lstTask, false);
      for (Database.SaveResult objSaveResult : lstSaveResult) {
        if (objSaveResult.isSuccess() == false) {
          for (Database.Error objError : objSaveResult.getErrors()) {
            System.debug(
              'GoalRelationshipTriggerHandler->createTaskForAccountOwner ' +
              objError.getMessage()
            );
          }
        }
      }
    }
  }

  /*
   * Method Name: createPrimaryKey
   * Input Parameters:
   * List<Goal_Initiative__c> newList: This holds new Goal Initiative list.
   * Return value:
   * Purpose: Create primary key.
   */
  private void createPrimaryKey(
    List<Goal_Initiative__c> newList,
    Map<Id, Goal_Initiative__c> oldMap
  ) {
    Set<String> setGoalInitiativeUniqueKey = new Set<String>();
    Set<String> setExistingGoalInitiativeUniqueKey = new Set<String>();
    String strUniqueKeyErrorMessage = Label.AINI_GOAL_INITIATIVE_UNIQUE_KEY_MESSAGE;

    for (Goal_Initiative__c objGoalInitiative : newList) {
      setGoalInitiativeUniqueKey.add(
        objGoalInitiative.Initiative__c +
        '' +
        objGoalInitiative.Account__c
      );
    }

    for (Goal_Initiative__c objGoalInitiative : [
      SELECT Id, Initiative__c, Account__c, Primary_Key__c
      FROM Goal_Initiative__c
      WHERE Primary_Key__c IN :setGoalInitiativeUniqueKey
    ]) {
      setExistingGoalInitiativeUniqueKey.add(
        objGoalInitiative.Initiative__c +
        '' +
        objGoalInitiative.Account__c
      );
    }

    for (Goal_Initiative__c objGoalInitiative : newList) {
      if (
        setExistingGoalInitiativeUniqueKey.contains(
          objGoalInitiative.Initiative__c +
          '' +
          objGoalInitiative.Account__c
        )
      ) {
        if (
          oldMap == null ||
          (oldMap != null &&
          oldMap.containsKey(objGoalInitiative.Id) &&
          ((oldMap.get(objGoalInitiative.Id).Initiative__c !=
          objGoalInitiative.Initiative__c) ||
          (oldMap.get(objGoalInitiative.Id).Account__c !=
          objGoalInitiative.Account__c)))
        ) {
          objGoalInitiative.addError(strUniqueKeyErrorMessage);
        }
      } else {
        objGoalInitiative.Primary_Key__c =
          objGoalInitiative.Initiative__c +
          '' +
          objGoalInitiative.Account__c;
      }
    }
  }

  /*
   * Method Name: checkAndPreventDelete
   * Input Parameters:
   * List<Goal_Initiative__c> newList: This holds new Goal Initiative list.
   * Return value:
   * Purpose: check if related to any record then not allow delete.
   */
  private void checkAndPreventDelete(List<Goal_Initiative__c> oldList) {
    Set<Id> setGoalInitiativeId = new Set<Id>();
    Map<Id, Goal_Initiative__c> mapGIWithChilds = new Map<Id, Goal_Initiative__c>();
    String strErrorMessage = Label.AINI_GI_DELETION_NOT_ALLOWED;

    for (Goal_Initiative__c objGoalInitiative : oldList) {
      setGoalInitiativeId.add(objGoalInitiative.Id);
    }

    mapGIWithChilds = new Map<Id, Goal_Initiative__c>(
      [
        SELECT
          Id,
          (SELECT Id FROM Activities__r),
          (SELECT Id FROM Opportunities__r)
        FROM Goal_Initiative__c
        WHERE Id IN :setGoalInitiativeId
      ]
    );

    for (Goal_Initiative__c objGoalInitiative : oldList) {
      if (
        mapGIWithChilds.containsKey(objGoalInitiative.Id) &&
        (mapGIWithChilds.get(objGoalInitiative.Id).Activities__r.size() > 0 ||
        mapGIWithChilds.get(objGoalInitiative.Id).Opportunities__r.size() > 0)
      ) {
        objGoalInitiative.addError(strErrorMessage);
      }
    }
  }
}
