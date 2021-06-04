({
  doInit: function (component, event, helper) {
    helper.SpendsList(component, event);
  },
  save: function (component, event, helper) {
    helper.saveRecordsList(component, event);
  },
  handleExit: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },
  handleTransSpendEvt: function (component, event, helper) {
    var params = event.getParams();
    var amt = params["amount"];
    helper.calcTotal(component, event, helper, amt);
  }
});
