({
  doInit: function (component, event, helper) {
    helper.getCommunityName(component);
    helper.highlightListItems(component, event);
    var selectedTab = decodeURIComponent(window.location.search.substring(1));
    component.set("v.selectedSequence", selectedTab);
  },
  changeHighlightSection: function (component, event, helper) {
    helper.highlightListItems(component, event);
  },
  handleselect: function (component, event, helper) {
    var navService = component.find("navigationService");
    var selectedTab = parseInt(component.get("v.selectedTabId"));
    var listItems = component.get("v.listitems");
    var pageName = null;

    for (var index = 0; index < listItems.length; index++) {
      if (selectedTab == listItems[index].Sequence__c) {
        pageName = listItems[index].DeveloperName.toLowerCase();
        break;
      }
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
