({
  fireSearchListEvt: function (component, event, helper) {
    var compEvent = component.getEvent("searchListEvent");
    var searchKeyWord = component.find("enter-search").get("v.value");
    compEvent.setParams({
      searchKeyWord: searchKeyWord
    });
    compEvent.fire();
  },
  fireFilterEvent: function (component, event, helper) {
    var compEvent = component.getEvent("filterEvent");
    var filters = {
      selectedAccountId: component.get("v.bolSelectedAccId"),
      selectedBookingId: component.get("v.bolSelectedBookingId"),
      selectedLocationId: component.get("v.bolSelectedUserId"),
      selectedSailDateFrom: component.get("v.bolSailDateFrom"),
      selectedSailDateTo: component.get("v.bolSailDateTo")
    };

    compEvent.setParams(filters);
    compEvent.fire();
  },
  clearAllAndSetDefault: function (component, event, helper) {
    let selectedAccountId = "";
    component.set("v.accountSearchKeyWord", "");
    component.set("v.bookingSearchKeyWord", "");
    component.set("v.createdBySearchKeyWord", "");
    if (component.get("v.accountDetailPage") == true) {
      selectedAccountId = component.get("v.bolSelectedAccId");
    }
    component.set("v.bolSelectedAccId", "");
    component.set("v.bolSelectedBookingId", "");
    component.set("v.bolSelectedUserId", "");
    component.set("v.bolSailDateFrom", "");
    component.set("v.bolSailDateTo", "");
    var compEvent = component.getEvent("filterEvent");
    var filters = {
      selectedAccountId: selectedAccountId,
      selectedBookingId: "",
      selectedLocationId: "",
      selectedSailDateFrom: "",
      selectedSailDateTo: ""
    };
    compEvent.setParams(filters);
    compEvent.fire();
  }
});
