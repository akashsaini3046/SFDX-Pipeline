trigger InitiativeTrigger on Initiative__c(before delete) {
  new InitiativeTriggerHandler().run();
}
