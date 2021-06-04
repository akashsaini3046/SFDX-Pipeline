({
  doInit: function (component, event, helper) {
    helper.getSearchFiledHelper(component);
  },

  handleCloselClick: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
    component.set("v.boolShowFilterModal", false);
  },

  handleSearchClick: function (component, event, helper) {
    if (
      component.get("v.strCalledFor") ==
      $A.get("$Label.c.AINI_CALLED_FOR_ACCOUNT")
    ) {
      helper.handleSearchAccountClickHelper(component);
    } else if (
      component.get("v.strCalledFor") == $A.get("$Label.c.AINI_CALLED_FOR_LEAD")
    ) {
      helper.handleSearchLeadClickHelper(component);
    }
  },

  handleSelectChange: function (component, event, helper) {
    if (
      component.get("v.strCalledFor") ==
      $A.get("$Label.c.AINI_CALLED_FOR_ACCOUNT")
    ) {
      helper.handleAccountSelectChangeHelper(component, event);
    } else if (
      component.get("v.strCalledFor") == $A.get("$Label.c.AINI_CALLED_FOR_LEAD")
    ) {
      helper.handleLeadSelectChangeHelper(component, event);
    }
  },

  handleSaveClick: function (component, event, helper) {
    if (
      component.get("v.strCalledFor") ==
      $A.get("$Label.c.AINI_CALLED_FOR_ACCOUNT")
    ) {
      helper.handleSaveAccountClickHelper(component, helper);
    } else if (
      component.get("v.strCalledFor") == $A.get("$Label.c.AINI_CALLED_FOR_LEAD")
    ) {
      helper.handleSaveLeadClickHelper(component, helper);
    }
  }
});
