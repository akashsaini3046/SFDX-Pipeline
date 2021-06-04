({
  handleApply: function (component, event, helper) {
    helper.fireFilterEvent(component, event, helper);
  },

  changeItemId: function (component, event, helper) {
    var IdSelected = event.getParams()["selectedItemID"];
    var selectedItem = event.getParams()["selectedItem"];
    var functionality = event.getParams()["functionality"];
    if (functionality == "AccountFilter:AccountName") {
      component.set("v.searchAccountName", selectedItem);
      component.set("v.searchAccountId", IdSelected);
    }
    if (functionality == "AccountFilter:ParentAccountName") {
      component.set("v.searchparentAccountName", selectedItem);
      component.set("v.searchparentAccountId", IdSelected);
    }
    component.set("v.selectedIdFromCustomInput", IdSelected);
  },
  handleClearAll: function (component, event, helper) {
    helper.clearAllAndSetDefault(component, event, helper);
  }
});
