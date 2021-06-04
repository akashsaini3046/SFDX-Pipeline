/*
 * Name: LeadTriggerHandler
 * Purpose: Handler class for Lead Trigger
 * Author: Nagarro
 * Created Date: 11/09/2018
 *
 *  Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public with sharing class TaskTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterDelete = true;

  List<Task> newTaskList;
  List<Task> oldTaskList;
  Map<Id, Task> oldTaskMap = new Map<Id, Task>();
  Map<Id, Task> newTaskMap = new Map<Id, Task>();

  //Constructor
  public TaskTriggerHandler() {
    this.newTaskList = (List<Task>) Trigger.new;
    this.oldTaskList = (List<Task>) Trigger.old;
    this.oldTaskMap = (Map<Id, Task>) Trigger.oldMap;
    this.newTaskMap = (Map<Id, Task>) Trigger.newMap;
  }

  //Override the before insert method
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      System.debug('newTaskList -> ' + newTaskList);
      recursionVarBeforeInsert = false;
      linkTaskWithInitiative(newTaskList, oldTaskMap);
    }
  }

  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      recursionVarAfterInsert = false;
      updateTasksClosedFieldOnLead(newTaskList);
      updateTaskTypeToEmail(newTaskList);
    }
    deleteNeglectedTaskAccounts(newTaskList);
  }

  //Override the before update method
  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      recursionVarBeforeUpdate = false;
      try {
        if (LeadConversionIdentifier.boolCalledAfterLeadConverted == false) {
          validateInitiativeChange(newTaskList, oldTaskMap);
        }
      } catch (Exception objEx) {
        System.debug(
          'TaskTriggerHandler.validateInitiativeChange ' + objEx.getMessage()
        );
      }
    }
  }

  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;
      updateTasksClosedFieldOnLead(newTaskList);
    }
    deleteNeglectedTaskAccounts(newTaskList);
  }

  //Override the before delete method
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      recursionVarBeforeDelete = false;
    }
  }

  public override void afterDelete() {
    if (recursionVarAfterDelete) {
      recursionVarAfterDelete = false;
      updateTasksClosedFieldOnLead(oldTaskList);
    }
  }

  /*
   * Method Name: updateTasksClosedFieldOnLead
   * Input Parameters: List<Task> taskList
   * Return value: void
   * Purpose: Update Tasks_Closed__c checkbox to true if all the tasks on a Lead are closed.
   */
  private static void updateTasksClosedFieldOnLead(List<Task> taskList) {
    Set<Id> leadIdSet = new Set<Id>();
    for (Task tsk : taskList) {
      if (tsk.WhoId != null && String.valueOf(tsk.WhoId).startsWith('00Q')) {
        leadIdSet.add(tsk.WhoId);
      }
    }

    if (leadIdSet != null && !leadIdSet.isEmpty()) {
      List<Lead> leadList = [
        SELECT Id, Activities_Closed__c
        FROM Lead
        WHERE Id IN :leadIdSet
      ];
      List<Task> leadTasksList = [
        SELECT Id, IsClosed, WhoId
        FROM Task
        WHERE WhoId IN :leadIdSet
      ];
      List<Task> allTaskList;
      List<Task> closedTaskList;
      Map<Id, List<Task>> leadAllTasksMap = new Map<Id, List<Task>>();
      Map<Id, List<Task>> leadClosedTasksMap = new Map<Id, List<Task>>();

      if (leadTasksList != null && !leadTasksList.isEmpty()) {
        for (Task tsk : leadTasksList) {
          //Preparing a map of a lead vs all the tasks on it
          if (leadAllTasksMap.containsKey(tsk.WhoId)) {
            allTaskList.add(tsk);
          } else {
            allTaskList = new List<Task>();
            allTaskList.add(tsk);
          }
          leadAllTasksMap.put(tsk.WhoId, allTaskList);

          //Preparing a map of a lead vs all the closed tasks on it
          if (tsk.isClosed) {
            if (leadClosedTasksMap.containsKey(tsk.WhoId)) {
              closedTaskList.add(tsk);
            } else {
              closedTaskList = new List<Task>();
              closedTaskList.add(tsk);
            }
            leadClosedTasksMap.put(tsk.WhoId, closedTaskList);
          }
        }
        if (
          leadAllTasksMap != null &&
          leadAllTasksMap.keySet() != null &&
          !leadAllTasksMap.keySet().isEmpty()
        ) {
          for (Lead ld : leadList) {
            if (leadAllTasksMap.containsKey(ld.Id)) {
              if (
                (!leadClosedTasksMap.containsKey(ld.Id)) ||
                (leadClosedTasksMap.containsKey(ld.Id) &&
                leadAllTasksMap.get(ld.Id).size() !=
                leadClosedTasksMap.get(ld.Id).size())
              ) {
                ld.Activities_Closed__c = false;
              } else {
                ld.Activities_Closed__c = true;
              }
            }
          }

          Database.SaveResult[] results = Database.update(leadList, false);
          if (results != null && !results.isEmpty()) {
            for (Database.SaveResult res : results) {
              if (res.isSuccess()) {
                System.debug('Record updated Successfully' + res.getId());
              } else {
                for (Database.Error err : res.getErrors()) {
                  System.debug('The following error has occurred.');
                  System.debug(err.getStatusCode() + ': ' + err.getMessage());
                  System.debug(
                    'Account fields that affected this error: ' +
                    err.getFields()
                  );
                }
              }
            }
          }
        }
      }
    }
  }

  /*
   * Method Name: updteTaskTypeToEmail
   * Input Parameters: List<Task> lstTasks
   * Return value: void
   * Purpose: Update email Task to email type.
   */
  private void updateTaskTypeToEmail(List<Task> lstTasks) {
    List<Task> lstTaskToUpdate = new List<Task>();
    for (Task objTask : lstTasks) {
      if (
        objTask.TaskSubtype == ConstantClass.TASK_SUB_TYPE_EMAIL &&
        objTask.Type == null
      ) {
        lstTaskToUpdate.add(
          new Task(Id = objTask.Id, Type = ConstantClass.TASK_TYPE_EMAIL)
        );
      }
    }

    if (lstTaskToUpdate.size() > 0) {
      try {
        update lstTaskToUpdate;
      } catch (Exception objEx) {
        System.debug(
          'Exception Occured in TaskTriggerHandler -> updateTaskTypeToEmail ' +
          objEx.getMessage()
        );
      }
    }
  }

  /*
   * Method Name: linkTaskWithInitiative
   * Input Parameters:
   * List<Goal_Initiative__c> lstNew: This holds new Goal Initiative list.
   * Return value:
   * Purpose: link task with initiative.
   */
  private void linkTaskWithInitiative(
    List<Task> lstNewTask,
    Map<Id, Task> mapOldTask
  ) {
    Set<Id> setGoalInitiativeId = new Set<Id>();
    Map<Id, Goal_Initiative__c> MapGoalInitiative = new Map<Id, Goal_Initiative__c>();
    Map<Id, Map<Id, Goal_Initiative__c>> mapAccountInitiatives = new Map<Id, Map<Id, Goal_Initiative__c>>();
    Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
    Set<Id> setWhatId = new Set<Id>();
    Set<Id> setWhoId = new Set<Id>();
    Map<Id, Lead> mapLeadInitiative = new Map<Id, Lead>();
    Map<Id, Initiative__c> mapInitiative = new Map<Id, Initiative__c>();
    //This holds those tasks id where initiative has been deliberately changed.
    Set<Id> setTaskNotconsideredForIniLink = new Set<Id>();

    for (Task objTask : lstNewTask) {
      if (objTask.Goal_Initiative__c != null) {
        setGoalInitiativeId.add(objTask.Goal_Initiative__c);
      }
      if (objTask.WhatId != null) {
        setWhatId.add(objTask.WhatId);
      }
      if (objTask.WhoId != null) {
        setWhoId.add(objTask.WhoId);
      }
      if (
        mapOldTask != null &&
        mapOldTask.containsKey(objTask.Id) &&
        mapOldTask.get(objTask.Id).Initiative__c != objTask.Initiative__c
      ) {
        setTaskNotconsideredForIniLink.add(objTask.Id);
        objTask.Goal_Initiative__c = null;
      }
    }
    if (setGoalInitiativeId.size() > 0) {
      MapGoalInitiative = new Map<Id, Goal_Initiative__c>(
        [
          SELECT Id, Initiative__c
          FROM Goal_Initiative__c
          WHERE Id IN :setGoalInitiativeId
        ]
      );
    }
    if (setWhatId.size() > 0) {
      mapOpportunity = new Map<Id, Opportunity>(
        [
          SELECT
            Id,
            Goal_Initiative__c,
            Goal_Initiative__r.Initiative__c,
            Goal_Initiative__r.Active__c
          FROM Opportunity
          WHERE Id IN :setWhatId
        ]
      );
      mapInitiative = new Map<Id, Initiative__c>(
        [
          SELECT Id, isActive__c, Initiative_Type__c
          FROM Initiative__c
          WHERE Id IN :setWhatId
        ]
      );
      for (Goal_Initiative__c objGoalInitiative : [
        SELECT Id, Initiative__c, Account__c, Active__c
        FROM Goal_Initiative__c
        WHERE Account__c IN :setWhatId
      ]) {
        if (mapAccountInitiatives.containsKey(objGoalInitiative.Account__c)) {
          mapAccountInitiatives.get(objGoalInitiative.Account__c)
            .put(objGoalInitiative.Initiative__c, objGoalInitiative);
        } else {
          mapAccountInitiatives.put(
            objGoalInitiative.Account__c,
            new Map<Id, Goal_Initiative__c>{
              objGoalInitiative.Initiative__c => objGoalInitiative
            }
          );
        }
      }
    }
    if (setWhoId.size() > 0) {
      mapLeadInitiative = new Map<Id, Lead>(
        [
          SELECT Id, Initiative__c, Initiative__r.IsActive__c
          FROM Lead
          WHERE Id IN :setWhoId
        ]
      );
    }

    for (Task objTask : lstNewTask) {
      if (
        !setTaskNotconsideredForIniLink.contains(objTask.Id) &&
        objTask.whatId != null &&
        objTask.whatId.getSObjectType() == Account.sObjectType &&
        objTask.Goal_Initiative__c != null &&
        MapGoalInitiative.containsKey(objTask.Goal_Initiative__c)
      ) {
        //What id is Account
        objTask.Initiative__c = MapGoalInitiative.get(
            objTask.Goal_Initiative__c
          )
          .Initiative__c;
      } else if (
        !setTaskNotconsideredForIniLink.contains(objTask.Id) &&
        objTask.whatId != null &&
        objTask.whatId.getSObjectType() == Opportunity.sObjectType &&
        objTask.Is_Related_to_Initiative__c &&
        mapOpportunity.containsKey(objTask.whatId)
      ) {
        //What id is Opportunity
        objTask.Initiative__c = mapOpportunity.get(objTask.whatId)
          .Goal_Initiative__r.Initiative__c;
      } else if (
        !setTaskNotconsideredForIniLink.contains(objTask.Id) &&
        objTask.whatId != null &&
        objTask.whatId.getSObjectType() == Initiative__c.sObjectType
      ) {
        //What id is Initiative
        objTask.Initiative__c = objTask.whatId;
        if (
          mapInitiative != null &&
          mapInitiative.containsKey(objTask.whatId) &&
          mapInitiative.get(objTask.whatId).isActive__c == false
        ) {
          objTask.addError(Label.AINI_ACTIVITY_ON_INACTIVE_INITIATIVE);
        } else if (
          mapInitiative != null &&
          mapInitiative.containsKey(objTask.whatId) &&
          mapInitiative.get(objTask.whatId).Initiative_Type__c == 'Closed'
        ) {
          //objTask.addError(Label.AINI_ACTIVITY_ON_CLOSED_INITIATIVE);
        }
      } else if (
        !setTaskNotconsideredForIniLink.contains(objTask.Id) &&
        objTask.whatId == null &&
        objTask.Goal_Initiative__c != null &&
        MapGoalInitiative.containsKey(objTask.Goal_Initiative__c)
      ) {
        //What id is null and only Goal Initiative is there
        objTask.Initiative__c = MapGoalInitiative.get(
            objTask.Goal_Initiative__c
          )
          .Initiative__c;
      } else if (
        !setTaskNotconsideredForIniLink.contains(objTask.Id) &&
        objTask.WhoId != null &&
        objTask.whoId.getSObjectType() == Lead.sObjectType &&
        objTask.Linked_to_Lead_Initiative__c &&
        mapLeadInitiative.containsKey(objTask.WhoId)
      ) {
        //Who id is Lead
        objTask.Initiative__c = mapLeadInitiative.get(objTask.WhoId)
          .Initiative__c;
      }

      if (objTask.Initiative__c == null) {
        objTask.Is_Related_to_Initiative__c = false;
      }

      //Validate Activity for Initiative and related to association
      if (objTask.Initiative__c != null && objTask.whatId != null) {
        if (
          objTask.whatId.getSObjectType() != Initiative__c.sObjectType &&
          objTask.whatId.getSObjectType() != Account.sObjectType &&
          objTask.whatId.getSObjectType() != Opportunity.sObjectType
        ) {
          objTask.addError(Label.AINI_INITIATIVE_WHATID_SUPPORT);
        }

        if (objTask.whatId.getSObjectType() == Account.sObjectType) {
          //Is Account linked with initiative
          Map<Id, Goal_Initiative__c> mapInitiativeLinkedToAcc = mapAccountInitiatives.get(
            objTask.whatId
          );

          if (mapInitiativeLinkedToAcc == null) {
            objTask.addError(Label.AINI_IS_ACC_LINKED_WITH_INITIATIVE);
          } else if (
            mapInitiativeLinkedToAcc != null &&
            mapInitiativeLinkedToAcc.containsKey(objTask.Initiative__c) == false
          ) {
            objTask.addError(Label.AINI_IS_ACC_LINKED_WITH_INITIATIVE);
          } else if (
            mapInitiativeLinkedToAcc != null &&
            mapInitiativeLinkedToAcc.containsKey(objTask.Initiative__c)
          ) {
            if (
              mapInitiativeLinkedToAcc.get(objTask.Initiative__c) != null &&
              mapInitiativeLinkedToAcc.get(objTask.Initiative__c).Active__c ==
              false
            ) {
              objTask.addError(
                Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE
              );
            }
          }
        }

        if (objTask.whatId.getSObjectType() == Opportunity.sObjectType) {
          //Is Opportunity linked with initiative
          if (mapOpportunity.containsKey(objTask.whatId) == false) {
            objTask.addError(Label.AINI_IS_OPP_LINKED_WITH_INITIATIVE);
          } else if (
            mapOpportunity.containsKey(objTask.whatId) &&
            mapOpportunity.get(objTask.whatId)
              .Goal_Initiative__r.Initiative__c != objTask.Initiative__c
          ) {
            objTask.addError(Label.AINI_IS_OPP_LINKED_WITH_INITIATIVE);
          } else if (
            mapOpportunity.containsKey(objTask.whatId) &&
            mapOpportunity.get(objTask.whatId)
              .Goal_Initiative__r.Initiative__c == objTask.Initiative__c &&
            mapOpportunity.get(objTask.whatId).Goal_Initiative__r.Active__c ==
            false
          ) {
            objTask.addError(
              Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE_OPP
            );
          }
        }
      }

      //Validate Activity for Initiative and name association
      if (objTask.Initiative__c != null && objTask.whoId != null) {
        if (objTask.whoId.getSObjectType() == Lead.sObjectType) {
          //Is Lead linked with initiative
          if (mapLeadInitiative.containsKey(objTask.whoId) == false) {
            objTask.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
          } else if (
            mapLeadInitiative.containsKey(objTask.whoId) &&
            mapLeadInitiative.get(objTask.whoId).Initiative__c !=
            objTask.Initiative__c
          ) {
            objTask.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
          } else if (
            mapLeadInitiative.containsKey(objTask.whoId) &&
            mapLeadInitiative.get(objTask.whoId).Initiative__c ==
            objTask.Initiative__c &&
            mapLeadInitiative.get(objTask.whoId).Initiative__r.IsActive__c ==
            false
          ) {
            objTask.addError(Label.AINI_ACTIVITY_ON_INACTIVE_INITIATIVE);
          }
        }

        if (objTask.whoId.getSObjectType() == Contact.sObjectType) {
          //Is Contact linked with initiative
        }
      }
    }
  }

  /*
   * Method Name: validateInitiativeChange
   * Input Parameters:
   * List<Goal_Initiative__c> lstNew: This holds new Goal Initiative list.
   * Return value:
   * Purpose: validate activity initaitve link.
   */
  private void validateInitiativeChange(
    List<Task> lstNewTask,
    Map<Id, Task> mapOldTask
  ) {
    Set<Id> setTasksWhereInitiativeChanged = new Set<Id>();
    Map<Id, Map<Id, Goal_Initiative__c>> mapAccountInitiatives = new Map<Id, Map<Id, Goal_Initiative__c>>();
    Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
    Set<Id> setWhatId = new Set<Id>();
    Set<Id> setWhoId = new Set<Id>();
    Map<Id, Lead> mapLeadInitiative = new Map<Id, Lead>();
    String strRelatedToInitiativeMismatchError = Label.AINI_INITIATIVE_RELATED_TO_MISMATCH;

    for (Task objTask : lstNewTask) {
      if (
        mapOldTask != null &&
        mapOldTask.containsKey(objTask.Id) &&
        ((mapOldTask.get(objTask.Id).Initiative__c != objTask.Initiative__c) ||
        (objTask.Initiative__c != null &&
        mapOldTask.get(objTask.Id).WhatId != objTask.WhatId) ||
        (objTask.Initiative__c != null &&
        mapOldTask.get(objTask.Id).WhoId != objTask.WhoId))
      ) {
        objTask.Goal_Initiative__c = null;
        if (objTask.Initiative__c == null) {
          objTask.Is_Related_to_Initiative__c = false;
          objTask.Linked_to_Lead_Initiative__c = false;
        }

        if (objTask.Initiative__c != null) {
          setTasksWhereInitiativeChanged.add(objTask.Id);
        }
        if (objTask.WhatId != null) {
          setWhatId.add(objTask.WhatId);
        }
        if (objTask.WhoId != null) {
          setWhoId.add(objTask.WhoId);
        }
      }
    }

    if (setTasksWhereInitiativeChanged.size() > 0) {
      if (setWhatId.size() > 0) {
        mapOpportunity = new Map<Id, Opportunity>(
          [
            SELECT
              Id,
              Goal_Initiative__c,
              Goal_Initiative__r.Initiative__c,
              Goal_Initiative__r.Active__c
            FROM Opportunity
            WHERE Id IN :setWhatId
          ]
        );
        for (Goal_Initiative__c objGoalInitiative : [
          SELECT Id, Initiative__c, Account__c, Active__c
          FROM Goal_Initiative__c
          WHERE Account__c IN :setWhatId
        ]) {
          if (mapAccountInitiatives.containsKey(objGoalInitiative.Account__c)) {
            mapAccountInitiatives.get(objGoalInitiative.Account__c)
              .put(objGoalInitiative.Initiative__c, objGoalInitiative);
          } else {
            mapAccountInitiatives.put(
              objGoalInitiative.Account__c,
              new Map<Id, Goal_Initiative__c>{
                objGoalInitiative.Initiative__c => objGoalInitiative
              }
            );
          }
        }
      }
      if (setWhoId.size() > 0) {
        mapLeadInitiative = new Map<Id, Lead>(
          [
            SELECT Id, Initiative__c, Initiative__r.IsActive__c
            FROM Lead
            WHERE Id IN :setWhoId
          ]
        );
      }
      for (Task objTask : lstNewTask) {
        if (setTasksWhereInitiativeChanged.contains(objTask.Id)) {
          //Validate Activity for Initiative and related to association
          if (objTask.Initiative__c != null && objTask.whatId != null) {
            if (
              objTask.whatId.getSObjectType() != Initiative__c.sObjectType &&
              objTask.whatId.getSObjectType() != Account.sObjectType &&
              objTask.whatId.getSObjectType() != Opportunity.sObjectType
            ) {
              objTask.addError(Label.AINI_INITIATIVE_WHATID_SUPPORT);
            }

            if (objTask.whatId.getSObjectType() == Account.sObjectType) {
              //Is Account linked with initiative
              Map<Id, Goal_Initiative__c> mapInitiativeLinkedToAcc = mapAccountInitiatives.get(
                objTask.whatId
              );

              if (mapInitiativeLinkedToAcc == null) {
                objTask.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapInitiativeLinkedToAcc != null &&
                mapInitiativeLinkedToAcc.containsKey(objTask.Initiative__c) ==
                false
              ) {
                objTask.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapInitiativeLinkedToAcc != null &&
                mapInitiativeLinkedToAcc.containsKey(objTask.Initiative__c)
              ) {
                if (
                  mapInitiativeLinkedToAcc.get(objTask.Initiative__c) != null &&
                  mapInitiativeLinkedToAcc.get(objTask.Initiative__c)
                    .Active__c == false
                ) {
                  objTask.addError(
                    Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE
                  );
                } else if (
                  mapInitiativeLinkedToAcc.get(objTask.Initiative__c) != null &&
                  mapInitiativeLinkedToAcc.get(objTask.Initiative__c)
                    .Active__c == true
                ) {
                  objTask.Goal_Initiative__c = mapInitiativeLinkedToAcc.get(
                      objTask.Initiative__c
                    )
                    .Id;
                }
              }
            }

            if (objTask.whatId.getSObjectType() == Opportunity.sObjectType) {
              //Is Opportunity linked with initiative
              if (mapOpportunity.containsKey(objTask.whatId) == false) {
                objTask.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapOpportunity.containsKey(objTask.whatId) &&
                mapOpportunity.get(objTask.whatId)
                  .Goal_Initiative__r.Initiative__c != objTask.Initiative__c
              ) {
                objTask.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapOpportunity.containsKey(objTask.whatId) &&
                mapOpportunity.get(objTask.whatId)
                  .Goal_Initiative__r.Initiative__c == objTask.Initiative__c &&
                mapOpportunity.get(objTask.whatId)
                  .Goal_Initiative__r.Active__c == false
              ) {
                objTask.addError(
                  Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE_OPP
                );
              } else if (
                mapOpportunity.containsKey(objTask.whatId) &&
                mapOpportunity.get(objTask.whatId)
                  .Goal_Initiative__r.Initiative__c == objTask.Initiative__c &&
                mapOpportunity.get(objTask.whatId)
                  .Goal_Initiative__r.Active__c == true
              ) {
                objTask.Is_Related_to_Initiative__c = true;
              }
            }
          }

          //Validate Activity for Initiative and name association
          if (objTask.Initiative__c != null && objTask.whoId != null) {
            if (objTask.whoId.getSObjectType() == Lead.sObjectType) {
              //Is Lead linked with initiative
              if (mapLeadInitiative.containsKey(objTask.whoId) == false) {
                objTask.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
              } else if (
                mapLeadInitiative.containsKey(objTask.whoId) &&
                mapLeadInitiative.get(objTask.whoId).Initiative__c !=
                objTask.Initiative__c
              ) {
                objTask.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
              } else if (
                mapLeadInitiative.containsKey(objTask.whoId) &&
                mapLeadInitiative.get(objTask.whoId).Initiative__c ==
                objTask.Initiative__c
              ) {
                objTask.Linked_to_Lead_Initiative__c = true;
              }
            }

            if (objTask.whoId.getSObjectType() == Contact.sObjectType) {
              //Is Contact linked with initiative
            }
          }
        }
      }
    }
  }

  public void deleteNeglectedTaskAccounts(List<Task> taskList) {
    Set<Id> accountIdSetToBeDeleted = new Set<Id>();
    List<Account> accList = new List<Account>();

    for (Task tk : taskList) {
      accountIdSetToBeDeleted.add(tk.AccountId);
    }
    accList = [
      SELECT Id, ParentId
      FROM Account
      WHERE Id IN :accountIdSetToBeDeleted
    ];
    if (accList != null) {
      for (Account acc : accList) {
        if (acc.ParentId != null) {
          accountIdSetToBeDeleted.add(acc.ParentId);
        }
      }
    }
    if (accountIdSetToBeDeleted != null) {
      NeglectedAccountReport.deleteNeglectedAccountRecord(
        accountIdSetToBeDeleted
      );
    }
  }
}
