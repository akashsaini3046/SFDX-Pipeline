trigger OpportunityTrigger on Opportunity(
  before delete,
  before insert,
  before update,
  after insert,
  after update
) {
  if (System.Label.Opportunity_Trigger_Flag == 'True') {
    new OpportunityTriggerHandler().run();
  }
}
