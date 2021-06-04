({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event, helper);
  },
  navigateToQuotes: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "quotes"
      }
    };
    navService.navigate(pageReference);
  },
  navigateToHome: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  },

  navigateToCreateQuote: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "get-a-quote"
      }
    };
    navService.navigate(pageReference);
  }
});
