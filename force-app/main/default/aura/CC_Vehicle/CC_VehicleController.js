({
  doInit: function (component, event, helper) {
    var cargoList = component.get("v.cargoList");
    if (cargoList.length > 0) {
      cargoList[0].cargoType = "AUTO";
      component.set("v.cargoList", cargoList);
    }
    helper.getPicklistValues(component, event, helper);
    var listVehicles = component.get("v.listVehicles");
    var listManufacture = component.get("v.listManufacture");
    helper.getYearList(component, event);
    helper.getVehiclesData(component, event);
    helper.getCommodityTypes(component, event);
  },
  addItem: function (component, event, helper) {
    helper.addItem(component, event, helper);
  },
  removeItem: function (component, event, helper) {
    helper.removeItem(component, event, helper);
  },
  getManufacturer: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var selectedId = event.getSource().get("v.value");
    helper.getManufacturer(component, event, selectedId, index);
  },
  getModel: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var selectedId = event.getSource().get("v.value");
    helper.getModel(component, event, selectedId, index, "onchange");
  },
  populateVehicleDetail: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var selectedId = event.getSource().get("v.value");
    helper.populateVehicleDetail(
      component,
      event,
      selectedId,
      index,
      "onchange"
    );
  },
  getUnitOfMeasure: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var cargoList = component.get("v.cargoList");
    var isChecked = event.detail.checked;
    var freightDetail = cargoList[0].listFreightDetailWrapper[index];
    if (isChecked == true || isChecked === "true") {
      freightDetail.measureUnit = "kg/m";
    } else {
      freightDetail.measureUnit = "lb/ft";
    }
    component.set("v.cargoList", cargoList);
  },

  setUnitKGM: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var cargoList = component.get("v.cargoList");
    var freightDetail = cargoList[0].listFreightDetailWrapper[index];
    if (freightDetail.measureUnit != "kg/m") {
      freightDetail.measureUnit = "kg/m";
      component.set("v.cargoList", cargoList);
      helper.populateVehicleDetail(
        component,
        event,
        freightDetail.freightDetail.Model__c,
        index,
        "onchange"
      );
    }
  },
  setUnitLBFT: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var cargoList = component.get("v.cargoList");
    var freightDetail = cargoList[0].listFreightDetailWrapper[index];
    if (freightDetail.measureUnit != "lb/ft") {
      freightDetail.measureUnit = "lb/ft";
      component.set("v.cargoList", cargoList);
      helper.populateVehicleDetail(
        component,
        event,
        freightDetail.freightDetail.Model__c,
        index,
        "onchange"
      );
    }
  },

  validateLengthField: function (component, event, helper) {
    var index = event.getSource().get("v.name");
    var selectedId = event.getSource().get("v.value");
    //alert(index);
    helper.validateLengthField(component, event, selectedId, index);
  },
  validateVehicleInfo: function (component, event, helper) {
    return helper.validateVehileData(component, event);
  },
  onQuantityChange: function (component, event, helper) {
    var index = event.getSource().get("v.id");
    var inputNumber = event.getSource().get("v.value");
    var cargoList = component.get("v.cargoList");
    var freightDetail = cargoList[0].listFreightDetailWrapper[index];

    /*if(!$A.util.isEmpty(freightDetail.lstVinDetail) && freightDetail.lstVinDetail.length > 0){
            var lstVinLength = freightDetail.lstVinDetail.length;
            if(inputNumber > 0){
                if(lstVinLength == inputNumber){
                    return;
                }
                else if(lstVinLength > inputNumber){
                    for(var i=0;i<(lstVinLength-inputNumber);i++){
                        freightDetail.lstVinDetail.pop();
                    }
                }
                else if(lstVinLength < inputNumber){
                    for(var i=0;i<(inputNumber-lstVinLength);i++){
                        freightDetail.lstVinDetail.push('');    
                    }    
                }
            }
            else{
                freightDetail.lstVinDetail = []; //Edit:001
            }
        }
        else{
            if(inputNumber > 0){
                for(var i=0;i<inputNumber;i++){
                    freightDetail.lstVinDetail.push('');    
                }
            }
            else{
                freightDetail.lstVinDetail = []; //Edit:001
            }
        }*/

    if (
      !$A.util.isEmpty(freightDetail.lstVinWrapper) &&
      freightDetail.lstVinWrapper.length > 0
    ) {
      var lstVinLength = freightDetail.lstVinWrapper.length;
      if (inputNumber > 0) {
        if (lstVinLength == inputNumber) {
          return;
        } else if (lstVinLength > inputNumber) {
          for (var i = 0; i < lstVinLength - inputNumber; i++) {
            freightDetail.lstVinWrapper.pop();
          }
        } else if (lstVinLength < inputNumber) {
          for (var i = 0; i < inputNumber - lstVinLength; i++) {
            freightDetail.lstVinWrapper.push({
              Vin: "",
              UnNumber: "UN3166 - Gasoline"
            });
          }
        }
      } else {
        freightDetail.lstVinWrapper = []; //Edit:001
      }
    } else {
      if (inputNumber > 0) {
        for (var i = 0; i < inputNumber; i++) {
          freightDetail.lstVinWrapper.push({
            Vin: "",
            UnNumber: "UN3166 - Gasoline"
          });
        }
      } else {
        freightDetail.lstVinWrapper = []; //Edit:001
      }
    }

    cargoList[0].listFreightDetailWrapper[index] = freightDetail;
    component.set("v.cargoList", cargoList);
  },
  /*inputValueChange: function(component, event, helper){
        var id = event.getSource().get('v.id');
        var indexmain = id.split(':');
        var indexParent = indexmain[0];
        var indexChild = indexmain[1];
        var inputValue = event.getSource().get('v.value');
        var cargoList = component.get("v.cargoList");
        cargoList[0].listFreightDetailWrapper[indexParent].lstVinDetail[indexChild] = inputValue;
        //component.set("v.cargoList",cargoList);
        console.log('Vehicle Wraper::'+JSON.stringify(cargoList));
    },*/
  changeItemId: function (component, event, helper) {
    console.log("@@@");
    var selectedId = event.getParams()["selectedItemID"];
    var index = event.getParams()["index"];
    console.log(index);
    if (event.getParams()["functionality"] === "Container:Size_Type") {
      if (selectedId != "") {
        helper.getContainer(
          component,
          event,
          "Container:Size_Type",
          selectedId,
          index
        );
      } else {
        helper.clearContainer(component, event, "Container:Size_Type", index);
      }
    }
  }
});
