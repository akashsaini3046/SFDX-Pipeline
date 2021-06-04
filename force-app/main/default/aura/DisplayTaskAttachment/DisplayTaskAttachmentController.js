({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    var action = component.get("c.getHaciendaChecked");
    action.setParams({
      caseId: recordId
    });
    action.setCallback(this, function (res) {
      var state = res.getState();
      if (state === "SUCCESS") {
        var caseRec = res.getReturnValue();
        component.set("v.caseRec", res.getReturnValue());
        component.set("v.subject", caseRec.Summary_BR__c);
        component.set("v.bccemail", caseRec.CreatedBy.Email);
        helper.getDestinationEmail(component, caseRec);
        if (!caseRec.Ha__c && !caseRec.Destination_Approval__c) {
          component.set(
            "v.error",
            "Please Approve the Hacienda Process/Destination!"
          );
        } else if (
          (caseRec.Ha__c || caseRec.Destination_Approval__c) &&
          caseRec.Hacienda_Mail_Sent__c
        ) {
          component.set("v.error", "Mail is already Sent!");
        }
      }
    });
    $A.enqueueAction(action);
    helper.getCaseAttachment(component, recordId);
  },
  handleKeyUp: function (cmp, evt) {
    //var isEnterKey = evt.keyCode === 13;
    var queryTerm = cmp.find("enter-search").get("v.value");
    var caseRec = cmp.get("v.caseRec");
    if (queryTerm != null && queryTerm != "") {
      var templateList = cmp.find("template-list");
      $A.util.removeClass(templateList, "slds-hide");
      var action = cmp.get("c.getTemplates");
      action.setParams({
        queryTerm: queryTerm,
        caseRec: caseRec
      });
      action.setCallback(this, function (res) {
        var state = res.getState();
        if (state === "SUCCESS") {
          var queryTemplates = JSON.parse(res.getReturnValue());
          cmp.set("v.emailMapping", queryTemplates);
        }
      });
      $A.enqueueAction(action);
    }
    //if (isEnterKey) {
    /*cmp.set('v.issearching', true);*
        /*setTimeout(function() {
            console.log('Searched for "' + queryTerm + '"!');
            cmp.set('v.issearching', false);
        }, 2000);*/
    //}
  },
  handleClick: function (component, event, helper) {
    var templateList = component.find("template-list");
    $A.util.addClass(templateList, "slds-hide");
    console.log(event.target.getAttribute("data-body"));
    if (event.target.getAttribute("data-body") != null) {
      var numberOfLineBreaks = (
        event.target.getAttribute("data-body").match(/\n/g) || []
      ).length;
      console.log(numberOfLineBreaks);
      component.set("v.description", event.target.getAttribute("data-body"));
    }
  },
  updateEmails: function (component, event, helper) {
    var key = event.target.value;
    var emailMapping = component.get("v.emailMapping");
    var em = [];
    if (key != "--None--") {
      for (var emkey in emailMapping) {
        if (emailMapping[emkey]["country"] == key) {
          for (var subkey in emailMapping[emkey]["emails"]) {
            var obj = {};
            obj["label"] = emailMapping[emkey]["emails"][subkey];
            obj["value"] = emailMapping[emkey]["emails"][subkey];
            em.push(obj);
          }
        }
      }
      if (em.length == 0) {
        var obj = {};
        obj["label"] = key;
        obj["value"] = key;
        em.push(obj);
      }
      component.set("v.emails", em);
    }
  },
  removeEmail: function (component, event, helper) {
    var name = event.getParam("item").name;
    var items = component.get("v.emails");
    var item = event.getParam("index");
    items.splice(item, 1);
    component.set("v.emails", items);
  },
  sendMail: function (component, event, helper) {
    var caseRec = component.get("v.caseRec");
    var subject = component.get("v.subject");
    var description = component.get("v.description");
    var ids = component.find("checkContact");
    var listOfId = [];
    if (ids != undefined) {
      for (var i = 0; i < ids.length; i++) {
        if (ids[i].get("v.value")) {
          listOfId.push(component.find("checkContact")[i].get("v.text"));
        }
      }
      if (ids.length == undefined) {
        listOfId.push(component.find("checkContact").get("v.text"));
      }
    }
    var emails = component.get("v.emails");
    var ccemails = component.get("v.ccemail");
    var bccemails = component.get("v.bccemail");
    var em = [];
    for (var key in emails) {
      em.push(emails[key]["value"]);
    }
    if (caseRec.Ha__c) {
      if (listOfId.length == 0 || em.length == 0) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Error",
          message:
            "Please select atleast 1 document and email for sending email!",
          key: "info_alt",
          type: "error",
          mode: "pester"
        });
        toastEvent.fire();
      } else {
        var action = component.get("c.sendAttachments");
        var caseRec = component.get("v.caseRec");
        console.log("bccemails: " + bccemails);
        action.setParams({
          attachIds: listOfId,
          emails: em,
          ccemails: ccemails,
          bccemails: bccemails,
          caseRec: caseRec,
          subject: subject,
          description: description
        });
        action.setCallback(this, function (res) {});
        $A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success",
          message: "eMail Sent Successfully!",
          key: "info_alt",
          type: "success",
          mode: "pester"
        });
        toastEvent.fire();
      }
    } else if (caseRec.Destination_Approval__c) {
      if (em.length == 0) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Error",
          message: "Please select atleast 1 email for sending email!",
          key: "info_alt",
          type: "error",
          mode: "pester"
        });
        toastEvent.fire();
      } else {
        var action = component.get("c.sendAttachments");
        var caseRec = component.get("v.caseRec");
        action.setParams({
          attachIds: listOfId,
          emails: em,
          ccemails: ccemails,
          bccemails: bccemails,
          caseRec: caseRec,
          subject: subject,
          description: description
        });
        action.setCallback(this, function (res) {
          console.log(res.getReturnValue());
          if (res.getReturnValue() == "success") {
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Success",
              message: "Email Sent Successfully!",
              key: "info_alt",
              type: "success",
              mode: "pester"
            });
            toastEvent.fire();
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Error",
              message:
                "Email not sent. Please make sure the email deliverabilty is on and the contact has email attached to it",
              key: "info_alt",
              type: "error",
              mode: "pester"
            });
            toastEvent.fire();
          }
        });
        $A.enqueueAction(action);
      }
    }
  }
});
