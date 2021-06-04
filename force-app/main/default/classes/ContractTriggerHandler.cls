public class ContractTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarAfterDelete = true;
  List<Contract> newContractList = new List<Contract>();
  List<Contract> oldContractList = new List<Contract>();
  Map<Id, Contract> newContractMap = new Map<Id, Contract>();
  Map<Id, Contract> oldContractMap = new Map<Id, Contract>();

  public ContractTriggerHandler() {
    this.newContractList = (List<Contract>) Trigger.New;
    this.oldContractList = (List<Contract>) Trigger.Old;
    this.newContractMap = (Map<Id, Contract>) Trigger.NewMap;
    this.oldContractMap = (Map<Id, Contract>) Trigger.OldMap;
  }
  /*Override the before insert method from the parent class*/
  public override void beforeInsert() {
    // notifyATM(newContractList. oldContractMap);
    updateRecordType(newContractList);
  }
  public override void beforeUpdate() {
  }
  public override void afterInsert() {
    notifyATM(newContractList, oldContractMap);
  }
  public override void afterUpdate() {
    notifyATM(newContractList, oldContractMap);
  }
  /*
    private void setNumOfContractOnAcc(List<Contract> newContractList, List<Contract> oldContractList){
        
        List<Id> accIdList = new List<Id>();
        Map<Id, List<Id>> accIdToContractListMap = new Map<Id, List<Id>>();
        List<Account> accListtoUpdate = new List<Account>();
        
        if(trigger.IsInsert){
            for(Contract contractobj: newContractList){
                accIdList.add(contractobj.AccountId);
            }
        }else if(Trigger.IsDelete){
            for(Contract contractobj: oldContractList){
                accIdList.add(contractobj.AccountId);
            }
        }
        
        for(Contract contractObj: [Select Id, AccountId from Contract where AccountId IN :accIdList]){
            if(!accIdToContractListMap.containsKey(contractObj.AccountId)){
                accIdToContractListMap.put(contractObj.AccountId, new List<Id>());
            }
            accIdToContractListMap.get(contractObj.AccountId).add(contractObj.Id);
        }
        
        for(Id accId: accIdList){
            Account accObj = new Account();
            accObj.Id = accId;
            if(accIdToContractListMap.containsKey(accId)){
                accObj.Number_of_Contracts__c = accIdToContractListMap.get(accId).Size();
            }else{
                accObj.Number_of_Contracts__c = 0;
            }
            accListtoUpdate.add(accObj);
        }
        
        TriggerHandler.Bypass('AccountTriggerHandler');
        update accListtoUpdate;
        TriggerHandler.ClearBypass('AccountTriggerHandler');
    } */

  private void notifyATM(
    list<Contract> contractList,
    Map<Id, Contract> oldContractMap
  ) {
    set<id> setOfContractIds = new Set<id>();
    set<string> setOfOtmIds = new Set<string>();
    for (Contract c : contractList) {
      if (
        (Trigger.IsInsert && c.Status == 'Out for Signature') ||
        (Trigger.IsUpdate &&
        c.Status != oldContractMap.get(c.id).Status &&
        c.Status == 'Out for Signature')
      ) {
        setOfContractIds.add(c.Id);
      }
    }
    for (OpportunityTeamMember oppTeam : [
      SELECT id, OpportunityId, Opportunity.ContractId, User.Id
      FROM OpportunityTeamMember
      WHERE Opportunity.ContractId IN :setOfContractIds
    ]) {
      setOfOtmIds.add(oppTeam.User.Id);
    }

    for (Contract c : [
      SELECT Id, AccountId, Account.Name
      FROM Contract
      WHERE Id IN :setOfContractIds
    ]) {
      String conId = c.Id;
      ContractNotificationFomApex.notifyUsers(
        setOfOtmIds,
        conId,
        c.Account.Name
      );
    }
  }

  private void updateRecordType(list<Contract> contractList) {
    Id standardRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
      .get('Standard')
      .getRecordTypeId();
    Id standardRORecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
      .get('Standard - Read Only')
      .getRecordTypeId();
    Id amendRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
      .get('Amendment')
      .getRecordTypeId();
    Id amendRORecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName()
      .get('Amendment - Read Only')
      .getRecordTypeId();

    for (Contract c : contractList) {
      System.debug('record typw' + c.RecordTypeId);
      if (c.RecordTypeId == standardRecordTypeId) {
        c.RecordTypeId = standardRORecordTypeId;
      } else if (c.RecordTypeId == amendRecordTypeId) {
        c.RecordTypeId = amendRORecordTypeId;
      }
    }
  }
}
