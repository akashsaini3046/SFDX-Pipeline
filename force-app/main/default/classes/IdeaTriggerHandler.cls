/*
 * @company     : Nagarro Inc.
 * @date        : 03-12-2019
 * @author      : Nagarro
 * @description : This class is to handle Idea realted actions
 * @history     : Version 1.0
 * @test class  : IdeaTriggerHandlerTest
 */
public with sharing class IdeaTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterDelete = true;
  List<Idea> newIdeaList;
  List<Idea> oldIdeaList;
  Map<Id, Idea> newIdeaMap;
  Map<Id, Idea> oldIdeaMap;

  /*Create the constructor*/
  public IdeaTriggerHandler() {
    this.newIdeaList = (List<Idea>) Trigger.new;
    this.oldIdeaList = (List<Idea>) Trigger.old;
    this.newIdeaMap = (Map<Id, Idea>) Trigger.newMap;
    this.oldIdeaMap = (Map<Id, Idea>) Trigger.oldMap;
  }

  /*Override the before insert method from the parent class*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      recursionVarBeforeInsert = false;
      Set<Id> idCommunity = new Set<Id>();
      for (Idea idea : newIdeaList) {
        idCommunity.add(idea.CommunityId);
      }
      List<Community> listCommunities = new List<Community>();
      listCommunities = [
        SELECT NetworkId, Id
        FROM Community
        WHERE Id IN :idCommunity
      ];
      Map<Id, Community> mapCommunities = new Map<Id, Community>(
        listCommunities
      );
      for (Idea idea : newIdeaList) {
        Id networkId = mapCommunities.get(idea.CommunityId).NetworkId;
        String loginURL = Network.getLoginURL(networkId);
        if (loginURL != null && loginURL != '')
          idea.CommunityURL__c =
            loginURL.subString(0, loginURL.length() - 5) +
            CC_Constants.IDEASFORWARDSLASH;
      }
    }
  }

  /*Override the after insert method from the parent class*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      recursionVarAfterInsert = false;
      CC_IdeasEmailService.sendNotificationIdeaPost(this.newIdeaList);
    }
  }

  /*Override the before update method from the parent class*/
  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      recursionVarBeforeUpdate = false;
    }
  }

  /*Override the after update method from the parent class*/
  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;

      List<Idea> implementedIdeas = new List<Idea>();
      for (Idea ideaObj : newIdeaList) {
        if (
          ideaObj.Status == CC_Constants.IMPLEMENTED_AND_CLOSED &&
          ideaObj.Status != oldIdeaMap.get(ideaObj.id).Status
        ) {
          implementedIdeas.add(ideaObj);
        }
      }
      System.debug('@@@implementedIdeas' + implementedIdeas);
      CC_IdeasEmailService.sendNotificationIdeaImplemented(implementedIdeas);
    }
  }

  /*Override before delete method*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      recursionVarBeforeDelete = false;
    }
  }

  /*Override after delete method*/
  public override void afterDelete() {
    if (recursionVarAfterDelete) {
      recursionVarAfterDelete = false;
    }
  }
}
