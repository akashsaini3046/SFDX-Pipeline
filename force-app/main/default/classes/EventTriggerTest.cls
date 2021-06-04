@isTest(seeAllData=false)
private class EventTriggerTest {
  static testMethod void testEventTriggerMethod() {
    Event evt = new Event();
    evt.Description = 'Test ABC';
    evt.Subject = 'Test ABC Subject';
    evt.Location = 'Test ABC Location';
    evt.Type = 'Test ABC Type';
    evt.DurationInMinutes = 60;
    evt.ActivityDateTime = System.now() + 60;
    insert evt;
  }
}
