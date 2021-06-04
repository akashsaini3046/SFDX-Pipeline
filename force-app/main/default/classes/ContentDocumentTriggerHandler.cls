public class ContentDocumentTriggerHandler extends TriggerHandler {
  public static Map<Id, ContentDocument> contentDocMap;
  List<ContentDocument> oldContentDocumentList;
  public ContentDocumentTriggerHandler() {
    this.oldContentDocumentList = (List<ContentDocument>) Trigger.old;
  }
  public override void beforeDelete() {
    System.debug(
      'ContentDocumentTriggerHandler: Limits.getQueries()/Limits.getLimitQueries -> ' +
      Limits.getQueries() +
      '/' +
      Limits.getLimitQueries()
    );
    deleterelatedAttachments(oldContentDocumentList);
    System.debug(
      'ContentDocumentTriggerHandler: Limits.getQueries()/Limits.getLimitQueries -> ' +
      Limits.getQueries() +
      '/' +
      Limits.getLimitQueries()
    );
  }
  private static void deleterelatedAttachments(List<ContentDocument> content) {
    list<string> sObjectIds = new List<string>();
    for (ContentDocument c : content) {
      sObjectIds.add(c.id);
    }
    list<Related_Case_Attachment__c> li = [
      SELECT Id, Content_Document_Id__c
      FROM Related_Case_Attachment__c
      WHERE Content_Document_Id__c IN :sObjectIds
    ];
    delete li;
  }
}
