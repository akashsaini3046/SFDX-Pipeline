({
  doInit: function (component, event, helper) {
    component.set("v.selectedItem", "details");
    component.set("v.currentContent", "details");
    helper.fetchBookingAndRelatedData(component, event, helper, "details");
  },

  toggleSection: function (component, event, helper) {
    var sectionAuraId = event.target.getAttribute("data-auraId");
    var hasClassCollapse = $A.util.hasClass(
      component.find(sectionAuraId),
      "slds-is-open"
    );
    if (!hasClassCollapse) {
      $A.util.addClass(
        component.find(sectionAuraId),
        "slds-section slds-is-open"
      );
      $A.util.removeClass(component.find(sectionAuraId), "slds-is-close");
    } else {
      $A.util.addClass(
        component.find(sectionAuraId),
        "slds-section slds-is-close"
      );
      $A.util.removeClass(component.find(sectionAuraId), "slds-is-open");
    }
  },

  handleSelect: function (component, event, helper) {
    var selected = event.getParam("name");
    if (selected !== "documents" && selected !== "rating") {
      helper.fetchBookingAndRelatedData(component, event, helper, selected);
    } else {
      component.set("v.currentContent", selected);
      component.set("v.selectedItem", selected);
    }
  },

  handleComponentEvent: function (component, event, helper) {
    helper.handleComponentEvent(component, event, helper);
  },

  handleValidateIMDG: function (component, event, helper) {
    helper.handleValidateIMDG(component, event, helper);
  }
});
