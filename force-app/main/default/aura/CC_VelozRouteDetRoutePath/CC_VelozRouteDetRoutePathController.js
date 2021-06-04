({
  doInit: function (component, event, helper) {
    var routeRecord = component.get("v.routeRecord");
    helper.setValues(component, event, helper, routeRecord);
  }
});
