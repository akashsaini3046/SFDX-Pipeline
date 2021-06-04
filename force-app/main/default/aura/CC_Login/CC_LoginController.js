({
  doInit: function (component, event, helper) {
    helper.fetchCommunityUrlPathPrefix(component);
  },
  getInput: function (component, event, helper) {
    helper.userLogin(component, event);
  },
  togglePassword: function (component, event, helper) {
    if (component.get("v.showpassword", true)) {
      component.set("v.showpassword", false);
    } else {
      component.set("v.showpassword", true);
    }
  },
  keyCheck: function (component, event, helper) {
    if (event.which == 13) {
      helper.userLogin(component, event);
    }
  },
  navigateToForgetPasswordScreen: function (component, event, helper) {
    var navService = component.find("navService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "ForgotPassword"
      }
    };
    console.log("pageReference " + pageReference);
    navService.navigate(pageReference);
  },
  handleRenderer: function (component, event, helper) {
    var elem = component.find("getDeviceHeight").getElement();
    var winHeight = window.innerHeight;
    elem.style.height = winHeight + "px";
  },
  handleLogIn: function (component, event, helper) {
    window.location.href = $A.get("$Label.c.CC_LoginSSOLink");
  }
});
