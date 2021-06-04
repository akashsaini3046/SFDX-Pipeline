({
  setCargoType: function (component, event, cargoType) {
    var bookingWrapper = component.get("v.bookingWrapper");
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
    console.log(
      "Cargo Detail:: setCategory:: Bookingwrapper::" +
        JSON.stringify(bookingWrapper)
    );
    //alert(cargoType);
    component.set("v.bookingWrapper", bookingWrapper);
    component.set("v.cargoType", cargoType);
  }
});
