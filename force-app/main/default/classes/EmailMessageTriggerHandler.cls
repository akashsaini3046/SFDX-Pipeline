public with sharing class EmailMessageTriggerHandler extends TriggerHandler {
  List<EmailMessage> newEmailMessageList;
  public static List<EmailMessage> msgList;
  public static Map<Id, EmailMessage> msgListMap;

  public EmailMessageTriggerHandler() {
    this.newEmailMessageList = (List<EmailMessage>) Trigger.new;
    msgListMap = (Map<Id, EmailMessage>) Trigger.newMap;
  }
  public override void afterInsert() {
    //updateOpportunityStage(newEmailMessageList);
    EmailMessageTriggerHandler.UpdateCaseStatus(newEmailMessageList);
    deleteNeglectedEmailAccounts(newEmailMessageList);
    applyEmailMatrix(newEmailMessageList);
    CreateNewCaseforEmailOnClosedCases(newEmailMessageList);
    UpdateAttachmentCountOnCases(newEmailMessageList);
    //getHTMLbodyFromEmailmessage(newEmailMessageList);
    //UpdateBookingQueue(newEmailMessageList);
  }

  public static void UpdateAttachmentCountOnCases(
    List<EmailMessage> newEmailMessageList
  ) {
    List<EmailMessage> newMessages = new List<EmailMessage>();
    for (EmailMessage e : newEmailMessageList) {
      if (
        e.Incoming &&
        e.ParentId != null &&
        e.Subject != null &&
        (e.HtmlBody != null ||
        e.TextBody != null) &&
        !e.Subject.contains('ref:_') &&
        e.ToAddress != null &&
        e.ParentId.getSobjectType().getDescribe().getName() == 'Case'
      ) {
        newMessages.add(e);
      }
    }
    if (newMessages.size() > 0) {
      getAttachmentCount(JSON.serialize(newMessages));
    }
  }

  @future
  public static void getAttachmentCount(string newMessageStr) {
    system.debug('inside attachment count method');
    List<EmailMessage> newMessages = (List<EmailMessage>) System.JSON.deserialize(
      newMessageStr,
      List<EmailMessage>.class
    );
    list<string> email_Ids = new List<string>();
    list<Case> updateToAddress = new List<case>();
    List<string> case_Ids = new List<string>();
    Map<Id, EmailMessage> emsgMap = new Map<Id, EmailMessage>();
    for (EmailMessage e : newMessages) {
      if (
        e.Incoming &&
        e.ParentId != null &&
        e.Subject != null &&
        !e.Subject.contains('ref:_') &&
        e.ToAddress != null &&
        e.ParentId.getSobjectType().getDescribe().getName() == 'Case'
      ) {
        email_Ids.add(e.id);
        case_Ids.add(e.ParentId);
        emsgMap.put(e.id, e);
      }
    }
    map<Id, case> checkDeletedCase = new Map<Id, case>(
      [SELECT Id, IsDeleted FROM case WHERE Id IN :case_Ids]
    );
    integer attachment_count = 0;
    if (!email_Ids.isEmpty()) {
      List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>(
        [
          SELECT Id, LinkedEntityId, ContentDocumentId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :email_Ids
        ]
      );
      system.debug('docLinks->' + docLinks);
      Set<Id> docIds = new Set<Id>();
      for (ContentDocumentLink l : docLinks) {
        docIds.add(l.ContentDocumentId);
      }
      system.debug('docIds->' + docIds);
      Set<String> docTypesToFilter = new Set<String>();
      if (String.isNotBlank(System.Label.Clear_Attachment_Type)) {
        string docTypesStr = System.Label.Clear_Attachment_Type;
        List<string> docTypes = docTypesStr.replaceAll(' ', '').split(',');
        docTypesToFilter.addAll(docTypes);
      }
      Map<Id, ContentDocument> docMap = new Map<Id, ContentDocument>(
        [
          SELECT Id, ContentSize, FileType
          FROM ContentDocument
          WHERE Id IN :docIds
        ]
      );
      system.debug('docMap->' + docMap);
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
          (!docTypesToFilter.Contains(
            docMap.get(l.ContentDocumentId).FileType
          ) ||
          (docMap.get(l.ContentDocumentId).ContentSize > attSizeLimit &&
          docTypesToFilter.Contains(docMap.get(l.ContentDocumentId).FileType)))
        ) {
          attachment_count = attachment_count + 1;
          system.debug('inside counting attachments');
        }
      }
    }
    /*try{
            attachment_count = [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId IN: email_Ids];
        }catch(exception e){
            system.debug(e);
        }*/

    for (EmailMessage e : newMessages) {
      if (
        e.Incoming &&
        e.ParentId != null &&
        e.Subject != null &&
        !e.Subject.contains('ref:_') &&
        e.ToAddress != null &&
        e.ParentId.getSobjectType().getDescribe().getName() == 'Case'
      ) {
        Case cs = checkDeletedCase.get(e.ParentId);
        if (attachment_count > 0 && !cs.IsDeleted) {
          updateToAddress.add(
            new case(
              id = e.ParentId,
              Attachments__c = 'Yes',
              Update_Count__c = 0
            )
          );
          system.debug('yes attachment present');
        } else {
          updateToAddress.add(
            new case(
              id = e.ParentId,
              Attachments__c = 'No',
              Update_Count__c = 0
            )
          );
          system.debug('no attachments');
        }
      }
    }
    try {
      if (!updateToAddress.isEmpty()) {
        update updateToAddress;
      }
    } catch (exception e) {
      system.debug(e);
    }
    system.debug('exiting attachment count method');
  }

  public static void checkForAutoResponse(List<EmailMessage> newMessages) {
    /*system.debug('checkForAutoResponse');
        list<string> subjectList = new list<string>();
        list<string> emailList = new list<string>();
        for(EmailMessage e: newMessages){
            emailList.add(e.FromAddress);
            subjectList.add(e.Subject);
        }
        List<EmailMessage> li = [Select Id,Subject,FromAddress,TextBody from EmailMessage where FromAddress in : emailList and Subject in :subjectList];
        map<string,EmailMessage> mp = new map<string,EmailMessage>();
        if(li!=null && !li.isEmpty()){
            for(EmailMessage e: li){
                mp.put(e.Subject,e);
            }
            for(EmailMessage e : newMessages){
                EmailMessage existingEmail = mp.get(e.Subject);
                if(e.FromAddress==existingEmail.FromAddress && e.TextBody==existingEmail.TextBody){
                    e.addError('This email already exists.');
                }
            }
        }
        
        system.debug('checkForAutoResponse');*/
  }

  private void applyEmailMatrix(List<EmailMessage> newMessages) {
    system.debug('applyEmailMatrix');
    list<EmailMatrix> matrix_li = new List<EmailMatrix>();
    list<string> parentCaseId = new List<string>();
    list<string> email_Ids = new List<string>();
    list<Case> updateToAddress = new List<case>();
    for (EmailMessage e : newMessages) {
      if (
        e.Incoming &&
        e.ParentId != null &&
        e.Subject != null &&
        e.ToAddress != null &&
        e.ParentId.getSobjectType().getDescribe().getName() == 'Case'
      ) {
        parentCaseId.add(e.ParentId);
        matrix_li.add(new EmailMatrix(e.ParentId, e.ToAddress, e.subject));
      }
      if (
        e.Incoming &&
        e.ParentId != null &&
        e.ToAddress != null &&
        e.ParentId.getSobjectType().getDescribe().getName() == 'Case'
      ) {
        updateToAddress.add(
          new case(Id = e.ParentId, To_Address__c = e.ToAddress)
        );
      }
    }
    system.debug('updateToAddress');
    try {
      system.debug(updateToAddress);
      update updateToAddress;
    } catch (exception e) {
      system.debug(e);
    }
    map<id, case> parentCases = new Map<id, case>(
      [
        SELECT Id, RecordTypeId, Case_Thread_Id__c, Subject, OwnerId
        FROM case
        WHERE Id IN :parentCaseId
      ]
    );
    List<case> toBeDeleted = new List<case>();

    for (EmailMatrix e : matrix_li) {
      case c = parentCases.get(id.valueOf(e.caseId));
      e.threadId = c.Case_Thread_Id__c;
      e.caseRecId = c.RecordTypeId;
      e.caseQueId = c.OwnerId;
      if (e.toEmails.contains(system.label.Crowley_Arrival_Notice_Email)) {
        e.hasArrivalNotices = true;
      }
      if (e.toEmails.contains(system.label.Crowley_BL_Revision_Email)) {
        e.hasBLRevision = true;
      }
      if (e.toEmails.contains(system.label.Crowley_Booking_Request_Email)) {
        e.hasBookingRequest = true;
      }
      if (e.toEmails.contains(system.label.Crowley_Customer_Inquiry_Email)) {
        e.hasCustomerInquiry = true;
      }
    }

    for (EmailMatrix e : matrix_li) {
      if (!e.Subject.contains(e.threadId)) {
        if (e.hasArrivalNotices) {
          if (
            !e.caseQueId.contains(
              system.label.Crowley_Arrival_Notice_Queue_Id
            ) && !e.caseQueId.startsWith('005')
          ) {
            toBeDeleted.add(new case(Id = e.caseId));
          }
        } else if (e.hasBLRevision && !e.hasArrivalNotices) {
          string blrevque = system.label.BL_revision_queue_Id_new.substring(
            0,
            15
          );
          if (
            !e.caseQueId.contains(blrevque) && !e.caseQueId.startsWith('005')
          ) {
            toBeDeleted.add(new case(Id = e.caseId));
          }
        } else if (
          e.hasBookingRequest &&
          !e.hasArrivalNotices &&
          !e.hasBLRevision
        ) {
          string bookingReqQue = system.label.Booking_Request_Queue_Id;
          string bookingSpQue1 = system.label.Booking_Specialty_Queue_1;
          string bookingSpQue2 = system.label.Booking_Speciality_Queue_2;
          string bookingSpQue3 = system.label.Booking_Specialty_Queue_3;
          string bookingInbox = system.label.Booking_Inbox_Queue;
          if (
            !e.caseQueId.contains(bookingReqQue) &&
            !e.caseQueId.contains(bookingSpQue1) &&
            !e.caseQueId.contains(bookingSpQue2) &&
            !e.caseQueId.contains(bookingSpQue3) &&
            !e.caseQueId.contains(bookingInbox) &&
            !e.caseQueId.startsWith('005')
          ) {
            toBeDeleted.add(new case(Id = e.caseId));
          }
        }
      }
    }
    system.debug('toBeDeleted');
    system.debug(toBeDeleted);
    if (toBeDeleted != null && !toBeDeleted.isEmpty()) {
      try {
        delete toBeDeleted;
      } catch (exception e) {
        system.debug(e);
      }
    }
    system.debug('applyEmailMatrix');
  }
  private class EmailMatrix {
    string caseId;
    string caseRecId;
    string caseQueId;
    string subject;
    string threadId;
    boolean hasArrivalNotices = false;
    boolean hasBLRevision = false;
    boolean hasBookingRequest = false;
    boolean hasCustomerInquiry = false;
    string toEmails = '';
    EmailMatrix(string c, string str, string s) {
      caseId = c;
      toEmails = str;
      subject = s;
    }
  }
  public static void CreateNewCaseforEmailOnClosedCases(
    List<EmailMessage> newMessages
  ) {
    system.debug('CreateNewCaseforEmailOnClosedCases');
    List<string> li = new List<string>();
    Set<String> emailAddresses = new Set<String>();
    map<string, emailMessage> emailMap = new Map<string, emailMessage>();
    Map<String, List<Contact>> EmailContactListMap = new Map<String, List<Contact>>();
    for (EmailMessage msg : newMessages) {
      system.debug(msg.ParentId);
      if (
        msg.ParentId != null &&
        msg.ParentId.getSobjectType().getDescribe().getName() == 'Case' &&
        msg.Incoming
      ) {
        li.add(msg.ParentId);
        emailMap.put(msg.ParentId, msg);
        emailAddresses.add(msg.FromAddress);
      }
    }

    List<Case> parentCases = [
      SELECT
        Id,
        Status,
        Origin,
        Subject,
        SuppliedEmail,
        ContactId,
        IsClosed,
        RecordTypeId,
        Account.Account_Tier__c
      FROM Case
      WHERE Id IN :li
    ];
    List<Contact> contacts = new List<Contact>();
    if (emailAddresses.size() > 0) {
      contacts = [
        SELECT Id, Email, AccountId
        FROM Contact
        WHERE Email IN :emailAddresses
      ];
      for (Contact con : contacts) {
        if (
          EmailContactListMap.isEmpty() ||
          !EmailContactListMap.containsKey(con.Email)
        ) {
          EmailContactListMap.put(con.Email, new List<Contact>{ con });
        } else if (EmailContactListMap.containsKey(con.Email)) {
          List<Contact> listContacts = new List<Contact>();
          listContacts = EmailContactListMap.get(con.Email);
          listContacts.add(con);
          EmailContactListMap.put(con.Email, listContacts);
        }
      }
    }
    List<Case> newCase = new List<Case>();

    for (Case c : parentCases) {
      EmailMessage msg = emailMap.get(c.Id);
      Id Contact_Id = null;
      Id Account_Id = null;
      if (
        EmailContactListMap.get(msg.FromAddress) != null ||
        EmailContactListMap.containsKey(msg.FromAddress)
      ) {
        Contact_Id = EmailContactListMap.get(msg.FromAddress)[0].Id;
        Account_Id = EmailContactListMap.get(msg.FromAddress)[0].AccountId;
      }
      if (
        c.IsClosed &&
        string.valueOf(c.RecordTypeId)
          .contains(System.Label.Customer_Inquiry_Case_Record_Type_Id)
      ) {
        string strLowerCase = c.Subject.toLowerCase();
        system.debug(strLowerCase.contains('trouble lane'));
        string str = '';
        if (msg.TextBody.length() > 32000) {
          str = msg.TextBody.substring(0, 31999);
        } else {
          str = msg.TextBody;
        }
        DateTime Due_Date = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          2 * 3600000
        );
        DateTime Reminder_Date_after_1_5_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          90 * 60000
        );
        DateTime Reminder_Date_after_2_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          2 * 3600000
        );
        DateTime Reminder_Date_After_6_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          6 * 3600000
        );
        if (strLowerCase.contains('trouble lane')) {
          newCase.add(
            new Case(
              Subject = c.Subject,
              Origin = c.Origin,
              Description = str,
              Original_Case_2__c = c.Id,
              ContactId = Contact_Id,
              AccountId = Account_Id,
              SuppliedEmail = msg.FromAddress,
              RecordTypeId = System.Label.Customer_Inquiry_Record_Type,
              OwnerId = System.Label.Trouble_Lane_Queue_Id,
              Case_Type__c = 'Customer Inquiry',
              Priority = 'Urgent',
              Due_Date__c = Due_Date,
              Reminder_Date_after_1_5_hrs__c = Reminder_Date_after_1_5_hrs,
              Reminder_Date_after_2_hrs__c = Reminder_Date_after_2_hrs,
              Reminder_Date_After_6_hrs__c = Reminder_Date_After_6_hrs
            )
          );
        } else if (
          msg.ToAddress.contains(System.Label.Crowley_Arrival_Notice_Email)
        ) {
          system.debug('ToAddress: ' + msg.ToAddress);
          newCase.add(
            new Case(
              Subject = c.Subject,
              Origin = c.Origin,
              Description = str,
              Original_Case_2__c = c.Id,
              ContactId = Contact_Id,
              AccountId = Account_Id,
              SuppliedEmail = msg.FromAddress,
              RecordTypeId = System.Label.Customer_Inquiry_Record_Type,
              OwnerId = System.Label.Crowley_Arrival_Notice_Queue_Id,
              Case_Type__c = 'Customer Inquiry',
              Priority = 'Urgent',
              Arrival_Notice_Case__c = true,
              Due_Date__c = Due_Date,
              Reminder_Date_after_1_5_hrs__c = Reminder_Date_after_1_5_hrs,
              Reminder_Date_after_2_hrs__c = Reminder_Date_after_2_hrs,
              Reminder_Date_After_6_hrs__c = Reminder_Date_After_6_hrs
            )
          );
        } else {
          newCase.add(
            new Case(
              Subject = c.Subject,
              Origin = c.Origin,
              Description = str,
              Original_Case_2__c = c.Id,
              ContactId = Contact_Id,
              AccountId = Account_Id,
              SuppliedEmail = msg.FromAddress,
              RecordTypeId = System.Label.Customer_Inquiry_Record_Type,
              OwnerId = System.Label.Customer_Inquiry_Queue_Id,
              Case_Type__c = 'Customer Inquiry',
              Due_Date__c = Due_Date,
              Reminder_Date_after_1_5_hrs__c = Reminder_Date_after_1_5_hrs,
              Reminder_Date_after_2_hrs__c = Reminder_Date_after_2_hrs,
              Reminder_Date_After_6_hrs__c = Reminder_Date_After_6_hrs
            )
          );
        }
      } else if (
        c.IsClosed &&
        (string.valueOf(c.RecordTypeId)
          .contains(System.Label.Booking_Request_Record_Type) ||
        string.valueOf(c.RecordTypeId)
          .contains(System.Label.Booking_Request_Case_Record_Type))
      ) {
        string str = '';
        if (msg.TextBody.length() > 32000) {
          str = msg.TextBody.substring(0, 31999);
        } else {
          str = msg.TextBody;
        }
        DateTime Reminder_Date_After_6_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          6 * 3600000
        );
        DateTime Reminder_Date_after_3_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          3 * 3600000
        );
        DateTime Reminder_Date_after_1_5_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          90 * 60000
        );
        DateTime Reminder_Date_after_2_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          2 * 3600000
        );
        DateTime Reminder_Date_after_0_25_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          15 * 60000
        );
        DateTime Reminder_Date_after_0_5_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          30 * 60000
        );
        DateTime Reminder_Date_after_1_0_hrs = BusinessHours.add(
          System.Label.Service_Cloud_Business_hours_Id,
          System.now(),
          60 * 60000
        );
        DateTime Due_Date;
        if (c.Origin != 'EDI/GT NEXUS') {
          if (c.Account.Account_Tier__c == 'Tier 1') {
            Due_Date = BusinessHours.add(
              System.Label.Service_Cloud_Business_hours_Id,
              System.now(),
              30 * 60000
            );
          } else if (c.Account.Account_Tier__c == 'Tier 2') {
            Due_Date = BusinessHours.add(
              System.Label.Service_Cloud_Business_hours_Id,
              System.now(),
              1 * 3600000
            );
          } else if (
            c.Account.Account_Tier__c == 'Tier 3' ||
            c.Account.Account_Tier__c == null ||
            c.Account.Account_Tier__c == ''
          ) {
            Due_Date = BusinessHours.add(
              System.Label.Service_Cloud_Business_hours_Id,
              System.now(),
              2 * 3600000
            );
          }
        }
        if (c.Origin == 'EDI/GT NEXUS') {
          Due_Date = BusinessHours.add(
            System.Label.Service_Cloud_Business_hours_Id,
            System.now(),
            1 * 3600000
          );
        }
        if (c.Origin == 'EDI/GT NEXUS') {
          newCase.add(
            new Case(
              Subject = c.Subject,
              Origin = c.Origin,
              Description = str,
              Original_Case_2__c = c.Id,
              ContactId = Contact_Id,
              AccountId = Account_Id,
              SuppliedEmail = msg.FromAddress,
              RecordTypeId = System.Label.Booking_Request_Record_Type,
              OwnerId = System.Label.Booking_Speciality_Queue_2,
              Case_Type__c = 'Booking Request',
              Attachments__c = 'No',
              Due_Date__c = Due_Date,
              Reminder_Date_after_1_0_hrs__c = Reminder_Date_after_1_0_hrs,
              Reminder_Date_after_0_5_hrs__c = Reminder_Date_after_0_5_hrs,
              Reminder_Date_after_0_25_hrs__c = Reminder_Date_after_0_25_hrs,
              Reminder_Date_after_2_hrs__c = Reminder_Date_after_2_hrs,
              Reminder_Date_after_1_5_hrs__c = Reminder_Date_after_1_5_hrs,
              Reminder_Date_after_3_hrs__c = Reminder_Date_after_3_hrs,
              Reminder_Date_After_6_hrs__c = Reminder_Date_After_6_hrs
            )
          );
        } else {
          newCase.add(
            new Case(
              Subject = c.Subject,
              Origin = c.Origin,
              Description = str,
              Original_Case_2__c = c.Id,
              ContactId = Contact_Id,
              AccountId = Account_Id,
              SuppliedEmail = msg.FromAddress,
              RecordTypeId = System.Label.Booking_Request_Record_Type,
              OwnerId = System.Label.Booking_Inbox_Queue,
              Case_Type__c = 'Booking Request',
              Attachments__c = 'No',
              Due_Date__c = Due_Date,
              Reminder_Date_after_1_0_hrs__c = Reminder_Date_after_1_0_hrs,
              Reminder_Date_after_0_5_hrs__c = Reminder_Date_after_0_5_hrs,
              Reminder_Date_after_0_25_hrs__c = Reminder_Date_after_0_25_hrs,
              Reminder_Date_after_2_hrs__c = Reminder_Date_after_2_hrs,
              Reminder_Date_after_1_5_hrs__c = Reminder_Date_after_1_5_hrs,
              Reminder_Date_after_3_hrs__c = Reminder_Date_after_3_hrs,
              Reminder_Date_After_6_hrs__c = Reminder_Date_After_6_hrs
            )
          );
        }
      }
    }
    system.debug('newCase');
    system.debug(newCase);
    if (!newCase.isEmpty()) {
      try {
        insert newCase;
      } catch (exception e) {
        system.debug(e);
      }
    }
    system.debug('CreateNewCaseforEmailOnClosedCases');
  }
  private void setCaseMessageCreatedDate(List<EmailMessage> newMessages) {
    Integer val = String.isNotBlank(System.Label.Created_Date_N_Minutes) &&
      System.Label.Created_Date_N_Minutes.isNumeric()
      ? Integer.valueOf(System.Label.Created_Date_N_Minutes)
      : 55;
    for (EmailMessage msg : newMessages) {
      if (
        msg.ParentId != null &&
        msg.ParentId.getSobjectType().getDescribe().getName() == 'Case'
      ) {
        msg.CreatedDate__c = System.now().addMinutes(-1 * val);
      }
    }
  }

  //Update opportunity’s stage to ‘Negotiation/Review’ when ‘Send Quote to Customer From Opportunity’ email template is sent in ‘Price Proposal/Quote’ stage
  /*   private void updateOpportunityStage (List<EmailMessage> newEmailMessageList){
Set<Id> oppIdSet = new Set<Id>();
if(newEmailMessageList != NULL && !newEmailMessageList.isEmpty()){
for(EmailMessage email: newEmailMessageList){
if(email.RelatedToId != NULL && email.RelatedToId.getSobjectType().getDescribe().getName()=='Opportunity')
oppIdSet.add(email.RelatedToId);
}
}
System.debug('EmailMessage: oppIdSet -> '+oppIdSet);
List<Opportunity> oppList = new List<Opportunity>();
if(oppIdSet != NULL && !oppIdSet.isEmpty())
oppList = [Select Id, StageName,Proposal_Submission_Due_Date__c  from Opportunity where Id in: oppIdSet];

System.debug('EmailMessage: oppList -> '+oppList);
Map<Id, Opportunity> map_Id_Opportunity = new Map<Id, Opportunity>();
if(oppList != NULL && !oppList.isEmpty()){
for(Opportunity opp: oppList){
if(opp.StageName == ConstantClass.PROPOSAL_PRICE_QUOTE_OPP_STAGE)
map_Id_Opportunity.put(opp.Id, opp);
}
}

List<Opportunity> oppToUpdateList = new List<Opportunity>();
if(newEmailMessageList != NULL && !newEmailMessageList.isEmpty())
{
for(EmailMessage email: newEmailMessageList){
String oppId ='';
if(email.RelatedToId != NULL)
oppId = email.RelatedToId;
if(String.isNotBlank(oppId)){
if(email.TextBody.contains('Send Quote '+oppId.substring(0, 15))){
if(map_Id_Opportunity.containsKey(email.RelatedToId)){
Opportunity opp = map_Id_Opportunity.get(email.RelatedToId);
opp.Proposal_Submission_Due_Date__c = System.TODAY();
oppToUpdateList.add(opp);
}
}
}
}
}
if(oppToUpdateList != NULL && !oppToUpdateList.isEmpty())
update oppToUpdateList;
}*/
  /*
   * @ Description: This method update a case status
   * @ Args       : List<EmailMessage>
   * @ Return     : None
   */
  public static void UpdateCaseStatus(List<EmailMessage> emails) {
    List<Id> ids = new List<Id>();
    List<Case> cases = new List<Case>();
    map<string, list<EmailMessage>> emailstatusmap = new Map<string, list<EmailMessage>>();
    for (EmailMessage e : emails) {
      if (
        e.ParentId != null &&
        string.valueOf(e.ParentId).substring(0, 3) == '500'
      ) {
        list<EmailMessage> li = emailstatusmap.get(e.ParentId);
        if (li == null) {
          li = new List<EmailMessage>();
        }
        ids.add(e.ParentId);
        li.add(e);
        emailstatusmap.put(e.ParentId, li);
      }
    }
    if (!ids.isEmpty()) {
      cases = [
        SELECT
          Id,
          Status,
          IsClosed,
          Case_Auto_Close__c,
          Ha__c,
          Unread_Emails__c,
          Destination_Approval__c,
          RecordTypeId
        FROM Case
        WHERE Id = :ids
      ];

      for (Case cs : cases) {
        list<EmailMessage> em = emailstatusmap.get(cs.Id);

        for (EmailMessage e : em) {
          integer unreademailcount = integer.valueOf(cs.Unread_Emails__c);
          if (
            e.status == '0' &&
            !(cs.IsClosed &&
            string.valueOf(cs.RecordTypeId)
              .contains(System.Label.Customer_Inquiry_Record_Type))
          ) {
            unreademailcount++;
          }
          cs.Unread_Emails__c = unreademailcount;
          /*if(((cs.Ha__c || cs.Destination_Approval__c) && e.Incoming && cs.Status !='Closed Resolved')|| (e.Incoming && cs.Status =='Awaiting More Information')){
cs.Status='Ready for Review';
}*/
          if (
            (e.Incoming &&
            cs.Status == 'Awaiting More Information' &&
            (cs.RecordTypeId == System.Label.Customer_Inquiry_Record_Type ||
            cs.RecordTypeId == System.Label.Booking_Request_Record_Type))
          ) {
            cs.Status = 'Ready for Review';
          }
          System.debug(
            'templateId -> ' +
            System.Label.BL_Revision_Final_Resolution_template_id
          );
          if (
            e.EmailTemplateId ==
            System.Label.BL_Revision_Final_Resolution_template_id &&
            cs.RecordTypeId == System.Label.B_L_Revision_record_type
          ) {
            cs.Status = 'Resolving Case';
          }
        }

        system.debug(cs);
      }
      if (cases.size() > 0) {
        try {
          update cases;
        } catch (Exception e) {
          System.debug(e);
        }
      }
    }
  }

  public void deleteNeglectedEmailAccounts(List<EmailMessage> emailList) {
    Set<Id> relatedToIdSet = new Set<Id>();
    Set<Id> accountIdSetToBeDeleted = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> oppIdSet = new Set<Id>();
    List<Account> accList = new List<Account>();
    List<Opportunity> oppList = new List<Opportunity>();

    for (EmailMessage em : emailList) {
      relatedToIdSet.add(em.RelatedToId);
    }
    if (relatedToIdSet != null) {
      for (Id relId : relatedToIdSet) {
        String str = String.valueof(relId);
        if (str != null && str.startsWith('001')) {
          accountIdSet.add(relId);
        } else if (str != null && str.startsWith('006')) {
          oppIdSet.add(relId);
        }
      }
    }
    if (accountIdSet != null) {
      accList = [SELECT Id, ParentId FROM Account WHERE Id IN :accountIdSet];

      for (Account acc : accList) {
        accountIdSetToBeDeleted.add(acc.Id);
        if (acc.ParentId != null) {
          accountIdSetToBeDeleted.add(acc.ParentId);
        }
      }
    }
    if (oppIdSet != null) {
      oppList = [
        SELECT Id, AccountId, Account.ParentId
        FROM Opportunity
        WHERE Id IN :oppIdSet
      ];

      for (Opportunity opp : oppList) {
        accountIdSetToBeDeleted.add(opp.AccountId);

        if (opp.Account.ParentId != null) {
          accountIdSetToBeDeleted.add(opp.Account.ParentId);
        }
      }
    }
    if (accountIdSetToBeDeleted != null) {
      NeglectedAccountReport.deleteNeglectedAccountRecord(
        accountIdSetToBeDeleted
      );
    }
  }
}
