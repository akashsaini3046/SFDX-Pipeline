({
  fireSortEvent: function (component, event, helper) {
    var sortFieldName = event.target.value;
    var sortByList = component.get("v.sortByList");
    var sortFieldItem = sortByList.filter((item) => {
      if (item.value == sortFieldName) {
        return item;
      }
    });
    var eventParam = {};
    eventParam.sortFieldName = sortFieldName;
    eventParam.sortDirection = "asc";

    if (sortFieldItem) {
      var sortFieldLabel = sortFieldItem[0].label;
      eventParam.sortFieldLabel = sortFieldLabel;
    }
    var compEvent = component.getEvent("sortEvent");
    compEvent.setParams(eventParam);
    compEvent.fire();
  }
});
