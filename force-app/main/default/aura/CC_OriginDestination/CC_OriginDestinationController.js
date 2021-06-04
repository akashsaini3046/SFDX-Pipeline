({
  doInit: function (component, event, helper) {
    helper.doInit(component, event);
    console.log(component.get("v.bookingWrapper.booking.Contract__c"));
    if (
      component.get("v.clickedItemOrigin") !== "" &&
      component.get("v.clickedItemOrigin") !== undefined
    ) {
      var comp = component.find("originId");
      comp.reInit();
    }
    if (
      component.get("v.clickedItemDestination") !== "" &&
      component.get("v.clickedItemDestination") !== undefined
    ) {
      var comp = component.find("destinationId");
      comp.reInit();
    }
    if (
      component.get("v.clickedItemPol") !== "" &&
      component.get("v.clickedItemPol") !== undefined
    ) {
      console.log(
        " component.get(v.clickedItemPol) " + component.get("v.clickedItemPol")
      );
      var comp = component.find("POLId");
      comp.reInit();
    }
    if (
      component.get("v.clickedItemPod") !== "" &&
      component.get("v.clickedItemPod") !== undefined
    ) {
      console.log(
        " component.get(v.clickedItemPod) " + component.get("v.clickedItemPod")
      );
      var comp = component.find("PODId");
      comp.reInit();
    }
  },
  searchFindRoute: function (component, event, helper) {
    var bookingWrap = component.get("v.bookingWrapper");
    console.log(bookingWrap);
    helper.searchFindRoute(component, event, helper);
  },
  changeItemId: function (component, event, helper) {
    var selectedId = event.getParams()["selectedItemID"];
    console.log(selectedId);
    var functionality = event.getParams()["functionality"];
    if (functionality === "Quote:Origin" && selectedId !== "") {
      component.set("v.isOriginValid", true);
    } else if (functionality === "Quote:Origin" && selectedId === "") {
      component.set("v.isOriginValid", false);
    }
    if (functionality === "Quote:Destination" && selectedId !== "") {
      component.set("v.isDestinationValid", true);
    } else if (functionality === "Quote:Destination" && selectedId === "") {
      component.set("v.isDestinationValid", false);
    }
    if (
      functionality === "Quote:PostLoginAccount" ||
      functionality === "Booking:PostLoginAccount"
    ) {
      component.set("v.selectedAccountPolId", selectedId);
      var bookingWrapper = component.get("v.bookingWrapper");
      bookingWrapper.booking.Account__c = selectedId;
      bookingWrapper.booking.Contract__c = "";
      bookingWrapper.booking.Contract_Number__c = "";
      component.set("v.tariffsCommodities", []);
      component.set("v.selectedAccountPol", event.getParams()["selectedItem"]);
    } else if (
      functionality === "Quote:PostLoginContact" ||
      functionality === "Booking:PostLoginContact" ||
      functionality === "Booking:ContactAccountDependent"
    ) {
      component.set("v.selectedContactPolId", selectedId);
      component.set("v.selectedContactPol", event.getParams()["selectedItem"]);
    } else if (
      functionality === "Booking:BusinessLocation" ||
      functionality === "Booking:BusinessLocationAccountDependent"
    ) {
      component.set("v.selectedAddressPolId", selectedId);
      component.set("v.selectedAddressPol", event.getParams()["selectedItem"]);
    } else {
      if (selectedId != "") {
        helper.getLocation(component, event, functionality, selectedId);
      } else {
        helper.clearLocation(component, event, functionality);
      }
      console.log(
        component.get("v.isDateValid") +
          " " +
          component.get("v.isOriginValid") +
          " " +
          component.get("v.isDestinationValid")
      );
      if (
        component.get("v.isDateValid") &&
        component.get("v.isOriginValid") &&
        component.get("v.isDestinationValid")
      ) {
        component.set("v.enableSearchButton", true);
      } else {
        component.set("v.enableSearchButton", false);
      }
    }
  },

  validateOriginDestination: function (component, event) {
    var controlAuraIds = ["readyDateId", "customerEmailId", "customerPhoneId"];
    var screen = component.get("v.screen");
    var bookingFlag = true;
    if (screen == "CreateBooking") {
      controlAuraIds.push("customerNameId");
      var accountId = component.find("accountId");
      var accountFlag = accountId.doValidityCheck();
      var addressId = component.find("addressId");
      var addressFlag = addressId.doValidityCheck();
      var contactId = component.find("contactId");
      var contactFlag = contactId.doValidityCheck();

      var originDestStopId = component.find("originDestStopId");
      var originDestStopFlag = true;
      if (originDestStopId) {
        if (originDestStopId.length) {
          originDestStopId.map((cmp) => {
            originDestStopFlag = cmp.doValidityCheck() && originDestStopFlag;
          });
        } else {
          originDestStopFlag =
            originDestStopId.doValidityCheck() && originDestStopFlag;
        }
      }
      bookingFlag =
        accountFlag && addressFlag && contactFlag && originDestStopFlag;
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

    var originLocation = component.find("originId");
    var isOriginValid = originLocation.doValidityCheck();
    var destinationLocation = component.find("destinationId");
    var isdestinationValid = destinationLocation.doValidityCheck();
    return (
      isAllValid &&
      isOriginValid &&
      isdestinationValid &&
      allSelectValid &&
      bookingFlag
    );
  },
  validateOriginDestinationForRoute: function (component, event) {
    component.set("v.showErrorMessageInRouteFinder", false);
    component.set("v.schedules", []);
    component.set("v.numberOfSchedules", 0);
    var inputCmp = component.find("readyDateIdRoute");
    var isDateValid = inputCmp.checkValidity();
    component.set("v.isDateValid", isDateValid);
    console.log(
      'component.get("v.isDateValid") ' + component.get("v.isDateValid")
    );

    if (
      component.get("v.isDateValid") &&
      component.get("v.isOriginValid") &&
      component.get("v.isDestinationValid")
    )
      component.set("v.enableSearchButton", true);
    else component.set("v.enableSearchButton", false);
  },
  refreshSchedulesCount: function (component, event) {
    component.set("v.showErrorMessageInRouteFinder", false);
    component.set("v.schedules", []);
    component.set("v.numberOfSchedules", 0);
  },
  resetOriginDestination: function (component, event) {
    component.set("v.selectedOriginLocation", "");
    component.set("v.selectedDestinationLocation", "");
    component.set("v.originMove", "P");
    component.set("v.destinationMove", "P");
  },
  handleSelectedAccountPolIdChange: function (component, event, helper) {
    var selectedAccountId = event.getParam("value");
    var bookingWrapper = component.get("v.bookingWrapper");
    if (selectedAccountId && selectedAccountId != "") {
      bookingWrapper.booking.Account__c = selectedAccountId;
      component.set("v.isDisableContractAndContact", false);
      helper.fetchContracts(component, event, helper, selectedAccountId);
    } else {
      bookingWrapper.booking.Account__c = "";
      component.set("v.isDisableContractAndContact", true);
    }
    bookingWrapper.booking.Contact__c = "";
    bookingWrapper.booking.Contract__c = "";
    bookingWrapper.booking.Address__c = "";
    component.set("v.selectedContactPol", "");
    component.set("v.selectedContactPolId", "");
    component.set("v.selectedContractPolId", "");
    component.set("v.selectedAddressPol", "");
    component.set("v.selectedAddressPolId", "");
    component.set("v.bookingWrapper", bookingWrapper);
  },

  handleSelectedContactPolIdChange: function (component, event, helper) {
    var selectedContactId = event.getParam("value");
    var bookingWrapper = component.get("v.bookingWrapper");
    if (selectedContactId && selectedContactId != "") {
      bookingWrapper.booking.Contact__c = selectedContactId;
    } else {
      bookingWrapper.booking.Contact__c = "";
      component.set("v.selectedContactPol", "");
      component.set("v.selectedContactPolId", "");
    }
    component.set("v.bookingWrapper", bookingWrapper);
    console.log(bookingWrapper);
  },

  handleSelectedAddressPolIdChange: function (component, event, helper) {
    var selectedAddressId = event.getParam("value");
    var bookingWrapper = component.get("v.bookingWrapper");
    if (selectedAddressId && selectedAddressId != "") {
      bookingWrapper.booking.Address__c = selectedAddressId;
    } else {
      bookingWrapper.booking.Address__c = "";
      component.set("v.selectedAddressPol", "");
      component.set("v.selectedAddressPolId", "");
    }
    component.set("v.bookingWrapper", bookingWrapper);
    console.log(bookingWrapper);
  },

  handleContractChange: function (component, event, helper) {
    var bookingWrapper = component.get("v.bookingWrapper");
    var contractId = event.getSource().get("v.value");
    var params = event.getParam("arguments");
    console.log("params ");
    console.log(params);
    if (params && (!contractId || contractId == "")) {
      contractId = params.contractId;
    }
    if (contractId && contractId != "") {
      if (!params) {
        bookingWrapper.booking.Contract_Number__c = helper.getContractNameById(
          component,
          contractId
        );
      }
      helper.fetchCommodities(component, event, helper, contractId);
      helper.fetchEquipments(component, event, helper, contractId);
      helper.fetchCommoditiesVehicle(component, event, helper, contractId);
    } else {
      bookingWrapper.booking.Contract_Number__c = "";
      component.set("v.tariffsCommodities", []);
      component.set("v.tariffsEquipments", []);
      component.set("v.vehichleCommodities", []);
    }
    component.set("v.bookingWrapper", bookingWrapper);
  },

  handleCrossDockExport: function (component, event, helper) {
    var showCrossDockExportChecked = event.target.checked;
    var bookingWrapper = component.get("v.bookingWrapper");
    bookingWrapper.transportOrigin.transport.Cross_Dock__c = showCrossDockExportChecked;
    component.set("v.bookingWrapper", bookingWrapper);
    component.set("v.showCrossDockExport", showCrossDockExportChecked);
  },

  handleCrossDockImport: function (component, event, helper) {
    var showCrossDockImportChecked = event.target.checked;
    var bookingWrapper = component.get("v.bookingWrapper");
    bookingWrapper.transportDestination.transport.Cross_Dock__c = showCrossDockImportChecked;
    component.set("v.bookingWrapper", bookingWrapper);
    component.set("v.showCrossDockImport", showCrossDockImportChecked);
  },

  handleAllObjectsChange: function (component, event, helper) {
    var allObjects = component.get("v.allObjects");
    var accountId;
    var contactId;
    var addressId;
    allObjects.map((item) => {
      if (item.Account) {
        accountId = item.Account.Id;
      }
      if (item.Location) {
        addressId = item.Location.Id;
      }
      if (item.Contact) {
        contactId = item.Contact.Id;
      }
    });
    if (accountId && accountId != null && accountId != "") {
      helper.getAccount(component, event, helper, accountId);
    }
    if (addressId && addressId != null && addressId != "") {
      helper.getAddress(component, event, helper, addressId);
    }
    if (contactId && contactId != null && contactId != "") {
      helper.getContact(component, event, helper, contactId);
    }
  }
});
