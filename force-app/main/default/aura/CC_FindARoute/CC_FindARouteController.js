({
  doInit: function (component, event, helper) {
    console.log("find a route init");
    helper.doInit(component, event);
    helper.checkGuestUser(component);
    helper.getBookingWrap(component, event);
  },
  searchFindRoute: function (component, event, helper) {
    var bookingWrap = component.get("v.bookingWrapper");
    console.log(bookingWrap);
    helper.searchFindRoute(component, event, helper);
  },
  changeItemId: function (component, event, helper) {
    var selectedId = event.getParams()["selectedItemID"];
    console.log(selectedId);
    if (event.getParams()["functionality"] === "RouteFinder:Origin") {
      if (selectedId != "") {
        helper.getLocation(component, event, "RouteFinder:Origin", selectedId);
      } else {
        helper.clearLocation(component, event, "RouteFinder:Origin");
      }
    }
    if (event.getParams()["functionality"] === "RouteFinder:Destination") {
      if (selectedId != "") {
        helper.getLocation(
          component,
          event,
          "RouteFinder:Destination",
          selectedId
        );
      } else {
        helper.clearLocation(component, event, "RouteFinder:Destination");
      }
    }
  },
  navigateToHome: function (component, event, helper) {
    var navService = component.find("navigationService");
    var pageReference = {
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    };
    navService.navigate(pageReference);
  },
  printPDF: function (component, event, helper) {
    var elements = document.getElementsByClassName("header");
    var headerdiv = document.getElementsByClassName("header-div");
    headerdiv[0].style.display = "none";
    elements[0].style.display = "none";
    window.print();
    elements[0].style.display = "block";
    headerdiv[0].style.display = "block";
  }
});
