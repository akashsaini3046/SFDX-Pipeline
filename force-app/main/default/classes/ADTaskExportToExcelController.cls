/*
 * Name: ADTaskExportToExcelController
 * Purpose: Controller class for ADTaskExportToExcel VF page.
 * Author: Nagarro
 * Created Date: 28-Nov-2019
 * Modification History
 * Modification #   Story/Defect#      Modified By     Date   Description
 */

public class ADTaskExportToExcelController {
  public transient String xmlheader { get; set; }
  public transient List<WrapTask> listOfTasks { get; set; }
  String strTaskAttachmentId;

  public ADTaskExportToExcelController() {
    xmlheader = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
    listOfTasks = new List<WrapTask>();
    strTaskAttachmentId = ApexPages.currentPage()
      .getParameters()
      .get('taskAttachmentId');
    Attachment objAttachment;
    Integer intIndex;
    Integer intMaxRowsInVFTable = Integer.valueOf(
      Label.AD_MAX_RECORDS_IN_VF_TABLE
    );

    if (String.isNotBlank(strTaskAttachmentId)) {
      objAttachment = [
        SELECT Id, Body
        FROM Attachment
        WHERE Id = :strTaskAttachmentId
      ];
    }
    if (objAttachment == null) {
      return;
    }

    List<Object> listOfTaskJson = (List<Object>) JSON.deserializeUntyped(
      objAttachment.Body.toString()
    );
    System.debug('listOfTaskJson: ' + listOfTaskJson);

    intIndex = 0;
    if (listOfTasks.isEmpty()) {
      if (listOfTaskJson.size() > 0) {
        for (Object task : listOfTaskJson) {
          Map<String, Object> data = (Map<String, Object>) task;
          String id = (String) data.get('Id');
          String status = (String) data.get('Status');
          String subject = (String) data.get('Subject');
          String description = (String) data.get('Description');
          String activityDate = (String) data.get('ActivityDate');
          Date createdDate = Date.valueOf((String) data.get('CreatedDate'));
          String formattedCreatedDate =
            createdDate.year() +
            '-' +
            createdDate.month() +
            '-' +
            createdDate.day();
          String taskSubtype = (String) data.get('TaskSubtype');
          Map<String, Object> owner = (Map<String, Object>) data.get('Owner');
          String ownerName = (String) Owner.get('Name');
          Map<String, Object> what = (Map<String, Object>) data.get('What');
          String accountName = (String) What.get('Name');
          String relatedTo = (String) What.get('Type');
          WrapTask tasks = new WrapTask(
            id,
            status,
            subject,
            description,
            activityDate,
            formattedCreatedDate,
            taskSubtype,
            ownerName,
            accountName,
            relatedTo
          );
          listOfTasks.add(tasks);
          intIndex++;
          if (intIndex == intMaxRowsInVFTable) {
            break;
          }
        }
      }
    }
  }

  public void deleteAttachment() {
    if (String.isNotBlank(strTaskAttachmentId)) {
      deleteAttachmentFuture(strTaskAttachmentId);
    }
  }

  @future
  public static void deleteAttachmentFuture(String strAttachmentId) {
    if (String.isNotBlank(strAttachmentId)) {
      try {
        delete new Attachment(Id = strAttachmentId);
      } catch (Exception objEx) {
        System.debug('ADTaskExportToExcelController > ' + objEx.getMessage());
      }
    }
  }

  public class WrapTask {
    public String taskId { get; set; }
    public String status { get; set; }
    public String subject { get; set; }
    public String description { get; set; }
    public String createdDate { get; set; }
    public String activityDate { get; set; }
    public String taskSubtype { get; set; }
    public String ownerName { get; set; }
    public String accountName { get; set; }
    public String relatedTo { get; set; }

    public WrapTask(
      String taskId,
      String status,
      String subject,
      String description,
      String activityDate,
      String createdDate,
      String taskSubtype,
      String ownerName,
      String accountName,
      String relatedTo
    ) {
      this.taskId = taskId;
      this.status = status;
      this.subject = subject;
      this.description = description;
      this.activityDate = activityDate;
      this.createdDate = createdDate;
      this.taskSubtype = taskSubtype;
      this.ownerName = ownerName;
      this.accountName = accountName;
      this.relatedTo = relatedTo;
    }
  }
}
