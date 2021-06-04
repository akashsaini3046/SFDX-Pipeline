({
  setClassForPublicCommunity: function (component, event, helper) {
    var sPageURL = window.location.pathname;
    console.log(sPageURL);
    if (sPageURL.includes("Veloz") || sPageURL.includes("crowley")) {
      var ContentDiv = component.find("ContentDiv");
      $A.util.addClass(ContentDiv, "banner-bg-img");
    }
  }
});
