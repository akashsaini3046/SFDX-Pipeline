({
  doInit: function (component, event, helper) {
    var options = component.get("v.options");
    options.forEach(function (element) {
      element.selected = false;
    });
    var containerCode = component.get("v.containerCode");
    var isLabelMatch = component.get("v.isLabelMatch");
    if (containerCode && containerCode != "") {
      options.map((item) => {
        var match;
        if (isLabelMatch) {
          match = item.label;
        } else {
          match = item.value;
        }
        if (containerCode == match) {
          item.selected = true;
          component.set("v.infoText", item.label);
          component.set("v.selectedItem", item);
        }
      });
    } else {
      component.set("v.infoText", "");
      component.set("v.selectedItem", "");
    }
    component.set("v.optionsValues", options);
  },
  handleSelection: function (component, event, helper) {
    var item = event.currentTarget;
    if (item && item.dataset) {
      var value = item.dataset.value;
      //var selected = item.dataset.selected;
      var options = component.get("v.optionsValues");
      options.forEach(function (element) {
        if (element.value == value) {
          element.selected = true;
          component.set("v.infoText", element.label);
          component.set("v.selectedItem", element);
          component.set("v.containerCode", element.value);
        } else {
          element.selected = false;
        }
      });
      var infoText = component.get("v.infoText");
      var isRequired = component.get("v.isRequired");
      if ((typeof infoText == "undefined" || infoText == "") && isRequired) {
        component.set("v.isError", true);
        $A.util.addClass(component.find("main-div"), "slds-has-error");
      } else {
        component.set("v.isError", false);
        $A.util.removeClass(component.find("main-div"), "slds-has-error");
      }
      component.set("v.optionsValues", options);
      var mainDiv = component.find("main-div");
      $A.util.removeClass(mainDiv, "slds-is-open");
    }
  },

  handleClick: function (component, event, helper) {
    component.set("v.isError", false);
    $A.util.removeClass(component.find("main-div"), "slds-has-error");
    var mainDiv = component.find("main-div");
    $A.util.addClass(mainDiv, "slds-is-open");
    var inputBox = component.find("inputBox");
    $A.util.addClass(inputBox, "slds-has-focus");
    event.stopPropagation();
  },

  handleMouseLeave: function (component, event, helper) {
    component.set("v.dropdownOver", false);
    var mainDiv = component.find("main-div");
    $A.util.removeClass(mainDiv, "slds-is-open");
    var inputBox = component.find("inputBox");
    $A.util.removeClass(inputBox, "slds-has-focus");
    var compEvent = component.getEvent("selectedItemEvent");
    compEvent.setParams({
      selectedItem: component.get("v.infoText"),
      selectedItemID: component.get("v.containerCode"),
      index: component.get("v.index"),
      functionality: component.get("v.functionality")
    });
    compEvent.fire();
    var infoText = component.get("v.infoText");
    var isRequired = component.get("v.isRequired");
    if ((typeof infoText == "undefined" || infoText == "") && isRequired) {
      component.set("v.isError", true);
      $A.util.addClass(component.find("main-div"), "slds-has-error");
    } else {
      component.set("v.isError", false);
      $A.util.removeClass(component.find("main-div"), "slds-has-error");
    }
  },

  handleMouseEnter: function (component, event, helper) {
    component.set("v.dropdownOver", true);
  },

  handleMouseOutButton: function (component, event, helper) {
    window.setTimeout(
      $A.getCallback(function () {
        if (component.isValid()) {
          if (component.get("v.dropdownOver")) {
            return;
          }
          var mainDiv = component.find("main-div");
          $A.util.removeClass(mainDiv, "slds-is-open");
          var inputBox = component.find("inputBox");
          $A.util.removeClass(inputBox, "slds-has-focus");
        }
      }),
      200
    );
  },
  showError: function (component, event, helper) {
    component.set("v.isError", true);
    $A.util.addClass(component.find("main-div"), "slds-has-error");
  },
  doValidate: function (component, event) {
    var controlAuraIds = ["inputBox"];
    let isAllValid = controlAuraIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      inputCmp.reportValidity();
      return isValidSoFar && inputCmp.checkValidity();
    },
    true);
    return isAllValid;
  }
});
