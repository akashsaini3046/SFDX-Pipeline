public class AccountTeamChangeCaptureBatch implements Database.Batchable<sObject> {
  public Map<Id, List<AccountTeamMember>> insertedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  public Map<Id, List<AccountTeamMember>> updatedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  public Map<Id, List<AccountTeamMember>> deletedAccMemberMap = new Map<Id, List<AccountTeamMember>>();
  Map<Id, Id> mapAllAccountIdOldOwnerId = new Map<Id, Id>();
  DateTime objActionStartTime;

  public AccountTeamChangeCaptureBatch(
    Map<Id, List<AccountTeamMember>> insAccMemberMap,
    Map<Id, List<AccountTeamMember>> updAccMemberMap,
    Map<Id, List<AccountTeamMember>> delAccMemberMap,
    Map<Id, Id> mapAllAccountIdOldOwnerId,
    DateTime objActionStartTime
  ) {
    insertedAccMemberMap = insAccMemberMap;
    updatedAccMemberMap = updAccMemberMap;
    deletedAccMemberMap = delAccMemberMap;
    this.mapAllAccountIdOldOwnerId = mapAllAccountIdOldOwnerId;
    this.objActionStartTime = objActionStartTime;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, ParentId, CVIF__c
        FROM Account
        WHERE
          Id IN :insertedAccMemberMap.keySet()
          OR Id IN :updatedAccMemberMap.keySet()
          OR Id IN :deletedAccMemberMap.keySet()
          OR ParentId IN :insertedAccMemberMap.keySet()
          OR ParentId IN :updatedAccMemberMap.keySet()
          OR ParentId IN :deletedAccMemberMap.keySet()
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Account> scope) {
    Map<Id, List<Account>> parentToChildMap = new Map<Id, List<Account>>();
    List<Account_Team_Member_Info__c> accTeamInfoInsertList = new List<Account_Team_Member_Info__c>();

    for (Account acc : scope) {
      if (acc.ParentId == null) {
        if (
          insertedAccMemberMap.containsKey(acc.Id) &&
          !insertedAccMemberMap.get(acc.Id).isEmpty()
        ) {
          for (AccountTeamMember accMem : insertedAccMemberMap.get(acc.Id)) {
            Account_Team_Member_Info__c obj = new Account_Team_Member_Info__c();
            obj.User__c = accMem.UserId;
            obj.Account__c = acc.Id;
            obj.Team_Role__c = accMem.TeamMemberRole;
            obj.Status__c = 'Inserted';
            obj.CVIF_Id__c = acc.CVIF__c;
            obj.Parent_Account__c = acc.ParentId;
            obj.Unique__c =
              accMem.UserId +
              ' ' +
              acc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj);
          }
        } else if (
          updatedAccMemberMap.containsKey(acc.Id) &&
          !updatedAccMemberMap.get(acc.Id).isEmpty()
        ) {
          for (AccountTeamMember accMem : updatedAccMemberMap.get(acc.Id)) {
            Account_Team_Member_Info__c obj = new Account_Team_Member_Info__c();
            obj.User__c = accMem.UserId;
            obj.Account__c = acc.Id;
            obj.Team_Role__c = accMem.TeamMemberRole;
            obj.Status__c = 'Updated';
            obj.CVIF_Id__c = acc.CVIF__c;
            obj.Parent_Account__c = acc.ParentId;
            obj.Unique__c =
              accMem.UserId +
              ' ' +
              acc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj);
          }
        } else if (
          deletedAccMemberMap.containsKey(acc.Id) &&
          !deletedAccMemberMap.get(acc.Id).isEmpty()
        ) {
          for (AccountTeamMember accMem : deletedAccMemberMap.get(acc.Id)) {
            Account_Team_Member_Info__c obj = new Account_Team_Member_Info__c();
            obj.User__c = accMem.UserId;
            obj.Account__c = acc.Id;
            obj.Team_Role__c = accMem.TeamMemberRole;
            obj.Status__c = 'Deleted';
            obj.CVIF_Id__c = acc.CVIF__c;
            obj.Parent_Account__c = acc.ParentId;
            obj.Unique__c =
              accMem.UserId +
              ' ' +
              acc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj);
          }
        }
      } else {
        if (
          insertedAccMemberMap.containsKey(acc.ParentId) &&
          !insertedAccMemberMap.get(acc.ParentId).isEmpty()
        ) {
          for (
            AccountTeamMember accMem : insertedAccMemberMap.get(acc.ParentId)
          ) {
            Account_Team_Member_Info__c obj2 = new Account_Team_Member_Info__c();
            obj2.User__c = accMem.UserId;
            obj2.Account__c = acc.Id;
            obj2.Team_Role__c = accMem.TeamMemberRole;
            obj2.Status__c = 'Inserted';
            obj2.CVIF_Id__c = acc.CVIF__c;
            obj2.Parent_Account__c = acc.ParentId;
            obj2.Unique__c =
              accMem.UserId +
              ' ' +
              acc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj2);
          }
        } else if (
          updatedAccMemberMap.containsKey(acc.ParentId) &&
          !updatedAccMemberMap.get(acc.ParentId).isEmpty()
        ) {
          for (
            AccountTeamMember accMem : updatedAccMemberMap.get(acc.ParentId)
          ) {
            Account_Team_Member_Info__c obj2 = new Account_Team_Member_Info__c();
            obj2.User__c = accMem.UserId;
            obj2.Account__c = acc.Id;
            obj2.Team_Role__c = accMem.TeamMemberRole;
            obj2.Status__c = 'Updated';
            obj2.CVIF_Id__c = acc.CVIF__c;
            obj2.Parent_Account__c = acc.ParentId;
            obj2.Unique__c =
              accMem.UserId +
              ' ' +
              acc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj2);
          }
        } else if (
          deletedAccMemberMap.containsKey(acc.ParentId) &&
          !deletedAccMemberMap.get(acc.ParentId).isEmpty()
        ) {
          for (
            AccountTeamMember accMem : deletedAccMemberMap.get(acc.ParentId)
          ) {
            Account_Team_Member_Info__c obj2 = new Account_Team_Member_Info__c();
            obj2.User__c = accMem.UserId;
            obj2.Account__c = acc.Id;
            obj2.Team_Role__c = accMem.TeamMemberRole;
            obj2.Status__c = 'Deleted';
            obj2.CVIF_Id__c = acc.CVIF__c;
            obj2.Parent_Account__c = acc.ParentId;
            obj2.Unique__c =
              accMem.UserId +
              ' ' +
              acc.Id +
              ' ' +
              DateTime.Now().day() +
              DateTime.Now().month();
            accTeamInfoInsertList.add(obj2);
          }
        }
      }
    }

    if (accTeamInfoInsertList != null && !accTeamInfoInsertList.isEmpty()) {
      Schema.SObjectField ftoken = Account_Team_Member_Info__c.Unique__c;
      Database.UpsertResult[] srList = Database.upsert(
        accTeamInfoInsertList,
        ftoken,
        false
      );
      System.debug('srList insertion: ' + srList);
    }
  }

  public void finish(Database.BatchableContext bc) {
    Mass_Account_Transfer__mdt objMeta = [
      SELECT DeveloperName, Label, Batch_Size__c
      FROM Mass_Account_Transfer__mdt
      WHERE DeveloperName = 'OpportunityOwnerUpdateBatch'
    ];
    Database.executeBatch(
      new OpportunityOwnerUpdateBatch(
        mapAllAccountIdOldOwnerId,
        this.objActionStartTime
      ),
      Integer.valueOf(objMeta.Batch_Size__c)
    );
  }
}
