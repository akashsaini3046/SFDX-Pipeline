({
  fetchAllTasks: function (component, objMasterFilter) {
    var action = component.get("c.fetchTasks");
    action.setParams({
      accountId: component.get("v.recordId"),
      objMasterFilter: objMasterFilter
    });

    // Register the callback function
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.taskControllerObj", response.getReturnValue());
        component.set(
          "v.taskList",
          component.get("v.taskControllerObj.taskList")
        );

        /*  var taskList=component.get("v.taskControllerObj.taskList");
                
                var openTaskHavingDueDateCount = 0;
                var openTaskListHavingDueDate = [];
                var openTaskListHavingNoDueDate = [];
                var completedTaskListHavingDueDate = [];
                var completedTaskListHavingNoDueDate = [];
                
                var lstTaskTemp = component.get("v.taskControllerObj.taskList");
                if(lstTaskTemp != null && lstTaskTemp.length > 0) {
                    for(var i = lstTaskTemp.length - 1; i >= 0 ; i--)
                    { 
                        if(taskList[i].Status === "Open" && $A.util.isEmpty(taskList[i].ActivityDate)==false)
                        {
                            openTaskHavingDueDateCount++;
                            openTaskListHavingDueDate.push(taskList[i]);
                            if(openTaskHavingDueDateCount>= 3)
                                break;
                        }
                        else if(taskList[i].Status === "Open" && $A.util.isEmpty(taskList[i].ActivityDate)==true)
                        {
                            openTaskListHavingNoDueDate.push(taskList[i]);
                        }
                            else if(taskList[i].Status === "Completed" && $A.util.isEmpty(taskList[i].ActivityDate)==true)
                            {
                                completedTaskListHavingDueDate.push(taskList[i]);
                            }
                                else if(taskList[i].Status === "Completed" && $A.util.isEmpty(taskList[i].ActivityDate)==false)
                                {
                                    completedTaskListHavingNoDueDate.push(taskList[i]);
                                }
                    }
                }
                var tempList = [];
                
                if(openTaskListHavingDueDate.length >= 3)
                {
                    component.set("v.taskList", openTaskListHavingDueDate);
                }
                else
                {
                    tempList = openTaskListHavingDueDate.concat(openTaskListHavingNoDueDate);
                    tempList = tempList.concat(completedTaskListHavingDueDate);
                    tempList = tempList.concat(completedTaskListHavingNoDueDate);
                    component.set("v.taskList", tempList);
                }*/

        component.set(
          "v.taskList",
          component.get("v.taskControllerObj.taskListTemp")
        );
      }
    });
    $A.enqueueAction(action);
  },

  createAllTaskComponent: function (component, event, helper) {
    $A.createComponent(
      "c:AllTasks",
      {
        taskControllerObj: component.get("v.taskControllerObj"),
        recordId: component.get("v.recordId"),
        strSelectedYear: component.get("v.strSelectedYear"),
        lstFilterTaskByOptions: component.get("v.lstFilterTaskStatusByOptions"),
        strSelectedFilterTaskBy: component.get(
          "v.lstDefaultFilterTaskStatusByOptions"
        )
      },
      function (msgBox) {
        if (component.isValid()) {
          var targetCmp = component.find("AllTaskModalDialog");
          var body = component.get("v.body");
          body.push(msgBox);
          targetCmp.set("v.body", body);
        }
      }
    );
  }
});
