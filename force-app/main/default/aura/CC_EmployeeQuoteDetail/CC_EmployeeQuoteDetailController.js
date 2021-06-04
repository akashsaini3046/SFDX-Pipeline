({
  doInit: function (component, event, helper) {
    //component.set("v.quotationNumber",'CQ-111295');
    var quoteId = helper.getURLParameter("id");
    helper.getQuoteNumber(component, event, helper, quoteId);
    console.log("record id----> " + quoteId);
    component.set("v.recordId", quoteId);
    helper.fireHighlightEvent(component, event, helper);
    component.set("v.showQuoteDetail", "true");
    console.log("set id is: " + component.get("v.recordId"));
  },
  handleSearchEvent: function (component, event, helper) {
    var selectedObjLabel = event.getParam("selectedObjLabel");
    if (selectedObjLabel == "Quotes") {
      var selectedItemId = event.getParam("selectedItemId");
      component.set("v.recordId", selectedItemId);
      var qId = component.get("v.recordId");
      helper.getQuoteNumber(component, event, helper, qId);
    }
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
  navigateToQuote: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "quotes"
      }
    };
    navService.navigate(pageReference);
  }
});
