({
  fireHighlightEvent: function (component, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = component.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },

  getMetaData: function (component, event, helper) {
    component.set("v.showLoadingSpinner", true);
    var action = component.get("c.getQuoteMetaData");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var wrapper = response.getReturnValue();
        console.log("metadata", wrapper);
        if (wrapper.statuses) {
          component.set("v.statuses", this.sortByLabel(wrapper.statuses));
        }
        if (wrapper.originMovementTypes) {
          component.set(
            "v.originMovementTypes",
            this.sortByLabel(wrapper.originMovementTypes)
          );
        }
        if (wrapper.destMovementTypes) {
          component.set(
            "v.destMovementTypes",
            this.sortByLabel(wrapper.destMovementTypes)
          );
        }
        if (wrapper.containerTypes) {
          component.set(
            "v.containerTypes",
            this.sortByLabel(wrapper.containerTypes)
          );
        }
        if (wrapper.commodities) {
          component.set("v.commodities", wrapper.commodities);
        }
        if (wrapper.vessals) {
          component.set("v.vessals", this.sortByLabel(wrapper.vessals));
        }
        component.set("v.showLoadingSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
            component.set("v.showLoadingSpinner", false);
          }
        } else {
          console.log("Unknown error");
        }
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(action);
  },

  getQuoteData: function (component, event, helper, offset, limit) {
    component.set("v.showLoadingSpinner", true);
    var filterObjectString = this.getFilterObjectString(
      component,
      event,
      helper
    );
    console.log("filterObjectString", filterObjectString);
    var paginationParamsString = this.getPaginationParamsString(
      component,
      event,
      helper,
      offset,
      limit
    );
    var searchListKeyword = component.get("v.searchKeyWord");
    console.log("paginationParamsString", paginationParamsString);
    var action = component.get("c.getQuoteListData");
    action.setParams({
      accountIds: null,
      filterObjectString: filterObjectString,
      paginationParamsString: paginationParamsString,
      searchListKeyword: searchListKeyword
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var data = response.getReturnValue();
        if (data && data.length > 0) {
          component.set("v.data", data);
          component.set("v.showNoResult", false);
        } else {
          component.set("v.showNoResult", true);
        }
        component.set("v.showLoadingSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
            component.set("v.showLoadingSpinner", false);
          }
        }
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(action);
  },

  fetchTotalQuotes: function (component, event, helper) {
    component.set("v.showLoadingSpinner", true);
    component.set("v.showNoResult", false);
    var filterObjectString = this.getFilterObjectString(
      component,
      event,
      helper
    );
    var searchListKeyword = component.get("v.searchKeyWord");
    var action = component.get("c.getTotalQuotes");
    action.setParams({
      accountIds: null,
      filterObjectString: filterObjectString,
      searchListKeyword: searchListKeyword
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var totalQuotes = response.getReturnValue();
        component.set("v.totalRange", totalQuotes);
        if (totalQuotes == 0) {
          component.set("v.showNoResult", true);
        } else {
          component.set("v.showNoResult", false);
        }
        var pagination1 = component.find("pagination1");
        if (pagination1) {
          pagination1.callDoInit();
        }
        var pagination2 = component.find("pagination2");
        if (pagination2) {
          pagination2.callDoInit();
        }
        component.set("v.showLoadingSpinner", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
            component.set("v.showLoadingSpinner", false);
          }
        } else {
          console.log("Unknown error");
        }
        component.set("v.showNoResult", true);
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(action);
  },

  getPaginationParamsString: function (
    component,
    event,
    helper,
    offset,
    limit
  ) {
    var paginationParams = {};
    if (offset != null) {
      paginationParams.offset = offset;
    } else {
      paginationParams.offset = component.get("v.startRange") - 1;
    }
    if (limit != null) {
      paginationParams.limit = limit;
    } else {
      paginationParams.limit = component.get("v.showRecords");
    }
    return JSON.stringify(paginationParams);
  },

  getFilterObjectString: function (component, event, helper) {
    var selected = component.find("tabs").get("v.selectedTabId");
    switch (selected) {
      case "all-quotes":
        component.set("v.statusSelected", "all");
        break;
      case "active":
        component.set("v.statusSelected", "Active");
        break;
      case "expired":
        component.set("v.statusSelected", "Expired");
        break;
      case "sent-to-pricing":
        component.set("v.statusSelected", "Sent to Pricing");
        break;
    }
    var filterObject = {};
    filterObject.selectedAccountId = component.get("v.selectedAccountId");
    filterObject.departureFromDate = component.get("v.departureFromDate");
    filterObject.departureToDate = component.get("v.departureToDate");
    filterObject.showChildAcc = component.get("v.showChildAcc");
    filterObject.statusSelected = component.get("v.statusSelected");
    filterObject.hazQuote = component.get("v.hazQuote");
    filterObject.comoditySelected = component.get("v.comoditySelected");
    filterObject.vessalSelected = component.get("v.vessalSelected");
    filterObject.selectedContractId = component.get("v.selectedContractId");
    filterObject.destinationLocationId = component.get(
      "v.destinationLocationId"
    );
    filterObject.originLocationId = component.get("v.originLocationId");
    filterObject.originMovementType = component.get("v.originMovementType");
    filterObject.destMovementType = component.get("v.destMovementType");
    filterObject.containerTypeSelected = component.get(
      "v.containerTypeSelected"
    );
    filterObject.contractInput = component.get("v.contractInput");

    return JSON.stringify(filterObject);
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
  },

  activeTab: function (component, event, helper) {
    var selected = component.get("v.tabId");
    component.find("tabs").set("v.selectedTabId", selected);
    var tab = event.getSource();
    switch (tab.get("v.id")) {
      case "all-quotes":
        component.set("v.statusSelected", "all");
        break;
      case "active":
        component.set("v.statusSelected", "Active");
        break;
      case "expired":
        component.set("v.statusSelected", "Expired");
        break;
      case "sent-to-pricing":
        component.set("v.statusSelected", "Sent to Pricing");
        break;
    }
    component.set("v.startRange", 1);
    component.set("v.showRecords", 10);
    this.fetchTotalQuotes(component, event, helper);
    this.getQuoteData(component, event, helper);
  },

  sortByLabel: function (data) {
    data.sort(function (a, b) {
      return a.label.localeCompare(b.label);
    });
    return data;
  }
});
