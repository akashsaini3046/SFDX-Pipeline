({
  doInit: function (component, event, helper) {
    var routeRecord = component.get("v.routeRecord");
    helper.setInitValues(component, event, helper, routeRecord);
  }
});
