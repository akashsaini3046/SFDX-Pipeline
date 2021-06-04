trigger EventTrigger on Event(before insert) {
  if (System.Label.Task_Trigger_Flag == 'True') {
    new EventTriggerHandler().run();
  }
}
