trigger AddressTrigger on Address__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete
) {
  if (System.Label.BL_Trigger_Flag == 'True') {
    new AddressTriggerHandler().run();
  }
}
