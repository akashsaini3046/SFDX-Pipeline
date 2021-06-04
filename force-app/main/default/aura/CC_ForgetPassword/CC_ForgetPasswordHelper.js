({
  setNewPassword: function (component, event) {
    var inputField = component.find("FormVal");
    var inputFieldValue = inputField.get("v.value");
    if (inputFieldValue == "" || typeof inputFieldValue == "undefined") {
      inputField.showHelpMessageIfInvalid();
      return;
    } else {
      if (!this.validateEmail(inputFieldValue)) {
        inputField.showHelpMessageIfInvalid();
        return;
      }
      var userN = component.get("v.userName");
      var action = component.get("c.usernameExists");
      action.setParams({
        username: userN
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() == "True") {
            component.set(
              "v.Message",
              "Please reset the password using the link sent to your registered email id."
            );
            component.set("v.showSuccessMessage", true);
            component.set("v.showErrorMessage", false);
          } else if (response.getReturnValue() == "False") {
            component.set(
              "v.Message",
              "Please check your username. If you still can't log in, contact your Crowley administrator"
            );
            component.set("v.showErrorMessage", true);
            component.set("v.showSuccessMessage", false);
          } else if (response.getReturnValue() == "Error") {
            component.set(
              "v.Message",
              "Something went wrong. Please contact Crowley Administrator."
            );
            component.set("v.showErrorMessage", true);
            component.set("v.showSuccessMessage", false);
          }
        } else {
          component.set(
            "v.Message",
            "Something went wrong. Please contact Crowley Administrator."
          );
          component.set("v.showErrorMessage", true);
          component.set("v.showSuccessMessage", false);
        }
      });
      $A.enqueueAction(action);
    }
  },
  validateEmail: function (email) {
    var pattern = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return pattern.test(String(email).toLowerCase());
  }
});
