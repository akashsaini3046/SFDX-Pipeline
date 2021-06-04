({
  getTasks: function (component, event, helper) {
    component.set("v.taskList", component.get("v.taskControllerObj.taskList"));
    component.set(
      "v.taskListCopy",
      JSON.stringify(component.get("v.taskList"))
    );
    component.set(
      "v.ownerIdList",
      component.get("v.taskControllerObj.ownerIdList")
    );
    component.set("v.taskListLength", component.get("v.taskList").length);
    component.set("v.allData", component.get("v.taskControllerObj.taskList"));
    component.set("v.currentPageNumber", 1);
    component.set(
      "v.totalPages",
      Math.ceil(
        component.get("v.taskList").length / component.get("v.pageSize")
      )
    );

    //Populate start date and end date on component load
    if (
      component.get("v.strSelectedYear") !=
      $A.get("$Label.c.AD_PICKLIST_VAL_ALL_YEAR")
    ) {
      var startDate = new Date();
      var endDate = new Date();

      //Select Due Date by default on component load
      component.set("v.dateOptionSelected", "Created Date");

      startDate = component.get("v.strSelectedYear") + "-01-01";
      component.set("v.startDate", startDate);

      endDate = component.get("v.strSelectedYear") + "-12-31";
      component.set("v.endDate", endDate);
    }

    helper.buildData(component, helper);
  },

  handleSortByCreatedDateAsc: function (component, event, helper) {
    component.set("v.sortingOptionSelected", "Created Date Asc");
    component.set("v.showCreatedDateAscSorting", true);
    component.set("v.showCreatedDateDescSorting", false);
    helper.applySortingHelper(component, event, helper);
  },

  handleSortByCreatedDateDesc: function (component, event, helper) {
    component.set("v.sortingOptionSelected", "Created Date Desc");
    component.set("v.showCreatedDateAscSorting", false);
    component.set("v.showCreatedDateDescSorting", true);
    helper.applySortingHelper(component, event, helper);
  },

  handleSortByDueDateAsc: function (component, event, helper) {
    component.set("v.sortingOptionSelected", "Due Date Asc");
    component.set("v.showDueDateAscSorting", true);
    component.set("v.showDueDateDescSorting", false);
    helper.applySortingHelper(component, event, helper);
  },

  handleSortByDueDateDesc: function (component, event, helper) {
    component.set("v.sortingOptionSelected", "Due Date Desc");
    component.set("v.showDueDateAscSorting", false);
    component.set("v.showDueDateDescSorting", true);
    helper.applySortingHelper(component, event, helper);
  },

  /* handleDateOptionsChange : function(component, event, helper) {
        var selected = event.getSource().get('v.text');
        component.set("v.dateOptionSelected", selected);
        console.log('SELECTED DATE'+ component.get("v.dateOptionSelected"));
    },
    */
  //When a user is added in the multi select lookup component
  getSelectedOwners: function (component, event, helper) {
    var listSelectedItems = component.get("v.listSelectedOwners");
    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
    listSelectedItems.push(selectedAccountGetFromEvent);
    component.set("v.listSelectedOwners", listSelectedItems);
  },

  //When a user is removed from the multi select lookup component
  handleSelectedOwnersEvent: function (component, event, helper) {
    var selectedOwnersFromEvent = event.getParam("selectedUserRecords");
    component.set("v.listSelectedOwners", selectedOwnersFromEvent);
  },

  handleFilterApplyClick: function (component, event, helper) {
    helper.applyFilterHelper(component, event, helper);
  },

  handleResetClick: function (component, event, helper) {
    component.set("v.startDate", null);
    component.set("v.endDate", null);
    component.set("v.dateOptionSelected", "null");

    //To remove all the selected users
    var reusableMultiSelectLookupComp = component.find(
      "reusableMultiSelectLookupComp"
    );
    reusableMultiSelectLookupComp.clearSelectedUsers();

    //To empty the selected Assigned To users. 'listSelectedOwners' variable was used to store the selected users
    component.set("v.listSelectedOwners", []);

    //Reset Task status filter
    component.set(
      "v.strSelectedFilterTaskBy",
      $A.get("$Label.c.AD_TASK_STATUS_ALL")
    );

    //Reset Task related to filter
    component.set("v.strRelatedTo", "");

    //After the above variables are set, again there will be a server call to fetch the results
    helper.applyFilterHelper(component, event, helper);

    helper.resetAscendingDescending(component);
  },

  onNext: function (component, event, helper) {
    var pageNumber = component.get("v.currentPageNumber");
    component.set("v.currentPageNumber", pageNumber + 1);
    helper.buildData(component, helper);
  },

  onPrev: function (component, event, helper) {
    var pageNumber = component.get("v.currentPageNumber");
    component.set("v.currentPageNumber", pageNumber - 1);
    helper.buildData(component, helper);
  },

  processMe: function (component, event, helper) {
    component.set("v.currentPageNumber", parseInt(event.target.name));
    helper.buildData(component, helper);
  },

  onFirst: function (component, event, helper) {
    component.set("v.currentPageNumber", 1);
    helper.buildData(component, helper);
  },

  onLast: function (component, event, helper) {
    component.set("v.currentPageNumber", component.get("v.totalPages"));
    helper.buildData(component, helper);
  },

  handleModalBoxCloseClick: function (component, event, helper) {
    component.set("v.boolShowAllTaskModal", false);
  },

  navigateToRecordClick: function (component, event, helper) {
    helper.navigateToRecordHelper(event.currentTarget.id);
  },

  handleDownloadClick: function (component, event, helper) {
    helper.handleDownloadHelper(component);
  }
});
