({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event);
    helper.HomeScreenView(component);
  },
  changeHomeScreen: function (component, event, helper) {
    var compName = event.getParam("HomeScreenComponent");
    component.set("v.DisplayComponent", compName);
    helper.HomeScreenView(component);
  },
  navigateToPage: function (component, event, helper) {
    var page = event.getSource().getLocalId();
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: page
      }
    };
    navService.navigate(pageReference);
  }
});
