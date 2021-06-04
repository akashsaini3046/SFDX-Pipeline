trigger ContactTrigger on Contact(
  before insert,
  after insert,
  before update,
  before delete,
  after update
) {
  if (System.Label.Contact_Trigger_Flag == 'True') {
    new ContactTriggerHandler().run();
  }
}
