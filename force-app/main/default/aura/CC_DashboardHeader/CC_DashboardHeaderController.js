({
  expandCollapseSection: function (component, event, helper) {
    helper.handleExpandCollapse(component, event);
  },
  doInit: function (component, event, helper) {
    helper.setGlobalSearchVisibility(component, event);
    helper.fetchUserDetails(component, event);
  },
  handleSelect: function (component, event, helper) {
    helper.userOptionSelect(component, event);
  },
  togglesearchBox: function (component, event, helper) {
    if ($A.util.hasClass(component.find("searchDiv"), "active")) {
      $A.util.addClass(component.find("searchDiv"), "inactive");
      $A.util.removeClass(component.find("searchDiv"), "active");
    } else if ($A.util.hasClass(component.find("searchDiv"), "inactive")) {
      $A.util.addClass(component.find("searchDiv"), "active");
      $A.util.removeClass(component.find("searchDiv"), "inactive");
    }
  },
  toggleGlobalSearch: function (component, event, helper) {
    var device = $A.get("$Browser.formFactor");
    if (device == "PHONE") {
      $A.util.addClass(component.find("searchDiv"), "inactive");
      $A.util.removeClass(component.find("searchDiv"), "active");
    }
  }
});
