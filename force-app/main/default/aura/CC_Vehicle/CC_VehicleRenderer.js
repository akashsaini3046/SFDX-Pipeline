({
  render: function (component, helper) {
    console.log("---entry in render---");
    var ret = this.superRender();
    return ret;
  },

  afterRender: function (component, helper) {
    this.superAfterRender();

    setTimeout(function () {
      component.set("v.isLoading", true);
      var cargoList = component.get("v.cargoList");
      component.set("v.cargoList", cargoList);
      component.set("v.isLoading", false);
    }, 2000);
  }
});
