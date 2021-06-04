@isTest
public class FeedbackReleaseTriggerHandler_Test {
  @testSetup
  static void dataSetup() {
    List<Feedback_Release__c> feedbackreleaseList = TestDataUtility.createFeedbackRelease();
    insert feedbackreleaseList;
  }

  static testMethod void TestMethod1() {
    List<Feedback_Release__c> releaselist = [
      SELECT Id
      FROM Feedback_Release__c
    ];
    update releaselist;
  }
}
