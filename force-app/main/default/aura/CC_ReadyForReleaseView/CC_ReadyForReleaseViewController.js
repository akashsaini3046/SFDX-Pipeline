({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event, helper);
    var idBooking = helper.getURLParameter("bookingId");
    var idBOL = helper.getURLParameter("bolId");
    component.set("v.strBookingId", idBooking);
    component.set("v.strBolId", idBOL);
    //component.set("v.strBookingId", 'a1e3F000001DjiuQAC');
    //component.set("v.strBolId", 'a223F000000fDMjQAM');
    var today = new Date();
    component.set("v.currentDate", today);
    helper.getBol(component, event);
    //helper.getShippingURL(component);
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

  navigateToBOL: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "billsoflading"
      }
    };
    navService.navigate(pageReference);
  },
  handleDownloadPDF: function (component, event, helper) {
    var bookingId = component.get("v.strBookingId");
    var bolId = component.get("v.strBolId");
    var bolName = component.get("v.strBolName");
    helper.downloadPDF(
      component,
      bolId,
      bookingId,
      "CC_ReadyForReleaseViewPDF",
      "Bill of Lading " + bolName
    );
  },
  handleEmailModal: function (component, event, helper) {
    var bookingId = component.get("v.strBookingId");
    var bolId = component.get("v.strBolId");
    var bolName = component.get("v.strBolName");
    component.set("v.showSendEmail", true);
    component.set("v.strBookingId", bookingId);
    component.set("v.strBolId", bolId);
    component.set("v.strBolName", bolName);
    component.set("v.typeOfEmail", "Bill of Lading");
    component.set(
      "v.emailTemplateName",
      $A.get("$Label.c.BOL_For_Release_Email_Template")
    );
    component.set("v.headerVal", "Email Bill of Lading");
  }
});
