trigger TaskTrigger on Task(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  if (System.Label.Task_Trigger_Flag == 'True') {
    new TaskTriggerHandler().run();
  }
}
