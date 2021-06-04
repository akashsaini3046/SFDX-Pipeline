({
  printFullList: function (component, event) {
    /* var numberOfSchedules = component.get("v.numberOfSchedules");
        var i = 1;
        while (i <= numberOfSchedules ) {
            var bodyId = "collapseOne" + i;
            var sectionId = "collapseSection" + i;
            var bodyElement = document.getElementById(bodyId);
            var sectionElement = document.getElementById(sectionId);
            $A.util.addClass(bodyElement, 'show');
            $A.util.removeClass(sectionElement, 'collapsed');
            i++;
        } */
    var childComps = component.find("schedulesDisplay");
    console.log("childComps " + childComps);
    var compsSize = 1;
    var numberOfSchedules = component.get("v.numberOfSchedules");
    if (numberOfSchedules === 1) {
      //childComps.expandSections(numberOfSchedules,compsSize);
      childComps.expandSections(numberOfSchedules, compsSize);
    } else {
      for (var i in childComps) {
        console.log(childComps[i]);
        childComps[i].expandSections(numberOfSchedules, compsSize);
        compsSize++;
      }
    }
    // window.print();
  },
  sortingTransitTime: function (component, event) {
    component.set("v.sortingDepartureClass", "");
    var sortingTransitClass = component.get("v.sortingTransitClass");
    if (sortingTransitClass === "" || sortingTransitClass === "active desc") {
      component.set("v.sortingTransitClass", "active asc");
      this.sortTransitTime(component, event, "asc");
    } else {
      component.set("v.sortingTransitClass", "active desc");
      this.sortTransitTime(component, event, "desc");
    }
  },
  sortTransitTime: function (component, event, sortingType) {
    var schedules = component.get("v.schedules");
    if (sortingType === "asc") {
      schedules.sort(function (a, b) {
        return a.totalDays - b.totalDays;
      });
    }
    if (sortingType === "desc") {
      schedules.sort(function (a, b) {
        return b.totalDays - a.totalDays;
      });
    }
    for (var i in schedules) {
      schedules[i].sequenceNumber = parseInt(i) + 1;
    }
    component.set("v.schedules", schedules);
  },
  sortingDepartureDate: function (component, event) {
    component.set("v.sortingTransitClass", "");
    var sortingDepartureClass = component.get("v.sortingDepartureClass");
    if (
      (sortingDepartureClass === "") |
      (sortingDepartureClass === "active desc")
    ) {
      component.set("v.sortingDepartureClass", "active asc");
      this.sortDepartureDate(component, event, "asc");
    } else {
      component.set("v.sortingDepartureClass", "active desc");
      this.sortDepartureDate(component, event, "desc");
    }
  },
  sortDepartureDate: function (component, event, sortingType) {
    var schedules = component.get("v.schedules");
    if (sortingType === "asc") {
      schedules.sort(function (a, b) {
        return a.startDateNumber - b.startDateNumber;
      });
    }
    if (sortingType === "desc") {
      schedules.sort(function (a, b) {
        return b.startDateNumber - a.startDateNumber;
      });
    }
    for (var i in schedules) {
      schedules[i].sequenceNumber = parseInt(i) + 1;
    }
    component.set("v.schedules", schedules);
  },
  sendEmail: function (component, event, quoteId) {
    console.log("^^ SEND EMAIL");
    /* if(!this.validateEmail(component,event)){
            return false;            
        } */

    component.set("v.isLoading", true);
    var action = component.get("c.sendEmail");
    var schedules = component.get("v.schedules");
    var emailAddresses = component.get("v.emailAddresses");
    var selectedSchedule = component.get("v.selectedSchedule");
    var selectedSchedulesList = component.get("v.selectedSchedulesList");
    var schedulesToSend = [];
    for (var i in selectedSchedulesList) {
      schedulesToSend.push(schedules[selectedSchedulesList[i] - 1]);
    }
    console.log("@@@");
    console.log(schedulesToSend);
    console.log(JSON.stringify(emailAddresses));
    console.log(quoteId);
    action.setParams({
      stringEmail: JSON.stringify(emailAddresses),
      quoteId: quoteId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state " + state);
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        var toastEvent = $A.get("e.force:showToast");
        if (responseData) {
          // component.set("v.isEmailSend",true);
          //component.set("v.showEmailModal",false);
          component.set("v.emailAddresses", []);
          component.set("v.showEmailModal", false);
          component.set("v.isEmailSend", false);
          toastEvent.setParams({
            title: "Email Status",
            message: "Email has been successfully sent.",
            type: "success"
          });
        } else {
          console.log(response.getError());
          component.set("v.isEmailSend", false);
          toastEvent.setParams({
            title: "Email Status",
            message: "Opps something went wrong. Email failed",
            type: "error"
          });
        }
        toastEvent.fire();
        console.log(responseData);
        component.set("v.isLoading", false);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
        component.set("v.isLoading", false);
      }
    });
    $A.enqueueAction(action);
  },
  openEmailModal: function (component, event, index) {
    var emails = component.get("v.emailAddresses");
    emails.push({ emailValue: "" });
    component.set("v.emailAddresses", emails);
    component.set("v.showEmailModal", true);
    component.set("v.selectedSchedule", index);
    component.set("v.isEmailSend", false);
  },

  openEmailModalTest: function (component, event, index) {
    var emails = component.get("v.emailAddresses");
    emails.push({ emailValue: "" });
    component.set("v.emailAddresses", emails);
    component.set("v.showEmailModal", true);
    component.set("v.selectedSchedule", index);
    component.set("v.isEmailSend", false);
  },

  validateEmail: function (component, event) {
    var emailAddresses = component.get("v.emailAddresses");
    for (var i in emailAddresses) {
      var emailFieldValue = emailAddresses[i].emailValue;
      var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      if (!$A.util.isEmpty(emailFieldValue)) {
        if (emailFieldValue.match(regExpEmailformat)) {
          return true;
        } else {
          alert("Invalid Email Address: " + emailFieldValue);
          return false;
        }
      } else {
        alert("Please Enter Email Address");
        return false;
      }
    }
    return true;
  },
  alterVoyagesData: function (schedules) {
    var alteredSchedules = schedules;
    if (alteredSchedules.length > 0) {
      for (var i = 0; i < alteredSchedules.length; i++) {
        var sched = alteredSchedules[i];
        if (sched.betweenLocations.length > 0) {
          if (sched.betweenLocations.length === 1) {
            this.putVoyageValuesToFrom(sched.endLoc, sched.betweenLocations[0]);
            this.putVoyageValuesToFrom(
              sched.betweenLocations[0],
              sched.startLoc
            );
          } else {
            for (var j = sched.betweenLocations.length - 1; j >= 0; j--) {
              if (j === sched.betweenLocations.length - 1) {
                this.putVoyageValuesToFrom(
                  sched.endLoc,
                  sched.betweenLocations[j]
                );
                this.putVoyageValuesToFrom(
                  sched.betweenLocations[j],
                  sched.betweenLocations[j - 1]
                );
              } else if (j === 0) {
                this.putVoyageValuesToFrom(
                  sched.betweenLocations[0],
                  sched.startLoc
                );
              } else {
                this.putVoyageValuesToFrom(
                  sched.betweenLocations[j],
                  sched.betweenLocations[j - 1]
                );
              }
            }
          }
        } else {
          this.putVoyageValuesToFrom(sched.endLoc, sched.startLoc);
        }
      }
    }
    return alteredSchedules;
  },
  putVoyageValuesToFrom: function (to, from) {
    if (from.voyageNumber === undefined) {
      to.voyageNumber = "";
    } else {
      to.voyageNumber = from.voyageNumber;
    }
    if (from.vesselName === undefined) {
      to.vesselName = "";
    } else {
      to.vesselName = from.vesselName;
    }
  },
  getRouteRecordId: function (component, event) {
    var selectedSchedulesList = component.get("v.selectedSchedulesList");
    var schedules = component.get("v.schedules");
    var schedulesToSend = [];
    for (var i in selectedSchedulesList) {
      schedulesToSend.push(schedules[selectedSchedulesList[i] - 1]);
    }
    var alteredSchedules = this.alterVoyagesData(schedulesToSend);
    var schedulesString = JSON.stringify(alteredSchedules);
    var bookingString = JSON.stringify(component.get("v.booking"));
    var action = component.get("c.createRouteRecord");
    action.setParams({
      stringSchedules: schedulesString,
      bookingString: bookingString
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state " + state);
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        this.sendEmail(component, event, responseData);
      }
    });
    $A.enqueueAction(action);
  }
});
