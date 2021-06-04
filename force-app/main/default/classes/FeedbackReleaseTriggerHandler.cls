public with sharing class FeedbackReleaseTriggerHandler extends TriggerHandler {
  List<Feedback_Release__c> newFeedbackReleaseList = new List<Feedback_Release__c>();
  List<Feedback_Release__c> oldFeedbackReleaseList = new List<Feedback_Release__c>();
  Map<Id, Feedback_Release__c> newFeedbackReleaseMap = new Map<Id, Feedback_Release__c>();
  Map<Id, Feedback_Release__c> oldFeedbackReleaseMap = new Map<Id, Feedback_Release__c>();

  public FeedbackReleaseTriggerHandler() {
    newFeedbackReleaseList = (List<Feedback_Release__c>) Trigger.New;
    oldFeedbackReleaseList = (List<Feedback_Release__c>) Trigger.Old;
    newFeedbackReleaseMap = (Map<Id, Feedback_Release__c>) Trigger.newMap;
    oldFeedbackReleaseMap = (Map<Id, Feedback_Release__c>) Trigger.oldMap;
  }

  public override void beforeInsert() {
    populateMonth(newFeedbackReleaseList);
  }

  public override void beforeUpdate() {
    populateMonth(newFeedbackReleaseList);
  }

  private void populateMonth(List<Feedback_Release__c> newFeedbackReleaseList) {
    for (Feedback_Release__c feedbackRelObj : newFeedbackReleaseList) {
      if (feedbackRelObj.Release_Date__c != null) {
        feedbackRelObj.Release_Month__c = feedbackRelObj.Release_Date__c.Format(
          'MMMM'
        );
      }
    }
  }
}
