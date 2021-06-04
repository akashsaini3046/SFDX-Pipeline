/*
 * Name: OpportunityTeamMemberTriggerHandler
 * Purpose: Handler class for Opportunity Team Member Trigger
 * Author: Nagarro
 * Created Date: 03/12/2020
 * Modification History
 * Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
public class OpportunityTeamMemberTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarAfterDelete = true;

  List<OpportunityTeamMember> newOpportunityTeamMemberList;
  List<OpportunityTeamMember> oldOpportunityTeamMemberList;
  Map<Id, OpportunityTeamMember> newOpportunityTeamMemberMap;
  Map<Id, OpportunityTeamMember> oldOpportunityTeamMemberMap;

  /*Constructor*/
  public OpportunityTeamMemberTriggerHandler() {
    this.newOpportunityTeamMemberList = (List<OpportunityTeamMember>) Trigger.new;
    this.oldOpportunityTeamMemberList = (List<OpportunityTeamMember>) Trigger.old;
    this.newOpportunityTeamMemberMap = (Map<Id, OpportunityTeamMember>) Trigger.newMap;
    this.oldOpportunityTeamMemberMap = (Map<Id, OpportunityTeamMember>) Trigger.oldMap;
  }

  /*Override the before insert method from the parent class*/
  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      updateMemberDeptFieldOnOTM(newOpportunityTeamMemberList);
      preventRoleMismatchForSalesAgent(newOpportunityTeamMemberList);
      recursionVarBeforeInsert = false;
    }
  }

  /*Override before Update method*/
  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      //preventAdditionMoreThanOneSalesAgent(newOpportunityTeamMemberList);
      updateMemberDeptFieldOnOTM(newOpportunityTeamMemberList);
      preventRoleMismatchForSalesAgent(newOpportunityTeamMemberList);
      recursionVarBeforeUpdate = false;
    }
  }

  /*Override after Update method*/
  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;
    }
  }

  /*Override the after insert method from the parent class*/
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      recursionVarAfterInsert = false;
    }
  }

  /*Override the after delete method from the parent class*/
  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      recursionVarBeforeDelete = false;
    }
  }

  /*
   * Method Name: preventRoleMismatchForSalesAgent.
   * Input Parameters: List of new opportunity team members.
   * Return value: None.
   * Purpose: Prevent role mismatch for Sales agent addition on opportunity team.
   * Comment: preventRoleMismatchForSalesAgent method should be called before
   * preventAdditionMoreThanOneSalesAgent in beforeInsert and beforeUpdate trigger.
   */
  private void preventRoleMismatchForSalesAgent(
    List<OpportunityTeamMember> newOpportunityTeamMemberList
  ) {
    Set<Id> opportunityIdSet = new Set<Id>();
    Set<Id> opportunityTeamUserIdSet = new Set<Id>();
    Map<Id, String> userIdToProfileNameMap = new Map<Id, String>();
    Map<Id, Profile> profileIdToNameMap = new Map<Id, Profile>(
      [SELECT Id, Name FROM Profile]
    );
    Id currentUserProfileId = UserInfo.getProfileId();
    Id currentUserId = UserInfo.getUserId();
    String currentUserProfile = (profileIdToNameMap.get(currentUserProfileId))
      .Name;

    for (OpportunityTeamMember oppTeamMem : newOpportunityTeamMemberList) {
      OpportunityIdSet.add(oppTeamMem.OpportunityId);
      OpportunityTeamUserIdSet.add(oppTeamMem.UserId);
    }

    List<User> oppTeamUserList = [
      SELECT Id, Profile.Id
      FROM User
      WHERE Id = :OpportunityTeamUserIdSet
    ];

    for (User oppTeamUser : OppTeamUserList) {
      userIdToProfileNameMap.put(
        oppTeamUser.Id,
        profileIdToNameMap.get(oppTeamUser.ProfileId).Name
      );
    }

    for (OpportunityTeamMember oppTeamMem : newOpportunityTeamMemberList) {
      if (
        (oppTeamMem.TeamMemberRole ==
        ConstantClass.TEAM_MEMBER_ROLE_AS_SALES_AGENT &&
        userIdToProfileNameMap.get(oppTeamMem.UserId) !=
        ConstantClass.SALES_AGENT_PROFILE) ||
        (oppTeamMem.TeamMemberRole !=
        ConstantClass.TEAM_MEMBER_ROLE_AS_SALES_AGENT &&
        userIdToProfileNameMap.get(oppTeamMem.UserId) ==
        ConstantClass.SALES_AGENT_PROFILE)
      ) {
        oppTeamMem.addError(
          System.label.Error_Opportunity_Team_Member_Sales_Agent_Role
        );
      }
    }
  }

  private static void updateMemberDeptFieldOnOTM(
    List<OpportunityTeamMember> newOpportunityTeamMemberList
  ) {
    Set<Id> userIds = new Set<Id>();
    Map<Id, String> userIdToProfileNameMap = new Map<Id, String>();
    Map<Id, Profile> profileIdToNameMap = new Map<Id, Profile>(
      [SELECT Id, Name FROM Profile]
    );

    for (OpportunityTeamMember otm : newOpportunityTeamMemberList) {
      userIds.add(otm.UserId);
    }
    map<Id, String> UserMap = new Map<Id, String>();
    for (User u : [
      SELECT Id, Department, Name, ProfileId, Profile.Name
      FROM User
      WHERE Id IN :userIds
    ]) {
      UserMap.put(u.id, u.Department);
      userIdToProfileNameMap.put(
        u.Id,
        profileIdToNameMap.get(u.ProfileId).Name
      );
    }

    for (OpportunityTeamMember otm : newOpportunityTeamMemberList) {
      //if(userIdToProfileNameMap.get(otm.UserId) == 'Account Manager' || userIdToProfileNameMap.get(otm.UserId) == 'Account Rep') {
      if (userMap.containsKey(otm.UserId))
        otm.Member_Department__c = UserMap.get(otm.UserId);
      //}
    }
  }
}
