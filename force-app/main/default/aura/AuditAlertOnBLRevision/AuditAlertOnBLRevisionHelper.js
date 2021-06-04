({
  showPopupAction: function (cmp, event, helper) {
    var caseId = cmp.get("v.recordId");
    var action = cmp.get("c.showAuditAlert");
    action.setParams({
      caseId: caseId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        helper.showToast(
          cmp,
          helper,
          "warning",
          "Please check the Number of Bill Revisions matches with BOL/BKG Number(s).",
          " "
        );
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },

  showToast: function (cmp, helper, type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      mode: "sticky",
      title: title,
      message: message,
      type: type
    });
    toastEvent.fire();
  }
});
