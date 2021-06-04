({
  doInit: function (component, event, helper) {
    console.log(
      ' component.get("v.clickedItem") ' + component.get("v.clickedItem")
    );
    if (
      component.get("v.clickedItem") !== undefined &&
      component.get("v.clickedItem") !== ""
    ) {
      var clickedItem = component.get("v.clickedItem");
      component.find("inputSearch").set("v.value", clickedItem);
      // helper.onBlurInputSearchHandler(component);
    }

    if (component.get("v.clickedItem") === "") {
      component.find("inputSearch").set("v.value", "");
    }
    if (component.get("v.isWarned")) {
      helper.warningChangeHandler(component, event);
      helper.setWarningMessage(component, event, helper);
    }
  },
  onChangeSearchText: function (component) {
    var inputValue = component.find("inputSearch").get("v.value");
    component.set("v.selectedItem", inputValue);
    var forclose = component.find("searchRes");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
  },
  keyPressController: function (component, event, helper) {
    component.set("v.loading", true);
    var getInputkeyWord = component.get("v.SearchKeyWord");
    if (getInputkeyWord !== "") {
      var forOpen = component.find("searchRes");
      $A.util.addClass(forOpen, "slds-is-open");
      $A.util.removeClass(forOpen, "slds-is-close");
      helper.searchHelper(component, event, getInputkeyWord);
    } else {
      component.set("v.listOfSearchRecords", null);
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, "slds-is-close");
      $A.util.removeClass(forclose, "slds-is-open");
    }
  },
  clearInputValue: function (component) {
    component.find("inputSearch").set("v.value", "");
    component.set("v.listOfSearchRecords", null);
    component.set("v.showmessageDialog", false);
    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: "",
      selectedItemID: "",
      index: component.get("v.index"),
      functionality: component.get("v.functionality")
    });
    compEvent.fire();
  },
  onBlurInputSearch: function (component, event, helper) {
    var clickedItem = component.get("v.clickedItem");
    var clickedItemId = component.get("v.clickedItemId");
    var inputValue = component.find("inputSearch").get("v.value");
    console.log("inputValue " + inputValue);
    if (typeof clickedItemId == "undefined" || clickedItemId == "") {
      component.find("inputSearch").set("v.value", "");
      var compEvent = component.getEvent("selectedItemEvent");
      compEvent.setParams({
        selectedItem: "",
        selectedItemID: "",
        index: component.get("v.index"),
        functionality: component.get("v.functionality")
      });
      compEvent.fire();
    } else {
      if (clickedItemId && clickedItemId.includes("Button")) {
        if (clickedItemId == "CreateProspectButton") {
          helper.handleCreateProspect(component, event, helper);
        }
        if (clickedItemId == "CreateAddressButton") {
          helper.handleCreateAddress(component, event, helper);
        }
        if (clickedItemId == "CreateContactButton") {
          helper.handleCreateContact(component, event, helper);
        }
        component.find("inputSearch").set("v.value", "");
        var compEvent = component.getEvent("selectedItemEvent");
        compEvent.setParams({
          selectedItem: "",
          selectedItemID: "",
          index: component.get("v.index"),
          functionality: component.get("v.functionality")
        });
        compEvent.fire();
      } else if (typeof inputValue == "undefined" || inputValue == "") {
        component.find("inputSearch").set("v.value", "");
        var compEvent = component.getEvent("selectedItemEvent");
        compEvent.setParams({
          selectedItem: "",
          selectedItemID: "",
          index: component.get("v.index"),
          functionality: component.get("v.functionality")
        });
        compEvent.fire();
      } else {
        //alert(component.get("v.selectedObj"));
        console.log("last else");
        component.find("inputSearch").set("v.value", clickedItem);
        var compEvent = component.getEvent("selectedItemEvent");
        compEvent.setParams({
          selectedItem: clickedItem,
          selectedItemID: clickedItemId,
          index: component.get("v.index"),
          functionality: component.get("v.functionality")
        });
        compEvent.fire();
      }
    }
    component.set("v.listOfSearchRecords", null);
    var forclose = component.find("searchRes");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");

    if (component.get("v.isWarned")) {
      helper.warningChangeHandler(component, event);
    }
  },
  doValidate: function (component, event) {
    var controlAuraIds = ["inputSearch"];
    let isAllValid = controlAuraIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      inputCmp.reportValidity();
      return isValidSoFar && inputCmp.checkValidity();
    },
    true);
    return isAllValid;
  },
  resetWarnedValue: function (component, event, helper) {
    let oldValue = component.get("v.oldValue");
    component.set("v.SearchKeyWord", oldValue);
    component.set("v.clickedItem", oldValue);
    component.set("v.clickedItemId", oldValue);
    let input = component.find("inputSearch");
    $A.util.removeClass(input, "warninginput");
    component.set("v.showWarning", false);
  },
  toggleWarned: function (component, event) {
    var toggleText = component.find("tooltip");
    $A.util.toggleClass(toggleText, "toggle");
  }
});
