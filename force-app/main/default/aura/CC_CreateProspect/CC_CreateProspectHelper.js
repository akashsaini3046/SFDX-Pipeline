({
  setInitValues: function (component, event, helper) {
    var action = component.get("c.fetchInitialValues");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var initValWrapper = response.getReturnValue();
        if (
          initValWrapper.marketSegments &&
          initValWrapper.marketSegments.length > 0
        ) {
          var segmentValues = [];
          segmentValues.push({ label: "-- Select Segment --", value: "" });
          component.set("v.marketSegments", [
            ...segmentValues,
            ...initValWrapper.marketSegments
          ]);
        }
        if (initValWrapper.cityNames && initValWrapper.cityNames.length > 0) {
          component.set("v.countryNames", initValWrapper.cityNames);
        }
        if (initValWrapper.stateNames && initValWrapper.stateNames.length > 0) {
          component.set("v.stateNames", initValWrapper.stateNames);
        }
        var showCreateAddress = component.get("v.showCreateAddress");
        var showCreateContact = component.get("v.showCreateContact");
        if (showCreateAddress || showCreateContact) {
          component.set("v.accountName", component.get("v.selectedAccountPol"));
        }
      } else {
        console.log("Error occured in In fetching Movement Types");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  setMarketSegment: function (component, event, helper, selectedAccountId) {
    var action = component.get("c.getAccountDetails");
    action.setParams({
      accountId: selectedAccountId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var account = response.getReturnValue();
        if (account.Industry) {
          var segmentValues = [];
          segmentValues.push({
            label: account.Industry,
            value: account.Industry
          });
          component.set("v.marketSegments", segmentValues);
          component.set("v.marketSegment", account.Industry);
        }
      } else {
        console.log("Error occured in In fetching Account Details");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  createProspect: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    var objValues = this.createValueObject(component, event, helper);
    var action = component.get("c.createProspectRecords");
    action.setParams({
      objValues: JSON.stringify(objValues)
    });
    console.log("objvalues " + JSON.stringify(objValues));
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var allObjects = response.getReturnValue();
        var hasErrorContact = false;
        var errorContact = {};
        allObjects.map((item) => {
          if (item.ErrorContact) {
            hasErrorContact = true;
            errorContact = item.ErrorContact;
          }
        });
        if (allObjects.length > 0 && !hasErrorContact) {
          component.set("v.showProspectCreatedMessage", true);
          component.set("v.showProspectModel", false);
          component.set("v.allObjects", allObjects);
          component.set("v.isLoading", false);
        } else if (hasErrorContact) {
          component.set("v.showProspectModel", false);
          component.set("v.showErrorContactMessage", true);
          component.set("v.errorContact", errorContact);
          component.set("v.isLoading", false);
        } else {
          toastEvent.setParams({
            message: "Something went wrong! Please try again later !",
            type: "warning"
          });
          component.set("v.showProspectModel", false);
          component.set("v.allObjects", allObjects);
        }
      } else {
        toastEvent.setParams({
          message: "Error Creating Prospect",
          type: "error"
        });
      }
      toastEvent.fire();
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  createValueObject: function (component, event, helper) {
    var obj = {
      contactNumber: component.get("v.contactNumber"),
      firstName: component.get("v.firstName"),
      lastName: component.get("v.lastName"),
      accountName: component.get("v.accountName"),
      emailAddress: component.get("v.emailAddress"),
      marketSegment: component.get("v.marketSegment"),
      countryName: component.get("v.countryName"),
      cityName: component.get("v.cityName"),
      zipCode: component.get("v.zipCode"),
      address: component.get("v.address"),
      stateSelected: component.get("v.stateSelected"),
      createAddress: component.get("v.showCreateAddress"),
      createContact: component.get("v.showCreateContact"),
      selectedAddressId: component.get("v.selectedAddressPolId")
    };
    if (
      component.get("v.showCreateAddress") ||
      component.get("v.showCreateContact")
    ) {
      obj.accountId = component.get("v.selectedAccountPolId");
    }
    return obj;
  }
});
