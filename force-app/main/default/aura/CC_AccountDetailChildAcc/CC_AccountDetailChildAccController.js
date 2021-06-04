({
  doInit: function (component, event, helper) {
    component.set("v.totalRange", component.get("v.numberOfChildAccounts"));
    helper.fetchChildMetadata(component, event, helper);
    helper.setSortByList(component, event, helper);
    helper.fetchTableJson(component, event, helper);
  },
  handlePagination: function (component, event, helper) {
    var params = event.getParams();
    helper.setTableJson(
      component,
      event,
      helper,
      params["limit"],
      params["offset"]
    );
  },
  handleSortBy: function (component, event, helper) {
    var params = event.getParams();
    component.set("v.sortByField", params["sortFieldName"]);
    component.set("v.sortByFieldLabel", params["sortFieldLabel"]);
    component.set("v.sortByDirection", params["sortDirection"]);
    var limit = component.get("v.showRecords");
    var offset = component.get("v.startRange") - 1;
    helper.setTableJson(component, event, helper, limit, offset);
  },
  handleFilters: function (component, event, helper) {
    component.set("v.tableData", '[""]');
    var params = event.getParams();
    var filters = {};
    for (var propName in params) {
      if (
        params[propName] &&
        params[propName] !== null &&
        params[propName] !== ""
      ) {
        if (propName == "selectedIdFromCustomInput") {
          filters["accountId"] = params[propName];
        } else {
          filters[propName] = params[propName];
        }
      }
    }
    component.set("v.filters", filters);
    component.set("v.startRange", 1);
    helper.fetchTotalChildAccounts(component, event, helper);
    var limit = component.get("v.showRecords");
    var offset = 0;
    helper.setTableJson(component, event, helper, limit, offset);
  },

  handleSearchList: function (component, event, helper) {
    var params = event.getParams();
    var searchKeyWord = params["searchKeyWord"];
    component.set("v.searchKeyWord", searchKeyWord);
    console.log("searchKeyWord", searchKeyWord);

    helper.fetchTotalChildAccounts(component, event, helper);
    var limit = component.get("v.showRecords");
    var offset = component.get("v.startRange") - 1;
    helper.setTableJson(component, event, helper, limit, offset);
  }
});
