public without sharing class EmailMessageCounterDecreased {
  private EmailMessage currentRecord;
  public EmailMessageCounterDecreased(
    ApexPages.StandardController stdController
  ) {
    this.currentRecord = (EmailMessage) stdController.getRecord();
    currentRecord = [
      SELECT Id, Status, Counter_Decreased__c, ParentId
      FROM EmailMessage
      WHERE Id = :currentRecord.Id
    ];
  }
  public void updateparentcase() {
    system.debug(currentRecord);
    if (String.isNotBlank(currentRecord.ParentId)) {
      case c = [
        SELECT Id, Status, Unread_Emails__c
        FROM case
        WHERE Id = :currentRecord.ParentId
        LIMIT 1
      ];
      if (
        !currentRecord.Counter_Decreased__c &&
        (currentRecord.Status == '1' ||
        currentRecord.Status == '2')
      ) {
        c.Unread_Emails__c -= 1;
        //c.Status = 'Ready for Review';
        currentRecord.Counter_Decreased__c = true;
      }
      try {
        system.debug(c);
        system.debug(currentRecord);
        update c;
        update currentRecord;
      } catch (exception e) {
        system.debug(e);
      }
    }
  }
}
