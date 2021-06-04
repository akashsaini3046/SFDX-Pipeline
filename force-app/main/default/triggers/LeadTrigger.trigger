trigger LeadTrigger on Lead(
  before insert,
  before update,
  before delete,
  after insert,
  after update
) {
  if (System.Label.Lead_Trigger_Flag == 'True') {
    new LeadTriggerHandler().run();
  }
}
