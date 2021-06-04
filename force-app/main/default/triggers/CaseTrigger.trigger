trigger CaseTrigger on Case(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  if (System.Label.Case_Trigger_Flag == 'True') {
    new CaseTriggerHandler().run();
  }
}
