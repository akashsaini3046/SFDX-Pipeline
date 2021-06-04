trigger GoalRelationshipTrigger on Goal_Initiative__c(
  before insert,
  after insert,
  before update,
  before delete
) {
  new GoalRelationshipTriggerHandler().run();
}
