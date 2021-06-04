({
  doInit: function (component, event, helper) {
    helper.getSObjectsLabels(component, event);
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
    var getInputkeyWord = component.get("v.searchKeyWord");
    if (getInputkeyWord !== "") {
      var forOpen = component.find("searchRes");
      $A.util.addClass(forOpen, "slds-is-open");
      $A.util.removeClass(forOpen, "slds-is-close");
      helper.searchHelper(component, event, getInputkeyWord);
    } else {
      component.set("v.listOfSearchRecords", null);
      if (component.get("v.buttonText") == "Location") {
        helper.hideLocationFields(component, event);
      }
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, "slds-is-close");
      $A.util.removeClass(forclose, "slds-is-open");
    }
  },
  clearInputValue: function (component) {
    component.find("inputSearch").set("v.value", "");
    component.set("v.listOfSearchRecords", null);
    component.set("v.showmessageDialog", false);
    var forclose = component.find("searchRes");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
  },
  onMouseOutInputSearch: function (component, event) {
    console.log(event.target);
    var forclose = component.find("searchRes");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
  },
  handleComponentEvent: function (component, event, helper) {
    var selectedItemId = event.getParam("selectedItemID");
    var selectedItemLabel = event.getParam("selectedObjLabel");
    var selectedItem = event.getParam("selectedItem");
    var forclose = component.find("searchRes");
    component.set("v.listOfSearchRecords", null);
    component.find("inputSearch").set("v.value", "");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
    var globalSearchEvent = $A.get("e.c:CC_GlobalSearchEvent");
    globalSearchEvent.setParams({
      selectedItemId: selectedItemId,
      selectedObjLabel: selectedItemLabel
    });
    globalSearchEvent.fire();
  }
});
