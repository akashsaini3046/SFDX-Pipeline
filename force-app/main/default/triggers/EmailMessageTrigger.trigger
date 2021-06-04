trigger EmailMessageTrigger on EmailMessage(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  if (System.Label.EmailMessage_Trigger_Flag == 'True') {
    new EmailMessageTriggerHandler().run();
  }
  if (Trigger.isBefore && Trigger.isInsert) {
    // EmailMessageTriggerHandler.UpdateFromAddressonCase(Trigger.new);
  }
  if (Trigger.isAfter && Trigger.isInsert) {
    //EmailMessageTriggerHandler.UpdateCaseStatus(Trigger.new);
  }
  if (Trigger.isAfter && Trigger.isUpdate) {
    //EmailMessageTriggerHandler.UpdateUnreadMessage(Trigger.old,Trigger.new);
  }
}
