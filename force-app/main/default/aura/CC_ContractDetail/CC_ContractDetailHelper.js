({
  getURLParameter: function (key) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1));
    var sURLVariables = sPageURL.split("&");
    var sParameterName;
    var i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split("=");
      if (sParameterName[0] == key) {
        return sParameterName[1];
      }
    }
    return "";
  },

  getContracts: function (component, event, helper, limit, offset) {
    var contractId = component.get("v.recordId");
    var action = component.get("c.getContractsRecord");
    action.setParams({
      contractId: contractId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        console.log("res", res);
        if (res.affiliatesList) {
          component.set("v.records", res.affiliatesList);
        }
        if (res.contract) {
          component.set("v.contract", res.contract);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast("error", "Error!", errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});
