public class Clean1kbAttachmentBatch implements Database.Batchable<sobject> {
  public DateTime dateLimit;
  public Database.QueryLocator start(Database.BatchableContext ctx) {
    Integer daysLimit = 7;
    if (String.isNotBlank(System.Label.Attachment_Clearing_Days_Limit)) {
      daysLimit = Integer.valueOf(System.Label.Attachment_Clearing_Days_Limit);
      daysLimit = Test.isRunningTest() ? -1 : daysLimit;
    }
    this.dateLimit = dateLimit != null
      ? dateLimit
      : Datetime.now().addDays(daysLimit * -1);
    return Database.getQueryLocator(
      'Select Id, Case__c From Case_Attachment__c Where CreatedDate < :dateLimit'
    );
  }

  public void execute(Database.BatchableContext ctx, List<Sobject> objList) {
    try {
      List<Case_Attachment__c> atts = (List<Case_Attachment__c>) objList;

      Set<Id> caseIds = new Set<Id>();
      Set<Id> attIds = new Set<Id>();
      for (Case_Attachment__c a : atts) {
        caseIds.add(a.Case__c);
        attIds.add(a.Id);
      }
      List<ContentDocumentLink> links = [
        SELECT
          Id,
          ContentDocument.Title,
          LinkedEntityId,
          ContentDocument.ContentModifiedDate
        FROM ContentDocumentLink
        WHERE
          LinkedEntityId IN :attIds
          AND ContentDocument.ContentModifiedDate < :dateLimit
      ];
      delete links;

      List<ContentDocumentLink> tlinks = [
        SELECT Id, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :attIds
      ];
      for (ContentDocumentLink l : tlinks) {
        if (attIds.contains(l.LinkedEntityId)) {
          attIds.remove(l.LinkedEntityId);
        }
      }
      List<Case_Attachment__c> delatts = [
        SELECT Id
        FROM Case_Attachment__c
        WHERE Id IN :attIds
      ];
      delete delatts;
    } catch (Exception ex) {
      System.debug(
        'DeleteSmallAttachmentBatch exception message -> ' + ex.getMessage()
      );
      System.debug(
        'DeleteSmallAttachmentBatch exception stacktrace -> ' +
        ex.getStackTraceString()
      );
    }
  }

  public void finish(Database.BatchableContext ctx) {
  }
}
