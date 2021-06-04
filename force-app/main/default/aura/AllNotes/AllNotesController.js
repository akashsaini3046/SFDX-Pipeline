({
  getNotes: function (component, event, helper) {
    component.set(
      "v.notesList",
      component.get("v.notesControllerObj.notesList")
    );
    component.set(
      "v.notesListCopy",
      JSON.stringify(component.get("v.notesList"))
    );
    component.set(
      "v.ownerIdList",
      component.get("v.notesControllerObj.ownerIdList")
    );
    component.set("v.notesListLength", component.get("v.notesList").length);
    component.set("v.allData", component.get("v.notesControllerObj.notesList"));
    component.set("v.currentPageNumber", 1);
    component.set(
      "v.totalPages",
      Math.ceil(
        component.get("v.notesList").length / component.get("v.pageSize")
      )
    );

    //Populate start date and end date on component load
    if (
      component.get("v.strSelectedYear") !=
      $A.get("$Label.c.AD_PICKLIST_VAL_ALL_YEAR")
    ) {
      var startDate = new Date();
      var endDate = new Date();

      startDate = component.get("v.strSelectedYear") + "-01-01";
      component.set("v.startDate", startDate);

      endDate = component.get("v.strSelectedYear") + "-12-31";
      component.set("v.endDate", endDate);
    }

    helper.buildData(component, helper);
  },

  handleSortByCreatedDateAsc: function (component, event, helper) {
    component.set("v.sortingOptionSelected", "Created Date Asc");
    component.set("v.showCreatedDateAscSorting", false);
    component.set("v.showCreatedDateDescSorting", true);
    helper.applySortingHelper(component, event, helper);
  },

  handleSortByCreatedDateDesc: function (component, event, helper) {
    component.set("v.sortingOptionSelected", "Created Date Desc");
    component.set("v.showCreatedDateAscSorting", true);
    component.set("v.showCreatedDateDescSorting", false);
    helper.applySortingHelper(component, event, helper);
  },

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
    var reusableMultiSelectLookupComp = component.find(
      "reusableMultiSelectLookupComp"
    );
    reusableMultiSelectLookupComp.clearSelectedUsers();

    //To empty the selected Assigned To users. 'listSelectedOwners' variable was used to store the selected users
    component.set("v.listSelectedOwners", []);

    //After the above variables are set, again there will be a server call to fetch the results
    helper.applyFilterHelper(component, event, helper);
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
    component.set("v.boolShowAllNotesModal", false);
  }
});
