@isTest
public class GetTaskAttachment_Test {
  public static testMethod void testSendDocuments() {
    Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject' LIMIT 1];
    Test.startTest();
    cs = GetTaskAttachemnt.getHaciendaChecked(cs.Id);

    String jsonAtts = GetTaskAttachemnt.getTaskAttachmentList(cs.Id);
    List<GetTaskAttachemnt.AttachmentList> attList = (List<GetTaskAttachemnt.AttachmentList>) JSON.deserialize(
      jsonAtts,
      List<GetTaskAttachemnt.AttachmentList>.class
    );
    List<string> attIds = new List<string>();
    for (GetTaskAttachemnt.AttachmentList att : attList) {
      attIds.add(att.attachId);
    }
    string jsonTemplates = GetTaskAttachemnt.getTemplates('Resolution', cs);
    string jsonDestinationEmailList = GetTaskAttachemnt.destinationEmailList();

    String result = GetTaskAttachemnt.sendAttachments(
      attIds,
      new List<string>{ 'vikash@nagarro.com' },
      cs,
      'vikash@yopmail.com',
      'vikash@yopmail.com',
      'Test 1',
      'Test Data'
    );
    System.debug('send task att status -> ' + result);
    System.assert(result == 'success');
    Test.stopTest();
  }

  @testSetup
  static void setup() {
    List<User_Region_to_Opp_Role__c> UserRegionRole = TestDataUtility.UserRegiontoOppRole();
    insert UserRegionRole;

    List<Account> accs = TestDataUtility.createAccount(
      'TestAccount',
      null,
      'Crowley',
      null,
      false,
      1
    );
    insert accs;

    List<Case> cslist = TestDataUtility.createBLRevisionCase(
      accs,
      null,
      null,
      'Subject',
      null,
      'Web',
      Userinfo.getUserId(),
      'Open',
      1
    );
    insert cslist;
    Id csId;
    for (Case cs : cslist) {
      cs.Ha__c = true;
      cs.Internal_Contact__c = true;
      cs.Reason_for_hold__c = 'Pricing';
      csId = cs.Id;
    }
    update cslist;
    insert TestDataUtility.createDestinationEmailList(
      'Honduras - Import',
      'Central America',
      2
    );
    List<ContentVersion> versions = TestDataUtility.createContentVersion(
      'Penguins',
      'Penguins.txt',
      'Test Data',
      1
    );
    insert versions;
    Set<Id> versionIds = (new Map<Id, ContentVersion>(versions)).keyset();
    List<id> contentdocumentIdList = new List<id>();
    for (ContentVersion cv : [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :versionIds
    ]) {
      contentdocumentIdList.add(cv.ContentDocumentId);
    }
    insert TestDataUtility.createContentDocumentLink(
      contentdocumentIdList,
      csId
    );
    insert TestDataUtility.createAttachment(csId, 'Test Data', 'Attachment', 2);
  }
}
