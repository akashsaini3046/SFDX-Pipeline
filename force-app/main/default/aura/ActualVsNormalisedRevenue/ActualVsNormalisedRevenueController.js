({
  getActualAndNormalisedRevenueFunc: function (component, event, helper) {
    //   helper.fetchActualAndNormalisedRevenue(component, event, helper);
    var objMasterFilter = {
      strSelectedYear: component.get("v.strCurrentYear")
    };
    helper.fetchActualAndNormalisedRevenue(component, objMasterFilter);
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
    helper.fetchActualAndNormalisedRevenue(component, objMasterFilter);
  }
});
