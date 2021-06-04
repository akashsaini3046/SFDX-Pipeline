({
  //Called when Apply button is clicked. Based on the dates and users selected, task list is displayed
  applyFilterHelper: function (component, event, helper) {
    if (
      (component.find("StartDateField").get("v.value") != null &&
        component.find("StartDateField").get("v.value") != "") ||
      (component.find("EndDateField").get("v.value") != null &&
        component.find("EndDateField").get("v.value") != "")
    ) {
      component.set("v.dateOptionSelected", "Created Date");
    }
    if (
      (component.get("v.dateOptionSelected") == "Created Date" ||
        component.get("v.dateOptionSelected") == "Due Date") &&
      (component.find("StartDateField").get("v.value") == null ||
        component.find("StartDateField").get("v.value") == "") &&
      (component.find("EndDateField").get("v.value") == null ||
        component.find("EndDateField").get("v.value") == "")
    ) {
      alert("Please enter Start Date and End Date");
    } else if (
      (component.get("v.dateOptionSelected") == "Created Date" ||
        component.get("v.dateOptionSelected") == "Due Date") &&
      (component.find("StartDateField").get("v.value") == null ||
        component.find("StartDateField").get("v.value") == "") &&
      component.find("EndDateField").get("v.value") != null &&
      component.find("EndDateField").get("v.value") != ""
    ) {
      alert("Please enter Start Date");
    } else if (
      (component.get("v.dateOptionSelected") == "Created Date" ||
        component.get("v.dateOptionSelected") == "Due Date") &&
      (component.find("EndDateField").get("v.value") == null ||
        component.find("EndDateField").get("v.value") == "") &&
      component.find("StartDateField").get("v.value") != null &&
      component.find("StartDateField").get("v.value") != ""
    ) {
      alert("Please enter End Date");
    } else if (
      component.get("v.dateOptionSelected") != "Created Date" &&
      component.get("v.dateOptionSelected") != "Due Date" &&
      ((component.find("StartDateField").get("v.value") != null &&
        component.find("StartDateField").get("v.value") != "") ||
        (component.find("EndDateField").get("v.value") != null &&
          component.find("EndDateField").get("v.value") != ""))
    ) {
      alert("Please select the date type");
    } else if (
      (component.get("v.dateOptionSelected") == "Created Date" ||
        component.get("v.dateOptionSelected") == "Due Date") &&
      ((component.find("StartDateField").get("v.value") != null &&
        component.find("StartDateField").get("v.value") != "") ||
        (component.find("EndDateField").get("v.value") != null &&
          component.find("EndDateField").get("v.value") != "")) &&
      component.find("StartDateField").get("v.value") >
        component.find("EndDateField").get("v.value")
    ) {
      alert("Start date must be less than end date");
    } else {
      //component.set("v.showCreatedDateAscSorting", true);
      //component.set("v.showCreatedDateDescSorting", false);

      //component.set("v.showDueDateAscSorting", true);
      //component.set("v.showDueDateDescSorting", false);

      var startDate = component.get("v.startDate");
      var endDate = component.get("v.endDate");
      var taskListTemp = JSON.parse(component.get("v.taskListCopy"));

      var action = component.get("c.applyFilter");
      action.setParams({
        accountId: component.get("v.recordId"),
        startDate: component.get("v.startDate"),
        endDate: component.get("v.endDate"),
        dateFilter: component.get("v.dateOptionSelected"),
        selectedOwners: component.get("v.listSelectedOwners"),
        taskList: taskListTemp,
        strTaskStatus: component.get("v.strSelectedFilterTaskBy"),
        strRelatedTo: component.get("v.strRelatedTo")
      });
      component.set("v.boolSpinner", true);
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log("State applyFilterHelper-> " + state);
        if (state == "SUCCESS") {
          component.set("v.taskList", response.getReturnValue());
          component.set("v.taskListLength", component.get("v.taskList").length);
          console.log("task length" + component.get("v.taskListLength"));
          component.set("v.currentPageNumber", "");
          component.set("v.allData", "");
          component.set("v.totalPages", "");
          component.set("v.pageList", "");
          component.set("v.allData", component.get("v.taskList"));
          component.set("v.currentPageNumber", 1);
          component.set(
            "v.totalPages",
            Math.ceil(
              component.get("v.allData").length / component.get("v.pageSize")
            )
          );
          component.set("v.data", component.get("v.taskList"));
          var pageNumber = component.get("v.currentPageNumber");
          helper.buildData(component, helper);
          helper.resetAscendingDescending(component);
        } else if (state === "ERROR") {
          alert("Problem with connection. Please try again.");
        }
        component.set("v.boolSpinner", false);
      });
      $A.enqueueAction(action);
    }
  },

  //Called when any of the two sorting link is clicked.
  applySortingHelper: function (component, event, helper) {
    var action = component.get("c.applySorting");
    action.setParams({
      sortedDateOptionSelected: component.get("v.sortingOptionSelected"),
      taskList: component.get("v.taskList")
    });
    component.set("v.boolSpinner", true);
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("State applySortingHelper-> " + state);
      if (state == "SUCCESS") {
        component.set("v.sortedTaskList", response.getReturnValue());
        component.set("v.taskList", response.getReturnValue());

        component.set("v.currentPageNumber", "");
        component.set("v.allData", "");
        component.set("v.totalPages", "");
        component.set("v.pageList", "");
        component.set("v.allData", component.get("v.taskList"));
        component.set("v.currentPageNumber", 1);
        component.set(
          "v.totalPages",
          Math.ceil(
            component.get("v.allData").length / component.get("v.pageSize")
          )
        );
        component.set("v.data", component.get("v.taskList"));
        //  console.log('======totalPages========='+component.set("v.totalPages"));
        var pageNumber = component.get("v.currentPageNumber");
        helper.buildData(component, helper);
      } else if (state === "ERROR") {
        alert("Problem with connection. Please try again.");
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(action);
  },

  buildData: function (component, helper) {
    var data = [];
    var pageNumber = component.get("v.currentPageNumber");
    var pageSize = component.get("v.pageSize");
    var allData = component.get("v.allData");
    var x = (pageNumber - 1) * pageSize;
    //var x = (pageNumber-1)*(pageSize+1); // Prevent repetition of last record on next page

    //creating data-table data
    for (; x < pageNumber * pageSize; x++) {
      //Changed from x<= (pageNumber)
      if (allData[x]) {
        data.push(allData[x]);
      }
    }
    component.set("v.data", data);

    helper.generatePageList(component, pageNumber);
  },

  generatePageList: function (component, pageNumber) {
    console.log(
      "pageListLastElement-- " + component.get("v.pageListLastElement")
    );
    pageNumber = parseInt(pageNumber);
    //    component.set("v.pageList", "");
    var pageList = [];
    var totalPages = component.get("v.totalPages");

    if (totalPages > 1) {
      if (totalPages <= 7) {
        var counter = 2;
        for (; counter < totalPages; counter++) {
          pageList.push(counter);
        }
      } else {
        if (pageNumber < 5) {
          pageList.push(2, 3, 4, 5, 6);
        } else {
          if (pageNumber > totalPages - 5) {
            pageList.push(
              totalPages - 5,
              totalPages - 4,
              totalPages - 3,
              totalPages - 2,
              totalPages - 1
            );
          } else {
            pageList.push(
              pageNumber - 2,
              pageNumber - 1,
              pageNumber,
              pageNumber + 1,
              pageNumber + 2
            );
          }
        }
      }
    }
    component.set("v.pageList", pageList);
    component.set("v.pageListFirstElement", pageList[0]);
    component.set("v.pageListLastElement", pageList[pageList.length - 1]);
  },

  resetAscendingDescending: function (component) {
    component.set("v.showDueDateAscSorting", false);
    component.set("v.showCreatedDateAscSorting", false);
    component.set("v.showDueDateDescSorting", true);
    component.set("v.showCreatedDateDescSorting", true);
  },

  navigateToRecordHelper: function (strNavagiteToRecordId) {
    window.open("/" + strNavagiteToRecordId);
  },

  handleDownloadHelper: function (component) {
    if (
      component.get("v.taskList").length >
      parseInt($A.get("$Label.c.AD_MAX_RECORDS_IN_VF_TABLE"))
    ) {
      alert($A.get("$Label.c.AD_ROW_LIMIT_MESSAGE"));
    }
    var objcreateExcelAction = component.get("c.createExcel");
    objcreateExcelAction.setParams({
      lstTasks: component.get("v.taskList"),
      strAccountId: component.get("v.recordId")
    });

    objcreateExcelAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var url = "/apex/ADTaskExportToExcel?";
        url = url + "taskAttachmentId=" + response.getReturnValue();
        window.open(url);
      }
    });
    $A.enqueueAction(objcreateExcelAction);
  }
});
