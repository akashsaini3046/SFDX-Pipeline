({
  doInit: function (component, event, helper) {
    helper.fireHighlightEvent(component, event, helper);
    var idBooking = helper.getURLParameter("bookingId");
    var idBOL = helper.getURLParameter("bolId");
    component.set("v.strBookingId", idBooking);
    component.set("v.strBolId", idBOL);
    var today = new Date();
    component.set("v.currentDate", today);
    helper.getBol(component, event);
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
    var bolName = component.get("v.BOL.customerReference.billOfLadingNumber");
    helper.downloadPDF(
      component,
      bolId,
      bookingId,
      "CC_ViewShippingInstructionPDF",
      "Shipping Instruction " + bolName
    );
  },
  handleEmailModal: function (component, event, helper) {
    var bookingId = component.get("v.strBookingId");
    var bolId = component.get("v.strBolId");
    var bolName = component.get("v.BOL.customerReference.billOfLadingNumber");
    component.set("v.showSendEmail", true);
    component.set("v.strBookingId", bookingId);
    component.set("v.strBolId", bolId);
    component.set("v.strBolName", bolName);
    component.set("v.typeOfEmail", "Shipping Instruction");
    component.set(
      "v.emailTemplateName",
      $A.get("$Label.c.Shipping_Instruction_Email_Template")
    );
    component.set("v.headerVal", "Email Shipping Instruction");
  }
});
