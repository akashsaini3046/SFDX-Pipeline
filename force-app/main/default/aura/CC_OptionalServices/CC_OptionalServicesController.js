({
  doInit: function (component, event, helper) {
    helper.getPicklistValues(component, event, helper);
  },

  reInit: function (component, event) {
    var commodityTypesId = component.find("OppServiceTypesId");
    if (commodityTypesId.length > 0) {
      commodityTypesId.map((item) => {
        item.reInit();
      });
    } else {
      commodityTypesId.reInit();
    }
  },
  handleNumberChange: function (component, event, helper) {
    var FieldLabel = event.getSource().get("v.label");
    var fieldId = event.getSource().getLocalId();
    var check = event.getSource().get("v.value");
    if (fieldId == "boxPack6" && !check) {
      component.set("v.masterObjServices.Additional_Chains_Qty__c", null);
    } else if (fieldId == "boxPack7" && !check) {
      component.set("v.masterObjServices.Additional_BoLs__c", null);
    } else if (fieldId == "boxPack10" && !check) {
      component.set("v.masterObjServices.Additional_Straps_Qty__c", null);
    }
  },
  validateContainerData: function (component, event, helper) {
    return helper.validateContainerData(component, event);
  }
});
