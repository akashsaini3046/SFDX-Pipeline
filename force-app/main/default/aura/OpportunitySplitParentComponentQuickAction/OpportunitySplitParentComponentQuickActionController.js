({
  doInit: function (component, event, helper) {
    component.set("v.strRecordId", component.get("v.recordId"));
    helper.getUITheme(component);
  }
});
