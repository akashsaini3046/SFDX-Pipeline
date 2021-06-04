({
  updateEndRange: function (component, event, helper) {
    var totalRange = component.get("v.totalRange");
    var startRange = component.get("v.startRange");
    var showRecords = parseInt(component.get("v.showRecords"));
    console.log(totalRange, startRange, showRecords);
    if (totalRange < startRange + showRecords - 1) {
      component.set("v.endRange", totalRange);
    } else {
      component.set("v.endRange", startRange + showRecords - 1);
    }
  },

  firePaginationEvent: function (component, event, helper) {
    var startRange = component.get("v.startRange");
    var showRecords = parseInt(component.get("v.showRecords"));
    var compEvent = component.getEvent("paginationEvent");
    compEvent.setParams({
      limit: showRecords,
      offset: startRange - 1,
      startRange: startRange,
      showRecords: showRecords
    });
    compEvent.fire();
  }
});
