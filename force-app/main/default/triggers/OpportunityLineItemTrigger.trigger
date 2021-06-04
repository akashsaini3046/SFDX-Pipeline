trigger OpportunityLineItemTrigger on OpportunityLineItem(
  after insert,
  after delete,
  before insert,
  before update
) {
  if (System.Label.OLI_Trigger_Flag == 'True') {
    new OpportunityLineItemTriggerHandler().run();
  }
}
