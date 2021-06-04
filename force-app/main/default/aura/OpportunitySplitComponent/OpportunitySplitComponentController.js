({
  doInit: function (component, event, helper) {
    helper.doInitHelper(component, helper);
  },

  handleSaveSplitClick: function (component, event, helper) {
    helper.handleSaveSplitClickHelper(component, helper);
  },

  handleWonAllClick: function (component, event, helper) {
    helper.handleWonAllClickHelper(component);
  },

  handleLostAllClick: function (component, event, helper) {
    helper.handleLostAllClickHelper(component);
  },

  handleCloselClick: function (component, event, helper) {
    helper.handleCloselClickHelper(component, helper);
  },

  serviceStatusChangeHandler: function (component, event, helper) {
    helper.serviceStatusChangeHandler(component, event);
  }
});
