({
  //Custom labels to be preloaded
  // $Label.c.CC_DashboardHeading
  // $Label.c.CC_Ideas
  // $Label.c.CC_Accounts
  // $Label.c.CC_BookingList
  // $Label.c.CC_Quotes
  // $Label.c.CC_BillofLading
  highlightListItems: function (component, event) {
    var menuItem = event.getParam("selectedMenu");
    console.log(menuItem);
    var action = component.get("c.getMenuItems");
    action.setCallback(this, function (a) {
      var menuOptions = a.getReturnValue();
      var i = 0;
      var highlightSequence = 0;
      for (i = 0; i < menuOptions.length; i++) {
        if (menuOptions[i]["Lightning_Component_Name__c"] == menuItem) {
          highlightSequence = i + 1;
        }
        menuOptions[i]["MasterLabel"] = $A.get(
          "$Label.c." + menuOptions[i]["MasterLabel"]
        );
      }
      component.set("v.listitems", menuOptions);
      if (highlightSequence != 0) {
        component.set("v.highlightedItem", highlightSequence);
      }
      component.set("v.selectedTabId", "" + highlightSequence);

      if (
        ($A.get("$Browser.isTablet") || $A.get("$Browser.isPhone")) &&
        $A.util.hasClass(document.getElementById("verticalMenuDiv"), "fliph")
      ) {
        $A.util.removeClass(
          document.getElementById("verticalMenuDiv"),
          "fliph"
        );
      }
    });
    $A.enqueueAction(action);
  },
  getCommunityName: function (component) {
    var action = component.get("c.getCommunityName");
    action.setCallback(this, function (res) {
      var resData = res.getReturnValue();
      component.set("v.communityName", resData);
    });
    $A.enqueueAction(action);
  }
});
