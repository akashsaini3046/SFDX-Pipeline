({
  doInit: function (component, event, helper) {
    var bookingWrapper = component.get("v.bookingWrapper");
    console.log(bookingWrapper);
    var shipmentMap1 = bookingWrapper.shipmentMap;
    console.log(shipmentMap1);
    var vehShipment = shipmentMap1["VEHICLE"];
    console.log(vehShipment);
    var bbShipment = shipmentMap1["BREAKBULK"];
    var contShipment = shipmentMap1["CONTAINER"];
    if (vehShipment.isSelected) {
      helper.setCargoType(component, event, "vehicle");
    } else if (bbShipment.isSelected) {
      helper.setCargoType(component, event, "breakbulk");
    } else if (contShipment.isSelected) {
      helper.setCargoType(component, event, "container");
    }
  },
  handleQuoteEvent: function (component, event, helper) {
    var message = event.getParam("action");
    //alert(message);
    if (message == "deleteVehicleItem") {
      //helper.setCargoType(component, event,'vehicle');
    }
  },
  selectContainer: function (component, event, helper) {
    helper.setCargoType(component, event, "container");
  },
  selectBreakbulk: function (component, event, helper) {
    helper.setCargoType(component, event, "breakbulk");
  },
  selectVehicle: function (component, event, helper) {
    helper.setCargoType(component, event, "vehicle");
  },
  selectCargoType: function (component, event, helper) {
    var bookingWrapper = component.get("v.bookingWrapper");
    var cargoType = event.getSource().get("v.text");
    alert(cargoType);
    bookingWrapper.shipmentMap.CONTAINER.isSelected = false;
    bookingWrapper.shipmentMap.BREAKBULK.isSelected = false;
    bookingWrapper.shipmentMap.VEHICLE.isSelected = false;
    //alert(cargoType);
    if (cargoType === "container") {
      bookingWrapper.shipmentMap.CONTAINER.isSelected = true;
    }
    if (cargoType === "breakbulk") {
      bookingWrapper.shipmentMap.BREAKBULK.isSelected = true;
    }
    if (cargoType === "vehicle") {
      bookingWrapper.shipmentMap.VEHICLE.isSelected = true;
    }
    console.log(bookingWrapper);
    alert(cargoType);
    component.set("v.bookingWrapper", bookingWrapper);
    component.set("v.cargoType", cargoType);
  },
  validateContainerData: function (component, event, helper) {
    var sizeType = component.find("containerId");
    var isValidContainer = sizeType.validateContainerData();
    return isValidContainer;
    //return helper.validateContainerData(component, event);
  },
  validateBreakbulData: function (component, event, helper) {
    var sizeType = component.find("breakbulkId");
    var isValidBreakbulk = sizeType.validateBreakbulData();
    return isValidBreakbulk;
  },

  validateVehicleData: function (component, event, helper) {
    var sizeType = component.find("vehicleAutoId");
    var isValidVehicle = sizeType.validateVehicleInfo();
    return isValidVehicle;
  },
  uploadfile: function (component, event, helper) {
    var childComponent = component.find("containerId");
    if (childComponent) {
      childComponent.uploadfile();
    }
  }
});
