@isTest
public class Test_ContentDocumentLinkTriggerHandler {
  @testSetup
  static void setup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    Group q = [
      SELECT Id, Name, Type
      FROM Group
      WHERE Type = 'Queue' AND Name LIKE '%BL Revision%'
      LIMIT 1
    ];
    List<Account> accs = TestDataUtility.createAccount(
      'ABC Company',
      null,
      'IT',
      null,
      false,
      1
    );
    insert accs;
    Id accId, conId;
    for (Account acc : accs) {
      accId = acc.Id;
    }
    List<Address__c> addresses = [
      SELECT Id, Account__c
      FROM Address__c
      WHERE Account__c = :accId
    ];
    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
      .get('Create_Record')
      .getRecordTypeId();
    //List<RecordType> contactRTs = [Select Id, Name, SobjectType From RecordType Where SobjectType='Contact' Limit 1];
    List<Contact> cts = TestDataUtility.createContact(
      recordTypeId,
      accs,
      addresses,
      'test',
      'contact',
      'test@yopmail.com',
      '9999888877',
      false,
      UserInfo.getUserId(),
      1
    );
    insert cts;

    List<Case> csList = TestDataUtility.createBLRevisionCase(
      accs,
      cts,
      null,
      'Subject1',
      'Desc1',
      'Web',
      q.Id,
      'Open',
      1
    );
    insert csList;
    for (Case cs1 : csList) {
      cs1.Reason_for_hold__c = 'Pricing';
    }
    update csList;
    CaseTriggerHandler.reset();
    //Creating a child case.
    List<Case> childcs = TestDataUtility.createPricingRateIssueCase(
      accs,
      cts,
      csList,
      'Subject2',
      'Desc1',
      'Web',
      q.Id,
      'Open',
      1
    );
    insert childcs;
  }
  public static testMethod void test_creatingChildCaseOnParentWithAttachment() {
    Group q = [
      SELECT Id, Name, Type
      FROM Group
      WHERE Type = 'Queue' AND Name LIKE '%BL Revision%'
      LIMIT 1
    ];
    Account accs = [SELECT Id FROM Account LIMIT 1];
    Contact cts = [SELECT Id FROM Contact LIMIT 1];
    Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject1' LIMIT 1];
    Test.startTest();
    List<Messaging.SingleEmailMessage> msgs = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    msg.setWhatId(cs.Id);
    msg.setTargetObjectId(cts.Id);
    msg.setSubject('TestEmail1');
    msg.setPlainTextBody('Testing');
    msgs.add(msg);
    List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgs);

    //Create Document
    List<ContentVersion> cvlist = TestDataUtility.createContentVersion(
      'Test Document',
      'TestDocument.pdf',
      'Test Content',
      1
    );
    insert cvlist;
    Id cvId;
    for (ContentVersion cv : cvlist) {
      cvId = cv.Id;
    }

    //Get Content Documents
    Id conDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cvId
    ]
    .ContentDocumentId;

    EmailMessage emsg = [
      SELECT Id, Subject
      FROM EmailMessage
      WHERE Subject LIKE '%TestEmail1%'
      LIMIT 1
    ];

    //Create ContentDocumentLink
    List<ContentDocumentLink> cdl = TestDataUtility.createContentDocumentLink(
      new List<Id>{ conDocId },
      emsg.Id
    );
    insert cdl;

    CaseTriggerHandler.reset();
    //Creating a child case. Parent case already have an attachment which should get copied to child case.
    List<Case> childcs = TestDataUtility.createPricingRateIssueCase(
      new List<Account>{ accs },
      new List<Contact>{ cts },
      new List<Case>{ cs },
      'Subject3',
      'Desc1',
      'Web',
      q.Id,
      'Open',
      1
    );
    insert childcs;
    Id childcsId;
    for (Case cs1 : childcs) {
      childcsId = cs1.Id;
    }
    Test.stopTest();

    //System.debug('child case -> '+childcs.ParentId);
    List<Related_Case_Attachment__c> relatedAtts = [
      SELECT Id, Case__c
      FROM Related_Case_Attachment__c
      WHERE Case__c = :childcsId
      LIMIT 1
    ];
    System.assert(relatedAtts.size() > 0);
  }

  public static testMethod void test_addingAttachmentOnParentCase() {
    Group q = [
      SELECT Id, Name, Type
      FROM Group
      WHERE Type = 'Queue' AND Name LIKE '%BL Revision%'
      LIMIT 1
    ];
    Account accs = [SELECT Id FROM Account LIMIT 1];
    Contact cts = [SELECT Id FROM Contact LIMIT 1];
    Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject1' LIMIT 1];
    Case childcs = [
      SELECT Id, ParentId
      FROM Case
      WHERE ParentId = :cs.Id
      LIMIT 1
    ];

    Test.startTest();

    //Create Document
    List<ContentVersion> cvlist = TestDataUtility.createContentVersion(
      'Test Document',
      'TestDocument.pdf',
      'Test Content',
      1
    );
    insert cvlist;
    Id cvId;
    for (ContentVersion cv : cvlist) {
      cvId = cv.Id;
    }

    //Get Content Documents
    Id conDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cvId
    ]
    .ContentDocumentId;

    //Create ContentDocumentLink
    List<ContentDocumentLink> cdl = TestDataUtility.createContentDocumentLink(
      new List<Id>{ conDocId },
      cs.Id
    );
    insert cdl;

    Test.stopTest();

    System.debug('child case -> ' + childcs.ParentId);
    List<Related_Case_Attachment__c> relatedAtts = [
      SELECT Id, Case__c
      FROM Related_Case_Attachment__c
      WHERE Case__c = :childcs.Id
      LIMIT 1
    ];
    System.assert(relatedAtts.size() > 0);
  }

  public static testMethod void test_scheduleHandle() {
    Group q = [
      SELECT Id, Name, Type
      FROM Group
      WHERE Type = 'Queue' AND Name LIKE '%BL Revision%'
      LIMIT 1
    ];
    Account accs = [SELECT Id FROM Account LIMIT 1];
    Contact cts = [SELECT Id FROM Contact LIMIT 1];
    Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject1' LIMIT 1];
    Case childcs = [SELECT Id FROM Case WHERE ParentId = :cs.Id LIMIT 1];
    // if EnhancedEmail Perm is enabled, create an EmailMessage object
    EmailMessage emailMessage = new EmailMessage();
    emailMessage.status = '3'; // email was sent
    emailMessage.parentId = cs.Id; // related to record e.g. an opportunity
    emailMessage.relatedToId = cs.Id; // related to record e.g. an opportunity
    emailMessage.fromName = 'Dan Perkins'; // from name
    emailMessage.subject = 'This is the Subject!'; // email subject
    emailMessage.htmlBody = '<html><body><b>Hello</b></body></html>'; // email body
    // Contact, Lead or User Ids of recipients
    String[] toIds = new List<String>{ cts.Id };
    emailMessage.toIds = toIds;
    // additional recipients who don’t have a corresponding contact, lead or user id in the Salesforce org (optional)
    emailMessage.toAddress = 'emailnotinsalesforce@toexample.com, anotherone@toexample.com';
    insert emailMessage; // insert

    // Add Email Message Relation for id of the sender
    EmailMessageRelation emr = new EmailMessageRelation();
    emr.emailMessageId = emailMessage.id;
    emr.relationId = UserInfo.getUserId(); // user id of the sender
    emr.relationType = 'FromAddress';
    insert emr;

    Test.startTest();

    //Create Document
    List<ContentVersion> cvlist = TestDataUtility.createContentVersion(
      'Test Document',
      'TestDocument.pdf',
      'Test Content',
      1
    );
    insert cvlist;
    Id cvId;
    for (ContentVersion cv : cvlist) {
      cvId = cv.Id;
    }

    //Get Content Documents
    Id conDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cvId
    ]
    .ContentDocumentId;

    //Create ContentDocumentLink
    List<ContentDocumentLink> cdl = TestDataUtility.createContentDocumentLink(
      new List<Id>{ conDocId },
      emailMessage.Id
    );
    insert cdl;

    List<Id> emsgIds = new List<Id>();
    emsgIds.add(emailMessage.Id);
    ContentDocumentLinkTriggerHandler.handleEmailAttachmentsInvocable(emsgIds);

    CleanAttachmentScheduler sch = new CleanAttachmentScheduler();
    System.schedule('TestSchedule', '0 0 10 ? * *', sch);
    Test.stopTest();

    List<Related_Case_Attachment__c> relatedAtts = [
      SELECT Id, Case__c
      FROM Related_Case_Attachment__c
      LIMIT 1
    ];
    System.assert(relatedAtts.size() > 0);
  }

  static testMethod void test_handleEmailAttachmentsInvocable() {
    Group q = [
      SELECT Id, Name, Type
      FROM Group
      WHERE Type = 'Queue' AND Name LIKE '%BL Revision%'
      LIMIT 1
    ];
    Account accs = [SELECT Id FROM Account LIMIT 1];
    Contact cts = [SELECT Id FROM Contact LIMIT 1];
    Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject1' LIMIT 1];
    Case childcs = [SELECT Id FROM Case WHERE ParentId = :cs.Id LIMIT 1];

    Test.startTest();
    List<Messaging.SingleEmailMessage> msgs = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    msg.setWhatId(cs.Id);
    msg.setTargetObjectId(cts.Id);
    msg.setSubject('TestEmail1');
    msg.setPlainTextBody('Testing');
    msgs.add(msg);
    List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgs);

    //Create Document
    List<ContentVersion> cvlist = TestDataUtility.createContentVersion(
      'Test Document',
      'TestDocument.pdf',
      'Test Content',
      1
    );
    insert cvlist;
    Id cvId;
    for (ContentVersion cv : cvlist) {
      cvId = cv.Id;
    }

    //Get Content Documents
    Id conDocId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cvId
    ]
    .ContentDocumentId;
    Test.stopTest();
    EmailMessage emsg = [
      SELECT Id, Subject
      FROM EmailMessage
      WHERE Subject LIKE '%TestEmail1%'
      LIMIT 1
    ];

    //Create ContentDocumentLink
    List<ContentDocumentLink> cdl = TestDataUtility.createContentDocumentLink(
      new List<Id>{ conDocId },
      emsg.Id
    );
    insert cdl;
    System.debug('emsg -> ' + emsg);
    System.debug('cdl -> ' + cdl);

    List<Id> emsgIds = new List<Id>();
    emsgIds.add(emsg.Id);
    ContentDocumentLinkTriggerHandler.handleEmailAttachmentsInvocable(emsgIds);
    List<Case_Attachment__c> csAttachments = [
      SELECT Id
      FROM Case_Attachment__c
      LIMIT 1
    ];
    System.assert(csAttachments.size() > 0);
  }
}
