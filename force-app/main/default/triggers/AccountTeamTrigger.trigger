trigger AccountTeamTrigger on AccountTeamMember(
  after insert,
  after update,
  after delete,
  before delete,
  before insert,
  before update
) {
  new AccountTeamTriggerHandler().run();
}
