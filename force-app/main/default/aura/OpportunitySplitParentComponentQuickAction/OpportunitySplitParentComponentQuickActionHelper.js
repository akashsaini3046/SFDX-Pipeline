({
  getUITheme: function (component) {
    var objGetUIThemeAction = component.get("c.getUIThemeDescription");
    objGetUIThemeAction.setCallback(this, function (themeResult) {
      if (themeResult.getState() === "SUCCESS") {
        if (
          themeResult.getReturnValue() ===
          $A.get("$Label.c.OPS_CONSTANT_MOBILE_UI_THEME")
        ) {
          component.set("v.strTheme", "MOBILE");
        } else {
          component.set("v.strTheme", "DESKTOP");
        }
      } else {
        alert("Problem in connection, please try later.");
      }
    });

    $A.enqueueAction(objGetUIThemeAction);
  }
});
