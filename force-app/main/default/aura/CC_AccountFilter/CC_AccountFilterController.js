({
  doInit: function (component, event, helper) {
    helper.showFilterSort(component, event, helper);
  },
  handleUseFilter: function (component, event, helper) {
    if (!component.get("v.showFilters")) {
      component.set("v.filterButtonLabel", "Hide Filter(s)");
    } else {
      component.set("v.filterButtonLabel", "Use Filter(s)");
    }
    component.set("v.showFilters", !component.get("v.showFilters"));
  },

  handleApply: function (component, event, helper) {
    helper.fireFilterEvent(component, event, helper);
  },

  handleSort: function (component, event, helper) {
    helper.fireSortEvent(component, event, helper);
  },

  changeItemId: function (component, event, helper) {
    var IdSelected = event.getParams()["selectedItemID"];
    console.log("IdSelected", IdSelected);
    component.set("v.selectedIdFromCustomInput", IdSelected);
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

  changeFilterLabel: function (component, event, helper) {
    component.set("v.filterButtonLabel", "Use Filter(s)");
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
  togglesearchBox: function (component, event, helper) {
    if ($A.util.hasClass(component.find("searchDiv"), "active")) {
      $A.util.addClass(component.find("searchDiv"), "inactive");
      $A.util.removeClass(component.find("searchDiv"), "active");
    } else {
      $A.util.addClass(component.find("searchDiv"), "active");
      $A.util.removeClass(component.find("searchDiv"), "inactive");
    }
  },
  clearCvifIdInputValue: function (component, event, helper) {
    component.find("cvifIdInput").set("v.value", "");
  },
  clearAccountOwnerValue: function (component, event, helper) {
    component.find("accountOwner").set("v.value", "");
  },
  clearContractNumberValue: function (component, event, helper) {
    component.find("contractNumber").set("v.value", "");
  }
});
