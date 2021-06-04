/*
 * Name: OpportunityTeamUpdateBatch
 * Purpose: Batch class for adding new owner to opportunity team after owner change on accounts.
 * Author: Nagarro
 * Created Date: 28/04/2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

public class OpportunityTeamUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  Set<Id> childOppIdSet = new Set<Id>();
  Map<Id, Id> mapOpportunitiesToAccountId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public opportunityTeamUpdateBatch(
    Map<Id, Id> mapAllAccountIdOldOwnerId,
    Set<Id> oppId,
    Map<Id, Id> mapOpportunitiesToAccountId,
    DateTime objActionStartTime
  ) {
    this.mapAllAccountIdOldOwnerId = mapAllAccountIdOldOwnerId;
    this.mapOpportunitiesToAccountId = mapOpportunitiesToAccountId;
    childOppIdSet = oppId;
    this.objActionStartTime = objActionStartTime;
  }
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, OwnerId, Owner.Region__c
        FROM Opportunity
        WHERE Id IN :childOppIdSet
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
    List<OpportunityTeamMember> oppMemList = new List<OpportunityTeamMember>();
    Map<Id, List<OpportunityTeamMember>> oppIdToMemberMap = new Map<Id, List<OpportunityTeamMember>>();
    Map<Id, String> ownerToRegionMap = new Map<Id, String>();
    Map<String, User_Region_to_Opp_Role__c> regionToRoleMap = new Map<String, User_Region_to_Opp_Role__c>();
    List<OpportunityTeamMember> oppTeamMemberListToUpdate = new List<OpportunityTeamMember>();
    List<OpportunityTeamMember> oppTeamMemberListToInsert = new List<OpportunityTeamMember>();
    List<Owner_Change_Logger__c> lstOwnerChangeLogger = new List<Owner_Change_Logger__c>();
    regionToRoleMap = User_Region_to_Opp_Role__c.getAll();

    oppMemList = [
      SELECT
        Id,
        OpportunityId,
        Opportunity.OwnerId,
        TeamMemberRole,
        UserId,
        User.Region__c
      FROM OpportunityTeamMember
      WHERE OpportunityId IN :scope
    ];

    for (Opportunity opp : scope) {
      ownerToRegionMap.put(opp.OwnerId, opp.Owner.Region__c);
    }
    for (OpportunityTeamMember oppTeam : oppMemList) {
      if (!oppIdToMemberMap.containsKey(oppTeam.OpportunityId)) {
        oppIdToMemberMap.put(
          oppTeam.OpportunityId,
          new List<OpportunityTeamMember>()
        );
      }

      oppIdToMemberMap.get(oppTeam.OpportunityId).add(oppTeam);
    }

    for (Opportunity opp : scope) {
      if (oppIdToMemberMap.containsKey(opp.Id)) {
        String newOppOwnerId = opp.OwnerId;

        if (
          oppIdToMemberMap.containsKey(opp.Id) &&
          !oppIdToMemberMap.get(opp.Id).isEmpty()
        ) {
          for (
            OpportunityTeamMember oppTeamMember : oppIdToMemberMap.get(opp.Id)
          ) {
            if (newOppOwnerId.contains(oppTeamMember.UserId)) {
              if (
                ownerToRegionMap.get(oppTeamMember.UserId) != null &&
                oppTeamMember.TeamMemberRole !=
                regionToRoleMap.get(ownerToRegionMap.get(oppTeamMember.UserId))
                  .Opp_Role__c &&
                oppTeamMember.TeamMemberRole !=
                ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR
              ) {
                oppTeamMember.TeamMemberRole = regionToRoleMap.get(
                    ownerToRegionMap.get(oppTeamMember.UserId)
                  )
                  .Opp_Role__c;
              } else if (
                ownerToRegionMap.get(oppTeamMember.UserId) == null &&
                oppTeamMember.TeamMemberRole !=
                ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN &&
                oppTeamMember.TeamMemberRole !=
                ConstantClass.TEAM_MEMBER_ROLE_AS_OPP_CREATOR
              ) {
                oppTeamMember.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
              }

              oppTeamMemberListToUpdate.add(oppTeamMember);
            }

            if (!newOppOwnerId.contains(oppTeamMember.UserId)) {
              OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();

              if (
                ownerToRegionMap.get(newOppOwnerId) != null &&
                regionToRoleMap.containsKey(ownerToRegionMap.get(newOppOwnerId))
              ) {
                oppTeamMem.TeamMemberRole = regionToRoleMap.get(
                    ownerToRegionMap.get(newOppOwnerId)
                  )
                  .Opp_Role__c;
              } else {
                oppTeamMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
              }

              oppTeamMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
              oppTeamMem.UserId = newOppOwnerId;
              oppTeamMem.OpportunityId = oppTeamMember.OpportunityId;
              oppTeamMemberListToInsert.add(oppTeamMem);
            }
          }
        }
      } else {
        String newOppOwnerId = opp.OwnerId;
        OpportunityTeamMember oppMem = new OpportunityTeamMember();
        if (ownerToRegionMap.get(newOppOwnerId) != null) {
          oppMem.TeamMemberRole = regionToRoleMap.get(
              ownerToRegionMap.get(newOppOwnerId)
            )
            .Opp_Role__c;
        } else {
          oppMem.TeamMemberRole = ConstantClass.TEAM_MEMBER_ROLE_AS_ADMIN;
        }

        oppMem.OpportunityAccessLevel = ConstantClass.EDIT_PERMISSION;
        oppMem.UserId = newOppOwnerId;
        oppMem.OpportunityId = opp.Id;
        oppTeamMemberListToInsert.add(oppMem);
      }
    }

    Database.SaveResult[] srListToInsert;
    if (
      oppTeamMemberListToInsert != null && !oppTeamMemberListToInsert.isEmpty()
    )
      srListToInsert = Database.insert(oppTeamMemberListToInsert, false);

    if (srListToInsert != null && !srListToInsert.isEmpty()) {
      Integer intIndex = 0;
      for (Database.SaveResult sr : srListToInsert) {
        if (sr.isSuccess()) {
          System.debug('Inserted Record ' + sr.id);
        } else {
          Id objRecId = null;
          if (intIndex < oppTeamMemberListToInsert.size()) {
            objRecId = oppTeamMemberListToInsert[intIndex].Id;
          }
          for (Database.Error objErr : sr.getErrors()) {
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                objRecId,
                UserInfo.getUserId(),
                'Failed',
                null,
                null,
                null,
                null,
                null,
                null,
                'Opportunity Team',
                '' +
                objErr.getFields() +
                ': ' +
                objErr.getMessage()
              )
            );
            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
          }
        }
        intIndex++;
      }
    }

    Database.SaveResult[] srListToUpdate;
    if (
      oppTeamMemberListToUpdate != null && !oppTeamMemberListToUpdate.isEmpty()
    )
      srListToUpdate = Database.update(oppTeamMemberListToUpdate, false);

    if (srListToUpdate != null && !srListToUpdate.isEmpty()) {
      Integer intIndex = 0;
      for (Database.SaveResult sr : srListToUpdate) {
        if (sr.isSuccess()) {
          System.debug('Inserted Record ' + sr.id);
        } else {
          Id objRecId = null;
          if (intIndex < oppTeamMemberListToUpdate.size()) {
            objRecId = oppTeamMemberListToUpdate[intIndex].Id;
          }
          for (Database.Error objErr : sr.getErrors()) {
            lstOwnerChangeLogger.add(
              OwnerChangeLoggerUtility.createLogger(
                objActionStartTime,
                objRecId,
                UserInfo.getUserId(),
                'Failed',
                null,
                null,
                null,
                null,
                null,
                null,
                'Opportunity Team',
                '' +
                objErr.getFields() +
                ': ' +
                objErr.getMessage()
              )
            );
            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
          }
        }
        intIndex++;
      }
    }
  }

  public void finish(Database.BatchableContext bc) {
    Mass_Account_Transfer__mdt objMeta = [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
      WHERE DeveloperName = 'ContactOwnerChangeBatch'
    ];
    Database.executeBatch(
      new ContactOwnerChangeBatch(
        mapAllAccountIdOldOwnerId,
        mapOpportunitiesToAccountId,
        this.objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
  }
}
