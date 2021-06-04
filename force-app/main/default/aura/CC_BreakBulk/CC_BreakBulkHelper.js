({
  addItem: function (component, event, helper) {
    var cargoList = component.get("v.cargoList");
    var objcargo = {};
    cargoList[0].listFreightDetailWrapper.push({
      freightDetail: {},
      commodityDesc: "NIT/Break Bulk, Vehicles",
      commodityCode: "8700000000",
      measureUnit: "lb/ft"
    });
    component.set("v.cargoList", cargoList);
  },
  removeItem: function (component, event, helper) {
    var index = event.target.id;
    console.log(index);
    var cargoList = component.get("v.cargoList");
    cargoList[0].listFreightDetailWrapper.splice(index, 1);
    console.log(cargoList);
    component.set("v.cargoList", cargoList);
  },

  validateAllField: function (component, event) {
    var cargoList = component.get("v.cargoList");
    var freightDetailList = cargoList[0].listFreightDetailWrapper;
    var errorMsg = component.get("v.errorMsg");
    errorMsg = "";
    for (var i = 0; i < freightDetailList.length; i++) {
      var freightDetail = freightDetailList[i].freightDetail;
      errorMsg = this.validateField(
        component,
        freightDetail.Length_Major__c,
        freightDetail.Length_Minor__c,
        cargoList[0].measureUnit,
        "Length"
      );
      if (errorMsg.length > 0) {
        break;
      }
      errorMsg += this.validateField(
        component,
        freightDetail.Width_Major__c,
        freightDetail.Width_Minor__c,
        cargoList[0].measureUnit,
        "Width"
      );
      if (errorMsg.length > 0) {
        break;
      }
      errorMsg += this.validateField(
        component,
        freightDetail.Height_Major__c,
        freightDetail.Height_Minor__c,
        cargoList[0].measureUnit,
        "Height"
      );
      if (errorMsg.length > 0) {
        break;
      }
    }
    component.set("v.errorMsg", errorMsg);
    return errorMsg == "";
  },

  validateLengthField: function (component, event, selectedId, index) {
    var cargoList = component.get("v.cargoList");
    var freightDetail =
      cargoList[0].listFreightDetailWrapper[index].freightDetail;
    var errorMsg = component.get("v.errorMsg");
    errorMsg = "";
    errorMsg = this.validateField(
      component,
      freightDetail.Length_Major__c,
      freightDetail.Length_Minor__c,
      cargoList[0].measureUnit,
      "Length"
    );
    errorMsg += this.validateField(
      component,
      freightDetail.Width_Major__c,
      freightDetail.Width_Minor__c,
      cargoList[0].measureUnit,
      "Width"
    );
    errorMsg += this.validateField(
      component,
      freightDetail.Height_Major__c,
      freightDetail.Height_Minor__c,
      cargoList[0].measureUnit,
      "Height"
    );
    if (errorMsg.length > 0) {
      errorMsg = "Please enter all the dimensions.";
    }
    component.set("v.errorMsg", errorMsg);
  },

  validateField: function (
    component,
    lengthMajor,
    LengthMinor,
    unitMajor,
    type
  ) {
    var errorMsg = "";
    lengthMajor = lengthMajor == "" || lengthMajor == null ? 0 : lengthMajor;
    LengthMinor = LengthMinor == "" || LengthMinor == null ? 0 : LengthMinor;
    if (lengthMajor + LengthMinor < 1) {
      errorMsg = "Please enter all the dimensions.";
    }
    /*if(unitMajor=='kg/m'){
           if(lengthMajor>0){
               if(LengthMinor>99){
                   errorMsg=type+': Centimeter value can not be greater than 99. ';
               }
               if(lengthMajor>25){
                   rrorMsg=type+': Meter value can not be greater than 25. ';
               }
               
           }else{
               if(LengthMinor>2530){
                   errorMsg=type+': Centimeter value can not be greater than 2530. ';
               }
           }
       }
       if(unitMajor=='lb/ft'){
           if(lengthMajor>0){
               if(LengthMinor>11){
                   errorMsg=type+': Inch value can not be greater than 11. ';
               }
               if(lengthMajor>83){
                   errorMsg=type+': Feet value can not be greater than 83. ';
               }
           } else{
               if(LengthMinor>999){
                   errorMsg=type+': Inch value can not be greater than 999. ';
               }
           }
       }*/
    return errorMsg;
  },

  validateBreakbulkData: function (component, event) {
    var controlAuraInputIds = ["inputFieldId"];
    let isAllValid = controlAuraInputIds.reduce(function (
      isValidSoFar,
      controlAuraId
    ) {
      var inputCmp = component.find(controlAuraId);
      if (inputCmp.length > 0) {
        var isvalidcheck = true;
        for (var i = 0; i < inputCmp.length; i++) {
          inputCmp[i].reportValidity();
          //return ;
          if ((isValidSoFar && inputCmp[i].checkValidity()) == false) {
            isvalidcheck = false;
            //break;
          }
        }
        return isvalidcheck;
      } else {
        inputCmp.reportValidity();
        return isValidSoFar && inputCmp.checkValidity();
      }
    },
    true);
    var selectType = component.find("selectId");
    var allSelectValid = true;
    if (selectType.length > 0) {
      allSelectValid = component
        .find("selectId")
        .reduce(function (validSoFar, selectCmp) {
          selectCmp.showHelpMessageIfInvalid();
          return validSoFar && !selectCmp.get("v.validity").valueMissing;
        }, true);
    } else {
      selectType.showHelpMessageIfInvalid();
      allSelectValid = !selectType.get("v.validity").valueMissing;
    }

    return (
      this.validateAllField(component, event) && isAllValid && allSelectValid
    );
  }
});
