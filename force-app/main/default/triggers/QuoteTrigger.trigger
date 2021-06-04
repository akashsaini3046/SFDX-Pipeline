trigger QuoteTrigger on Quote__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  new QuoteTriggerHandler().run();
}
