({
  sendEmailQuote: function (component, event, helper) {
    var emailAddress = component.get("v.EmailId");
    var contName = "";
    var contNum = "";
    var compName = "";
    var agree = component.get("v.isAgreed");
    var quoteId = component.get("v.QuoteId");
    component.set("v.showSpinner", true);
    var comm = component.get("v.internalComm");
    var action = component.get("c.sendEmail");
    action.setParams({
      emailAddress: emailAddress,
      contactName: contName,
      contactNumber: contNum,
      companyName: compName,
      agree: agree,
      quoteId: quoteId,
      iComm: comm
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var toastEvent = $A.get("e.force:showToast");
      if (state === "SUCCESS") {
        toastEvent.setParams({
          message: "Email Sent Successfully",
          type: "success"
        });
      } else {
        toastEvent.setParams({
          message: "Error sending Email",
          type: "error"
        });
      }
      component.set("v.showSpinner", false);
      toastEvent.fire();
      component.set("v.showEmail", false);
    });
    $A.enqueueAction(action);
  }
});
