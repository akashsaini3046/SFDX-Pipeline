/*
 * Name: NeglectedAccountBatch
 * Purpose: For reporting neglected accounts.
 * Author: Nagarro
 * Created Date: 30/04/2020
 *
 *  Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */

global class NeglectedAccountBatch implements Database.Batchable<sObject> {
  Integer days = Integer.valueOf(
    System.Label.Number_of_Days_Neglected_Account_Report
  );
  String query =
    'Select Id,Name,Owner.Name,ParentId,CreatedDate,CreatedById,LastActivityDate,LastModifiedById,Primary_Account__c,LastModifiedDate from Account where (NOT Owner.Name Like \'%SYSTEM%\') and (NOT Owner.Name Like \'%ADMIN%\') and LastModifiedDate < LAST_N_DAYS:' +
    days;
  global Database.QueryLocator start(database.BatchableContext bc) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext bc, List<Account> accountList) {
    Integer days = Integer.valueOf(
      System.Label.Number_of_Days_Neglected_Account_Report
    );
    Set<Id> neglectedAccountIds = new Set<Id>();
    Set<Id> parentAccountIds = new Set<Id>();
    List<Account> childAccountList = new List<Account>();
    Set<Id> activeParentAccountIds = new Set<Id>();
    Set<Id> activeAccounts = new Set<Id>();
    Set<Id> recurringTaskIds = new Set<Id>();
    Set<Id> recurringEventIds = new Set<Id>();
    Map<Id, Account> accIdToAccountMap = new Map<Id, Account>();
    Map<Id, Account> accIdtoParentAccountMap = new Map<Id, Account>();

    if (accountList.size() > 0) {
      for (Account acc : accountList) {
        neglectedAccountIds.add(acc.Id);
        if (acc.Primary_Account__c) {
          parentAccountIds.add(acc.Id);
        }
        accIdToAccountMap.put(acc.Id, acc);
      }
    }

    for (Account acc : accountList) {
      if (acc.ParentId == null) {
        accIdtoParentAccountMap.put(acc.Id, acc);
      } else {
        accIdtoParentAccountMap.put(
          acc.Id,
          accIdToAccountMap.get(acc.ParentId)
        );
      }
    }

    childAccountList = (List<Account>) Database.query(
      'Select Id,ParentId,LastModifiedDate from Account where ParentId IN :parentAccountIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );

    if (childAccountList.size() > 0) {
      for (Account acc : childAccountList) {
        activeParentAccountIds.add(acc.ParentId);
        if (accIdtoParentAccountMap.containsKey(acc.ParentId)) {
          System.debug('Inside Child Account if condition-------------------');
          accIdtoParentAccountMap.remove(acc.ParentId);
        }
      }
    }

    neglectedAccountIds.removeAll(activeParentAccountIds);

    List<Task> taskList = (List<Task>) Database.query(
      'Select Id,AccountId,IsRecurrence,RecurrenceActivityId,Subject from task where AccountId IN :neglectedAccountIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );

    if (taskList.size() > 0) {
      for (Task tasks : taskList) {
        if (tasks.IsRecurrence == false) {
          activeAccounts.add(tasks.AccountId);
          if (accIdtoParentAccountMap.containsKey(tasks.AccountId)) {
            accIdtoParentAccountMap.remove(tasks.AccountId);
          }
        } else {
          recurringTaskIds.add(tasks.RecurrenceActivityId);
        }
      }
    }

    /*Recurring Task**/
    taskList = (List<Task>) Database.query(
      'Select Id,AccountId,IsRecurrence,RecurrenceActivityId,Subject from task where Id IN :recurringTaskIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );
    if (taskList.size() > 0) {
      for (Task tasks : taskList) {
        activeAccounts.add(tasks.AccountId);
        if (accIdtoParentAccountMap.containsKey(tasks.AccountId)) {
          accIdtoParentAccountMap.remove(tasks.AccountId);
        }
      }
    }

    /********/

    neglectedAccountIds.removeAll(activeAccounts);

    List<Event> eventList = (List<Event>) Database.query(
      'Select Id, AccountId,IsRecurrence,RecurrenceActivityId from Event where AccountId IN :neglectedAccountIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );

    activeAccounts.clear();
    if (eventList.size() > 0) {
      for (Event events : eventList) {
        if (events.IsRecurrence == false) {
          activeAccounts.add(events.AccountId);
          if (accIdtoParentAccountMap.containsKey(events.AccountId)) {
            accIdtoParentAccountMap.remove(events.AccountId);
          }
        } else {
          recurringEventIds.add(events.RecurrenceActivityId);
        }
      }
    }

    /**Recurring Event**/
    eventList = (List<Event>) Database.query(
      'Select Id, AccountId,IsRecurrence,RecurrenceActivityId from Event where Id IN :recurringEventIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );
    if (eventList.size() > 0) {
      for (Event events : eventList) {
        activeAccounts.add(events.AccountId);
        if (accIdtoParentAccountMap.containsKey(events.AccountId)) {
          accIdtoParentAccountMap.remove(events.AccountId);
        }
      }
    }

    /********/

    neglectedAccountIds.removeAll(activeAccounts);

    List<Opportunity> oppList = (List<Opportunity>) Database.query(
      'Select Id,AccountId,LastModifiedDate From Opportunity where AccountId IN :neglectedAccountIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );

    activeAccounts.clear();
    if (oppList.size() > 0) {
      for (Opportunity opp : oppList) {
        activeAccounts.add(opp.AccountId);
        if (accIdtoParentAccountMap.containsKey(opp.AccountId)) {
          accIdtoParentAccountMap.remove(opp.AccountId);
        }
      }
    }

    neglectedAccountIds.removeAll(activeAccounts);

    activeAccounts.clear();
    List<EmailMessage> emailList = (List<EmailMessage>) Database.query(
      'Select Id,RelatedToId,LastModifiedDate From EmailMessage where RelatedToId IN :neglectedAccountIds and LastModifiedDate >= LAST_N_DAYS:' +
      days
    );

    for (EmailMessage email : emailList) {
      activeAccounts.add(email.RelatedToId);
      if (accIdtoParentAccountMap.containsKey(email.RelatedToId)) {
        accIdtoParentAccountMap.remove(email.RelatedToId);
      }
    }
    neglectedAccountIds.removeAll(activeAccounts);

    List<Neglected_Account_Data__c> neglectedAccList = new List<Neglected_Account_Data__c>();

    Set<Account> accSet = new Set<Account>();

    accSet.addAll(accIdtoParentAccountMap.values());

    for (Account acc : accSet) {
      System.debug(
        'neglectedAccountIds------------------' + neglectedAccountIds
      );
      System.debug('neglectedAccountIds------------------');
      System.debug('neglectedAccountIds------------------' + acc);

      if (acc != null && neglectedAccountIds.contains(acc.Id)) {
        Neglected_Account_Data__c negAcc = new Neglected_Account_Data__c();
        negAcc.AccountId__c = acc.Id;
        negAcc.Account__c = acc.Id;
        negAcc.Owner_Name__c = acc.Owner.Name;
        negAcc.Account_Created_Date__c = acc.CreatedDate;
        negAcc.Account_Modified_Date__c = acc.LastModifiedDate;
        negAcc.Last_Activity_Date__c = acc.LastActivityDate;
        negAcc.Name = acc.Name;
        negAcc.Parent_Account__c = acc.ParentId;
        neglectedAccList.add(negAcc);
      }
    }

    if (neglectedAccList.size() > 0) {
      Database.UpsertResult[] srList = Database.upsert(
        neglectedAccList,
        Neglected_Account_Data__c.Fields.AccountId__c,
        false
      );

      for (Database.UpsertResult sr : srList) {
        for (Database.Error err : sr.getErrors()) {
          System.debug(
            'error has occurred.' +
            err.getStatusCode() +
            ': ' +
            err.getMessage()
          );
          System.debug('fields that affected this error: ' + err.getFields());
        }
      }
    }
  }

  global void finish(Database.BatchableContext bc) {
  }
}
