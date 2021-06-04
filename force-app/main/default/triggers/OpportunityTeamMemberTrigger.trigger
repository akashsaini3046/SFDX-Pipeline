trigger OpportunityTeamMemberTrigger on OpportunityTeamMember(
  before delete,
  before insert,
  before update,
  after insert,
  after update
) {
  if (System.Label.OpportunityTeamMember_Trigger_Flag == 'True') {
    new OpportunityTeamMemberTriggerHandler().run();
  }
}
