({
  handleBlur: function (component, event, helper) {
    var compEvent = component.getEvent("transSpendEvt");
    var amt = component.find("amountId").get("v.value");
    amt = parseInt(amt);
    if (Number.isNaN(amt)) {
      alert("Please enter numeric value, this field can not be left blank.");
      component.find("amountId").set("v.value", 0);
    }
    compEvent.setParams({
      amount: component.find("amountId").get("v.value")
    });
    compEvent.fire();
  },

  handleInputType: function (component, event, helper) {
    var amountVal = component.find("amountId");
  }
});
