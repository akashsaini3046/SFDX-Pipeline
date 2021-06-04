({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event, helper);
    helper.fetchTotalAccts(component, event, helper);
    helper.fetchMetadata(component, event, helper);
    helper.setSortByList(component, event, helper);
    helper.fetchTableJson(component, event, helper);
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
  handleSortBy: function (component, event, helper) {
    var params = event.getParams();
    component.set("v.sortByField", params["sortFieldName"]);
    component.set("v.sortByFieldLabel", params["sortFieldLabel"]);
    component.set("v.sortByDirection", params["sortDirection"]);
    var limit = component.get("v.showRecords");
    var offset = component.get("v.startRange") - 1;
    helper.setTableJsonFilter(component, event, helper, limit, offset);
  },
  handlePagination: function (component, event, helper) {
    var params = event.getParams();
    helper.setTableJsonFilter(
      component,
      event,
      helper,
      params["limit"],
      params["offset"]
    );
  },
  handleUseFilter: function (component, event, helper) {
    if (!component.get("v.showFilters")) {
      component.set("v.filterButtonLabel", "Hide Filter(s)");
    } else {
      component.set("v.filterButtonLabel", "Use Filter(s)");
    }
    component.set("v.showFilters", !component.get("v.showFilters"));
  },
  handleFilters: function (component, event, helper) {
    var params = event.getParams();
    var filters = {};
    for (var propName in params) {
      if (
        params[propName] &&
        params[propName] !== null &&
        params[propName] !== "" &&
        propName !== "searchAccountName" &&
        propName !== "searchparentAccountName"
      ) {
        filters[propName] = params[propName];
      }
      var atrbt = "v." + propName;
    }
    component.set("v.filters", filters);
    helper.fetchTotalAccts(component, event, helper);
    component.set("v.startRange", 1);
    var limit = component.get("v.showRecords");
    var offset = 0;
    helper.setTableJsonFilter(component, event, helper, limit, offset);
  }
});
