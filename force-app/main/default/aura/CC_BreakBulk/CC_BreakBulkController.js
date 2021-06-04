({
  doInit: function (component, event, helper) {
    component.set("v.isLoading", true);
    var cargoList = component.get("v.cargoList");

    if (cargoList.length > 0) {
      cargoList[0].cargoType = "BBULK";
      component.set("v.cargoList", cargoList);
    }
    component.set("v.isLoading", false);
  },
  addItem: function (component, event, helper) {
    helper.addItem(component, event, helper);
  },
  removeItem: function (component, event, helper) {
    helper.removeItem(component, event, helper);
  },
  getUnitOfMeasure: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var cargoList = component.get("v.cargoList");
    var isChecked = event.detail.checked;
    var freightDetail = cargoList[0].listFreightDetailWrapper[index];
    if (isChecked == true || isChecked === "true") {
      freightDetail.measureUnit = "kg/m";
    } else {
      freightDetail.measureUnit = "lb/ft";
    }
    component.set("v.cargoList", cargoList);
  },
  validateLengthField: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var selectedId = event.getSource().get("v.value");
    //alert(index);
    helper.validateLengthField(component, event, selectedId, index);
  },
  validateBreakbulkData: function (component, event, helper) {
    return helper.validateBreakbulkData(component, event);
  }
});
