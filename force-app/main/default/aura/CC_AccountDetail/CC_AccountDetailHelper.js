({
  fireHighlightEvent: function (component, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = component.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },
  getURLParameter: function (key) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1));
    var sURLVariables = sPageURL.split("&");
    var sParameterName;
    var i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");
      if (sParameterName[0] == key) {
        return sParameterName[1];
      }
    }
    return "";
  },
  setDefaultValues: function (component, event, helper) {
    component.set("v.teamMembersText", "Show All");
    component.set("v.displayTeamMembers", false);
    component.set("v.isParentAccount", true);
    component.set("v.hasChildAccounts", true);
    component.set("v.showChildAccounts", false);
    component.set("v.isContactTab", false);
    component.set("v.isQuoteTab", false);
    component.set("v.isBookingTab", false);
    component.set("v.isBolTab", false);
    component.set("v.isContractTab", false);
    component.set("v.isChildAccountTab", true);
    component.set("v.showChildAccountTab", true);
    component.set("v.selectedTabId", "ChildAccounts");
  },
  getAccount: function (component, event, helper) {
    var action = component.get("c.getAccountRecord");
    var accId = component.get("v.recordId");
    action.setParams({
      accountId: accId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        console.log("res", res);
        component.set("v.account", res.account);
        if (res.accountTeamMembers && res.accountTeamMembers.length > 0) {
          component.set("v.teamMembers", res.accountTeamMembers);
          component.set("v.teamMembersText", "Show All");
        } else {
          component.set("v.teamMembers", res.accountTeamMembers);
          component.set("v.teamMembersText", "");
        }
        if (res.childAccounts && res.childAccounts.length > 0) {
          component.set("v.hasChildAccounts", true);
          component.set("v.numberOfChildAccounts", res.childAccounts.length);
          component.set("v.childAccounts", res.childAccounts);
        } else {
          component.set("v.hasChildAccounts", false);
        }
        if (typeof res.isParent !== "undefined") {
          component.set("v.isParentAccount", res.isParent);
          if (!res.isParent) {
            component.set("v.selectedTabId", "Contacts");
            component.set("v.showChildAccountTab", false);
            this.handleActiveTab(component, event, helper, "Contacts");
          } else {
            component.set("v.selectedTabId", "ChildAccounts");
            this.handleActiveTab(component, event, helper, "ChildAccounts");
          }
        }
        if (
          typeof res.searchFieldSetChildAcc !== "undefined" &&
          res.searchFieldSetChildAcc.length > 0
        ) {
          component.set("v.searchFieldSetChildAcc", res.searchFieldSetChildAcc);
        }
        if (
          typeof res.searchFieldSetContracts !== "undefined" &&
          res.searchFieldSetContracts.length > 0
        ) {
          component.set(
            "v.searchFieldSetContracts",
            res.searchFieldSetContracts
          );
        }
        if (
          typeof res.searchFieldSetContacts !== "undefined" &&
          res.searchFieldSetContacts.length > 0
        ) {
          component.set("v.searchFieldSetContacts", res.searchFieldSetContacts);
        }
        if (
          typeof res.searchFieldSetBookings !== "undefined" &&
          res.searchFieldSetBookings.length > 0
        ) {
          component.set("v.searchFieldSetBookings", res.searchFieldSetBookings);
        }
        if (
          typeof res.searchFieldSetQuotes !== "undefined" &&
          res.searchFieldSetQuotes.length > 0
        ) {
          component.set("v.searchFieldSetQuotes", res.searchFieldSetQuotes);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast(
              "error",
              "Error!",
              "Something went wrong. Please try again."
            );
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  handleActiveTab: function (component, event, helper, tab) {
    component.set("v.selectedTab", tab);
    component.set("v.isContactTab", false);
    component.set("v.isQuoteTab", false);
    component.set("v.isBookingTab", false);
    component.set("v.isBolTab", false);
    component.set("v.isContractTab", false);
    component.set("v.isChildAccountTab", false);
    switch (tab) {
      case "ChildAccounts":
        component.set("v.isChildAccountTab", true);
        break;
      case "Contacts":
        component.set("v.isContactTab", true);
        break;
      case "Quotes":
        component.set("v.isQuoteTab", true);
        break;
      case "Contracts":
        component.set("v.isContractTab", true);
        break;
      case "Bookings":
        component.set("v.isBookingTab", true);
        break;
      case "Bill Of Lading":
        component.set("v.isBolTab", true);
        break;
    }
  },

  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: "sticky",
      type: type,
      title: title,
      message: message
    });
    toastEvent.fire();
  }
});
