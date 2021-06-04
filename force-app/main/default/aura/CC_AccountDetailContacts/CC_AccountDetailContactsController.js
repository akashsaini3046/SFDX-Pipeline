({
  doInit: function (component, event, helper) {
    helper.fetchTotalContacts(component, event, helper, true);
    helper.fetchTableJson(component, event, helper);
    helper.setSortByList(component, event, helper);
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

  handleSearchList: function (component, event, helper) {
    component.set("v.tableData", '[""]');
    var params = event.getParams();
    var searchKeyWord = params["searchKeyWord"];
    component.set("v.searchKeyWord", searchKeyWord);
    console.log("searchKeyWord", searchKeyWord);
    component.set("v.startRange", 1);
    helper.fetchTotalContacts(component, event, helper, false);
    var limit = component.get("v.showRecords");
    var offset = 0;
    helper.setTableJson(component, event, helper, limit, offset);
  },
  handleValueChange: function (component, event, helper) {
    console.log("Hello", component.get("v.tableData"));
  }
});
