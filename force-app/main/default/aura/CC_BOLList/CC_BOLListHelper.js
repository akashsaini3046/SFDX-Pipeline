({
  getBolData: function (component, event, helper, offset, limit) {
    component.set("v.showLoadingSpinner", true);
    var filterObjectString = this.getFilterObjectString(
      component,
      event,
      helper
    );
    var paginationParamsString = this.getPaginationParamsString(
      component,
      event,
      helper,
      offset,
      limit
    );
    var searchListKeyword = component.get("v.searchKeyWord");
    var action = component.get("c.getBolListData");
    action.setParams({
      filterObjectString: filterObjectString,
      paginationParamsString: paginationParamsString,
      searchListKeyword: searchListKeyword
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data) {
          component.set("v.data", data);
        } else {
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            //helper.showToast('error', 'Error!', errors[0].message);
          }
        }
      }
      component.set("v.showLoadingSpinner", false);
    });
    $A.enqueueAction(action);
  },
  fetchTotalBols: function (component, event, helper, offset, limit) {
    component.set("v.showLoadingSpinner", true);
    component.set("v.showNoResult", false);
    var filterObjectString = this.getFilterObjectString(
      component,
      event,
      helper
    );
    var paginationParamsString = this.getPaginationParamsString(
      component,
      event,
      helper,
      offset,
      limit
    );
    var searchListKeyword = component.get("v.searchKeyWord");
    var action = component.get("c.getTotalBols");
    action.setParams({
      filterObjectString: filterObjectString,
      searchListKeyword: searchListKeyword
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        var totalBols = response.getReturnValue();
        component.set("v.totalRange", totalBols);
        if (totalBols == 0) {
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
            //helper.showToast('error', 'Error!', errors[0].message);
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
  getFilterObjectString: function (component, event, helper) {
    var filterObject = {};
    filterObject.selectedAccountId = component.get("v.selectedAccountId");
    filterObject.bookingNumber = component.get("v.selectBookingNumber");
    filterObject.originLocationId = component.get("v.selectedLocationId");
    filterObject.sailBetweenFrom = component.get("v.selectedSailBetweenFrom");
    filterObject.sailBetweenTo = component.get("v.selectedSailBetweenTo");
    if (component.get("v.status") != "All" || component.get("v.status") != "") {
      filterObject.status = component.get("v.status");
    }
    return JSON.stringify(filterObject);
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
    var tab = event.getSource();
    switch (tab.get("v.id")) {
      case "all-bols":
        console.log("all-bols");
        component.set("v.status", "All");
        break;
      case "docrecieved-bols":
        component.set("v.status", "DOC RECEIVED");
        break;
      case "processing-bols":
        console.log("processing-bols");
        component.set("v.status", "In Process");
        break;
      case "pending-bols":
        console.log("pending-bols");
        component.set("v.status", "Pending");
        break;
      case "submitted-bols":
        console.log("submitted-bols");
        component.set("v.status", "Submitted");
        break;
      case "for-review-bols":
        console.log("for-review-bols");
        component.set("v.status", "BOL for Review");
        break;
      case "for-release-bols":
        console.log("for-release-bols");
        component.set("v.status", "RR");
        break;
    }
    this.fetchTotalBols(component, event, helper);
    this.getBolData(component, event, helper);
  },
  fireHighlightEvent: function (component, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = component.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  }
});
