({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event);
    helper.HomeScreenView(component);
  },
  changeHomeScreen: function (component, event, helper) {
    var compName = event.getParam("HomeScreenComponent");
    component.set("v.DisplayComponent", compName);
    helper.HomeScreenView(component);
  }
});
