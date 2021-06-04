({
  doInit: function (component, event, helper) {
    console.log("@@@@@");
    var originMove = component.get("v.originMove");
    var destinationMove = component.get("v.destinationMove");
    if (originMove === "P") component.set("v.originType", "Port");
    if (originMove === "D") component.set("v.originType", "Door");
    if (originMove === "R") component.set("v.originType", "Rail");
    if (destinationMove === "P") component.set("v.destType", "Port");
    if (destinationMove === "D") component.set("v.destType", "Door");
    if (destinationMove === "R") component.set("v.destType", "Rail");
    var scheduleRecord = component.get("v.schedule");
    console.log("scheduleRecord ");
    console.log(scheduleRecord);
    helper.setValues(component, event, helper, scheduleRecord);
  },
  handleShowDetails: function (component, event, helper) {
    var showDetails = component.get("v.showDetails");
    component.set("v.showDetails", !showDetails);
    if (showDetails) {
      component.set("v.showHideDetailsText", "Show Details");
    } else {
      component.set("v.showHideDetailsText", "Hide Details");
    }
  },
  expandSectionsHandler: function (component, event, helper) {
    var params = event.getParam("arguments");
    var numberOfSchedules = params.numberOfSchedules;
    var scheduleCount = params.scheduleCount;
    console.log(numberOfSchedules + "  " + scheduleCount);
    console.log("Entered inside expandSectionsHandler");
    component.set("v.showDetails", true);
    component.set("v.showHideDetailsText", "Hide Details");
    if (numberOfSchedules === scheduleCount) {
      console.log("inside last schedule");
      component.set("v.isPrint", true);
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
  }
});
