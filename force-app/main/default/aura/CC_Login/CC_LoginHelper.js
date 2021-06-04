({
  userLogin: function (component, event) {
    var currentURL = component.get("v.currentUrl");
    var validForm = component
      .find("FormVal")
      .reduce(function (validSoFar, inputCmp) {
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && inputCmp.get("v.validity").valid;
      }, true);
    if (validForm) {
      var Username = component.get("v.Username");
      var Password = component.get("v.Password");
      var action = component.get("c.checkPortal");
      action.setParams({
        username: Username,
        password: Password,
        currentURL: currentURL
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var responseServer = response.getReturnValue();
          console.log("responseServer  " + responseServer);
          if (responseServer == "False") {
            component.set(
              "v.errorMessage",
              "Please check your username and password. If you still can't log in, contact your Crowley administrator."
            );
            console.log("Error in credentials");
            component.set("v.showErrorMessage", true);
          }
        } else if (state === "ERROR") {
          component.set(
            "v.errorMessage",
            "Please check your username and password. If you still can't log in, contact your Crowley administrator."
          );
          component.set("v.showErrorMessage", true);
          var errors = response.getError();
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " + errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  fetchCommunityUrlPathPrefix: function (component) {
    var action = component.get("c.getCommunityUrlPathPrefix");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.currentUrl", response.getReturnValue());
        console.log(response.getReturnValue());
      }
    });
    $A.enqueueAction(action);
  }
});
