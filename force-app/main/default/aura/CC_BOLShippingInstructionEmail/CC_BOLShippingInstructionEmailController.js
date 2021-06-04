({
  doInit: function (component, event, helper) {},

  onCheck: function (cmp, evt) {
    var checkCmp = cmp.find("checkbox");
    cmp.set("v.isAgreed", checkCmp.get("v.value"));
  },

  closeModal: function (cmp, evt) {
    cmp.set("v.showEmail", false);
  },

  SendEmailHandler: function (component, event, helper) {
    var controlAuraIds = ["emailAddress"];
    let isAllValid = controlAuraIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      inputCmp.reportValidity();
      return isValidSoFar && inputCmp.checkValidity();
    },
    true);
    if (isAllValid) {
      helper.sendEmailShippingInstruction(
        component,
        component.get("v.typeOfEmail"),
        component.get("v.emailTemplateName")
      );
    }
  }
});
