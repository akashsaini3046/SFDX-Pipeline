({
  setPassword: function (component, event) {
    if (this.checkValidation(component)) {
      var userPassword = component.get("v.userPassword");
      var confirmpassword = component.get("v.userConfirmPassword");
      if (userPassword !== confirmpassword) {
        component.set("v.Message", "Password and Confirm Password Donot Match");
        component.set("v.showErrorMessage", true);
        return;
      } else {
        var contactId = null;
        var query = window.location.search.substring(1);
        var vars = query.split("=");
        if (vars != null) {
          contactId = vars[1];
        }
        component.set("v.showErrorMessage", false);
        var action = component.get("c.setNewPassword");
        action.setParams({
          idContact: contactId,
          password: userPassword
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
            var response = response.getReturnValue();
            if (response == "False") {
              component.set(
                "v.Message",
                "Your password must be at least 8 characters long and it must include letters and numbers. Old password cannot be reused."
              );
              component.set("v.showErrorMessage", true);
              component.set("v.showSuccessMessage", false);
            } else {
              var currentURL = window.location.origin + "/Employees/s/";
              component.set(
                "v.Message",
                "Your Password has been set SuccessFully !!!"
              );
              component.set("v.showSuccessMessage", true);
              component.set("v.showErrorMessage", false);
              this.loginUser(component, currentURL, response, userPassword);
            }
          } else if (state == "ERROR") {
            this.ErrorHandler(component);
          }
        });
        $A.enqueueAction(action);
      }
    }
  },
  ErrorHandler: function (component, response) {
    var errors = response.getError();
    if (errors) {
      if (errors[0] && errors[0].message) {
        console.log("Error message: " + errors[0].message);
      }
    } else {
      console.log("Unknown error");
    }
  },
  loginUser: function (component, currentURL, username, userpassword) {
    var action = component.get("c.Login");
    action.setParams({
      username: username,
      password: userpassword,
      currentURL: currentURL
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var response = response.getReturnValue();
        if (response == "True") {
          console.log("NavigatedToPortal@@" + response);
        }
      }
    });
    $A.enqueueAction(action);
  },
  checkValidation: function (component) {
    var password = true,
      confirmpassword = true;
    var inputPassword = component.find("Password");
    var inputPasswordValue = inputPassword.get("v.value");
    if (inputPasswordValue == "" || typeof inputPasswordValue == "undefined") {
      password = inputPassword.showHelpMessageIfInvalid();
    }
    var inputConfirmPassword = component.find("Confirmpassword");
    var inputConfirmValue = inputConfirmPassword.get("v.value");
    if (inputConfirmValue == "" || typeof inputConfirmValue == "undefined") {
      confirmpassword = inputConfirmPassword.showHelpMessageIfInvalid();
    }
    if (password && confirmpassword) return true;
    else return false;
  }
});
