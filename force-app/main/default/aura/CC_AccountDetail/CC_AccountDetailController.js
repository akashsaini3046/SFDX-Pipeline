({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event, helper);
    var idAccount = helper.getURLParameter("id");
    component.set("v.recordId", idAccount);
    helper.getAccount(component, event, helper);
  },
  handleSearchEvent: function (component, event, helper) {
    var selectedObjLabel = event.getParam("selectedObjLabel");
    if (selectedObjLabel == "Accounts") {
      var selectedItemId = event.getParam("selectedItemId");
      component.set("v.recordId", selectedItemId);
      helper.getAccount(component, event, helper);
    }
  },

  handleselect: function (component, event, helper) {
    var selectedTab = component.get("v.selectedTabId");
    helper.handleActiveTab(component, event, helper, selectedTab);
  },

  showChildAccountsData: function (component, event, helper) {
    var tabset = component.find("accountTabSet");
    helper.handleActiveTab(
      component,
      event,
      helper,
      tabset.get("v.selectedTabId")
    );
  },

  showTeamMembers: function (component, event, helper) {
    if (!component.get("v.displayTeamMembers")) {
      component.set("v.teamMembersText", "Hide All");
      component.set("v.displayTeamMembers", true);
    } else {
      component.set("v.teamMembersText", "Show All");
      component.set("v.displayTeamMembers", false);
    }
  },

  closeTeamMembers: function (component, event, helper) {
    component.set("v.teamMembersText", "Show All");
    component.set("v.displayTeamMembers", false);
  },

  navigateToAccount: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "accounts"
      }
    };
    navService.navigate(pageReference);
  },
  navigateToRecord: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idAccount = component.get("v.recordId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "accountDetail"
      },
      state: {
        id: idAccount
      }
    };
    navService.navigate(pageReference);
    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: "accountDetail",
      selectedItemID: idAccount,
      functionality: "RefreshTheComponent"
    });
    compEvent.fire();
  },
  navigateToHome: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  },
  navigateToParentRecord: function (component, event, helper) {
    var navService = component.find("navigationService");
    var account = component.get("v.account");
    var parentAccountId = account.ParentId;
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "accountDetail"
      },
      state: {
        id: parentAccountId
      }
    };
    navService.navigate(pageReference);
    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: "accountDetail",
      selectedItemID: parentAccountId,
      functionality: "RefreshTheComponent"
    });
    compEvent.fire();
  },
  handleRefreshCmp: function (component, event, helper) {
    var selectedItem = event.getParams()["selectedItem"];
    var selectedId = event.getParams()["selectedItemID"];
    var functionality = event.getParams()["functionality"];
    if (
      selectedId &&
      functionality &&
      functionality == "RefreshTheComponent" &&
      selectedItem.includes("accountDetail")
    ) {
      component.set("v.recordId", selectedId);
      helper.setDefaultValues(component, event, helper);
      helper.getAccount(component, event, helper);
    }
  }
});
