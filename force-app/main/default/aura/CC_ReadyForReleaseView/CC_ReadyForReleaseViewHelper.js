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
  getBol: function (component, event) {
    var action = component.get("c.getBol");
    component.set("v.boolSpinner", true);
    action.setParams({
      bookingId: component.get("v.strBookingId"),
      bolId: component.get("v.strBolId"),
      isForEdit: false
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var data = response.getReturnValue();
        if (data) {
          console.log("data: " + JSON.stringify(data));
          component.set("v.BOL", data);
          component.set(
            "v.strBolName",
            data.customerReference.billOfLadingNumber
          );
          if (data) {
            var shipperList = [];
            if (data.shipperLst.length > 0) {
              shipperList.push(data.shipperLst[0]);
            }
            component.set("v.ShipperList", shipperList);
            var conList = [];
            if (data.consigneeLst.length > 0) {
              conList.push(data.consigneeLst[0]);
            }
            component.set("v.ConsigneeList", conList);
          }
          //component.set("v.ITNNumber",data.itnNumber);
        }
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(action);
  },
  downloadPDF: function (component, bolId, bookingId, pageName, fileName) {
    component.set("v.boolSpinner", true);
    var action = component.get("c.fetchPDFUrl");
    action.setParams({
      bookingId: bookingId,
      bolId: bolId,
      strPageName: pageName
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var source = response.getReturnValue();
        var hiddenElement = document.createElement("a");
        hiddenElement.href = source;
        hiddenElement.target = "_self";
        hiddenElement.download = fileName;
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();
      } else if (state === "ERROR") {
        console.log("error");
        let errors = response.getError();
        let message = "";
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        console.error(message);
      }
      component.set("v.boolSpinner", false);
    });
    $A.enqueueAction(action);
  },
  fireHighlightEvent: function (component, event, helper) {
    var appEvent = $A.get("e.c:CC_HighlightedMenu");
    var compname = component.get("v.componentName");
    appEvent.setParams({ selectedMenu: compname });
    appEvent.fire();
  }
});
