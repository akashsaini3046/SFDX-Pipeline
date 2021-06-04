({
  setNewPassword: function (component, event, helper) {
    helper.setNewPassword(component, event);
  },
  navigateToLoginScreen: function (component, event, helper) {
    console.log("navigateToLoginScreen");
    var navService = component.find("navService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "login"
      }
    };
    console.log("pageReference " + pageReference);
    navService.navigate(pageReference);
  },
  handleRenderer: function (component, event, helper) {
    var elem = component.find("getDeviceHeight").getElement();
    var winHeight = window.innerHeight;
    elem.style.height = winHeight + "px";
  }
});
