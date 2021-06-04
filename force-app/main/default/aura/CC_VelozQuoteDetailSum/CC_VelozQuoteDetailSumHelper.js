({
  // $Label.c.CC_VC_Route_TC_1
  // $Label.c.CC_VC_Route_TC_2
  // $Label.c.CC_VC_Route_TC_3
  // $Label.c.CC_VC_Route_TC_4
  // $Label.c.CC_VC_Route_TC_5
  // $Label.c.CC_VC_Route_TC_6
  // $Label.c.CC_VC_Route_TC_7
  // $Label.c.CC_VC_Route_TC_8
  // $Label.c.CC_VC_Route_TC_9
  // $Label.c.CC_VC_Route_TC_10
  // $Label.c.CC_VC_Route_TC_11
  // $Label.c.CC_VC_Route_TC_12
  fetchQuoteDetails: function (component, event, helper) {
    component.set("v.isLoading", true);
    var recordId = component.get("v.recordId");
    var action = component.get("c.getQuoteDetails");
    action.setParams({
      quoteId: recordId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        console.log("res", res);
        if (res.termsAndConditions) {
          var termsAndConditions = [];
          res.termsAndConditions.map((term) => {
            var termsString = $A.get("$Label.c." + term);
            termsAndConditions.push(termsString);
          });
          component.set("v.termsAndConditions", termsAndConditions);
        }
        if (res.quoteRecord) {
          helper.resolveQuoteRecord(component, event, helper, res.quoteRecord);
        }
        if (res.chargeLines) {
          component.set("v.chargeLines", res.chargeLines);
        }
        component.set("v.quoteWrapper", res);
        component.set("v.showCargo", true);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            helper.showToast(
              "error",
              "Error!",
              "Something went wrong. Please try again."
            );
          }
        } else {
          console.log("Unknown error");
        }
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  newQuoteFlow: function (component, event, helper) {
    //$A.get('e.force:refreshView').fire();
    var appEvent = $A.get("e.c:CreateParentQuoteAppEvent");
    appEvent.setParams({ actionName: "NewQuote" });
    appEvent.fire();
  },

  resolveQuoteRecord: function (component, event, helper, quoteRecord) {
    var quotationDate =
      quoteRecord.CreatedDate != null
        ? this.handleDates(quoteRecord.CreatedDate)
        : "NA";
    var quotationNumber = quoteRecord.Name;
    var cargoReadyDate =
      quoteRecord.Ready_Date__c != null
        ? this.handleDates(quoteRecord.Ready_Date__c)
        : "NA";
    var validToDate =
      quoteRecord.Valid_To__c != null
        ? this.handleDates(quoteRecord.Valid_To__c)
        : "NA";
    var quotationContractNumber =
      quoteRecord.Contract_Number__c != null
        ? quoteRecord.Contract_Number__c
        : "NA";
    var quotationContactName =
      quoteRecord.Contact_Name__c != null ? quoteRecord.Contact_Name__c : "NA";
    var quotationEmailId =
      quoteRecord.Customer_Email__c != null
        ? quoteRecord.Customer_Email__c
        : "NA";
    var quotationPhone =
      quoteRecord.Contact_Number__c != null
        ? quoteRecord.Contact_Number__c
        : "NA";
    var loadPort =
      quoteRecord.Port_of_Load__c != null ? quoteRecord.Port_of_Load__c : "NA";
    var dischargePort =
      quoteRecord.Port_of_Discharge__c != null
        ? quoteRecord.Port_of_Discharge__c
        : "NA";
    var quotationStatus = quoteRecord.Status__c;
    var quotationCompanyName =
      quoteRecord.Company_Name__c != null ? quoteRecord.Company_Name__c : "NA";
    var setQuoteAccountName =
      quoteRecord.Account__c && quoteRecord.Account__r.Name != null
        ? quoteRecord.Account__r.Name
        : quotationCompanyName;
    var setQuoteName =
      quoteRecord.Contact__c && quoteRecord.Contact__r.Name != null
        ? quoteRecord.Contact__r.Name
        : quotationContactName;
    var setCaseNumber =
      quoteRecord.Cases__r && quoteRecord.Cases__r[0].CaseNumber != null
        ? quoteRecord.Cases__r[0].CaseNumber
        : "NA";

    component.set("v.quotationDate", quotationDate);
    component.set("v.quotationNumber", quotationNumber);
    component.set("v.cargoReadyDate", cargoReadyDate);
    component.set("v.validToDate", validToDate);
    component.set("v.quotationContractNumber", quotationContractNumber);
    component.set("v.quotationEmail", quotationEmailId);
    component.set("v.quotationPhone", quotationPhone);
    component.set("v.quotationStatus", quotationStatus);
    component.set("v.quotationAccountName", setQuoteAccountName);
    component.set("v.quoteName", setQuoteName);
    component.set("v.CaseNo", setCaseNumber);
    component.set("v.LoadPort", loadPort);
    component.set("v.DischargePort", dischargePort);

    if (quoteRecord.Description__c) {
      var description = quoteRecord.Description__c;
      var originObject = {};
      var destinationObject = {};
      if (description.startsWith("D")) {
        originObject.type = "Door";
        var country = this.checkNull(quoteRecord.Customer_Origin_Country__c);
        if (country.toUpperCase() === "US") {
          originObject.code = this.checkNull(
            quoteRecord.Customer_Origin_Zip__c
          );
        } else {
          originObject.code = "";
        }
      }
      if (description.startsWith("P")) {
        originObject.type = "Port";
        originObject.code = this.checkNull(quoteRecord.Customer_Origin_Code__c);
      }
      if (description.startsWith("R")) {
        originObject.type = "Rail";
        originObject.code = this.checkNull(quoteRecord.Customer_Origin_Code__c);
      }
      if (description.endsWith("D")) {
        destinationObject.type = "Door";
        var country = this.checkNull(
          quoteRecord.Customer_Destination_Country__c
        );
        if (country.toUpperCase() === "US") {
          destinationObject.code = this.checkNull(
            quoteRecord.Customer_Destination_Zip__c
          );
        } else {
          destinationObject.code = "";
        }
      }
      if (description.endsWith("P")) {
        destinationObject.type = "Port";
        destinationObject.code = this.checkNull(
          quoteRecord.Customer_Destination_Code__c
        );
      }
      if (description.endsWith("R")) {
        destinationObject.type = "Rail";
        destinationObject.code = this.checkNull(
          quoteRecord.Customer_Destination_Code__c
        );
      }
      originObject.displayName = this.checkCommaAndTrim(
        this.checkNullAndAddComma(quoteRecord.Customer_Origin_City__c) +
          this.checkNullAndAddComma(quoteRecord.Customer_Origin_State__c) +
          this.checkNull(
            this.checkCountryUS(quoteRecord.Customer_Origin_Country__c)
          )
      );
      destinationObject.displayName = this.checkCommaAndTrim(
        this.checkNullAndAddComma(quoteRecord.Customer_Destination_City__c) +
          this.checkNullAndAddComma(quoteRecord.Customer_Destination_State__c) +
          this.checkNull(
            this.checkCountryUS(quoteRecord.Customer_Destination_Country__c)
          )
      );
      component.set("v.originObject", originObject);
      component.set("v.destinationObject", destinationObject);
    }
    if (quoteRecord.Transit_Time__c) {
      this.setTransitTime(component, quoteRecord.Transit_Time__c);
    }
    if (quoteRecord.Transportation_Management_System_Origin__c) {
      component.set(
        "v.receiptType",
        quoteRecord.Transportation_Management_System_Origin__c
      );
    } else {
      component.set("v.receiptType", "NA");
    }
    if (quoteRecord.Transportation_Management_System_Destina__c) {
      component.set(
        "v.deliveryType",
        quoteRecord.Transportation_Management_System_Destina__c
      );
    } else {
      component.set("v.deliveryType", "NA");
    }
    if (quoteRecord.Total_Amount__c) {
      component.set("v.totalAmount", quoteRecord.Total_Amount__c);
    }
  },

  setTransitTime: function (component, transitTime) {
    var timeInDays = 0;
    var timeInHours = 0;
    if (transitTime && transitTime != null && transitTime != 0) {
      timeInDays = parseInt(transitTime / 24);
      timeInHours = parseInt(transitTime % 24);
    }
    component.set("v.transitTime", timeInDays);
    component.set("v.transitTimeHours", timeInHours);
  },

  handleDates: function (dates) {
    return $A.localizationService.formatDate(dates, "MMM dd, yyyy");
  },

  checkNull: function (value) {
    return value && value != null ? value : "";
  },

  checkNullAndAddComma: function (value) {
    return value && value != null ? value + ", " : "";
  },

  checkCountryUS: function (value) {
    return value && value != null && value == "US" ? null : value;
  },

  checkCommaAndTrim: function (value) {
    return value.trim().endsWith(",") ? value.trim().slice(0, -1) : value;
  },
  identifyCommunity: function (component, event, helper) {
    console.log("recordId-- " + component.get("v.recordId"));
    var action = component.get("c.isInternalCommunity");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.internalComm", response.getReturnValue());
        console.log("internal comm value - " + component.get("v.internalComm"));
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          console.log("Errors", errors);
          if (errors[0] && errors[0].message) {
            throw new Error("Error" + errors[0].message);
          }
        }
      }
    });
    $A.enqueueAction(action);
  },

  showQuoteDetails: function (component) {
    console.log("showQuoteDetails()");
    var quoteId = component.get("v.recordId");
    var action = component.get("c.fetchIframeUrl");
    action.setParams({
      qId: quoteId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.recordURL", response.getReturnValue());
        console.log("response.getReturnValue()", response.getReturnValue());
      } else if (state === "ERROR") {
        console.log("error");
        let errors = response.getError();
        let message = "";
        if (errors && Array.isArray(errors) && errors.length > 0) {
          message = errors[0].message;
        }
        console.error(message);
      }
      cmp.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },

  callDownloadPDF: function (component, event, helper) {
    var nameQuote = component.get("v.quotationNumber");
    var source = component.get("v.recordURL");
    var hiddenElement = document.createElement("a");
    hiddenElement.href = source;
    hiddenElement.target = "_self";
    hiddenElement.download = nameQuote;
    document.body.appendChild(hiddenElement); // Required for FireFox browser
    hiddenElement.click();
  }
});
