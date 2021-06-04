({
  doInit: function (component, event, helper) {
    component.set("v.isLoading", true);
    helper.setInitValues(component, event, helper);
    var showCreateAddress = component.get("v.showCreateAddress");
    var showCreateContact = component.get("v.showCreateContact");
    if (showCreateAddress || showCreateContact) {
      var selectedAccountPolId = component.get("v.selectedAccountPolId");
      if (selectedAccountPolId) {
        helper.setMarketSegment(component, event, helper, selectedAccountPolId);
      }
    }
  },

  handleCancel: function (component, event, helper) {
    component.set("v.showCreateProspect", false);
    component.set("v.showCreateAddress", false);
    component.set("v.showCreateContact", false);
  },

  handleContactErrorCancel: function (component, event, helper) {
    component.set(
      "v.showErrorContactMessage",
      !component.get("v.showErrorContactMessage")
    );
    component.set("v.showProspectModel", true);
  },

  handleCreate: function (component, event, helper) {
    component.set("v.isLoading", true);
    var accountFlag = true;
    var controlAuraIds = [];
    if (component.get("v.showCreateContact")) {
      if (component.get("v.showAddressSection")) {
        controlAuraIds.push("cityId");
        controlAuraIds.push("zipcodeId");
        controlAuraIds.push("addressId");
      } else {
        var accountId = component.find("addressLocationId");
        accountFlag = accountId.doValidityCheck();
      }
      controlAuraIds.push("emailAddressId");
      controlAuraIds.push("firstNameId");
      controlAuraIds.push("lastNameId");
      controlAuraIds.push("contactNumberId");
    } else if (component.get("v.showCreateAddress")) {
      controlAuraIds.push("cityId");
      controlAuraIds.push("zipcodeId");
      controlAuraIds.push("addressId");
    } else {
      controlAuraIds.push("accountNameId");
      controlAuraIds.push("emailAddressId");
      controlAuraIds.push("firstNameId");
      controlAuraIds.push("lastNameId");
      controlAuraIds.push("contactNumberId");
      controlAuraIds.push("cityId");
      controlAuraIds.push("zipcodeId");
      controlAuraIds.push("addressId");
    }
    let isAllValid = controlAuraIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      inputCmp.reportValidity();
      return isValidSoFar && inputCmp.checkValidity();
    },
    true);

    var requiredId = component.find("requiredId");
    var allSelectValid = true;
    if (requiredId) {
      if (requiredId.length > 0) {
        allSelectValid = component
          .find("requiredId")
          .reduce(function (validSoFar, selectCmp) {
            selectCmp.showHelpMessageIfInvalid();
            return validSoFar && !selectCmp.get("v.validity").valueMissing;
          }, true);
      } else {
        requiredId.showHelpMessageIfInvalid();
        allSelectValid = !requiredId.get("v.validity").valueMissing;
      }
    }

    if (isAllValid && allSelectValid && accountFlag) {
      helper.createProspect(component, event, helper);
    } else {
      component.set("v.isLoading", false);
    }
  },

  handleCountryChange: function (component, event, helper) {
    var countrySelected = event.getSource().get("v.value");
    if (countrySelected && countrySelected == "US") {
      component.set("v.showStateField", true);
    } else {
      component.set("v.showStateField", false);
    }
  },

  changeItemId: function (component, event, helper) {
    var selectedId = event.getParams()["selectedItemID"];
    var functionality = event.getParams()["functionality"];
    if (functionality === "Booking:BusinessLocationAccountDependent") {
      component.set("v.selectedAddressPolId", selectedId);
      component.set("v.selectedAddressPol", event.getParams()["selectedItem"]);
    }
  },

  handleSelectedAddressPolIdChange: function (component, event, helper) {
    var selectedAddressId = event.getParam("value");
    if (!(selectedAddressId && selectedAddressId != "")) {
      component.set("v.selectedAddressPol", "");
      component.set("v.selectedAddressPolId", "");
    }
  }
});
