({
  getAccount: function (component, event, helper) {
    var selectedAccountId = component.get("v.selectedAccountId");
    if (
      selectedAccountId &&
      selectedAccountId != null &&
      selectedAccountId != ""
    ) {
      var action = component.get("c.fetchAccountDetails");
      action.setParams({
        accountId: selectedAccountId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var account = response.getReturnValue();
          component.set("v.account", account);
          component.set("v.selectedAccount", account.Name);
        } else {
          console.log("Error occured in fetching Account Details");
          component.set("v.isLoading", false);
        }
        component.set("v.isLoading", false);
      });
      $A.enqueueAction(action);
    }
  },
  getAddress: function (component, event, helper) {
    var selectedAddressId = component.get("v.selectedAddressId");
    if (
      selectedAddressId &&
      selectedAddressId != null &&
      selectedAddressId != ""
    ) {
      var action = component.get("c.fetchAddressDetails");
      action.setParams({
        addressId: selectedAddressId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var address = response.getReturnValue();
          component.set("v.address", address);
          component.set("v.selectedAddress", address.Name);
        } else {
          console.log("Error occured in fetching Address Details");
          component.set("v.isLoading", false);
        }
        component.set("v.isLoading", false);
      });
      $A.enqueueAction(action);
    }
  },
  getContact: function (component, event, helper) {
    var selectedContactId = component.get("v.selectedContactId");
    if (
      selectedContactId &&
      selectedContactId != null &&
      selectedContactId != ""
    ) {
      var action = component.get("c.fetchContactDetails");
      action.setParams({
        contactId: selectedContactId
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var contact = response.getReturnValue();
          component.set("v.contact", contact);
          component.set("v.selectedContact", contact.Name);
        } else {
          console.log("Error occured in fetching Contact Details");
          component.set("v.isLoading", false);
        }
        component.set("v.isLoading", false);
      });
      $A.enqueueAction(action);
    }
  },
  getAccountDetails: function (component, event, helper, selectedAccountId) {
    var action = component.get("c.fetchAccountDetails");
    action.setParams({
      accountId: selectedAccountId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var account = response.getReturnValue();
        component.set("v.account", account);
        if (component.get("v.isAccountChanged")) {
          component.set("v.selectedContact", "");
          component.set("v.selectedContactId", "");
          component.set("v.selectedAddress", "");
          component.set("v.selectedAddressId", "");
          component.set("v.address", null);
          component.set("v.contact", null);
          component.set("v.isAccountChanged", false);
        }
      } else {
        console.log("Error occured in fetching Account Details");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getAddressDetails: function (component, event, helper, selectedAddressId) {
    var action = component.get("c.fetchAddressDetails");
    action.setParams({
      addressId: selectedAddressId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var address = response.getReturnValue();
        component.set("v.address", address);
      } else {
        console.log("Error occured in fetching Address Details");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  getContactDetails: function (component, event, helper, selectedContactId) {
    var action = component.get("c.fetchContactDetails");
    action.setParams({
      contactId: selectedContactId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var contact = response.getReturnValue();
        component.set("v.contact", contact);
      } else {
        console.log("Error occured in fetching Contact Details");
        component.set("v.isLoading", false);
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  }
});
