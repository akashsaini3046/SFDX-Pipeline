trigger UserTrigger on User(after insert, after update) {
  if (System.Label.User_Trigger_Flag == 'True') {
    new UserTriggerHandler().run();
  }
}
