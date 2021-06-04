({
  getAllTasks: function (component, event, helper) {
    var lstFilterTaskStatusByOptions = [
      {
        label: $A.get("$Label.c.AD_TASK_STATUS_ALL"),
        value: $A.get("$Label.c.AD_TASK_STATUS_ALL")
      },
      {
        label: $A.get("$Label.c.AD_TASK_STATUS_OPEN"),
        value: $A.get("$Label.c.AD_TASK_STATUS_OPEN")
      },
      {
        label: $A.get("$Label.c.AD_TASK_STATUS_COMPLETED"),
        value: $A.get("$Label.c.AD_TASK_STATUS_COMPLETED")
      },
      {
        label: $A.get("$Label.c.AD_TASK_STATUS_OVERDUE"),
        value: $A.get("$Label.c.AD_TASK_STATUS_OVERDUE")
      }
    ];
    component.set(
      "v.lstFilterTaskStatusByOptions",
      lstFilterTaskStatusByOptions
    );
    component.set(
      "v.lstDefaultFilterTaskStatusByOptions",
      $A.get("$Label.c.AD_TASK_STATUS_ALL")
    );

    var objMasterFilter = {
      strSelectedYear: component.get("v.strCurrentYear")
    };
    //Set the selected year as the current year if the user has not changed any year in the master filter component
    component.set("v.strSelectedYear", component.get("v.strCurrentYear"));
    helper.fetchAllTasks(component, objMasterFilter);
  },

  handleViewAllTaskClick: function (component, event, helper) {
    helper.createAllTaskComponent(component, event, helper);
  },

  handleMasterFilterEvent: function (component, event, helper) {
    var mapMasterEventParams = event.getParam("mapMasterEventParams");
    var objMasterFilter = {
      lstSelectedAccounts: mapMasterEventParams.lstSelectedAccounts,
      lstSelectedOwners: mapMasterEventParams.lstSelectedOwners,
      strSelectedTopFilter: mapMasterEventParams.strSelectedTopFilter,
      strSelectedOppSizeFilterOperator:
        mapMasterEventParams.strSelectedOppSizeFilterOperator,
      strOppSizeVal: mapMasterEventParams.strOppSizeVal,
      strSelectedYear: mapMasterEventParams.strSelectedYear
    };
    //Set the selected year as the year selected in the master filter component
    component.set("v.strSelectedYear", mapMasterEventParams.strSelectedYear);

    helper.fetchAllTasks(component, objMasterFilter);
  }
});
