({
  navigatetoDetail: function (component, event, helper) {
    var navService = component.find("navigationService");
    var selectedItemID = event.currentTarget.getAttribute("data-target");
    var selectedlabel = component.get("v.item.objLabel");
    var compEvent = component.getEvent("selectedItemEvent");
    var listItems = component.get("v.item.recordList");
    var selectedObj = listItems.find(function (listItem) {
      return selectedItemID == listItem.Id;
    });
    if (selectedlabel == "Bookings") {
      var pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "bookingDetail"
        },
        state: {
          id: selectedItemID
        }
      };
      navService.navigate(pageReference);
    } else if (selectedlabel == "Accounts") {
      var pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "accountDetail"
        },
        state: {
          id: selectedItemID
        }
      };
      navService.navigate(pageReference);
    } else if (selectedlabel == "Quotes") {
      var pageReference = {
        type: "comm__namedPage",
        attributes: {
          pageName: "quote-detail"
        },
        state: {
          id: selectedItemID
        }
      };
      navService.navigate(pageReference);
    }
    var selectedItem = null;
    if (selectedlabel == "Accounts") {
      selectedItem = selectedObj["Name"];
    } else if (selectedlabel == "Bookings") {
      selectedItem = selectedObj["Booking_Number__c"];
    } else if (selectedlabel == "Quotes") {
      selectedItem = selectedObj["Name"];
    }
    compEvent.setParams({
      selectedItemID: selectedItemID,
      selectedObjLabel: selectedlabel,
      selectedItem: selectedItem
    });
    compEvent.fire();
  }
});
