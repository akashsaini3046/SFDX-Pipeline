({
  doInit: function (component, event, helper) {
    //helper.sortTransitTime(component, event, 'asc');
    helper.sortDepartureDate(component, event, "asc");
    console.log(component.get("v.booking"));
  },
  handleComponentEvent: function (component, event, helper) {
    console.log("handleComponentEvent");
    //window.print();
    component.set("v.firePrint", true);
  },
  printScreen: function (component, event, helper) {
    helper.printFullList(component, event);
    var elements = document.getElementsByClassName("header");
    var headerdiv = document.getElementsByClassName("header-div");
    headerdiv[0].style.display = "none";
    elements[0].style.display = "none";
    //window.print();
    elements[0].style.display = "block";
    headerdiv[0].style.display = "block";
  },
  sortingTransitTime: function (component, event, helper) {
    helper.sortingTransitTime(component, event);
  },
  sortingDepartureDate: function (component, event, helper) {
    helper.sortingDepartureDate(component, event);
  },

  addEmail: function (component, event, helper) {
    var emails = component.get("v.emailAddresses");
    emails.push({ emailValue: "" });
    component.set("v.emailAddresses", emails);
  },
  removeEmail: function (component, event, helper) {
    var currentTarget = event.currentTarget;
    var index = currentTarget.dataset.value;
    console.log(index);
    var emails = component.get("v.emailAddresses");
    emails.splice(index, 1);
    component.set("v.emailAddresses", emails);
  },
  closeModal: function (component, event, helper) {
    var emails = component.get("v.emailAddresses");
    console.log(emails);
    component.set("v.emailAddresses", []);
    component.set("v.showEmailModal", false);
    component.set("v.isEmailSend", false);
  },
  getToggleIncludeTime: function (component, event, helper) {
    var checkCmp = component.find("tglbtn").get("v.checked");
    component.set("v.includeTime", checkCmp);
  },
  send: function (component, event, helper) {
    helper.getRouteRecordId(component, event);
  },
  handleMenuSelect: function (component, event, helper) {
    var selectedMenuItemValue = event.getParam("value");
    var index = event.getSource().get("v.name");
    console.log("index " + index);
    switch (selectedMenuItemValue) {
      case "email":
        helper.openEmailModal(component, event, index);
        break;
      case "quote":
        alert("Under Construction");
    }
  },
  handleSelectedSchedule: function (component, event, helper) {
    var selectedScheduleNum = event.target.value;
    var selectedScheduleChecked = event.target.checked;
    if (!selectedScheduleChecked)
      component.set("v.checkSelectedAll", selectedScheduleChecked);
    var selectedSchedulesList = component.get("v.selectedSchedulesList");
    selectedSchedulesList.push(selectedScheduleNum);
    var newList = [];
    selectedSchedulesList.map((item) => {
      if (item == selectedScheduleNum) {
        if (selectedScheduleChecked) {
          newList.push(item);
        }
      } else {
        newList.push(item);
      }
    });
    component.set("v.selectedSchedulesList", newList);
    console.log(newList);
  },
  handleSelectAllSchedules: function (component, event, helper) {
    var selectedScheduleChecked = event.target.checked;

    component.set("v.checkSelectedAll", selectedScheduleChecked);
    if (selectedScheduleChecked) {
      component.set("v.checkAll", false);
      component.set("v.checkAll", true);
      var newList = [];
      var schedules = component.get("v.schedules");
      for (var i in schedules) newList.push(schedules[i].sequenceNumber);
      component.set("v.selectedSchedulesList", newList);
    }

    if (!selectedScheduleChecked) {
      component.set("v.checkAll", selectedScheduleChecked);
      component.set("v.selectedSchedulesList", null);
    }
  },
  handleEmailClick: function (component, event, helper) {
    var selectedSchedulesList = component.get("v.selectedSchedulesList");
    console.log(selectedSchedulesList);
    if (selectedSchedulesList.length === 0) {
      var toastEvent = $A.get("e.force:showToast");

      toastEvent.setParams({
        title: "Email Status",
        message: "Select atleast one schedule.",
        type: "info"
      });
      toastEvent.fire();
    } else {
      var emails = component.get("v.emailAddresses");
      emails.push({ emailValue: "" });
      component.set("v.emailAddresses", emails);
      component.set("v.showEmailModal", true);
      component.set("v.isEmailSend", false);
    }
  },
  handleQuoteClick: function (component, event, helper) {
    console.log(
      ' component.get("v.searchKeywordPOL") ' +
        component.get("v.searchKeywordPOL")
    );
    console.log(
      ' component.get("v.searchKeywordPOD") ' +
        component.get("v.searchKeywordPOD")
    );
    console.log(
      ' component.get("v.selectedOriginLocation") ' +
        component.get("v.selectedOriginLocation")
    );
    console.log(
      ' component.get("v.selectedDestinationLocation") ' +
        component.get("v.selectedDestinationLocation")
    );
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "get-a-quote"
      },
      state: {
        selectedOriginLocation: component.get("v.selectedOriginLocation"),
        selectedDestinationLocation: component.get(
          "v.selectedDestinationLocation"
        ),
        booking: JSON.stringify(component.get("v.booking")),
        originMove: component.get("v.originMove"),
        destinationMove: component.get("v.destinationMove"),
        searchKeywordPOL: component.get("v.searchKeywordPOL"),
        searchKeywordPOD: component.get("v.searchKeywordPOD"),
        clickedItemOrigin: component.get("v.clickedItemOrigin"),
        clickedItemIdOrigin: component.get("v.clickedItemIdOrigin"),
        clickedItemDestination: component.get("v.clickedItemDestination"),
        clickedItemIdDestination: component.get("v.clickedItemIdDestination"),
        clickedItemPol: component.get("v.clickedItemPol"),
        clickedItemIdPol: component.get("v.clickedItemIdPol"),
        clickedItemPod: component.get("v.clickedItemPod"),
        clickedItemIdPod: component.get("v.clickedItemIdPod")
      }
    };
    navService.navigate(pageReference);
  }
});
