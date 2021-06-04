trigger ContractTrigger on Contract(
  before insert,
  after insert,
  before update,
  after update
) {
  if (System.Label.Contract_Trigger_Flag == 'True') {
    new ContractTriggerHandler().Run();
  }
}
