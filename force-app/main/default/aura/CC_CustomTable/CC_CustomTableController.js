({
  doInit: function (component, event, helper) {
    component.set("v.showLoadingSpinner", true);
    var tableJson = component.get("v.tableJson");
    if (tableJson && tableJson != "") {
      helper.fetchData(component, event, helper);
    }
  },
  viewdetail: function (component, event, helper) {
    var navService = component.find("navigationService");
    var redirectUrl = event.currentTarget.id;
    var selectedItemID = redirectUrl.substring(
      redirectUrl.lastIndexOf("/") + 1,
      redirectUrl.length
    );
    var redirectPageName = redirectUrl.substring(
      redirectUrl.indexOf("/") + 1,
      redirectUrl.length
    );
    redirectPageName = redirectPageName.substring(
      0,
      redirectPageName.indexOf("/")
    );
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: redirectPageName
      },
      state: {
        id: selectedItemID
      }
    };
    navService.navigate(pageReference);
    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: redirectPageName,
      selectedItemID: selectedItemID,
      functionality: "RefreshTheComponent"
    });
    compEvent.fire();
  }
  /*changeOrder: function (component, event, helper) {
        helper.handleChangeOrder(component, event, helper);
    }*/
});
