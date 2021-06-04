({
  validateContainerData: function (component, event) {
    var controlAuraInputIds = ["inputFieldId"];
    let isAllValid = controlAuraInputIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      if (inputCmp.length > 0) {
        var isvalidcheck = true;
        for (var i = 0; i < inputCmp.length; i++) {
          inputCmp[i].reportValidity();
          //return ;
          if ((isValidSoFar && inputCmp[i].checkValidity()) == false) {
            isvalidcheck = false;
            //break;
          }
        }
        return isvalidcheck;
      } else {
        inputCmp.reportValidity();
        return isValidSoFar && inputCmp.checkValidity();
      }
    },
    true);

    return isAllValid;
  },
  getPicklistValues: function (component, event, helper) {
    var lstFieldNameRequirement = ["Marine_Cargo_Insurance__c"];
    //{'objectName1',List<fieldNames>,'objectName2',List<fieldNames>}
    var mapToSend = { Requirement__c: lstFieldNameRequirement };
    var action = component.get("c.fetchMultiplePickListValues");
    action.setParams({
      mapFieldValuestoGet: mapToSend
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state " + state);
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        console.log("res" + JSON.stringify(res));
        var MarineCargofieldMap =
          res["Requirement__c~Marine_Cargo_Insurance__c"];
        var marineoptions = [];
        for (var singlekey in MarineCargofieldMap) {
          marineoptions.push({
            label: singlekey,
            value: MarineCargofieldMap[singlekey],
            isShowIcon: false
          });
        }
        component.set("v.lstMarineCargoInsur", marineoptions);

        var OppServiceTypesId = component.find("OppServiceTypesId");
        if (!$A.util.isUndefined(OppServiceTypesId)) {
          if (OppServiceTypesId.length > 0) {
            OppServiceTypesId.map((item) => {
              item.reInit();
            });
          } else {
            OppServiceTypesId.reInit();
          }
        }
      } else {
        console.log("Error Occured");
      }
    });
    $A.enqueueAction(action);
  }
});
