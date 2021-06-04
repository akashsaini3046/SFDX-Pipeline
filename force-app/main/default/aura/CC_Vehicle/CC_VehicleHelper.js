({
  addItem: function (component, event, helper) {
    var cargoList = component.get("v.cargoList");
    var objcargo = {};
    var tarriffCom = component.get("v.vehicleCommodities");
    if (component.get("v.isPostLogin")) {
      cargoList[0].listFreightDetailWrapper.push({
        freightDetail: { Marine_Cargo_Insurance__c: "No" },
        lstVinDetail: [],
        lstVinWrapper: [],
        commodityDesc: "",
        commodityCode: "",
        measureUnit: "lb/ft"
      });
    } else {
      cargoList[0].listFreightDetailWrapper.push({
        freightDetail: { Marine_Cargo_Insurance__c: "No" },
        lstVinDetail: [],
        commodityDesc: "NIT / Breakbulk, Vehicles, Boats",
        commodityCode: $A.get("$Label.c.CC_NitBBCode"),
        measureUnit: "lb/ft"
      });
    }
    component.set("v.cargoList", cargoList);
    component.set(
      "v.sizeVehicle",
      cargoList[0].listFreightDetailWrapper.length
    );
  },

  removeItem: function (component, event, helper) {
    component.set("v.isLoading", true);
    var index = event.target.id;
    console.log(index);
    var cargoList = component.get("v.cargoList");
    cargoList[0].listFreightDetailWrapper.splice(index, 1);
    var modelData = component.get("v.modelData");
    modelData.splice(index, 1);
    component.set("v.modelData", modelData);
    component.set("v.cargoList", cargoList);
    window.setTimeout(
      $A.getCallback(function () {
        var cargoList = component.get("v.cargoList");
        component.set("v.cargoList", cargoList);
        component.set("v.isLoading", false);
      }),
      1500
    );
    //component.set("v.sizeVehicle", cargoList[0].listFreightDetailWrapper.length);
    /*var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "action" : "deleteVehicleItem" 
        });
        cmpEvent.fire();*/
  },

  setMeterKG: function (component, event) {
    component.set("v.measureFT_M", "m");
    component.set("v.measureIN_CM", "cm");
    component.set("v.weightUnit", "kg");
  },

  setFeetLB: function (component, event) {
    component.set("v.measureFT_M", "ft");
    component.set("v.measureIN_CM", "in");
    component.set("v.weightUnit", "lb");
  },

  getPicklistValues: function (component, event, helper) {
    var lstFieldNameFreight = ["Marine_Cargo_Insurance__c"];
    //{'objectName1',List<fieldNames>,'objectName2',List<fieldNames>}
    var mapToSend = { FreightDetail__c: lstFieldNameFreight };
    var action = component.get("c.fetchMultiplePickListValues");
    action.setParams({
      mapFieldValuestoGet: mapToSend
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state " + state);
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        console.log("res" + JSON.stringify(res));
        var MarineCargofieldMap =
          res["FreightDetail__c~Marine_Cargo_Insurance__c"];
        var marineoptions = [];
        for (var singlekey in MarineCargofieldMap) {
          marineoptions.push({
            label: singlekey,
            value: MarineCargofieldMap[singlekey],
            isShowIcon: false
          });
        }
        component.set("v.lstMarineCargoInsur", marineoptions);
      } else {
        console.log("Error Occured");
      }
    });
    $A.enqueueAction(action);
  },

  getVehiclesData: function (component, event) {
    component.set("v.isLoading", true);
    let manufacture = new Set();
    var action = component.get("c.getVehicles");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var vehicles = response.getReturnValue();
        console.log(vehicles);
        component.set("v.listVehicles", vehicles);
        for (var i = 0; i < vehicles.length; i++) {
          manufacture.add(vehicles[i].Name);
        }
        const manufactureVal = manufacture.values();
        var listManufacture = component.get("v.listManufacture");
        for (var i = 0; i < manufacture.size; i++) {
          listManufacture.push(manufactureVal.next().value);
        }
        component.set("v.listManufacture", listManufacture);
        if (manufacture.size > 0) {
          var cargoList = component.get("v.cargoList");
          var freightDetailList = cargoList[0].listFreightDetailWrapper;
          for (var i = 0; i < freightDetailList.length; i++) {
            this.getModel(
              component,
              event,
              freightDetailList[i].freightDetail.Manufacturer__c,
              i,
              "edit"
            );
            this.populateVehicleDetail(
              component,
              event,
              freightDetailList[i].freightDetail.Model__c,
              i,
              "edit"
            );
          }
        }
      } else if (state === "ERROR") {
        console.log("error");
      }
      //component.set('v.isLoading', false);
    });
    $A.enqueueAction(action);
  },

  getManufacturer: function (component, event, selectedId, index) {
    var cargoList = component.get("v.cargoList");
    var freightDetail =
      cargoList[0].listFreightDetailWrapper[index].freightDetail;
    console.log("Vehicle::Helper::getMaufaturer::IsSlected:: " + selectedId);
    if (selectedId == "CVEH") {
      freightDetail.Manufacturer__c = "other";
      freightDetail.Model__c = "other";
      freightDetail.Vehicle_Name__c = "Others-Others";
      //alert(freightDetail.typeOfPackage)
    } else {
      freightDetail.Manufacturer__c = "";
      freightDetail.Model__c = "";
    }
    //cargoList[0].listFreightDetailWrapper[index].lstVinDetail = [];
    this.resetfreightDetail(freightDetail);

    //Need not to refresj OptionalServices
    //if (component.get("v.screen") != 'Quote') {
    //To refresh piclists on Optional Services
    /*var optionalServiceComp = component.find('optionalServiceComp');
            if (optionalServiceComp.length > 0) {
                optionalServiceComp.map((item) => {
                    item.refreshServices();
                });
            } else {
                optionalServiceComp.refreshServices();
            }*/
    //}

    component.set("v.cargoList", cargoList);
    component.set("v.errorMsg", "");
  },
  setModelData: function (component, modelData) {
    try {
      component.set("v.modelData", modelData);
    } catch (err) {
      this.setModelData(component, modelData);
    }
  },
  getModel: function (component, event, selectedId, index, callType) {
    var listVehicles = component.get("v.listVehicles");
    var model = [];
    for (var i = 0; i < listVehicles.length; i++) {
      if (listVehicles[i].Name === selectedId) {
        model.push(listVehicles[i]);
      }
    }
    console.log(model);
    var modelData = component.get("v.modelData");
    modelData[index] = model;
    try {
      component.set("v.modelData", modelData);
    } catch (err) {
      this.setModelData(component, modelData);
    }
    //component.set("v.modelData", modelData);
    var cargoList = component.get("v.cargoList");
    var freightDetail =
      cargoList[0].listFreightDetailWrapper[index].freightDetail;
    if (callType == "onchange") {
      freightDetail.Model__c = "";
      //cargoList[0].listFreightDetailWrapper[index].lstVinDetail = [];
      this.resetfreightDetail(freightDetail);
    }
    if (selectedId == "other") {
      freightDetail.Model__c = "other";
      freightDetail.Vehicle_Name__c = "Others-Others";
    }

    component.set("v.errorMsg", "");
    component.set("v.cargoList", cargoList);
  },
  populateVehicleDetail: function (
    component,
    event,
    selectedId,
    index,
    callType
  ) {
    var modelData = component.get("v.modelData")[index];
    var cargoList = component.get("v.cargoList");
    var freightDetailWrap = cargoList[0].listFreightDetailWrapper[index];
    var freightDetail = freightDetailWrap.freightDetail;
    freightDetail.Model__c = selectedId;
    if (callType == "onchange" && (selectedId == "other" || selectedId == "")) {
      //cargoList[0].listFreightDetailWrapper[index].lstVinDetail = [];
      this.resetfreightDetail(freightDetail);
      freightDetail.Vehicle_Name__c = freightDetail.Manufacturer__c + "-Others";
    } else {
      for (var i = 0; i < modelData.length; i++) {
        if (modelData[i].Model__c.toString() == selectedId) {
          freightDetail.Vehicle_Name__c =
            modelData[i].Name + "-" + modelData[i].Model_Name__c;
          freightDetail.Type__c = modelData[i].Type__c;
          if (freightDetailWrap.measureUnit == "lb/ft") {
            freightDetail.Length_Major__c = null;
            freightDetail.Length_Minor__c = modelData[i].Length_Inch__c;
            freightDetail.Width_Major__c = null;
            freightDetail.Width_Minor__c = modelData[i].Width_Inch__c;
            freightDetail.Height_Major__c = null;
            freightDetail.Height_Minor__c = modelData[i].Height_Inch__c;
            freightDetail.Declared_Weight_Value__c = Math.floor(
              modelData[i].Weight__c * 2.205
            );
            cargoList[0].measureUnit = "lb/ft";
          }
          if (freightDetailWrap.measureUnit == "kg/m") {
            freightDetail.Length_Major__c = this.getFloorValue(
              modelData[i].Length__c / 100
            );
            freightDetail.Length_Minor__c = this.getDecimalValue(
              modelData[i].Length__c / 100,
              2
            );
            freightDetail.Width_Major__c = this.getFloorValue(
              modelData[i].Width__c / 100
            );
            freightDetail.Width_Minor__c = this.getDecimalValue(
              modelData[i].Width__c / 100,
              2
            );
            freightDetail.Height_Major__c = this.getFloorValue(
              modelData[i].Height__c / 100
            );
            freightDetail.Height_Minor__c = this.getDecimalValue(
              modelData[i].Height__c / 100,
              2
            );
            freightDetail.Declared_Weight_Value__c = modelData[i].Weight__c;
            cargoList[0].measureUnit = "kg/m";
          }
          break;
        }
      }
    }

    component.set("v.cargoList", cargoList);
    component.set("v.errorMsg", "");
  },
  getFloorValue: function (value) {
    return Math.floor(value);
  },
  getDecimalValue: function (value, decimalPlace) {
    var decimals = value - Math.floor(value);
    var decimalVal = decimals.toFixed(decimalPlace);
    //alert(decimalVal.split('.')[1]);
    return decimalVal.split(".")[1];
  },
  resetfreightDetail: function (freightDetail) {
    freightDetail.Length_Major__c = null;
    freightDetail.Length_Minor__c = null;
    freightDetail.Width_Major__c = null;
    freightDetail.Width_Minor__c = null;
    freightDetail.Height_Major__c = null;
    freightDetail.Height_Minor__c = null;
    freightDetail.Declared_Weight_Value__c = null;

    //For refreshing Optional Service Section
    /*freightDetail.Marine_Cargo_Insurance__c =  '';
        freightDetail.EEI_Preparation__c =  null;
        freightDetail.Labels_Placards__c = null;
        freightDetail.BOL_Processing_Fee__c = null;
        freightDetail.LoadLast_HotHatch__c = null;
        freightDetail.Importer_Security_Filing__c = null;
        freightDetail.Additional_Chains__c =null;
        freightDetail.Additional_Chains_Qty__c =  null;
        freightDetail.Multiple_BoL_Fee__c =  null;
        freightDetail.Do_not_Advance__c = null;
        freightDetail.Customs_Brokerage__c = null;
        freightDetail.Additional_Straps__c = null;
        freightDetail.Additional_Straps_Qty__c = null;
        freightDetail.Caricom_Invoice_Preparation__c =null;
        freightDetail.Do_not_Split__c =  null;
        freightDetail.Fumigate__c =  null;
        freightDetail.Additional_Tarps__c = null;
        freightDetail.Additional_Tarps_Qty__c = null;
        freightDetail.Late_Documentation_Fee__c = null;
        freightDetail.Excess_Fuel_in_Vehicles_RO_RO__c = null;
        freightDetail.VGM_Certification__c =null;
        freightDetail.Wire_Pick_End_Down_Charge__c =  null;
        freightDetail.Diversion_or_Reconsignment__c =  null;
        freightDetail.Bonded_Cargo_Doc_Fee__c = null;
        freightDetail.Customs_Exam__c = null;*/
    //For refreshing Optional Service Section
  },

  validateAllField: function (component, event) {
    var cargoList = component.get("v.cargoList");
    var freightDetailList = cargoList[0].listFreightDetailWrapper;
    var errorMsg = component.get("v.errorMsg");
    errorMsg = "";
    for (var i = 0; i < freightDetailList.length; i++) {
      var freightDetail = freightDetailList[i].freightDetail;
      if (component.get("v.isPostLogin")) {
        if (
          freightDetailList[i].commodityDesc === "" ||
          freightDetailList[i].commodityCode === ""
        ) {
          errorMsg = "Please enter container type";
          break;
        }
      }
      if (freightDetail.Model__c != "") {
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
    }
    component.set("v.errorMsg", errorMsg);
    return errorMsg == "";
  },

  validateLengthField: function (component, event, selectedId, index) {
    var cargoList = component.get("v.cargoList");
    var freightDetailWrap = cargoList[0].listFreightDetailWrapper[index];
    var freightDetail = freightDetailWrap.freightDetail;
    var errorMsg = component.get("v.errorMsg");
    errorMsg = "";
    errorMsg = this.validateField(
      component,
      freightDetail.Length_Major__c,
      freightDetail.Length_Minor__c,
      freightDetailWrap.measureUnit,
      "Length"
    );
    errorMsg += this.validateField(
      component,
      freightDetail.Width_Major__c,
      freightDetail.Width_Minor__c,
      freightDetailWrap.measureUnit,
      "Width"
    );
    errorMsg += this.validateField(
      component,
      freightDetail.Height_Major__c,
      freightDetail.Height_Minor__c,
      freightDetailWrap.measureUnit,
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

  validateVehileData: function (component, event) {
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

    var allSelectValid = component
      .find("selectId")
      .reduce(function (validSoFar, selectCmp) {
        selectCmp.showHelpMessageIfInvalid();
        return validSoFar && !selectCmp.get("v.validity").valueMissing;
      }, true);

    var optionalServiceComp = component.find("optionalServiceComp");
    var allOptionalServicesValid = true;
    if (optionalServiceComp.length > 0) {
      optionalServiceComp.map((item) => {
        if (!item.validateContainerData()) {
          allOptionalServicesValid = false;
        }
      });
    } else {
      allOptionalServicesValid = optionalServiceComp.validateContainerData();
    }
    console.log("optionalSerice Valid:" + allOptionalServicesValid);

    return (
      this.validateAllField(component, event) &&
      isAllValid &&
      allSelectValid &&
      allOptionalServicesValid
    );
  },
  getYearList: function (component, event) {
    console.log("yessss");
    var action = component.get("c.fetchYearList");
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log("state " + state);
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        console.log("res" + res);
        var yearData = [];
        for (var i in res) {
          yearData.push({ label: i, value: res[i] });
        }
        component.set("v.yearData", yearData);
      }
    });
    $A.enqueueAction(action);
  },
  getCommodityTypes: function (component, event) {
    console.log("inside getCommodityTypes");
    var action = component.get("c.getOpenTariffVehicleCommodities");
    console.log("a");
    action.setCallback(this, function (response) {
      console.log("b");
      var state = response.getState();
      console.log("state " + state);
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        console.log("responseData " + responseData);
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
        }
        component.set("v.commodityTypes", responseData);
        this.compareCommodities(component, event);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
    });
    $A.enqueueAction(action);
  },

  compareCommodities: function (component, event) {
    var tariffsCommodities = component.get("v.vehicleCommodities");
    var commodityTypes = component.get("v.commodityTypes");
    var newCommodities = [];
    var cargoList = component.get("v.cargoList");
    console.log(tariffsCommodities);
    console.log("tariffsCommodities.length " + tariffsCommodities.length);
    if (tariffsCommodities && tariffsCommodities.length > 0) {
      commodityTypes.map((open) => {
        var isInsert = true;
        tariffsCommodities.map((particular) => {
          if (open.Commodity_Code__c === particular.Commodity_Code__c) {
            isInsert = false;
          }
        });
        if (isInsert) {
          newCommodities.push(open);
        }
      });
    } else {
      newCommodities = commodityTypes;
    }

    /*  if(tariffsCommodities && tariffsCommodities.length === 1){
                    cargoList[0].listFreightDetailWrapper[0].commodityCode=tariffsCommodities[0].Commodity_Code__c;
                    cargoList[0].listFreightDetailWrapper[0].commodityDesc=tariffsCommodities[0].Commodity_Name__c;    
                }
                if(tariffsCommodities && tariffsCommodities.length === 0){
                    cargoList[0].listFreightDetailWrapper[0].commodityCode='8700000000';
                    cargoList[0].listFreightDetailWrapper[0].commodityDesc='NIT/Break Bulk, Vehicles';
                } 
                if(tariffsCommodities && tariffsCommodities.length> 1){
                    cargoList[0].listFreightDetailWrapper[0].commodityCode='';
                    cargoList[0].listFreightDetailWrapper[0].commodityDesc='';
                }
                component.set("v.cargoList",cargoList);   */
    component.set("v.commodityTypes", newCommodities);

    var tarrifComm = component.get("v.vehicleCommodities");
    var commTypes = component.get("v.commodityTypes");
    var options = [];
    tarrifComm.map((item) => {
      var option = {
        label: item.Commodity_Name__c,
        value: item.Commodity_Code__c,
        isShowIcon: true,
        iconName: "utility:magicwand"
      };
      options.push(option);
    });
    commTypes.map((item) => {
      var option = {
        label: item.Commodity_Name__c,
        value: item.Commodity_Code__c
      };
      options.push(option);
    });
    component.set("v.commodityOptions", options);

    var commodityTypesId = component.find("commodityTypesId");
    if (commodityTypesId !== undefined) {
      if (commodityTypesId.length > 0) {
        commodityTypesId.map((item) => {
          item.reInit();
        });
      } else {
        commodityTypesId.reInit();
      }
    }
  },
  getContainer: function (component, event, functanility, selectedId, index) {
    component.set("v.isLoading", true);
    component.set("v.commodityCode", selectedId);
    var cargoList = component.get("v.cargoList");
    cargoList[0].listFreightDetailWrapper[index].commodityCode = selectedId;
    var commodityOptions = component.get("v.commodityOptions");
    for (var i in commodityOptions) {
      var com = commodityOptions[i];
      if (com.value === selectedId) {
        cargoList[0].listFreightDetailWrapper[index].commodityDesc = com.label;
      }
    }
    component.set("v.cargoList", cargoList);
    component.set("v.isLoading", false);
  },
  clearContainer: function (component, event, functanility, index) {
    cargoList[0].listFreightDetailWrapper[index].commodityCode = "";
    cargoList[0].listFreightDetailWrapper[index].commodityDesc = "";
  }
});
