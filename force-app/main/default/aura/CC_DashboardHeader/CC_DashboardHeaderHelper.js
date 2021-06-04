({
  handleExpandCollapse: function (component, event) {
    var isCollapsed = $A.util.hasClass(
      document.getElementById("verticalMenuDiv"),
      "fliph"
    );
    if (!isCollapsed) {
      $A.util.addClass(document.getElementById("verticalMenuDiv"), "fliph");
      $A.util.addClass(
        document.getElementById("DashboardContentDiv"),
        "dasboard-content-lg"
      );
    } else {
      $A.util.removeClass(document.getElementById("verticalMenuDiv"), "fliph");
      if (
        $A.util.hasClass(
          document.getElementById("DashboardContentDiv"),
          "dasboard-content-lg"
        )
      ) {
        $A.util.removeClass(
          document.getElementById("DashboardContentDiv"),
          "dasboard-content-lg"
        );
      }
    }
  },
  setGlobalSearchVisibility: function (component, event) {
    var device = $A.get("$Browser.formFactor");
    if (device == "DESKTOP" || device == "TABLET") {
      $A.util.addClass(component.find("searchDiv"), "active");
    } else if (device == "PHONE") {
      $A.util.addClass(component.find("searchDiv"), "inactive");
    }
  },
  fetchUserDetails: function (component, event) {
    var action = component.get("c.getUserName");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (response.getReturnValue() != null) {
        var userDetail = JSON.parse(response.getReturnValue());
        component.set("v.LastName", userDetail.LastName);
        component.set("v.FirstName", userDetail.FirstName);
        component.set("v.Language", userDetail.language);
        component.set("v.UserId", userDetail.UserId);
      }
    });
    $A.enqueueAction(action);
  },
  userOptionSelect: function (component, event) {
    var selectedMenuItemValue = event.getParam("value");
    var MenuItem = component.get("v.MenuItemOne");
    if (selectedMenuItemValue === MenuItem) {
      window.location.replace($A.get("$Label.c.CC_Logout"));
    }
  }
});
