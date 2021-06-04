public class NoteController {
  public List<WrapperClass> wrapList { get; set; }

  public NoteController() {
    Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id FROM Account]);
    System.debug('accMap = ' + accMap.size());
    Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id FROM Contact]);
    System.debug('conMap = ' + conMap.size());
    Map<Id, Address__c> addMap = new Map<Id, Address__c>(
      [SELECT Id FROM Address__c]
    );
    System.debug('addMap = ' + addMap.size());
    Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
      [SELECT Id FROM Opportunity]
    );
    System.debug('oppMap = ' + oppMap.size());
    Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id FROM Lead]);
    System.debug('leadMap = ' + leadMap.size());
    Set<Id> idSet = new Set<Id>();
    if (accMap != null) {
      idSet.addAll(accMap.keySet());
      System.debug('idSet = ' + idSet.size());
    }
    if (conMap != null) {
      idSet.addAll(conMap.keySet());
      System.debug('idSet = ' + idSet.size());
    }
    if (addMap != null) {
      idSet.addAll(addMap.keySet());
      System.debug('idSet = ' + idSet.size());
    }
    if (oppMap != null) {
      idSet.addAll(oppMap.keySet());
      System.debug('idSet = ' + idSet.size());
    }
    if (leadMap != null) {
      idSet.addAll(leadMap.keySet());
      System.debug('idSet = ' + idSet.size());
    }
    List<ContentDocumentLink> CDLList = [
      SELECT
        Id,
        ContentDocumentID,
        LinkedEntityid,
        LinkedEntity.Name,
        ShareType,
        Visibility
      FROM ContentDocumentLink
      WHERE LinkedEntityid IN :idSet
    ];
    System.debug('CDLList = ' + CDLList.size());
    Set<Id> CDIds = new Set<Id>();
    Map<Id, ContentDocumentLink> linkedObjectMap = new Map<Id, ContentDocumentLink>();
    for (ContentDocumentLink link : CDLList) {
      CDIds.add(link.ContentDocumentID);
      linkedObjectMap.put(link.ContentDocumentID, link);
    }

    System.debug('CDIds = ' + CDIds.size());

    List<ContentNote> contentNoteList = [
      SELECT Content, Title, CreatedDate, CreatedBy.Name, OwnerId
      FROM ContentNote
      WHERE Id IN :CDIds
      ORDER BY CreatedDate DESC
    ];
    System.debug('contentNoteList = ' + contentNoteList.size());
    wrapList = new List<WrapperClass>();
    for (ContentNote noteRecord : contentNoteList) {
      wrapList.add(
        new WrapperClass(
          noteRecord,
          linkedObjectMap.get(noteRecord.Id),
          noteRecord.Content.toString()
        )
      );
    }
    System.debug('wrapList = ' + wrapList.size());
  }

  public class WrapperClass {
    public ContentNote noteRecord { get; set; }
    public String contentData { get; set; }
    public ContentDocumentLink CDLRecord { get; set; }
    public WrapperClass(
      ContentNote note,
      ContentDocumentLink CDL,
      String contentData
    ) {
      this.noteRecord = note;
      this.CDLRecord = CDL;
      this.contentData = contentData;
    }
  }
}
