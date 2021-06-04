({
  fireHighlightEvent: function (component, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = component.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  },
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
  getQuoteNumber: function (component, event, helper, qId) {
    var action = component.get("c.getQuotationNumber");
    action.setParams({
      quoId: qId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        //alert('getting quote number'+res.Name);
        component.set("v.quotationNumber", res.Name);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          console.log("Errors", errors);
          if (errors[0] && errors[0].message) {
            throw new Error("Error" + errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action);
  }
});
