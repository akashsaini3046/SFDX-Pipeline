({
  openModel: function (component, event, helper) {
    // for Display Model,set the "isOpen" attribute to "true"
    var action = component.get("c.getOpportunityStageValue");
    action.setParams({ opportunityId: component.get("v.recordId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        component.set("v.isOpen", returnValue);
      } else if (state === "INCOMPLETE") {
        // do something
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

    var action2 = component.get("c.getQuotedPriceOfOpportunity");
    action2.setParams({ opportunityId: component.get("v.recordId") });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        component.set("v.quotedPrice", returnValue);
      } else if (state === "INCOMPLETE") {
        // do something
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
    $A.enqueueAction(action2);
  },

  closeModel: function (component, event, helper) {
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
    component.set("v.isOpen", false);
  },

  likenClose: function (component, event, helper) {
    //alert('thank you :)');
    component.set("v.isOpen", false);
  }
});
