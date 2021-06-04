({
  modifyData: function (component, event, helper) {
    var data = component.get("v.data");
    var modifiedData = [];
    data.map((item) => {
      var modItem = item;
      if (modItem.billOfLading.Bill_of_lading_Status__c) {
        //modItem.billOfLading.statusClass = this.handleStatusClass(modItem.booking.Description__c);
        switch (modItem.billOfLading.Bill_of_lading_Status__c.toUpperCase()) {
          case "IN PROCESS":
            modItem.billOfLading.statusClass = "process";
            break;
          case "PENDING":
            modItem.billOfLading.statusClass = "pending";
            break;
          case "SUBMITTED":
            modItem.billOfLading.statusClass = "submitted";
            break;
          case "BOL FOR REVIEW":
            modItem.billOfLading.statusClass = "review";
            break;
        }
      }
      modifiedData.push(modItem);
    });
    component.set("v.modifiedData", modifiedData);
  },
  handleDescription: function (status) {},
  navigateTopage: function (component, pageName, bolId, bookingId) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: pageName
      },
      state: {
        bookingId: bookingId,
        bolId: bolId
      }
    };
    navService.navigate(pageReference);
  },

  PageNavigation: function (component, event) {
    var bolAndBookingId = event.currentTarget.id;
    var bolId;
    var bookingId;
    var status;
    if (
      bolAndBookingId != null &&
      bolAndBookingId != "" &&
      bolAndBookingId != undefined
    ) {
      var bolAndBookingIdSplits = bolAndBookingId.split(" ");
      if (bolAndBookingIdSplits.length > 1) {
        bolId = bolAndBookingIdSplits[0];
        bookingId = bolAndBookingIdSplits[1];
        status = bolAndBookingIdSplits[2];
        if (bolAndBookingIdSplits.length == 4) {
          status = status + bolAndBookingIdSplits[3];
        }
      }
    }
    if (status == "INPROCESS" || status == "PENDING") {
      this.navigateTopage(
        component,
        "edit-shipping-instruction",
        bolId,
        bookingId
      );
    } else if (status == "SUBMITTED") {
      this.navigateTopage(
        component,
        "view-submitted-shipping-instruction",
        bolId,
        bookingId
      );
    } else if (status == "BOLFORREVIEW" || status == "RR") {
      this.navigateTopage(
        component,
        "view-ready-for-release",
        bolId,
        bookingId
      );
    }
  },

  handleMenuSelectHelper: function (component, event) {
    var selectedItem = event.getParam("value");
    var bolAndBookingId = event.getSource().get("v.name");
    var bolId;
    var bookingId;
    var bolName;
    if (
      bolAndBookingId != null &&
      bolAndBookingId != "" &&
      bolAndBookingId != undefined
    ) {
      var bolAndBookingIdSplits = bolAndBookingId.split(" ");
      if (bolAndBookingIdSplits.length > 1) {
        bolId = bolAndBookingIdSplits[0];
        bookingId = bolAndBookingIdSplits[1];
        bolName = bolAndBookingIdSplits[2];
      }
    }

    if (
      selectedItem != null &&
      selectedItem != "" &&
      selectedItem != undefined
    ) {
      var selectedItemSplits = selectedItem.split(" ");
      var selecteAction;
      var status;
      if (selectedItemSplits.length > 1) {
        selecteAction = selectedItemSplits[0];
        status = selectedItemSplits[1];
        if (selecteAction == "view" && status == "INPROCESS") {
          this.navigateTopage(
            component,
            "edit-shipping-instruction",
            bolId,
            bookingId
          );
        } else if (selecteAction == "view" && status == "PENDING") {
          this.navigateTopage(
            component,
            "edit-shipping-instruction",
            bolId,
            bookingId
          );
        } else if (selecteAction == "view" && status == "SUBMITTED") {
          this.navigateTopage(
            component,
            "view-submitted-shipping-instruction",
            bolId,
            bookingId
          );
        } else if (selecteAction == "download" && status == "SUBMITTED") {
          this.downloadPDF(
            component,
            bolId,
            bookingId,
            "CC_ViewShippingInstructionPDF",
            "Shipping Instruction " + bolName
          );
        } else if (selecteAction == "email" && status == "SUBMITTED") {
          component.set("v.showSendEmail", true);
          component.set("v.strBookingId", bookingId);
          component.set("v.strBolId", bolId);
          component.set("v.strBolName", bolName);
          component.set("v.typeOfEmail", "Shipping Instruction");
          component.set(
            "v.emailTemplateName",
            $A.get("$Label.c.Shipping_Instruction_Email_Template")
          );
          component.set("v.headerVal", "Email Shipping Instruction");
        } else if (selecteAction == "view" && status == "BOLFORREVIEW") {
          this.navigateTopage(
            component,
            "view-ready-for-release",
            bolId,
            bookingId
          );
        } else if (selecteAction == "download" && status == "BOLFORREVIEW") {
          this.downloadPDF(
            component,
            bolId,
            bookingId,
            "CC_ReadyForReleaseViewPDF",
            "Bill of Lading " + bolName
          );
        } else if (selecteAction == "email" && status == "BOLFORREVIEW") {
          //Email code
        } else if (selecteAction == "view" && status == "RR") {
          this.navigateTopage(
            component,
            "view-ready-for-release",
            bolId,
            bookingId
          );
        } else if (selecteAction == "download" && status == "RR") {
          this.downloadPDF(
            component,
            bolId,
            bookingId,
            "CC_ReadyForReleaseViewPDF",
            "Bill of Lading " + bolName
          );
        } else if (selecteAction == "email" && status == "RR") {
          component.set("v.showSendEmail", true);
          component.set("v.strBookingId", bookingId);
          component.set("v.strBolId", bolId);
          component.set("v.strBolName", bolName);
          component.set("v.typeOfEmail", "Bill of Lading");
          component.set(
            "v.emailTemplateName",
            $A.get("$Label.c.BOL_For_Release_Email_Template")
          );
          component.set("v.headerVal", "Email Bill of Lading");
        }
      }
    }
  },

  downloadPDF: function (component, bolId, bookingId, pageName, fileName) {
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
    });
    $A.enqueueAction(action);
  }
});
