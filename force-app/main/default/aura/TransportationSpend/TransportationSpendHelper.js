({
  saveRecordsList: function (component, event, helper) {
    var action = component.get("c.saveSpends");
    action.setParams({
      spendsWToInsert: component.get("v.spendsList")
    });
    //var validity = component.find("amountId").get("v.validity");
    //console.log(validity.valid);
    action.setCallback(this, function (response) {
      if (
        component.isValid() &&
        response !== null &&
        response.getState() == "SUCCESS"
      ) {
        console.log("Spend records saved successfully");
      } else {
        console.log("Save not successful.");
      }
      $A.get("e.force:closeQuickAction").fire();
      $A.get("e.force:refreshView").fire();
    });
    $A.enqueueAction(action);
  },

  SpendsList: function (component, event, helper) {
    var getSpendAction = component.get("c.getTransportationSpends");
    getSpendAction.setParams({
      accountId: component.get("v.recordId")
    });
    getSpendAction.setCallback(this, function (response) {
      if (
        component.isValid() &&
        response !== null &&
        response.getState() == "SUCCESS"
      ) {
        var data = response.getReturnValue();
        component.set("v.spendsList", data);
        var totalAmount = 0;
        if (data && data.length > 0) {
          data.map((item) => {
            totalAmount += item.amount;
          });
        }
        component.set("v.totalAmount", totalAmount);
        console.log("Transportation Setting loaded.");
      } else {
        console.log("Failed to load Transportation Setting.");
      }
    });
    $A.enqueueAction(getSpendAction);
  },

  calcTotal: function (component, event, helper, amount) {
    var totalAmount = 0;
    var data = component.get("v.spendsList");
    if (data && data.length > 0) {
      data.map((item) => {
        var amt = parseInt(item.amount);
        if (!Number.isNaN(amt) && amt != "") {
          totalAmount += amt;
        }
      });
    }
    component.set("v.totalAmount", totalAmount);
  }
});
