({
  fireFilterEvent: function (component, event, helper) {
    var compEvent = component.getEvent("filterEvent");
    var cvifId = component.get("v.cvifId");
    var parentCvifId = component.get("v.parentCvifId");
    var searchRegion = component.get("v.searchRegion");
    var accountType = component.get("v.accountType");
    var accountOwner = component.get("v.accountOwner");
    var searchAccountId = component.get("v.searchAccountId");
    var searchparentAccountId = component.get("v.searchparentAccountId");
    var searchAccountName = component.get("v.searchAccountName");
    var searchparentAccountName = component.get("v.searchparentAccountName");
    compEvent.setParams({
      cvifId: cvifId,
      searchRegion: searchRegion,
      accountType: accountType,
      accountOwner: accountOwner,
      searchAccountId: searchAccountId,
      searchparentAccountId: searchparentAccountId,
      parentCvifId: parentCvifId,
      searchAccountName: searchAccountName,
      searchparentAccountName: searchparentAccountName
    });
    compEvent.fire();
  },
  clearAllAndSetDefault: function (component, event, helper) {
    component.set("v.cvifId", "");
    component.set("v.parentCvifId", "");
    component.set("v.searchRegion", "");
    component.set("v.accountType", "");
    component.set("v.accountOwner", "");
    component.set("v.searchAccountId", "");
    component.set("v.searchparentAccountId", "");
    component.set("v.searchAccountName", "");
    component.set("v.searchparentAccountName", "");
  }
});
