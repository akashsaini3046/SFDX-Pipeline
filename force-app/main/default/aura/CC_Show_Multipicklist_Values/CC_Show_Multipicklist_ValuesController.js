({
  doInit: function (component, event, helper) {
    var values = component.get("v.values");
    console.log(values);
    var displayValues = [];
    if (values && values != "") {
      displayValues = values.split(";");
      if (displayValues && displayValues.length > 0) {
        component.set("v.displayValues", displayValues);
      }
    } else {
      component.set("v.displayValues", null);
    }
  }
});
