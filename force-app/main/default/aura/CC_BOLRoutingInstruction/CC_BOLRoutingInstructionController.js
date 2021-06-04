({
  handleCollapse: function (component, event, helper) {
    if (component.get("v.isExpand") == true) {
      component.set("v.collapseExpand", "EXPAND");
    } else if (component.get("v.isExpand") == false) {
      component.set("v.collapseExpand", "COLLAPSE");
    }
    component.set("v.isExpand", !component.get("v.isExpand"));
  }
});
