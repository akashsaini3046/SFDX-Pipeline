/*
 * Name: EventTriggerHandler
 * Purpose: Handler class for Event Trigger
 * Author: Nagarro
 * Created Date: 17- Oct - 2019
 *
 *  Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
public class EventTriggerHandler extends TriggerHandler {
  List<Event> newEventList;
  List<Event> oldEventList;
  Map<Id, Event> oldEventMap = new Map<Id, Event>();
  Map<Id, Event> newEventMap = new Map<Id, Event>();
  public static Boolean isRecursion = false;

  //Constructor
  public EventTriggerHandler() {
    this.newEventList = (List<Event>) Trigger.new;
    this.oldEventList = (List<Event>) Trigger.old;
    this.oldEventMap = (Map<Id, Event>) Trigger.oldMap;
    this.newEventMap = (Map<Id, Event>) Trigger.newMap;
  }

  //Override the before insert method
  public override void beforeInsert() {
    if (isRecursion == false) {
      isRecursion = true;
      changeEventTypeToMeeting(newEventList);
      linkEventWithInitiative(newEventList, oldEventMap);
    }
  }

  //Override the before update method
  public override void beforeUpdate() {
    if (isRecursion == false) {
      isRecursion = true;
      try {
        if (LeadConversionIdentifier.boolCalledAfterLeadConverted == false) {
          validateInitiativeChange(newEventList, oldEventMap);
        }
      } catch (Exception objEx) {
        System.debug(
          'EventTriggerHandler.validateInitiativeChange ' + objEx.getMessage()
        );
      }
    }
  }

  public override void afterUpdate() {
    deleteNeglectedEventAccounts(newEventList);
  }

  public override void afterInsert() {
    deleteNeglectedEventAccounts(newEventList);
  }

  /*
   * Method Name: changeEventTypeToMeeting
   * Input Parameters: List<Event> lstEvents
   * Return value: void
   * Purpose: Update event type to meeting.
   */
  private void changeEventTypeToMeeting(List<Event> lstEvents) {
    for (Event objEvent : lstEvents) {
      if (objEvent.Type == null) {
        objEvent.Type = ConstantClass.EVENT_TYPE_MEETING;
      }
    }
  }

  /*
   * Method Name: linkEventWithInitiative
   * Input Parameters:
   * List<Goal_Initiative__c> lstNew: This holds new Goal Initiative list.
   * Return value:
   * Purpose: link Event with initiative.
   */
  private void linkEventWithInitiative(
    List<Event> lstNewEvent,
    Map<Id, Event> mapOldEvent
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

    for (Event objEvent : lstNewEvent) {
      if (objEvent.Goal_Initiative__c != null) {
        setGoalInitiativeId.add(objEvent.Goal_Initiative__c);
      }
      if (objEvent.WhatId != null) {
        setWhatId.add(objEvent.WhatId);
      }
      if (objEvent.WhoId != null) {
        setWhoId.add(objEvent.WhoId);
      }
      if (
        mapOldEvent != null &&
        mapOldEvent.containsKey(objEvent.Id) &&
        mapOldEvent.get(objEvent.Id).Initiative__c != objEvent.Initiative__c
      ) {
        setTaskNotconsideredForIniLink.add(objEvent.Id);
        objEvent.Goal_Initiative__c = null;
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

    for (Event objEvent : lstNewEvent) {
      if (
        !setTaskNotconsideredForIniLink.contains(objEvent.Id) &&
        objEvent.whatId != null &&
        objEvent.whatId.getSObjectType() == Account.sObjectType &&
        objEvent.Goal_Initiative__c != null &&
        MapGoalInitiative.containsKey(objEvent.Goal_Initiative__c)
      ) {
        //What id is Account
        objEvent.Initiative__c = MapGoalInitiative.get(
            objEvent.Goal_Initiative__c
          )
          .Initiative__c;
      } else if (
        !setTaskNotconsideredForIniLink.contains(objEvent.Id) &&
        objEvent.whatId != null &&
        objEvent.whatId.getSObjectType() == Opportunity.sObjectType &&
        objEvent.Is_Related_to_Initiative__c &&
        mapOpportunity.containsKey(objEvent.whatId)
      ) {
        //What id is Opportunity
        objEvent.Initiative__c = mapOpportunity.get(objEvent.whatId)
          .Goal_Initiative__r.Initiative__c;
      } else if (
        !setTaskNotconsideredForIniLink.contains(objEvent.Id) &&
        objEvent.whatId != null &&
        objEvent.whatId.getSObjectType() == Initiative__c.sObjectType
      ) {
        //What id is Initiative
        objEvent.Initiative__c = objEvent.whatId;
        if (
          mapInitiative != null &&
          mapInitiative.containsKey(objEvent.whatId) &&
          mapInitiative.get(objEvent.whatId).isActive__c == false
        ) {
          objEvent.addError(Label.AINI_ACTIVITY_ON_INACTIVE_INITIATIVE);
        } else if (
          mapInitiative != null &&
          mapInitiative.containsKey(objEvent.whatId) &&
          mapInitiative.get(objEvent.whatId).Initiative_Type__c == 'Closed'
        ) {
          //objEvent.addError(Label.AINI_ACTIVITY_ON_CLOSED_INITIATIVE);
        }
      } else if (
        !setTaskNotconsideredForIniLink.contains(objEvent.Id) &&
        objEvent.whatId == null &&
        objEvent.Goal_Initiative__c != null &&
        MapGoalInitiative.containsKey(objEvent.Goal_Initiative__c)
      ) {
        //What id is null and only Goal Initiative is there
        objEvent.Initiative__c = MapGoalInitiative.get(
            objEvent.Goal_Initiative__c
          )
          .Initiative__c;
      } else if (
        !setTaskNotconsideredForIniLink.contains(objEvent.Id) &&
        objEvent.WhoId != null &&
        objEvent.whoId.getSObjectType() == Lead.sObjectType &&
        objEvent.Linked_to_Lead_Initiative__c &&
        mapLeadInitiative.containsKey(objEvent.WhoId)
      ) {
        //Who id is Lead
        objEvent.Initiative__c = mapLeadInitiative.get(objEvent.WhoId)
          .Initiative__c;
      }

      if (objEvent.Initiative__c == null) {
        objEvent.Is_Related_to_Initiative__c = false;
      }

      //Validate Activity for Initiative and related to association
      if (objEvent.Initiative__c != null && objEvent.whatId != null) {
        if (
          objEvent.whatId.getSObjectType() != Initiative__c.sObjectType &&
          objEvent.whatId.getSObjectType() != Account.sObjectType &&
          objEvent.whatId.getSObjectType() != Opportunity.sObjectType
        ) {
          objEvent.addError(Label.AINI_INITIATIVE_WHATID_SUPPORT);
        }

        if (objEvent.whatId.getSObjectType() == Account.sObjectType) {
          //Is Account linked with initiative
          Map<Id, Goal_Initiative__c> mapInitiativeLinkedToAcc = mapAccountInitiatives.get(
            objEvent.whatId
          );

          if (mapInitiativeLinkedToAcc == null) {
            objEvent.addError(Label.AINI_IS_ACC_LINKED_WITH_INITIATIVE);
          } else if (
            mapInitiativeLinkedToAcc != null &&
            mapInitiativeLinkedToAcc.containsKey(objEvent.Initiative__c) ==
            false
          ) {
            objEvent.addError(Label.AINI_IS_ACC_LINKED_WITH_INITIATIVE);
          } else if (
            mapInitiativeLinkedToAcc != null &&
            mapInitiativeLinkedToAcc.containsKey(objEvent.Initiative__c)
          ) {
            if (
              mapInitiativeLinkedToAcc.get(objEvent.Initiative__c) != null &&
              mapInitiativeLinkedToAcc.get(objEvent.Initiative__c).Active__c ==
              false
            ) {
              objEvent.addError(
                Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE
              );
            }
          }
        }

        if (objEvent.whatId.getSObjectType() == Opportunity.sObjectType) {
          //Is Opportunity linked with initiative
          if (mapOpportunity.containsKey(objEvent.whatId) == false) {
            objEvent.addError(Label.AINI_IS_OPP_LINKED_WITH_INITIATIVE);
          } else if (
            mapOpportunity.containsKey(objEvent.whatId) &&
            mapOpportunity.get(objEvent.whatId)
              .Goal_Initiative__r.Initiative__c != objEvent.Initiative__c
          ) {
            objEvent.addError(Label.AINI_IS_OPP_LINKED_WITH_INITIATIVE);
          } else if (
            mapOpportunity.containsKey(objEvent.whatId) &&
            mapOpportunity.get(objEvent.whatId)
              .Goal_Initiative__r.Initiative__c == objEvent.Initiative__c &&
            mapOpportunity.get(objEvent.whatId).Goal_Initiative__r.Active__c ==
            false
          ) {
            objEvent.addError(
              Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE_OPP
            );
          }
        }
      }

      //Validate Activity for Initiative and name association
      if (objEvent.Initiative__c != null && objEvent.whoId != null) {
        if (objEvent.whoId.getSObjectType() == Lead.sObjectType) {
          //Is Lead linked with initiative
          if (mapLeadInitiative.containsKey(objEvent.whoId) == false) {
            objEvent.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
          } else if (
            mapLeadInitiative.containsKey(objEvent.whoId) &&
            mapLeadInitiative.get(objEvent.whoId).Initiative__c !=
            objEvent.Initiative__c
          ) {
            objEvent.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
          } else if (
            mapLeadInitiative.containsKey(objEvent.whoId) &&
            mapLeadInitiative.get(objEvent.whoId).Initiative__c ==
            objEvent.Initiative__c &&
            mapLeadInitiative.get(objEvent.whoId).Initiative__r.IsActive__c ==
            false
          ) {
            objEvent.addError(Label.AINI_ACTIVITY_ON_INACTIVE_INITIATIVE);
          }
        }

        if (objEvent.whoId.getSObjectType() == Contact.sObjectType) {
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
    List<Event> lstNewEvent,
    Map<Id, Event> mapOldEvent
  ) {
    Set<Id> setEventsWhereInitiativeChanged = new Set<Id>();
    Map<Id, Map<Id, Goal_Initiative__c>> mapAccountInitiatives = new Map<Id, Map<Id, Goal_Initiative__c>>();
    Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
    Set<Id> setWhatId = new Set<Id>();
    Set<Id> setWhoId = new Set<Id>();
    Map<Id, Lead> mapLeadInitiative = new Map<Id, Lead>();
    String strRelatedToInitiativeMismatchError = Label.AINI_INITIATIVE_RELATED_TO_MISMATCH;

    for (Event objEvent : lstNewEvent) {
      if (
        mapOldEvent != null &&
        mapOldEvent.containsKey(objEvent.Id) &&
        ((mapOldEvent.get(objEvent.Id).Initiative__c !=
        objEvent.Initiative__c) ||
        (objEvent.Initiative__c != null &&
        mapOldEvent.get(objEvent.Id).WhatId != objEvent.WhatId) ||
        (objEvent.Initiative__c != null &&
        mapOldEvent.get(objEvent.Id).WhoId != objEvent.WhoId))
      ) {
        objEvent.Goal_Initiative__c = null;
        if (objEvent.Initiative__c == null) {
          objEvent.Is_Related_to_Initiative__c = false;
          objEvent.Linked_to_Lead_Initiative__c = false;
        }

        if (objEvent.Initiative__c != null) {
          setEventsWhereInitiativeChanged.add(objEvent.Id);
        }
        if (objEvent.WhatId != null) {
          setWhatId.add(objEvent.WhatId);
        }
        if (objEvent.WhoId != null) {
          setWhoId.add(objEvent.WhoId);
        }
      }
    }

    if (setEventsWhereInitiativeChanged.size() > 0) {
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
      for (Event objEvent : lstNewEvent) {
        if (setEventsWhereInitiativeChanged.contains(objEvent.Id)) {
          //Validate Activity for Initiative and related to association
          if (objEvent.Initiative__c != null && objEvent.whatId != null) {
            if (
              objEvent.whatId.getSObjectType() != Initiative__c.sObjectType &&
              objEvent.whatId.getSObjectType() != Account.sObjectType &&
              objEvent.whatId.getSObjectType() != Opportunity.sObjectType
            ) {
              objEvent.addError(Label.AINI_INITIATIVE_WHATID_SUPPORT);
            }

            if (objEvent.whatId.getSObjectType() == Account.sObjectType) {
              //Is Account linked with initiative
              Map<Id, Goal_Initiative__c> mapInitiativeLinkedToAcc = mapAccountInitiatives.get(
                objEvent.whatId
              );

              if (mapInitiativeLinkedToAcc == null) {
                objEvent.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapInitiativeLinkedToAcc != null &&
                mapInitiativeLinkedToAcc.containsKey(objEvent.Initiative__c) ==
                false
              ) {
                objEvent.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapInitiativeLinkedToAcc != null &&
                mapInitiativeLinkedToAcc.containsKey(objEvent.Initiative__c)
              ) {
                if (
                  mapInitiativeLinkedToAcc.get(objEvent.Initiative__c) !=
                  null &&
                  mapInitiativeLinkedToAcc.get(objEvent.Initiative__c)
                    .Active__c == false
                ) {
                  objEvent.addError(
                    Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE
                  );
                } else if (
                  mapInitiativeLinkedToAcc.get(objEvent.Initiative__c) !=
                  null &&
                  mapInitiativeLinkedToAcc.get(objEvent.Initiative__c)
                    .Active__c == true
                ) {
                  objEvent.Goal_Initiative__c = mapInitiativeLinkedToAcc.get(
                      objEvent.Initiative__c
                    )
                    .Id;
                }
              }
            }

            if (objEvent.whatId.getSObjectType() == Opportunity.sObjectType) {
              //Is Opportunity linked with initiative
              if (mapOpportunity.containsKey(objEvent.whatId) == false) {
                objEvent.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapOpportunity.containsKey(objEvent.whatId) &&
                mapOpportunity.get(objEvent.whatId)
                  .Goal_Initiative__r.Initiative__c != objEvent.Initiative__c
              ) {
                objEvent.addError(strRelatedToInitiativeMismatchError);
              } else if (
                mapOpportunity.containsKey(objEvent.whatId) &&
                mapOpportunity.get(objEvent.whatId)
                  .Goal_Initiative__r.Initiative__c == objEvent.Initiative__c &&
                mapOpportunity.get(objEvent.whatId)
                  .Goal_Initiative__r.Active__c == false
              ) {
                objEvent.addError(
                  Label.AINI_INITIATIVE_ACCOUNT_RELATIONSHIP_IS_INACTIVE_OPP
                );
              } else if (
                mapOpportunity.containsKey(objEvent.whatId) &&
                mapOpportunity.get(objEvent.whatId)
                  .Goal_Initiative__r.Initiative__c == objEvent.Initiative__c &&
                mapOpportunity.get(objEvent.whatId)
                  .Goal_Initiative__r.Active__c == true
              ) {
                objEvent.Is_Related_to_Initiative__c = true;
              }
            }
          }

          //Validate Activity for Initiative and name association
          if (objEvent.Initiative__c != null && objEvent.whoId != null) {
            if (objEvent.whoId.getSObjectType() == Lead.sObjectType) {
              //Is Lead linked with initiative
              if (mapLeadInitiative.containsKey(objEvent.whoId) == false) {
                objEvent.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
              } else if (
                mapLeadInitiative.containsKey(objEvent.whoId) &&
                mapLeadInitiative.get(objEvent.whoId).Initiative__c !=
                objEvent.Initiative__c
              ) {
                objEvent.addError(Label.AINI_IS_LEAD_LINKED_WITH_INITIATIVE);
              } else if (
                mapLeadInitiative.containsKey(objEvent.whoId) &&
                mapLeadInitiative.get(objEvent.whoId).Initiative__c ==
                objEvent.Initiative__c
              ) {
                objEvent.Linked_to_Lead_Initiative__c = true;
              }
            }

            if (objEvent.whoId.getSObjectType() == Contact.sObjectType) {
              //Is Contact linked with initiative
            }
          }
        }
      }
    }
  }

  public void deleteNeglectedEventAccounts(List<Event> eventList) {
    Set<Id> accountIdSetToBeDeleted = new Set<Id>();
    List<Account> accList = new List<Account>();

    for (Event ev : eventList) {
      accountIdSetToBeDeleted.add(ev.AccountId);
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
