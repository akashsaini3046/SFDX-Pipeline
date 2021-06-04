({
  getDestinationEmail: function (component, caseRec) {
    var action = component.get("c.destinationEmailList");
    action.setCallback(this, function (res) {
      var state = res.getState();
      if (state === "SUCCESS") {
        var destinationList = JSON.parse(res.getReturnValue());
        var arr = [];
        var des = [];
        var em = [];
        for (var key in destinationList) {
          var objlength = [];
          for (var subkey in destinationList[key]) {
            if (destinationList[key][subkey].length == 1) {
              if (
                destinationList[key][subkey][0].Is_Hacienda_Destination__c ==
                caseRec.Ha__c
              ) {
                var obj = {
                  region: key,
                  label: subkey,
                  value: destinationList[key][subkey][0].Email__c
                };
                des.push(obj);
                objlength.push(obj);
              } else if (
                caseRec.Destination_Approval__c &&
                !destinationList[key][subkey][0].Is_Hacienda_Destination__c
              ) {
                var obj = {
                  region: key,
                  label: subkey,
                  value: destinationList[key][subkey][0].Email__c
                };
                des.push(obj);
                objlength.push(obj);
              }
            } else {
              var li = [];
              for (var ems in destinationList[key][subkey]) {
                if (
                  destinationList[key][subkey][ems]
                    .Is_Hacienda_Destination__c == caseRec.Ha__c
                ) {
                  li.push(destinationList[key][subkey][ems].Email__c);
                } else if (
                  caseRec.Destination_Approval__c &&
                  !destinationList[key][subkey][ems].Is_Hacienda_Destination__c
                ) {
                  li.push(destinationList[key][subkey][ems].Email__c);
                }
              }
              if (li.length > 0) {
                var obj = { region: key, label: subkey, value: subkey };
                des.push(obj);
                objlength.push(obj);
                em.push({ country: subkey, emails: li });
              }
            }
          }
          if (objlength.length != 0) {
            arr.push(key);
          }
        }
        component.set("v.regionList", arr);
        component.set("v.emailMapping", em);
        component.set("v.destinationList", des);
      }
    });
    $A.enqueueAction(action);
  },
  getCaseAttachment: function (component, recordId) {
    var action = component.get("c.getTaskAttachmentList");
    action.setParams({ caseId: recordId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var taskList = [];
      taskList = JSON.parse(response.getReturnValue());
      component.set("v.attachmentList", taskList);
    });
    $A.enqueueAction(action);
  }
});
