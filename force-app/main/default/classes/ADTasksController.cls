/*
 * Name: ADTasksController
 * Purpose: Controller class for Task component
 * Author: Nagarro
 * Created Date: 08-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADTasksController {
  @AuraEnabled
  public Integer totalTaskCount { get; set; }
  @AuraEnabled
  public Integer openTaskCount { get; set; }
  @AuraEnabled
  public Integer closedTaskCount { get; set; }
  @AuraEnabled
  public Integer overdueTaskCount { get; set; }
  @AuraEnabled
  public List<Task> taskList { get; set; }
  @AuraEnabled
  public List<Id> ownerIdList { get; set; }

  //Task list to display on task summary section based on the open and completed tasks having activity date.
  @AuraEnabled
  public List<Task> taskListTemp { get; set; }

  /*
   * Method Name: fetchTasks
   * Input Parameters:
   * Id accountId: This holds parent/current account Id.
   * ADMasterFilterWrapper objMasterFilter: This is filter warapper which holds filter parameters.
   * Return value: ADTasksController
   * Purpose: This method fetches all the tasks related to account hierarchy or opportunities.
   */
  @AuraEnabled
  public static ADTasksController fetchTasks(
    Id accountId,
    ADMasterFilterWrapper objMasterFilter
  ) {
    ADTasksController taskControllerObj = new ADTasksController();
    Date dateFilterTaskAfter;
    // Set<Id> ownerIdSet = new Set<Id>();
    taskControllerObj.ownerIdList = new List<Id>();
    String strAllYearExterQueryString = Label.AD_TASK_WITHOUT_YEAR_QUERYSTRING;
    String strYearExterQueryString = Label.AD_TASK_WITH_YEAR_QUERYSTRING;
    String strSelectedYear = objMasterFilter.strSelectedYear;
    //Filter accounts
    List<Id> lstFilteredAccounts = ADAccountDashboardUtil.applyAccountFilter(
      ADAccountDashboardUtil.getAllRelatedAccount(accountId),
      objMasterFilter
    );

    //Get related opportunities and apply filter on those
    ADMasterFilterWrapper objMasterFilterTemp = new ADMasterFilterWrapper();
    objMasterFilterTemp.lstSelectedAccounts = objMasterFilter.lstSelectedAccounts;
    objMasterFilterTemp.lstSelectedOwners = objMasterFilter.lstSelectedOwners;
    objMasterFilterTemp.strSelectedTopFilter = objMasterFilter.strSelectedTopFilter;
    objMasterFilterTemp.strSelectedOppSizeFilterOperator = objMasterFilter.strSelectedOppSizeFilterOperator;
    objMasterFilterTemp.strOppSizeVal = objMasterFilter.strOppSizeVal;
    objMasterFilterTemp.strSelectedYear = null;
    List<Opportunity> opportunityList = ADAccountDashboardUtil.applyOpportunityFilter(
      ADAccountDashboardUtil.getAllRelatedOpportunitiesWithoutFilter(
        lstFilteredAccounts
      ),
      objMasterFilterTemp
    );
    for (Account_Dashboard_Custom_Metadata__mdt objADMetadata : [
      SELECT Filter_Task_After_Date__c
      FROM Account_Dashboard_Custom_Metadata__mdt
      WHERE DeveloperName = 'Custom_Metadata_1'
    ]) {
      List<String> lstDateString = objADMetadata.Filter_Task_After_Date__c.split(
        '-'
      );
      dateFilterTaskAfter = Date.newInstance(
        Integer.valueOf(lstDateString[0]),
        Integer.valueOf(lstDateString[1]),
        Integer.valueOf(lstDateString[2])
      );
    }
    //Get tasks related to account or opportunity
    if (
      (lstFilteredAccounts != null && !lstFilteredAccounts.isEmpty()) ||
      (opportunityList != null && !opportunityList.isEmpty())
    ) {
      if (objMasterFilter.strSelectedYear == Label.AD_PICKLIST_VAL_ALL_YEAR) {
        taskControllerObj.taskList = filterTaskForWhoIdAccountOrCompany(
          (List<Task>) Database.query(strAllYearExterQueryString)
        );
      } else {
        taskControllerObj.taskList = filterTaskForWhoIdAccountOrCompany(
          (List<Task>) Database.query(strYearExterQueryString)
        );
      }
    }

    //Initializing the variables
    taskControllerObj.openTaskCount = 0;
    taskControllerObj.closedTaskCount = 0;
    taskControllerObj.overdueTaskCount = 0;
    taskControllerObj.totalTaskCount = 0;

    if (
      taskControllerObj.taskList == null || taskControllerObj.taskList.isEmpty()
    )
      taskControllerObj.totalTaskCount = 0;
    else
      taskControllerObj.totalTaskCount = taskControllerObj.taskList.size(); //Total number of tasks

    if (
      taskControllerObj.taskList != null &&
      !taskControllerObj.taskList.isEmpty()
    ) {
      for (Task t : taskControllerObj.taskList) {
        if (t.Status == ConstantClass.TASK_STATUS_OPEN) {
          taskControllerObj.openTaskCount++; //Total number of open tasks
          if (t.ActivityDate < System.today())
            taskControllerObj.overdueTaskCount++; //Total number of overdue tasks
        }
        if (t.Status == ConstantClass.TASK_STATUS_COMPLETED) {
          taskControllerObj.closedTaskCount++; //Total number of closed tasks
        }
        //Used to fetch only the related users in the multiselect lookup filter.
        if (t.OwnerId != null) {
          taskControllerObj.ownerIdList.add(t.OwnerId);
        }
      }
    }

    Integer openTaskHavingDueDateCount = 0;
    List<Task> openTaskListHavingDueDate = new List<Task>();
    List<Task> openTaskListHavingNoDueDate = new List<Task>();
    List<Task> completedTaskListHavingDueDate = new List<Task>();
    List<Task> completedTaskListHavingNoDueDate = new List<Task>();
    taskControllerObj.taskListTemp = new List<Task>();

    if (
      taskControllerObj.taskList != null &&
      !taskControllerObj.taskList.isEmpty()
    ) {
      for (Task t : taskControllerObj.taskList) {
        if (
          t.Status == ConstantClass.TASK_STATUS_OPEN &&
          t.ActivityDate != null
        ) {
          openTaskHavingDueDateCount++;
          openTaskListHavingDueDate.add(t);
          if (openTaskHavingDueDateCount >= 6)
            break;
        } else if (
          t.Status == ConstantClass.TASK_STATUS_OPEN &&
          t.ActivityDate == null
        ) {
          openTaskListHavingNoDueDate.add(t);
        } else if (
          t.Status == ConstantClass.TASK_STATUS_COMPLETED &&
          t.ActivityDate == null
        ) {
          completedTaskListHavingDueDate.add(t);
        } else if (
          t.Status == ConstantClass.TASK_STATUS_COMPLETED &&
          t.ActivityDate != null
        ) {
          completedTaskListHavingNoDueDate.add(t);
        }
      }
    }

    if (openTaskListHavingDueDate.size() >= 6) {
      taskControllerObj.taskListTemp.addAll(openTaskListHavingDueDate);
    } else {
      taskControllerObj.taskListTemp.addAll(openTaskListHavingDueDate);
      taskControllerObj.taskListTemp.addAll(openTaskListHavingNoDueDate);
      taskControllerObj.taskListTemp.addAll(completedTaskListHavingDueDate);
      taskControllerObj.taskListTemp.addAll(completedTaskListHavingNoDueDate);
    }

    return taskControllerObj;
  }

  /*
* Method Name: applyFilter
* Input Parameters:
* Id accountId: This holds parent/current account Id.
* Date startDate: This holds the start date.
* Date endDate: This holds the end date.
* String dateFilter: This holds the selected date type (Due Date or Created Date).
* List<sObject> selectedOwners: This holds the list of owners selected in the multi select lookup component on the AllTasks component.
* List<Task> taskList: List of tasks related to account hierarchy or opportunities.
* String strTaskStatus : This holds task status.
* String strRelatedTo : This holds related to name.
* Return value: List<Task>
* Purpose: 	There are 3 filter options on the component: Assigned To, Created Date and Due Date.
This method is called when Apply button is clicked on the component. Based on the users and date filter selected, filtered task list is returned.
*/
  @AuraEnabled
  public static List<Task> applyFilter(
    Id accountId,
    Date startDate,
    Date endDate,
    String dateFilter,
    List<sObject> selectedOwners,
    List<Task> taskList,
    String strTaskStatus,
    String strRelatedTo
  ) {
    Set<Id> selectedOwnerIds = new Set<Id>();

    if (selectedOwners != null && !selectedOwners.isEmpty()) {
      for (sObject s : selectedOwners) {
        selectedOwnerIds.add(s.Id);
      }
    }
    Set<Id> taskIdSet = new Set<Id>();
    for (Task t : taskList) {
      taskIdSet.add(t.Id);
    }
    List<Task> filteredTaskList = new List<Task>();
    if (taskIdSet != null && !taskIdSet.isEmpty()) {
      if (dateFilter == ConstantClass.DATE_FILTER_CREATED_DATE) {
        filteredTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE
            Id IN :taskIdSet
            AND DAY_ONLY(CreatedDate) >= :startDate
            AND DAY_ONLY(CreatedDate) <= :endDate
          ORDER BY ActivityDate DESC NULLS LAST
        ];
        if (selectedOwnerIds != null && !selectedOwnerIds.isEmpty()) {
          filteredTaskList = [
            SELECT
              Id,
              Status,
              Description,
              Owner.Name,
              Subject,
              What.Type,
              What.Name,
              ActivityDate,
              CreatedDate,
              TaskSubtype,
              WhoId,
              WhatId,
              IsClosed
            FROM Task
            WHERE
              Id IN :taskIdSet
              AND DAY_ONLY(CreatedDate) >= :startDate
              AND DAY_ONLY(CreatedDate) <= :endDate
              AND OwnerId IN :selectedOwnerIds
            ORDER BY ActivityDate DESC NULLS LAST
          ];
        }
      } else if (dateFilter == ConstantClass.DATE_FILTER_DUE_DATE) {
        filteredTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE
            Id IN :taskIdSet
            AND ActivityDate >= :startDate
            AND ActivityDate <= :endDate
          ORDER BY ActivityDate DESC NULLS LAST
        ];
        if (selectedOwnerIds != null && !selectedOwnerIds.isEmpty()) {
          filteredTaskList = [
            SELECT
              Id,
              Status,
              Description,
              Owner.Name,
              Subject,
              What.Type,
              What.Name,
              ActivityDate,
              CreatedDate,
              TaskSubtype,
              WhoId,
              WhatId,
              IsClosed
            FROM Task
            WHERE
              Id IN :taskIdSet
              AND ActivityDate >= :startDate
              AND ActivityDate <= :endDate
              AND OwnerId IN :selectedOwnerIds
            ORDER BY ActivityDate DESC NULLS LAST
          ];
        }
      } else if (
        selectedOwnerIds != null &&
        !selectedOwnerIds.isEmpty() &&
        (dateFilter != '' ||
        dateFilter != null)
      ) {
        filteredTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE Id IN :taskIdSet AND OwnerId IN :selectedOwnerIds
          ORDER BY ActivityDate DESC NULLS LAST
        ];
      } else {
        return filterTaskByStatusAndRelatedTo(
          taskList,
          strTaskStatus,
          strRelatedTo
        );
      }
    }
    return filterTaskByStatusAndRelatedTo(
      filteredTaskList,
      strTaskStatus,
      strRelatedTo
    );
  }

  /*
* Method Name: applySorting
* Input Parameters: 
* String sortedDateOptionSelected: This holds the sorting option selected.
* List<Task> taskList: This holds the list of tasks currently displayed on the component.
* Return value: List<Task>
* Purpose: 	There are 2 sorting links on the component: Sort by Due Date, Sort by Created Date.
This method is called when either of the sorting link is clicked on the component. Based on the sorting link the sorted task list is returned.	
*/
  @AuraEnabled
  public static List<Task> applySorting(
    String sortedDateOptionSelected,
    List<Task> taskList
  ) {
    Set<Id> taskIdSet = new Set<Id>();
    if (taskList != null && !taskList.isEmpty()) {
      for (Task t : taskList) {
        taskIdSet.add(t.Id);
      }
    }
    List<Task> sortedTaskList = new List<Task>();

    if (taskIdSet != null && !taskIdSet.isEmpty()) {
      if (sortedDateOptionSelected == ConstantClass.SORTING_DUE_DATE_ASC)
        sortedTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE Id IN :taskIdSet
          ORDER BY ActivityDate ASC NULLS LAST
        ];
      else if (
        sortedDateOptionSelected == ConstantClass.SORTING_CREATED_DATE_ASC
      )
        sortedTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE Id IN :taskIdSet
          ORDER BY CreatedDate ASC NULLS LAST
        ];
      else if (sortedDateOptionSelected == ConstantClass.SORTING_DUE_DATE_DESC)
        sortedTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE Id IN :taskIdSet
          ORDER BY ActivityDate DESC NULLS LAST
        ];
      else if (
        sortedDateOptionSelected == ConstantClass.SORTING_CREATED_DATE_DESC
      )
        sortedTaskList = [
          SELECT
            Id,
            Status,
            Description,
            Owner.Name,
            Subject,
            What.Type,
            What.Name,
            ActivityDate,
            CreatedDate,
            TaskSubtype,
            WhoId,
            WhatId,
            IsClosed
          FROM Task
          WHERE Id IN :taskIdSet
          ORDER BY CreatedDate DESC NULLS LAST
        ];
    }
    return sortedTaskList;
  }

  /*
   * Method Name: filterTaskForWhoIdAccountOrCompany
   * Input Parameters:
   * List<Task> lstTasks: This holds task list.
   * Return value: List<Task>
   * Purpose: 	This method will filter task to check that related what id must have associated Account or Company.
   */
  private static List<Task> filterTaskForWhoIdAccountOrCompany(
    List<Task> lstTasks
  ) {
    List<Task> lstFilteredTask = new List<Task>();
    Set<Id> setWhatId = new Set<Id>();
    Set<Id> setValidWhatId = new Set<Id>();
    for (Task objTask : lstTasks) {
      if (objTask.WhatId != null) {
        setWhatId.add(objTask.WhatId);
      }
    }
    for (Account objAccount : [
      SELECT Id, Name
      FROM Account
      WHERE Name != NULL AND Id IN :setWhatId
    ]) {
      setValidWhatId.add(objAccount.Id);
    }
    for (Opportunity objOpportunity : [
      SELECT Id, Account.Name
      FROM Opportunity
      WHERE Account.Name != NULL AND Id IN :setWhatId
    ]) {
      setValidWhatId.add(objOpportunity.Id);
    }

    for (Task objTask : lstTasks) {
      if (objTask.WhatId != null && setValidWhatId.contains(objTask.WhatId)) {
        lstFilteredTask.add(objTask);
      }
    }
    return lstFilteredTask;
  }

  /*
   * Method Name: filterTaskByStatusAndRelatedTo
   * Input Parameters:
   * List<Task> lstTasks: This holds task list.
   * String strTaskStatus : This holds task status.
   * String strRelatedTo : This holds related to.
   * Return value: List<Task>
   * Purpose: 	This method will filter task by status.
   */
  private static List<Task> filterTaskByStatusAndRelatedTo(
    List<Task> lstTask,
    String strTaskStatus,
    String strRelatedTo
  ) {
    List<Task> lstFilteredTask = new List<Task>();

    if (String.isNotBlank(strRelatedTo)) {
      strRelatedTo = strRelatedTo.trim().toLowerCase();
    }

    if (
      (String.isBlank(strTaskStatus) ||
      strTaskStatus == Label.AD_TASK_STATUS_ALL) && String.isBlank(strRelatedTo)
    ) {
      lstFilteredTask = lstTask;
    } else if (
      (String.isBlank(strTaskStatus) ||
      strTaskStatus == Label.AD_TASK_STATUS_ALL) &&
      String.isNotBlank(strRelatedTo)
    ) {
      for (Task objTask : lstTask) {
        if (
          String.isNotBlank(objTask.What.Name) &&
          objTask.What.Name.toLowerCase().contains(strRelatedTo)
        ) {
          lstFilteredTask.add(objTask);
        }
      }
    } else if (strTaskStatus == Label.AD_TASK_STATUS_OVERDUE) {
      for (Task objTask : lstTask) {
        if (
          objTask.IsClosed == false &&
          objTask.ActivityDate < System.today()
        ) {
          if (String.isBlank(strRelatedTo)) {
            lstFilteredTask.add(objTask);
          } else if (
            String.isNotBlank(strRelatedTo) &&
            String.isNotBlank(objTask.What.Name) &&
            objTask.What.Name.toLowerCase().contains(strRelatedTo)
          ) {
            lstFilteredTask.add(objTask);
          }
        }
      }
    } else if (
      strTaskStatus == Label.AD_TASK_STATUS_CLOSED ||
      strTaskStatus == Label.AD_TASK_STATUS_COMPLETED
    ) {
      for (Task objTask : lstTask) {
        if (objTask.IsClosed == true) {
          if (String.isBlank(strRelatedTo)) {
            lstFilteredTask.add(objTask);
          } else if (
            String.isNotBlank(strRelatedTo) &&
            String.isNotBlank(objTask.What.Name) &&
            objTask.What.Name.toLowerCase().contains(strRelatedTo)
          ) {
            lstFilteredTask.add(objTask);
          }
        }
      }
    } else {
      for (Task objTask : lstTask) {
        if (objTask.Status == strTaskStatus) {
          if (String.isBlank(strRelatedTo)) {
            lstFilteredTask.add(objTask);
          } else if (
            String.isNotBlank(strRelatedTo) &&
            String.isNotBlank(objTask.What.Name) &&
            objTask.What.Name.toLowerCase().contains(strRelatedTo)
          ) {
            lstFilteredTask.add(objTask);
          }
        }
      }
    }
    return lstFilteredTask;
  }

  @AuraEnabled
  public static String createExcel(List<Task> lstTasks, String strAccountId) {
    TriggerHandler.bypass('AttachmentTriggerHandler');
    Attachment objAttachment = new Attachment();
    objAttachment.Body = Blob.valueOf(JSON.serialize(lstTasks));
    objAttachment.Name = 'TaskList.txt';
    objAttachment.ParentId = strAccountId;
    insert objAttachment;
    TriggerHandler.clearBypass('AttachmentTriggerHandler');
    return objAttachment.Id;
  }
}
