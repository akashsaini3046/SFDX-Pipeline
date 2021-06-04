({
  //Called when Apply button is clicked. Based on the dates and users selected, notes list is displayed
  applyFilterHelper: function (component, event, helper) {
    if (
      (component.find("StartDateField").get("v.value") == null ||
        component.find("StartDateField").get("v.value") == "") &&
      component.find("EndDateField").get("v.value") != null &&
      component.find("EndDateField").get("v.value") != ""
    ) {
      alert("Please enter Start Date");
    } else if (
      (component.find("EndDateField").get("v.value") == null ||
        component.find("EndDateField").get("v.value") == "") &&
      component.find("StartDateField").get("v.value") != null &&
      component.find("StartDateField").get("v.value") != ""
    ) {
      alert("Please enter End Date");
    } else if (
      ((component.find("StartDateField").get("v.value") != null &&
        component.find("StartDateField").get("v.value") != "") ||
        (component.find("EndDateField").get("v.value") != null &&
          component.find("EndDateField").get("v.value") != "")) &&
      component.find("StartDateField").get("v.value") >
        component.find("EndDateField").get("v.value")
    ) {
      alert("Start date must be less than end date");
    } else {
      console.log(
        "INSIDE ELSE START" +
          component.get("v.startDate") +
          "--" +
          component.find("StartDateField").get("v.value")
      );
      console.log(
        "INSIDE ELSE END" +
          component.get("v.endDate") +
          "--" +
          component.find("EndDateField").get("v.value")
      );
      component.set("v.showCreatedDateAscSorting", true);
      component.set("v.showCreatedDateDescSorting", false);
      component.set("v.showDueDateAscSorting", true);
      component.set("v.showDueDateDescSorting", false);

      var startDate = component.get("v.startDate");
      var endDate = component.get("v.endDate");
      var notesListTemp = JSON.parse(component.get("v.notesListCopy"));

      var action = component.get("c.applyFilter");
      action.setParams({
        accountId: component.get("v.recordId"),
        startDate: component.get("v.startDate"),
        endDate: component.get("v.endDate"),
        //  "dateFilter" : "Created Date",
        selectedOwners: component.get("v.listSelectedOwners"),
        notesList: notesListTemp
      });
      component.set("v.boolSpinner", true);
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state == "SUCCESS") {
          component.set("v.notesList", response.getReturnValue());
          component.set(
            "v.notesListLength",
            component.get("v.notesList").length
          );
          component.set("v.currentPageNumber", "");
          component.set("v.allData", "");
          component.set("v.totalPages", "");
          component.set("v.pageList", "");
          component.set("v.allData", component.get("v.notesList"));
          component.set("v.currentPageNumber", 1);
          component.set(
            "v.totalPages",
            Math.ceil(
              component.get("v.allData").length / component.get("v.pageSize")
            )
          );
          component.set("v.data", component.get("v.notesList"));
          var pageNumber = component.get("v.currentPageNumber");

          helper.buildData(component, helper);
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
      notesList: component.get("v.notesList"),
      sortedDateOptionSelected: component.get("v.sortingOptionSelected")
    });
    component.set("v.boolSpinner", true);
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.sortednotesList", response.getReturnValue());
        component.set("v.notesList", response.getReturnValue());

        component.set("v.currentPageNumber", "");
        component.set("v.allData", "");
        component.set("v.totalPages", "");
        component.set("v.pageList", "");
        component.set("v.allData", component.get("v.notesList"));
        component.set("v.currentPageNumber", 1);
        component.set(
          "v.totalPages",
          Math.ceil(
            component.get("v.allData").length / component.get("v.pageSize")
          )
        );
        component.set("v.data", component.get("v.notesList"));
        var pageNumber = component.get("v.currentPageNumber");

        helper.buildData(component, helper);
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
    pageNumber = parseInt(pageNumber);
    component.set("v.pageList", "");
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
  }
});
