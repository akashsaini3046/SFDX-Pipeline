({
  sendEmailShippingInstruction: function (
    component,
    strType,
    strEmailTemplate
  ) {
    var emailAddress = component.get("v.EmailId");
    var bookingId = component.get("v.bookingId");
    var bolId = component.get("v.bolId");
    var bolName = component.get("v.bolName");
    component.set("v.showSpinner", true);
    var action = component.get("c.sendEmail");
    action.setParams({
      emailAddress: emailAddress,
      bookingId: bookingId,
      bolId: bolId,
      bolName: bolName,
      strType: strType,
      strEmailTemplate: strEmailTemplate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(state);
      var toastEvent = $A.get("e.force:showToast");
      if (state === "SUCCESS") {
        toastEvent.setParams({
          message: "Email Sent Successfully",
          type: "success"
        });
      } else {
        console.log(response.getError()[0].message);
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
