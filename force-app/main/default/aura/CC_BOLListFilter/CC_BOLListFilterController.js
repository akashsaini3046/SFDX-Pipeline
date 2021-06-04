({
  handleFilter: function (component, event, helper) {
    if (!component.get("v.showFilters")) {
      component.set("v.filterButtonLabel", "Hide Filter(s)");
    } else {
      component.set("v.filterButtonLabel", "Use Filter(s)");
    }
    component.set("v.showFilters", !component.get("v.showFilters"));
  },
  handleSearchListEnterPress: function (component, event, helper) {
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
  changeSelectedItemId: function (component, event, helper) {
    var idSelected = event.getParams()["selectedItemID"];
    var strFunctionality = event.getParams()["functionality"];
    if (strFunctionality === "BOLListFilter:Account") {
      component.set("v.bolSelectedAccId", idSelected);
    } else if (strFunctionality === "BOLListFilter:Booking") {
      component.set("v.bolSelectedBookingId", idSelected);
    } else if (strFunctionality === "BOLListFilter:LoadPort") {
      component.set("v.bolSelectedUserId", idSelected);
    }
  },
  handleApplyFilter: function (component, event, helper) {
    helper.fireFilterEvent(component, event, helper);
  },
  navigateToCreateShipInst: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "create-shipping-instruction"
      }
    };
    navService.navigate(pageReference);
  },
  handleClearAll: function (component, event, helper) {
    helper.clearAllAndSetDefault(component, event, helper);
  }
});
