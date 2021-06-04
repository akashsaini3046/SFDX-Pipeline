({
  rerender: function (component, helper) {
    this.superRerender();
    var isPrint = component.get("v.isPrint");
    var isLastSchedule = component.get("v.isLastSchedule");
    console.log("isPrint " + isPrint + "  isLastSchedule" + isLastSchedule);
    if (isPrint) {
      // && isLastSchedule
      var compEvent = component.getEvent("printScreenEvent");
      compEvent.fire();
    }
    component.set("v.isPrint", false);
  }
});
