({
  showFilterSort: function (component, event, helper) {
    var tab = component.get("v.selectedTab");
    switch (tab) {
      case "ChildAccounts":
        component.set("v.showSortBy", true);
        component.set("v.showUseFilters", true);
        break;
      case "Contacts":
        component.set("v.showSortBy", true);
        component.set("v.showUseFilters", false);
        break;
      case "Quotes":
        component.set("v.showSortBy", false);
        component.set("v.showUseFilters", true);
        break;
      case "Contracts":
        component.set("v.showSortBy", true);
        component.set("v.showUseFilters", true);
        break;
      case "Bookings":
        component.set("v.showSortBy", false);
        component.set("v.showUseFilters", true);
        break;
      case "Bill Of Lading":
        component.set("v.showSortBy", true);
        component.set("v.showUseFilters", true);
        break;
    }
  },
  fireSortEvent: function (component, event, helper) {
    var sortFieldName = event.target.value;
    var sortByList = component.get("v.sortByList");
    var sortFieldItem = sortByList.filter((item) => {
      if (item.value == sortFieldName) {
        return item;
      }
    });
    var eventParam = {};
    eventParam.sortFieldName = sortFieldName;
    eventParam.sortDirection = "asc";

    if (sortFieldItem) {
      var sortFieldLabel = sortFieldItem[0].label;
      eventParam.sortFieldLabel = sortFieldLabel;
    }
    var compEvent = component.getEvent("sortEvent");
    compEvent.setParams(eventParam);
    compEvent.fire();
  },
  fireFilterEvent: function (component, event, helper) {
    var compEvent = component.getEvent("filterEvent");
    var cvifId = component.get("v.cvifId");
    var searchRegion = component.get("v.searchRegion");
    var accountType = component.get("v.accountType");
    var accountOwner = component.get("v.accountOwner");
    var contractNumber = component.get("v.contractNumber");
    var searchTheList = component.get("v.searchTheList");
    var searchContractRegion = component.get("v.searchContractRegion");
    var startContractDate = component.get("v.startContractDate");
    var endContractDate = component.get("v.endContractDate");
    var contractStatus = component.get("v.contractStatus");
    var selectedIdFromCustomInput = component.get(
      "v.selectedIdFromCustomInput"
    );
    compEvent.setParams({
      cvifId: cvifId,
      searchRegion: searchRegion,
      accountType: accountType,
      accountOwner: accountOwner,
      contractNumber: contractNumber,
      searchTheList: searchTheList,
      searchContractRegion: searchContractRegion,
      startContractDate: startContractDate,
      endContractDate: endContractDate,
      contractStatus: contractStatus,
      selectedIdFromCustomInput: selectedIdFromCustomInput
    });
    compEvent.fire();
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
