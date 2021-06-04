({
  rerender: function (component, helper) {
    this.superRerender();
    var firePrint = component.get("v.firePrint");
    if (firePrint) {
      window.print();
    }
    component.set("v.firePrint", false);
  }
});
