({
  handleCloselClick: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
    component.set("v.boolShowFilterModal", false);
  },

  doInit: function (component, event, helper) {
    helper.doInitHelper(component);
  },

  handleChange: function (component, event, helper) {
    var selectedOptionValue = event.getParam("value");
    if (
      selectedOptionValue != "" &&
      selectedOptionValue != null &&
      selectedOptionValue != $A.get("$Label.c.AINI_OPTION_SELECT_INITIATIVE")
    ) {
      component.set("v.boolDisabledSaveButton", false);
    } else {
      component.set("v.boolDisabledSaveButton", true);
    }
  },

  handleSaveClick: function (component, event, helper) {
    helper.handleSaveClickHelper(component, helper);
  }
});
