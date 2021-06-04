public class ContentDocumentLinkTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterDelete = true;
  private static Boolean Flag = true;
  private static Boolean recflag;

  List<ContentDocumentLink> newContentDocumentList;
  public ContentDocumentLinkTriggerHandler() {
    this.newContentDocumentList = (List<ContentDocumentLink>) Trigger.new;
  }
  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      //recursionVarAfterInsert = false;
      if (!System.isFuture()) {
        System.debug(
          'EmailMEssageTriggerHandler.msgListMap -> ' +
          EmailMEssageTriggerHandler.msgListMap
        );
        List<ContentDocumentLink> caseLinks = new List<ContentDocumentLink>();
        String parentName;
        for (ContentDocumentLink l : newContentDocumentList) {
          if (
            EmailMessageTriggerHandler.msgListMap != null &&
            EmailMessageTriggerHandler.msgListMap.containsKey(
              l.linkedEntityId
            ) &&
            EmailMessageTriggerHandler.msgListMap.get(l.linkedEntityId)
              .ParentId != null &&
            EmailMessageTriggerHandler.msgListMap.get(l.linkedEntityId)
              .ParentId.getSobjectType()
              .getDescribe()
              .getName() == 'Case'
          ) {
            caseLinks.add(l);
          }
        }
        System.debug('caseLinks -> ' + caseLinks);
        // If content documentlink were attached to email, we use an invocable method on EmailMessage process builder to excute our flows.
        // Therefore, nothing being done on caselinks being empty
        if (!caseLinks.isEmpty()) {
          //handleAttachments(JSON.serialize(caseLinks));
        } else {
          shareDocumentWithRelatedUsers(
            JSON.serialize(newContentDocumentList),
            ''
          );
        }
      }
    }
    Set<string> str = new Set<string>();
  }
  public class CaseAttachment {
    public Id caseId;
    public List<ContentDocumentLink> docLinks;
    public Id attId;
  }

  @future
  public static void handleAttachments(string docLinksJson) {
    List<ContentDocumentLink> docLinks = (List<ContentDocumentLink>) JSON.deserialize(
      docLinksJson,
      List<ContentDocumentLink>.class
    );
    //handle1kbAttachments(docLinks);
    shareDocs(docLinksJson, '');
  }

  @future
  public static void handle1kbAttachments(string docLinksJson) {
    List<ContentDocumentLink> docLinks = (List<ContentDocumentLink>) JSON.deserialize(
      docLinksJson,
      List<ContentDocumentLink>.class
    );
    handle1kbAttachments(docLinks);
  }

  @InvocableMethod(
    label='Email Message'
    description='Email message ids'
    category='EmailMessage'
  )
  public static void handleEmailAttachmentsInvocable(List<Id> emailMessageIds) {
    try {
      List<ContentDocumentLink> docLinks = [
        SELECT Id, LinkedEntityId, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :emailMessageIds
      ];
      System.debug('docLinks -> ' + docLinks.size() + ' ' + docLinks);

      handle1kbAttachments(docLinks);
      shareDocs(JSON.serialize(docLinks), '');
    } catch (Exception ex) {
      System.debug(
        'handle1kbAttachments exception message-> ' + ex.getMessage()
      );
      System.debug(
        'handle1kbAttachments exception stacktrace-> ' +
        ex.getStackTraceString()
      );
    }
  }

  public static void handle1kbAttachments(List<ContentDocumentLink> docLinks) {
    try {
      System.debug('docLinks -> ' + docLinks.size() + ' ' + docLinks);
      Set<Id> emailMsgIds = new Set<Id>();
      Set<Id> docIds = new Set<Id>();
      for (ContentDocumentLink l : docLinks) {
        if (
          l.LinkedEntityId.getSobjectType().getDescribe().getName() ==
          'EmailMessage'
        ) {
          emailMsgIds.add(l.LinkedEntityId);
          docIds.add(l.ContentDocumentId);
        }
      }
      if (!emailMsgIds.isEmpty()) {
        Set<String> docTypesToFilter = new Set<String>();
        if (String.isNotBlank(System.Label.Clear_Attachment_Type)) {
          string docTypesStr = System.Label.Clear_Attachment_Type;
          List<string> docTypes = docTypesStr.replaceAll(' ', '').split(',');
          docTypesToFilter.addAll(docTypes);
        }
        Map<Id, ContentDocument> docMap = new Map<Id, ContentDocument>(
          [
            SELECT Id, ContentSize
            FROM ContentDocument
            WHERE Id IN :docIds AND FileType = :docTypesToFilter
          ]
        );

        System.debug(
          'emailMsgIds -> ' +
          emailMsgIds.size() +
          ' ' +
          emailMsgIds
        );
        Map<Id, EmailMessage> emsgMap = new Map<Id, EmailMessage>(
          [SELECT Id, ParentId FROM EmailMessage WHERE Id IN :emailMsgIds]
        );
        System.debug('emsgMap -> ' + emsgMap);
        Set<Id> caseIds = new Set<Id>();
        for (Id emsgId : emsgMap.keyset()) {
          if (
            emsgMap.get(emsgId).ParentId != null &&
            String.valueOf(emsgMap.get(emsgId).ParentId).startsWith('500')
          ) {
            caseIds.add(emsgMap.get(emsgId).ParentId);
          }
        }
        System.debug('caseIds -> ' + caseIds);
        if (!caseIds.isEmpty()) {
          Map<Id, Case_Attachment__c> csaMap = new Map<Id, Case_Attachment__c>();
          List<Case_Attachment__c> caseAtts = [
            SELECT Id, Case__c
            FROM Case_Attachment__c
            WHERE Case__c IN :caseIds
          ];
          System.debug('caseAtts -> ' + caseAtts);
          for (Case_Attachment__c csa : caseAtts) {
            csaMap.put(csa.Case__c, csa);
          }

          Map<Id, Case_Attachment__c> attMap = new Map<Id, Case_Attachment__c>();
          Map<Id, Id> emsgCaseMap = new Map<Id, Id>();
          for (Id emsgId : emsgMap.keyset()) {
            if (emsgMap.get(emsgId).ParentId != null) {
              String recId = String.valueOf(emsgMap.get(emsgId).ParentId);
              if (recId.startsWith('500')) {
                Case_Attachment__c att = new Case_Attachment__c();
                if (csaMap.containsKey(recId))
                  att.Id = csaMap.get(recId).Id;
                att.Case__c = emsgMap.get(emsgId).ParentId;
                attMap.put(emsgMap.get(emsgId).ParentId, att);
              }
            }
          }

          if (attMap.keySet().size() > 0)
            upsert attMap.values();

          System.debug('attMap -> ' + attMap.keyset().size() + ' ' + attMap);

          List<ContentDocumentLink> newDocLinks = new List<ContentDocumentLink>();
          List<ContentDocumentLink> delDocLinks = new List<ContentDocumentLink>();
          Integer attSizeLimit = String.isNotBlank(
              System.Label.Case_Attachment_Size_Limit
            ) && System.Label.Case_Attachment_Size_Limit.isNumeric()
            ? Integer.valueOf(System.Label.Case_Attachment_Size_Limit)
            : 1024;
          for (ContentDocumentLink l : docLinks) {
            if (
              emsgMap.containsKey(l.LinkedEntityId) &&
              docMap.containsKey(l.ContentDocumentId) &&
              docMap.get(l.ContentDocumentId).ContentSize != null &&
              docMap.get(l.ContentDocumentId).ContentSize <= attSizeLimit
            ) {
              newDocLinks.add(
                new ContentDocumentLink(
                  ContentDocumentId = l.ContentDocumentId,
                  LinkedEntityId = attMap.get(
                      emsgMap.get(l.LinkedEntityId).ParentId
                    )
                    .Id,
                  Visibility = 'AllUsers',
                  ShareType = 'I'
                )
              );
              delDocLinks.add(new ContentDocumentLink(Id = l.Id));
            }
          }
          System.debug(
            'newDocLinks -> ' +
            newDocLinks.size() +
            ' ' +
            newDocLinks
          );
          System.debug(
            'delDocLinks -> ' +
            delDocLinks.size() +
            ' ' +
            delDocLinks
          );
          insert newDocLinks;
          delete delDocLinks;
        }
      }
    } catch (Exception ex) {
      System.debug(
        'handle1kbAttachments exception message-> ' + ex.getMessage()
      );
      System.debug(
        'handle1kbAttachments exception stacktrace-> ' +
        ex.getStackTraceString()
      );
    }
  }

  @future
  public static void shareDocumentWithRelatedUsers(
    string content,
    string parentcaseIds
  ) {
    shareDocs(content, parentcaseIds);
  }

  public static void shareDocs(string contentStr, string parentcaseIds) {
    system.debug(contentStr);
    system.debug('shareDoumentWithRelatedUsers');
    //system.debug(parentcaseIds);
    List<ContentDocumentLink> content = (List<ContentDocumentLink>) System.JSON.deserialize(
      contentStr,
      List<ContentDocumentLink>.class
    );
    system.debug(content);
    map<string, string> parentCaseLi = new Map<string, string>();
    List<EmailMessage> emailLi = new List<EmailMessage>();
    list<contentMap> li = new List<contentMap>();
    if (parentcaseIds != '' && parentcaseIds != null) {
      parentCaseLi = (map<string, string>) System.JSON.deserialize(
        parentcaseIds,
        map<string, string>.class
      );
      emailLi = [
        SELECT
          Id,
          ParentId,
          Status,
          Subject,
          (
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLinks
          )
        FROM EmailMessage
        WHERE ParentId IN :parentCaseLi.keyset()
      ];
      system.debug(emailLi);
      for (EmailMessage e : emailLi) {
        content.addAll(e.ContentDocumentLinks);
        for (ContentDocumentLink c : e.ContentDocumentLinks) {
          li.add(
            new contentMap(
              c.ContentDocumentId,
              parentCaseLi.get(e.ParentId),
              '',
              e.Id
            )
          );
        }
      }
    }
    system.debug('Content Map');
    system.debug(li);
    //SELECT CaseNumber,Id,(Select Id,Subject from EmailMessages) FROM Case WHERE Id
    list<string> sObjectIds = new List<string>();
    map<string, list<string>> entityContentMap = new Map<string, list<string>>();
    List<string> emailIds = new List<string>();

    for (ContentDocumentLink c : content) {
      if (
        c.LinkedEntityId != null &&
        string.valueOf(c.LinkedEntityId).substring(0, 3) == '02s'
      ) {
        emailIds.add(c.LinkedEntityId);
      }
    }
    map<Id, EmailMessage> emailMap = new Map<Id, EmailMessage>(
      [
        SELECT
          Id,
          ParentId,
          Status,
          Subject,
          (
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLinks
          )
        FROM EmailMessage
        WHERE Id IN :emailIds
      ]
    );
    for (ContentDocumentLink c : content) {
      sObjectIds.add(c.ContentDocumentId);
      if (
        c.LinkedEntityId != null &&
        (string.valueOf(c.LinkedEntityId).substring(0, 3) == '500')
      ) {
        if (entityContentMap.get(c.LinkedEntityId) != null) {
          list<string> str = new List<string>();
          str = entityContentMap.get(c.LinkedEntityId);
          str.add(c.ContentDocumentId);
          entityContentMap.put(c.LinkedEntityId, str);
        } else {
          list<string> str = new List<string>();
          str.add(c.ContentDocumentId);
          entityContentMap.put(c.LinkedEntityId, str);
        }
      }
      if (parentcaseIds == '') {
        if (
          c.LinkedEntityId != null &&
          string.valueOf(c.LinkedEntityId).substring(0, 3) == '02s'
        ) {
          EmailMessage emails = emailMap.get(c.LinkedEntityId);
          system.debug(emails);
          if (entityContentMap.get(emails.ParentId) != null) {
            list<string> str = new List<string>();
            str = entityContentMap.get(emails.ParentId);
            str.add(c.ContentDocumentId);
            entityContentMap.put(emails.ParentId, str);
          } else {
            list<string> str = new List<string>();
            str.add(c.ContentDocumentId);
            entityContentMap.put(emails.ParentId, str);
          }
        }
      }
    }
    map<string, list<contentMap>> cdlmap = new Map<string, list<contentMap>>();
    list<Case> mainCases = [
      SELECT
        Id,
        ParentId,
        Parent.OwnerId,
        CaseNumber,
        OwnerId,
        (SELECT Id, CaseNumber, OwnerId FROM Cases)
      FROM Case
      WHERE Id IN :entityContentMap.keySet()
    ];
    system.debug('maincases');
    system.debug(mainCases);
    //if(parentcaseIds==''){

    list<string> parentIds = new List<string>();

    for (case c : mainCases) {
      if (c.parentId != null) {
        parentIds.add(c.parentId);
        for (string s : entityContentMap.get(c.Id)) {
          //entityContentMap.put(c.parentId,s);
          if (cdlmap.get(s) != null) {
            list<contentMap> str = new List<contentMap>();
            str = cdlmap.get(s);
            str.add(new contentMap(s, c.parentId, c.Parent.OwnerId, ''));
            cdlmap.put(s, str);
          } else {
            list<contentMap> str = new List<contentMap>();
            str.add(new contentMap(s, c.parentId, c.Parent.OwnerId, ''));
            cdlmap.put(s, str);
          }
        }
      }
      if (!c.cases.isEmpty() && c.cases != null) {
        for (case sub : c.cases) {
          for (string s : entityContentMap.get(c.Id)) {
            if (cdlmap.get(s) != null) {
              list<contentMap> str = new List<contentMap>();
              str = cdlmap.get(s);
              str.add(new contentMap(s, sub.Id, sub.OwnerId, ''));
              cdlmap.put(s, str);
            } else {
              list<contentMap> str = new List<contentMap>();
              str.add(new contentMap(s, sub.Id, sub.OwnerId, ''));
              cdlmap.put(s, str);
            }
          }
        }
      }
    }
    //}
    list<contentVersion> versionList = [
      SELECT id, ContentDocumentId, Title
      FROM contentVersion
      WHERE ContentDocumentId IN :sObjectIds
    ];
    system.debug(versionList);
    Map<string, contentVersion> versionMap = new Map<string, contentVersion>();
    for (contentVersion cd : versionList) {
      versionMap.put(cd.ContentDocumentId, cd);
    }
    if (cdlmap != null && !cdlmap.isEmpty()) {
      list<Related_Case_Attachment__c> ExistingList = [
        SELECT id, Content_Document_Id__c, Case__c
        FROM Related_Case_Attachment__c
        WHERE Content_Document_Id__c IN :sObjectIds
      ];
      system.debug('ExistingList');
      system.debug(ExistingList);
      if (ExistingList != null && !ExistingList.isEmpty()) {
        for (Related_Case_Attachment__c r : ExistingList) {
          list<contentMap> cm = cdlmap.get(r.Content_Document_Id__c);
          for (contentMap c : cm) {
            if (
              c.contentId == r.Content_Document_Id__c &&
              c.caseId != r.Case__c
            ) {
              li.add(c);
            }
          }
        }
      } else {
        for (string s : cdlmap.keySet()) {
          li.addAll(cdlmap.get(s));
        }
      }
    }
    //system.debug(li);
    list<Related_Case_Attachment__c> contentli = new List<Related_Case_Attachment__c>();
    for (contentMap c : li) {
      string versionId = versionMap.get(c.contentId).id;
      contentli.add(
        new Related_Case_Attachment__c(
          Content_Document_Id__c = c.contentId,
          Case__c = c.caseId,
          Content_Version_Id__c = versionId,
          Content_Document_Name__c = versionMap.get(c.contentId).title
        )
      );
    }
    system.debug('Content Li');
    system.debug(contentli);
    insert contentli;

    /*list<Case> parentCases = [Select Id,ParentId,Parent.OwnerId,CaseNumber,OwnerId,(Select Id,CaseNumber,OwnerId from Cases) from Case where Id in : parentIds];
for(case c : parentCases){            
if(!c.cases.isEmpty() && c.cases!=null){
for(case sub : c.cases){
cdlSet.add(new contentMap(entityContentMap.get(c.Id),sub.Id,sub.OwnerId));
}
}
}*/
  }

  private class contentMap {
    string contentId;
    string caseId;
    string caseownerId;
    string emailId;
    contentMap(string cd, string c, string o, string e) {
      this.contentId = cd;
      this.caseId = c;
      this.caseownerId = o;
      this.emailId = e;
    }
  }
}
