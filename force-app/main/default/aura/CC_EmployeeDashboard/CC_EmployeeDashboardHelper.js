({
  fireHighlightEvent: function (component, event) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = component.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },
  HomeScreenView: function (component) {
    var compname = component.get("v.DisplayComponent");
    $A.createComponent(
      compname,
      {},
      function (newScreen, status, errorMessage) {
        //Add the new button to the body array
        if (status === "SUCCESS") {
          component.set("v.body", "");
          var body = component.get("v.body");
          body.push(newScreen);
          component.set("v.body", body);
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
        }
      }
    );
  }
});
