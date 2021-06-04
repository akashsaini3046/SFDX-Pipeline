trigger FeedbackReleaseTrigger on Feedback_Release__c(
  before insert,
  before update
) {
  new FeedbackReleaseTriggerHandler().run();
}
