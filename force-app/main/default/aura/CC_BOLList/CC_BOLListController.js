({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event, helper);
    helper.getBolData(component, event, helper);
    helper.fetchTotalBols(component, event, helper);
  },
  navigateToHome: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  },
  handlePaginationEvent: function (component, event, helper) {
    var params = event.getParams();
    component.set("v.startRange", params["startRange"]);
    component.set("v.showRecords", params["showRecords"]);
    helper.getBolData(
      component,
      event,
      helper,
      params["offset"],
      params["limit"]
    );
  },
  handleBOLSearchList: function (component, event, helper) {
    var params = event.getParams();
    var searchKeyWord = params["searchKeyWord"];
    component.set("v.searchKeyWord", searchKeyWord);
    console.log(searchKeyWord);
    helper.getBolData(component, event, helper);
    helper.fetchTotalBols(component, event, helper);
  },
  handleBOLFilterList: function (component, event, helper) {
    var params = event.getParams();
    component.set("v.selectedAccountId", params["selectedAccountId"]);
    component.set("v.selectBookingNumber", params["selectedBookingId"]);
    component.set("v.selectedLocationId", params["selectedLocationId"]);
    component.set("v.selectedSailBetweenFrom", params["selectedSailDateFrom"]);
    component.set("v.selectedSailBetweenTo", params["selectedSailDateTo"]);
    helper.getBolData(component, event, helper);
    helper.fetchTotalBols(component, event, helper);
  },
  handleActiveTab: function (component, event, helper) {
    helper.activeTab(component, event, helper);
  }
});
