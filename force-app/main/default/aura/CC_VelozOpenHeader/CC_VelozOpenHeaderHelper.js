({
  setHighlightedTab: function (component, event, helper) {
    var sPageURL = window.location.pathname;
    if (sPageURL.includes("get-a-quote")) {
      component.set("v.selectedTabId", "get-a-quote");
    } else {
      component.set("v.selectedTabId", "find-a-route");
    }
  }
});
