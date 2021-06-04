({
  doInit: function (component, event, helper) {
    helper.setHighlightedTab(component, event, helper);
  },
  handleselect: function (component, event, helper) {
    var navService = component.find("navigationService");
    var selectedTabId = component.get("v.selectedTabId");
    var pageName = "";
    switch (selectedTabId) {
      case "find-a-route":
        pageName = "home";
        break;
      case "get-a-quote":
        pageName = "get-a-quote";
        break;
      default:
        pageName = "home";
        break;
    }
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: pageName
      }
    };
    navService.navigate(pageReference);
  }
});
