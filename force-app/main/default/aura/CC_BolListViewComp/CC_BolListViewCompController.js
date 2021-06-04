({
  doInit: function (component, event, helper) {},
  handleDataValueChange: function (component, event, helper) {
    helper.modifyData(component, event, helper);
  },
  handleMenuSelect: function (component, event, helper) {
    helper.handleMenuSelectHelper(component, event);
  },
  handlePageNavigation: function (component, event, helper) {
    helper.PageNavigation(component, event);
  }
});
