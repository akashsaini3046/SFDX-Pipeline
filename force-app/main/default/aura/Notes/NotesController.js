({
  getAllNotes: function (component, event, helper) {
    var objMasterFilter = {
      strSelectedYear: component.get("v.strCurrentYear")
    };
    component.set("v.strSelectedYear", component.get("v.strCurrentYear"));
    helper.fetchAllNotes(component, objMasterFilter);
  },

  displayAllNotes: function (component, event, helper) {
    helper.createAllNotesComponent(component, event, helper);
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

    helper.fetchAllNotes(component, objMasterFilter);
  }
});
