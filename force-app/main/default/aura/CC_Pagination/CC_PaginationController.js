({
  doInit: function (component, event, helper) {
    helper.updateEndRange(component, event, helper);
  },

  handleNext: function (component, event, helper) {
    var startRange = component.get("v.startRange");
    var showRecords = parseInt(component.get("v.showRecords"));
    component.set("v.startRange", startRange + showRecords);
    helper.updateEndRange(component, event, helper);
    helper.firePaginationEvent(component, event, helper);
  },

  handlePrevious: function (component, event, helper) {
    var startRange = component.get("v.startRange");
    var showRecords = parseInt(component.get("v.showRecords"));
    if (startRange - showRecords < 1) {
      component.set("v.startRange", 1);
    } else {
      component.set("v.startRange", startRange - showRecords);
    }
    helper.updateEndRange(component, event, helper);
    helper.firePaginationEvent(component, event, helper);
  },

  handleShowRecords: function (component, event, helper) {
    helper.updateEndRange(component, event, helper);
    helper.firePaginationEvent(component, event, helper);
  }
});
