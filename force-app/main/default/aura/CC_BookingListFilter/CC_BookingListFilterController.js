({
  doInit: function (component, event, helper) {
    helper.setInitValues(component, event, helper);
  },

  handleShippingType: function (component, event, helper) {
    var newShippingType = event.target.value;
    var newShippingTypeChecked = event.target.checked;
    var id = event.currentTarget.id;
    if (id == "fcl") {
      component.set("v.shippingTypeFcl", newShippingTypeChecked);
    } else {
      component.set("v.shippingTypeLcl", newShippingTypeChecked);
    }
    var shippingType = component.get("v.shippingType");
    if (shippingType) {
      if (shippingType.includes(newShippingType)) {
        if (!newShippingTypeChecked) {
          component.set(
            "v.shippingType",
            shippingType.replace(newShippingType, "").replace(",", "")
          );
        }
      } else {
        if (newShippingTypeChecked) {
          shippingType += "," + newShippingType;
          component.set("v.shippingType", shippingType);
        }
      }
    } else {
      if (newShippingTypeChecked) {
        component.set("v.shippingType", newShippingType);
      }
    }
  },

  handleHazBook: function (component, event, helper) {
    var newHazBook = event.target.value;
    var newHazBookChecked = event.target.checked;
    var hazBook = component.get("v.hazBook");
    var id = event.currentTarget.id;
    if (id == "hazYes") {
      component.set("v.hazBookYes", newHazBookChecked);
    } else {
      component.set("v.hazBookNo", newHazBookChecked);
    }
    if (hazBook) {
      if (hazBook.includes(newHazBook)) {
        if (!newHazBookChecked) {
          component.set(
            "v.hazBook",
            hazBook.replace(newHazBook, "").replace(",", "")
          );
        }
      } else {
        if (newHazBookChecked) {
          hazBook += "," + newHazBook;
          component.set("v.hazBook", hazBook);
        }
      }
    } else {
      if (newHazBook) {
        component.set("v.hazBook", newHazBook);
      }
    }
  },

  handleChildAccShow: function (component, event, helper) {
    var newShowChildAcc = event.target.value;
    var newShowChildAccChecked = event.target.checked;
    var showChildAcc = component.get("v.showChildAcc");
    var id = event.currentTarget.id;
    if (id == "showChildAccYes") {
      component.set("v.showChildAccYes", newShowChildAccChecked);
    } else {
      component.set("v.showChildAccNo", newShowChildAccChecked);
    }
    if (showChildAcc) {
      if (showChildAcc.includes(newShowChildAcc)) {
        if (!newShowChildAccChecked) {
          component.set(
            "v.showChildAcc",
            showChildAcc.replace(newShowChildAcc, "").replace(",", "")
          );
        }
      } else {
        if (newShowChildAccChecked) {
          showChildAcc += "," + newShowChildAcc;
          component.set("v.showChildAcc", showChildAcc);
        }
      }
    } else {
      if (newShowChildAcc) {
        component.set("v.showChildAcc", newShowChildAcc);
      }
    }
  },

  handleUseFilter: function (component, event, helper) {
    if (!component.get("v.showFilters")) {
      component.set("v.filterButtonLabel", "Hide Filter(s)");
    } else {
      component.set("v.filterButtonLabel", "Use Filter(s)");
    }
    component.set("v.showFilters", !component.get("v.showFilters"));
  },

  handleClearAll: function (component, event, helper) {
    helper.clearAllAndSetDefault(component, event, helper);
  },

  handleApply: function (component, event, helper) {
    helper.fireFilterEvent(component, event, helper);
  },

  changeItemId: function (component, event, helper) {
    var IdSelected = event.getParams()["selectedItemID"];
    if (event.getParams()["functionality"] === "BookingListFilter:Account") {
      component.set("v.selectedAccountId", IdSelected);
      if (IdSelected) {
        helper.fetchChildAccounts(component, event, helper, IdSelected);
      } else {
        component.set("v.childAccounts", null);
        component.set("v.showChildCheckbox", false);
        component.set("v.contractInputDisabled", true);
        component.set("v.selectedContractId", null);
        component.set("v.contractNumSearchKeyWord", null);
      }
    }
    if (event.getParams()["functionality"] === "BookingListFilter:Contract") {
      component.set("v.selectedContractId", IdSelected);
    }
    if (event.getParams()["functionality"] === "BookingListFilter:Origin") {
      component.set("v.originLocationId", IdSelected);
    }
    if (
      event.getParams()["functionality"] === "BookingListFilter:Destination"
    ) {
      component.set("v.destinationLocationId", IdSelected);
    }
  },
  handleSearchListEnter: function (component, event, helper) {
    var isEnterKey = event.keyCode === 13;
    var searchKeyWord = component.find("enter-search").get("v.value");
    var searchKeyWordExisting = component.get("v.searchTheList");
    if (
      isEnterKey &&
      ((typeof searchKeyWordExisting == "undefined" && searchKeyWord !== "") ||
        (typeof searchKeyWordExisting !== "undefined" &&
          searchKeyWord !== searchKeyWordExisting))
    ) {
      component.set("v.searchTheList", searchKeyWord);
      helper.fireSearchListEvt(component, event, helper);
    }
  },

  handleSearchList: function (component, event, helper) {
    var searchKeyWord = component.find("enter-search").get("v.value");
    var searchKeyWordExisting = component.get("v.searchTheList");
    if (
      (typeof searchKeyWordExisting == "undefined" && searchKeyWord !== "") ||
      (typeof searchKeyWordExisting !== "undefined" &&
        searchKeyWord !== searchKeyWordExisting)
    ) {
      component.set("v.searchTheList", searchKeyWord);
      helper.fireSearchListEvt(component, event, helper);
    }
  },

  handleOriginMovementType: function (component, event, helper) {
    component.set("v.origMovType", event.getSource().get("v.value"));
    if (
      component.get("v.origMovType") &&
      component.get("v.origMovType") !== ""
    ) {
      component.set("v.disbaleOrigin", false);
    } else {
      component.set("v.disbaleOrigin", true);
    }
    component.set("v.originSearchKeyWord", null);
    component.set("v.originLocationId", "");
  },

  handleDestMovementType: function (component, event, helper) {
    component.set("v.destMovType", event.getSource().get("v.value"));
    if (
      component.get("v.destMovType") &&
      component.get("v.destMovType") !== ""
    ) {
      component.set("v.disbaleDestination", false);
    } else {
      component.set("v.disbaleDestination", true);
    }
    component.set("v.destinationSearchKeyWord", null);
    component.set("v.destinationLocationId", "");
  },

  clearContractInputValue: function (component, event, helper) {
    component.find("contractInput").set("v.value", "");
  }
});
