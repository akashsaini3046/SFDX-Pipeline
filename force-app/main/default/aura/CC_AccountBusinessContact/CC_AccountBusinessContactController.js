({
  doInit: function (component, event, helper) {
    helper.getAccount(component, event, helper);
    helper.getAddress(component, event, helper);
    helper.getContact(component, event, helper);
  },
  handleSelectedItemEvent: function (component, event, helper) {
    var selectedId = event.getParams()["selectedItemID"];
    var selectedItem = event.getParams()["selectedItem"];
    var functionality = event.getParams()["functionality"];
    if (functionality === "Combo:Account") {
      var previousAccount = component.get("v.selectedAccount");
      if (previousAccount || previousAccount == "") {
        component.set("v.isAccountChanged", true);
      }
      component.set("v.selectedAccount", selectedItem);
      component.set("v.selectedAccountId", selectedId);
    } else if (functionality === "Combo:Address") {
      component.set("v.selectedAddress", selectedItem);
      component.set("v.selectedAddressId", selectedId);
    } else if (functionality === "Combo:Contact") {
      component.set("v.selectedContact", selectedItem);
      component.set("v.selectedContactId", selectedId);
    }
  },

  handleSelectedAccountIdChange: function (component, event, helper) {
    var selectedAccountId = event.getParam("value");
    if (selectedAccountId && selectedAccountId != "") {
      component.set("v.isDisableDependent", false);
      helper.getAccountDetails(component, event, helper, selectedAccountId);
    } else {
      component.set("v.isDisableDependent", true);
      component.set("v.selectedContact", "");
      component.set("v.selectedContactId", "");
      component.set("v.selectedAddress", "");
      component.set("v.selectedAddressId", "");
      component.set("v.account", null);
      component.set("v.address", null);
      component.set("v.contact", null);
    }
  },

  handleSelectedAddressIdChange: function (component, event, helper) {
    var selectedAddressId = event.getParam("value");
    if (selectedAddressId && selectedAddressId != "") {
      helper.getAddressDetails(component, event, helper, selectedAddressId);
    } else {
      component.set("v.selectedAddress", "");
      component.set("v.selectedAddressId", "");
      component.set("v.address", null);
    }
  },

  handleSelectedContactIdChange: function (component, event, helper) {
    var selectedContactId = event.getParam("value");
    if (selectedContactId && selectedContactId != "") {
      helper.getContactDetails(component, event, helper, selectedContactId);
    } else {
      component.set("v.selectedContact", "");
      component.set("v.selectedContactId", "");
      component.set("v.contact", null);
    }
  },
  doValidate: function (component, event) {
    var isAccountValid = true;
    var isAddressValid = true;
    var isContactValid = true;
    if (component.get("v.isAccountRequired")) {
      isAccountValid = component.find("accountId").doValidityCheck();
    }
    if (component.get("v.isAddressRequired")) {
      isAddressValid = component.find("addressId").doValidityCheck();
    }
    if (component.get("v.isContactRequired")) {
      isContactValid = component.find("contactId").doValidityCheck();
    }
    return isAccountValid && isAddressValid && isContactValid;
  },

  handleAllObjectsChange: function (component, event, helper) {
    var allObjects = component.get("v.allObjects");
    allObjects.map((item) => {
      if (item.Account) {
        component.set("v.selectedAccountId", item.Account.Id);
      }
      if (item.Location) {
        component.set("v.selectedAddressId", item.Location.Id);
      }
      if (item.Contact) {
        component.set("v.selectedContactId", item.Contact.Id);
      }
    });
    helper.getAccount(component, event, helper);
    helper.getAddress(component, event, helper);
    helper.getContact(component, event, helper);
  }
});
