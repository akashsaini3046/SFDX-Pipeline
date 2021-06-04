({
  fetchActualAndNormalisedRevenue: function (component, objMasterFilter) {
    var action = component.get("c.getActualAndNormalisedRevenue");
    action.setParams({
      accountId: component.get("v.recordId"),
      objMasterFilter: objMasterFilter
    });

    // Register the callback function
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.actualAndNormalisedRevObj", response.getReturnValue());
      }
    });
    $A.enqueueAction(action);
  }
});
