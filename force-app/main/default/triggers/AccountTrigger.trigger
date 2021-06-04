trigger AccountTrigger on Account(
  before insert,
  after insert,
  before update,
  after update,
  before delete
) {
  if (System.Label.Account_Trigger_Flag == 'True') {
    new AccountTriggerHandler().run();
  }
}
