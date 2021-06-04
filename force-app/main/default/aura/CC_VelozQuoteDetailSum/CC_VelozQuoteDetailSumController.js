({
  doInit: function (component, event, helper) {
    helper.fetchQuoteDetails(component, event, helper);
    helper.identifyCommunity(component, event, helper);
    helper.showQuoteDetails(component);
  },

  handleSearchEvent: function (component, event, helper) {
    var selectedObjLabel = event.getParam("selectedObjLabel");
    if (selectedObjLabel == "Quotes") {
      var selectedItemId = event.getParam("selectedItemId");
      component.set("v.recordId", selectedItemId);
      helper.fetchQuoteDetails(component, event, helper);
      helper.showQuoteDetails(component);
    }
  },

  handleEmailModal: function (component, event, helper) {
    component.set("v.showSendEmail", !component.get("v.showSendEmail"));
  },

  handleNewQuote: function (component, event, helper) {
    helper.newQuoteFlow(component, event, helper);
  },

  handleExpand: function (component, event, helper) {
    var showTermsAndConditions = component.get("v.showTermsAndConditions");
    if (showTermsAndConditions) {
      component.set("v.expandText", "Expand");
    } else {
      component.set("v.expandText", "Collapse");
    }
    component.set("v.showTermsAndConditions", !showTermsAndConditions);
  },
  downloadPDF: function (component, event, helper) {
    helper.callDownloadPDF(component, event, helper);
  },

  handleRequote: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idQuote = component.get("v.recordId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "get-a-quote"
      },
      state: {
        id: idQuote
      }
    };
    navService.navigate(pageReference);

    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: "Requote",
      selectedItemID: idQuote,
      functionality: "RefreshTheComponent"
    });
    compEvent.fire();
  },
  handleBook: function (component, event, helper) {
    var navService = component.find("navigationService");
    var idQuote = component.get("v.recordId");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "create-booking"
      },
      state: {
        qId: idQuote
      }
    };
    navService.navigate(pageReference);
  }
});
