({
  setInitValues: function (component, event, helper) {
    this.initChildAccShow(component, event, helper);
    this.initShipmentType(component, event, helper);
    this.initHazardousBooking(component, event, helper);
  },
  initChildAccShow: function (component, event, helper) {
    var showChildAcc = component.get("v.showChildAcc");
    if (showChildAcc) {
      if (showChildAcc.includes("Yes")) {
        component.set("v.showChildAccYes", true);
      } else {
        component.set("v.showChildAccYes", false);
      }
      if (showChildAcc.includes("No")) {
        component.set("v.showChildAccNo", true);
      } else {
        component.set("v.showChildAccNo", false);
      }
    }
  },
  initShipmentType: function (component, event, helper) {
    var shippingType = component.get("v.shippingType");
    if (shippingType && shippingType.includes("FCL")) {
      component.set("v.shippingTypeFcl", "true");
    }
    if (shippingType && shippingType.includes("LCL")) {
      component.set("v.shippingTypeLcl", "true");
    }
  },
  initHazardousBooking: function (component, event, helper) {
    var hazardousBook = component.get("v.hazBook");
    if (hazardousBook && hazardousBook.includes("Yes")) {
      component.set("v.hazBookYes", "true");
    }
    if (hazardousBook && hazardousBook.includes("No")) {
      component.set("v.hazBookNo", "true");
    }
  },
  fireFilterEvent: function (component, event, helper) {
    var compEvent = component.getEvent("filterEvent");
    var selectedAccountId = component.get("v.selectedAccountId");
    var selectedContractId = component.get("v.selectedContractId");
    var showChildAcc = component.get("v.showChildAcc");
    var statusSelected = component.get("v.statusSelected");
    var originMovementType = component.get("v.originMovementType");
    var destMovementType = component.get("v.destMovementType");
    var destinationLocationId = component.get("v.destinationLocationId");
    var departureFromDate = component.get("v.departureFromDate");
    var departureToDate = component.get("v.departureToDate");
    var shippingType = component.get("v.shippingType");
    var hazBook = component.get("v.hazBook");
    var transModeOriginSelected = component.get("v.transModeOriginSelected");
    var transModeDestSelected = component.get("v.transModeDestSelected");
    var comoditySelected = component.get("v.comoditySelected");
    var vessalSelected = component.get("v.vessalSelected");
    var originLocationId = component.get("v.originLocationId");
    var containerTypeSelected = component.get("v.containerTypeSelected");
    var contractInput = component.get("v.contractInput");

    var filters = {
      selectedAccountId: selectedAccountId,
      selectedContractId: selectedContractId,
      departureFromDate: departureFromDate,
      departureToDate: departureToDate,
      shippingType: shippingType,
      showChildAcc: showChildAcc,
      hazBook: hazBook,
      comoditySelected: comoditySelected,
      vessalSelected: vessalSelected,
      statusSelected: statusSelected,
      destinationLocationId: destinationLocationId,
      destMovementType: destMovementType,
      transModeOriginSelected: transModeOriginSelected,
      transModeDestSelected: transModeDestSelected,
      originMovementType: originMovementType,
      originLocationId: originLocationId,
      containerTypeSelected: containerTypeSelected,
      contractInput: contractInput
    };
    compEvent.setParams(filters);
    compEvent.fire();
  },

  clearAllAndSetDefault: function (component, event, helper) {
    component.set("v.selectedAccountId", "");
    component.set("v.selectedContractId", "");
    component.set("v.departureFromDate", "");
    component.set("v.departureToDate", "");
    component.set("v.shippingType", "");
    component.set("v.shippingTypeLcl", "false");
    component.set("v.shippingTypeFcl", "false");
    component.set("v.showChildAcc", "");
    component.set("v.showChildAccYes", "false");
    component.set("v.showChildAccNo", "false");
    component.set("v.hazBook", "");
    component.set("v.hazBookYes", "false");
    component.set("v.hazBookNo", "false");
    component.set("v.comoditySelected", "");
    component.set("v.vessalSelected", "");
    component.set("v.statusSelected", "");
    component.set("v.destinationLocationId", "");
    component.set("v.transModeOriginSelected", "");
    component.set("v.transModeDestSelected", "");
    component.set("v.originMovementType", "");
    component.set("v.destMovementType", "");
    component.set("v.containerTypeSelected", "");
    component.set("v.accountSearchKeyWord", "");
    component.set("v.contractInputDisabled", true);
    component.set("v.showChildCheckbox", false);
    component.set("v.disbaleOrigin", true);
    component.set("v.disbaleDestination", true);
    component.set("v.originSearchKeyWord", "");
    component.set("v.destinationSearchKeyWord", "");
    component.set("v.contractInput", "");
  },

  fetchChildAccounts: function (component, event, helper, IdSelected) {
    var action = component.get("c.getChildAccounts");
    action.setParams({
      accountId: IdSelected
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data && data.length > 0) {
          component.set("v.childAccounts", data);
          component.set("v.showChildCheckbox", true);
          component.set("v.contractInputDisabled", false);
        } else {
          component.set("v.showChildCheckbox", false);
          component.set("v.contractInputDisabled", true);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  fireSearchListEvt: function (component, event, helper) {
    var compEvent = component.getEvent("searchListEvent");
    var searchKeyWord = component.find("enter-search").get("v.value");
    compEvent.setParams({
      searchKeyWord: searchKeyWord
    });
    compEvent.fire();
  }
});
