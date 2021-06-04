({
  handleActive: function (cmp, event) {
    var tab = event.getSource();
    var tabName = tab.get("v.id");
    if (tabName.includes("tab-view-details")) {
      this.injectComponent(cmp, "c:CC_VelozQuoteDetailSum", tab);
    }
  },

  injectComponent: function (cmp, name, target) {
    var attr = {};
    if (name === "c:CC_VelozQuoteDetailSum") {
      attr = {
        recordId: target
          .get("v.id")
          .substring(target.get("v.id").lastIndexOf("-") + 1),
        isPostLogin: cmp.get("v.isPostLogin")
      };
    }
    $A.createComponent(name, attr, function (contentComponent, status, error) {
      if (status === "SUCCESS") {
        target.set("v.body", contentComponent);
      } else {
        throw new Error(error);
      }
    });
  }
});
