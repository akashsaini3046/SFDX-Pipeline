({
  fetchBookingAndRelatedData: function (
    component,
    event,
    helper,
    selectedMenu
  ) {
    this.showSpinner(component);

    var bookingId = component.get("v.recordId");
    var action = component.get("c.getBookingDetail");
    action.setParams({
      bookingId: bookingId,
      selectedMenu: selectedMenu
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (selectedMenu === "details") {
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingFieldNameValue",
            "Booking"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingServiceTypeFieldNameValue",
            "BookingServiceType"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingIMTypeFieldNameValue",
            "BookingIMType"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingTMSTypeFieldNameValue",
            "BookingTMSType"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingCustomerOriginFieldNameValue",
            "BookingCustomerOrigin"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingCustomerDestinationFieldNameValue",
            "BookingCustomerDestination"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingConnectingCarrierFieldNameValue",
            "BookingConnectingCarrier"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingConnectAtLocFieldNameValue",
            "BookingConnectAtLoc"
          );
          this.setBookingRelatedData(
            component,
            responseData,
            "v.bookingConnectToLocFieldNameValue",
            "BookingConnectToLoc"
          );
        }
        if (selectedMenu === "parties") {
          this.setSectionData(component, responseData, "v.partyList", "Party");
        }
        if (selectedMenu === "transports") {
          this.setSectionData(
            component,
            responseData,
            "v.transportList",
            "Transport"
          );
        }
        if (selectedMenu === "stops") {
          this.setSectionData(component, responseData, "v.stopList", "Stop");
        }
        if (selectedMenu === "bookingRemarks") {
          this.setSectionData(
            component,
            responseData,
            "v.bookingRemarkList",
            "BookingRemark"
          );
        }
        if (selectedMenu === "shipment") {
          this.setSectionData(
            component,
            responseData,
            "v.shipmentList",
            "Shipment"
          );
        }
        if (selectedMenu === "customerNotifications") {
          this.setSectionData(
            component,
            responseData,
            "v.customerNotificationList",
            "CustomerNotification"
          );
        }
        if (selectedMenu === "voyages") {
          this.setSectionData(
            component,
            responseData,
            "v.voyageList",
            "Voyage"
          );
        }
        if (selectedMenu === "dockReceipts") {
          this.setSectionData(
            component,
            responseData,
            "v.dockReceiptList",
            "DockReceipt"
          );
        }
        if (selectedMenu === "freightDetails") {
          this.setSectionData(
            component,
            responseData,
            "v.freightDetailList",
            "FreightDetail"
          );
        }
        if (selectedMenu === "commodities") {
          this.setSectionData(
            component,
            responseData,
            "v.commodityList",
            "Commodity"
          );
        }
        if (selectedMenu === "requirements") {
          this.setSectionData(
            component,
            responseData,
            "v.requirementList",
            "Requirement"
          );
        }
        if (selectedMenu === "equipments") {
          this.setSectionData(
            component,
            responseData,
            "v.equipmentList",
            "Equipment"
          );
        }
        component.set("v.currentContent", selectedMenu);
        component.set("v.selectedItem", selectedMenu);
        this.hideSpinner(component);
      } else if (state === "ERROR") {
        let errors = response.getError();
        let message = "";
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        console.error(message);
      } else {
        console.error("Error Unknown !");
      }
    });
    $A.enqueueAction(action);
  },

  setSectionData: function (component, responseData, attribute, sectionName) {
    var sectionRecords = responseData[sectionName];
    var sectionList = [];
    for (var s in sectionRecords) {
      var sectionFieldNameValue = [];
      var sectionRec = sectionRecords[s];
      for (var key in sectionRec) {
        sectionFieldNameValue.push({ label: key, value: sectionRec[key] });
      }
      sectionList.push(sectionFieldNameValue);
    }
    component.set(attribute, sectionList);
  },
  setBookingRelatedData: function (
    component,
    responseData,
    attribute,
    sectionName
  ) {
    var record = responseData[sectionName][0];
    var varFieldNameValue = [];
    for (var key in record)
      varFieldNameValue.push({ label: key, value: record[key] });
    component.set(attribute, varFieldNameValue);
  },
  showSpinner: function (component) {
    component.set("v.spinner", true);
  },
  hideSpinner: function (component) {
    component.set("v.spinner", false);
  }
});
