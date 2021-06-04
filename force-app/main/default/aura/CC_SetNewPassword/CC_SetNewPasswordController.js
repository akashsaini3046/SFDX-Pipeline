({
  togglePassword: function (component, event, helper) {
    if (component.get("v.showpassword", true)) {
      component.set("v.showpassword", false);
    } else {
      component.set("v.showpassword", true);
    }
  },
  toggleConfirmPassword: function (component, event, helper) {
    if (component.get("v.showconfirmpassword", true)) {
      component.set("v.showconfirmpassword", false);
    } else {
      component.set("v.showconfirmpassword", true);
    }
  },
  setPassword: function (component, event, helper) {
    helper.setPassword(component, event);
  }
});
