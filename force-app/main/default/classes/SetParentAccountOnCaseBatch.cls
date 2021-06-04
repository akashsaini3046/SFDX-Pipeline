public class SetParentAccountOnCaseBatch implements Database.Batchable<SObject>, Database.Stateful {
  public static final string SetParentAccountOnCaseType = 'SetParentAccountOnCase';
  public List<Id> accountIds;
  public List<Cache__c> caches;
  public SetParentAccountOnCaseBatch() {
    accountIds = new List<Id>();
  }
  public Database.QueryLocator start(Database.BatchableContext ctx) {
    Id thisJobId = ctx.getJobId();
    List<AsyncApexJob> jobs = [
      SELECT Id, ApexClass.Name, Status
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'SetParentAccountOnCaseBatch'
        AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        AND Id != :thisJobId
    ];
    if (!jobs.isEmpty()) {
      for (AsyncApexJob job : jobs) {
        System.abortJob(job.Id);
      }
    }
    caches = [
      SELECT Id, Type__c, Data__c
      FROM Cache__c
      WHERE Type__c = :SetParentAccountOnCaseType
      LIMIT 1000
    ];
    for (Cache__c c : caches) {
      accountIds.add(c.Data__c);
    }
    return Database.getQueryLocator(
      'Select Id, AccountId, Account.ParentId, Parent_Account__c From Case Where AccountId IN :accountIds'
    );
  }
  public void execute(Database.BatchableContext ctx, List<Sobject> records) {
    List<Case> cases = (List<Case>) records;
    for (Case cs : cases) {
      if (cs.Account.ParentId != null)
        cs.Parent_Account__c = cs.Account.ParentId;
      else
        cs.Parent_Account__c = null;
    }
    List<Database.SaveResult> results = Database.Update(cases, false);
  }
  public void finish(Database.BatchableContext ctx) {
    if (!caches.isEmpty()) {
      delete caches;
    }
    List<Cache__c> newCaches = [
      SELECT Id, Type__c, Data__c
      FROM Cache__c
      WHERE Type__c = :SetParentAccountOnCaseType
      LIMIT 1
    ];
    if (!newCaches.isEmpty()) {
      SetParentAccountOnCaseBatch.start();
    }
  }
  public static void start() {
    //stop();
    SetParentAccountOnCaseBatch bc = new SetParentAccountOnCaseBatch();
    Database.executeBatch(bc);
  }
  public static void stop() {
    List<AsyncApexJob> jobs = [
      SELECT Id, ApexClass.Name, Status
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'SetParentAccountOnCaseBatch'
        AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
    ];
    if (!jobs.isEmpty()) {
      for (AsyncApexJob job : jobs) {
        System.abortJob(job.Id);
      }
    }
  }
}
