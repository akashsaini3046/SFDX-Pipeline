trigger IdeaTrigger on Idea(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete
) {
  System.debug(
    'System.Label.Idea_Trigger_Flag -> ' + System.Label.Idea_Trigger_Flag
  );
  if (System.Label.Idea_Trigger_Flag == 'True') {
    new IdeaTriggerHandler().run();
  }
}
