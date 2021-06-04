({
  addCargoToContainer: function (component, event) {
    var cargoList = component.get("v.cargoList");

    var objcommodity = {};
    objcommodity["substanceDesc"] = "";
    objcommodity["commodity"] = {};

    var objcargo = {};
    objcargo["cargoType"] = "container";
    objcargo["listFreightDetailWrapper"] = [
      {
        commodityDesc: "",
        freightDetail: {},
        listCommodityWrapper: [objcommodity],
        listRequirementWrapper: [
          {
            commodityDesc: "",
            commodityCode: "",
            containerDesc: "",
            containerType: "",
            requirement: { Marine_Cargo_Insurance__c: "No" }
          }
        ]
      }
    ];

    component.set("v.lstCommodityWrapper", objcommodity);
    component.set("v.cargoList", objcargo);
    console.log(component.get("v.cargoList"));
  },

  editCargoToContainer: function (component, event) {
    var cargoList = component.get("v.cargoList");
    cargoList[0].cargoType = "container";

    if (cargoList[0].listFreightDetailWrapper.length > 0) {
      if (
        cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper.length > 0
      ) {
        component.set(
          "v.lstCommodityWrapper",
          cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper
        );
      }
    }

    component.set("v.cargoList", cargoList);
  },

  addItem: function (component, event, helper) {
    var cargoList = component.get("v.cargoList");
    //var objcargo = {};
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper.push({
      commodityDesc: "",
      commodityCode: "",
      containerDesc: "",
      containerType: "",
      requirement: { Marine_Cargo_Insurance__c: "No" }
    });
    component.set("v.cargoList", cargoList);
    console.log("Add Item:: " + JSON.stringify(cargoList));
  },
  addCommItem: function (component, event, helper) {
    var cargoList = component.get("v.cargoList");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
    var firstCommodity =
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper[0]
        .commodity;
    var objcommoditywrapper = {};
    var objcommodity = {};
    objcommodity.Emergency_Contact_Name__c =
      firstCommodity.Emergency_Contact_Name__c == undefined
        ? ""
        : firstCommodity.Emergency_Contact_Name__c;
    objcommodity.Emergency_Contact_Number__c =
      firstCommodity.Emergency_Contact_Number__c == undefined
        ? ""
        : firstCommodity.Emergency_Contact_Number__c;
    objcommodity.Contract_Number__c =
      firstCommodity.Contract_Number__c == undefined
        ? ""
        : firstCommodity.Contract_Number__c;

    objcommoditywrapper["substanceDesc"] = "";
    objcommoditywrapper["commodity"] = objcommodity;
    lstCommodityWrapper.push(objcommoditywrapper);
    cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;

    component.set("v.lstCommodityWrapper", lstCommodityWrapper);
    component.set("v.cargoList", cargoList);
  },
  removeItem: function (component, event, helper) {
    //this.validateContainerData(component, event);
    var index = event.target.id;
    var cargoList = component.get("v.cargoList");
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper.splice(
      index,
      1
    );
    console.log(cargoList);
    component.set("v.cargoList", cargoList);
  },
  removeCommItem: function (component, event, helper) {
    //this.validateContainerData(component, event);
    var index = event.target.id;
    var cargoList = component.get("v.cargoList");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
    lstCommodityWrapper.splice(index, 1);
    cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
    console.log(cargoList);
    component.set("v.lstCommodityWrapper", lstCommodityWrapper);
    component.set("v.cargoList", cargoList);
  },

  getPicklistValues: function (component, event, helper) {
    var lstFieldNameCommodity = ["Content_Type__c", "Type_of_Package__c"];
    var lstFieldNameRequirement = ["Marine_Cargo_Insurance__c"];
    //{'objectName1',List<fieldNames>,'objectName2',List<fieldNames>}
    var mapToSend = {
      Commodity__c: lstFieldNameCommodity,
      Requirement__c: lstFieldNameRequirement
    };
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
        var contentTypefieldMap = res["Commodity__c~Content_Type__c"];
        var packageTypefieldMap = res["Commodity__c~Type_of_Package__c"];
        var MarineCargofieldMap =
          res["Requirement__c~Marine_Cargo_Insurance__c"];

        var contentTypes = [];
        for (var singlekey in contentTypefieldMap) {
          contentTypes.push({
            label: singlekey,
            value: contentTypefieldMap[singlekey]
          });
        }
        component.set("v.lstContentType", contentTypes);

        var PackageTypes = [];
        for (var singlekey in packageTypefieldMap) {
          PackageTypes.push({
            label: singlekey,
            value: packageTypefieldMap[singlekey],
            isShowIcon: false
          });
        }
        component.set("v.lstPackageType", PackageTypes);

        var marineoptions = [];
        for (var singlekey in MarineCargofieldMap) {
          marineoptions.push({
            label: singlekey,
            value: MarineCargofieldMap[singlekey],
            isShowIcon: false
          });
        }
        component.set("v.lstMarineCargoInsur", marineoptions);

        var hazardousSelctBox = component.find("hazardousSelctBox");
        if (!$A.util.isUndefined(hazardousSelctBox)) {
          if (hazardousSelctBox.length > 0) {
            hazardousSelctBox.map((item) => {
              item.reInit();
            });
          } else {
            hazardousSelctBox.reInit();
          }
        }
      } else {
        console.log("Error Occured");
      }
    });
    $A.enqueueAction(action);
  },

  getCommodityTypes: function (component, event) {
    var action = component.get("c.getOpenTariffCommodities");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
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
    var tariffsCommodities = component.get("v.tariffsCommodities");
    var commodityTypes = component.get("v.commodityTypes");
    var newCommodities = [];
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
    component.set("v.commodityTypes", newCommodities);

    var tarrifComm = component.get("v.tariffsCommodities");
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
    if (!$A.util.isUndefined(commodityTypesId)) {
      if (commodityTypesId.length > 0) {
        commodityTypesId.map((item) => {
          item.reInit();
        });
      } else {
        commodityTypesId.reInit();
      }
    }
  },

  getEquipments: function (component, event, helper) {
    var action = component.get("c.getAllContainers");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
        }
        component.set("v.containers", responseData);
        this.compareContainers(component, event);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
    });
    $A.enqueueAction(action);
  },

  compareContainers: function (component, event) {
    var tariffsEquipments = component.get("v.tariffsEquipments");
    var containers = component.get("v.containers");
    var newEquipments = [];
    if (tariffsEquipments && tariffsEquipments.length > 0) {
      containers.map((open) => {
        var isInsert = true;
        tariffsEquipments.map((particular) => {
          if (open.Name === particular.Container_Code__c) {
            isInsert = false;
          }
        });
        if (isInsert) {
          newEquipments.push(open);
        }
      });
    } else {
      newEquipments = containers;
    }
    component.set("v.containers", newEquipments);

    var tarrifEquip = component.get("v.tariffsEquipments");
    var cons = component.get("v.containers");
    var options = [];
    tarrifEquip.map((item) => {
      var option = {
        label: item.Container_Name__c,
        value: item.Container_Code__c,
        isShowIcon: true,
        iconName: "utility:magicwand"
      };
      options.push(option);
    });
    cons.map((item) => {
      if (item.Is_Open_Tariff__c) {
        var option = {
          label: item.Description__c,
          value: item.Name
        };
        options.push(option);
      }
    });
    component.set("v.containerOptions", options);

    var containerTypeId = component.find("containerTypesId");
    if (!$A.util.isUndefined(containerTypeId)) {
      if (containerTypeId.length > 0) {
        containerTypeId.map((item) => {
          item.reInit();
        });
      } else {
        containerTypeId.reInit();
      }
    }
  },

  getContainer: function (component, event, functanility, selectedId, index) {
    component.set("v.isLoading", true);
    //var action = component.get("c.getContainerByIds");
    var action = component.get("c.getContainerByNames");
    /*action.setParams({
            recordId : selectedId
        });*/
    action.setParams({
      name: selectedId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        console.log(responseData);
        if (responseData.length > 0) {
          var cargoList = component.get("v.cargoList");
          cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
            index
          ].containerType = responseData[0].Name;
          cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
            index
          ].containerDesc = responseData[0].Description__c;
          cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
            index
          ].unitType = responseData[0].Unit_Type__c;

          cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
            index
          ].requirement.Running_Reefer__c =
            responseData[0].Reefer__c == "Y" ? true : false;
          cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
            index
          ].requirement.Container_Type__c = responseData[0].CICS_ISO_Code__c;

          //console.log(cargoList);
          component.set("v.cargoList", cargoList);
        } else {
          console.log("No Record Found !");
        }
        //component.set("v.commodityTypes", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  findHazardSubstance: function (component, event, getInputkeyWord) {
    component.set("v.isLoading", true);
    var action = component.get("c.getHazardSubstance");
    action.setParams({
      searchKeyWord: getInputkeyWord
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length > 0) {
          component.set("v.lstHazardSubstance", responseData);
          console.log("lstHazardSubstance:: " + JSON.stringify(responseData));
          var modal = component.find("popupModal");
          $A.util.removeClass(modal, "hideDiv");
        } else {
          component.set("v.lstHazardSubstance", []);
          console.log("lstHazardSubstance:: " + JSON.stringify(responseData));
        }
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.isLoading", false);
    });
    $A.enqueueAction(action);
  },
  clearContainer: function (component, event, functanility, index) {
    var cargoList = component.get("v.cargoList");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");

    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].containerType = "";
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].containerDesc = "";
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].unitType = "";
    //cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[index].requirement =  {}; //Clearing Object
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].requirement.Running_Reefer__c = false;

    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].requirement.IsNonOperativeReefer__c = false;
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].requirement.OutOfGauge__c = false;
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].commodityCode = "";
    cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
      index
    ].requirement.Quantity__c = "";
    if (cargoList[0].isHazardous && index == 0) {
      cargoList[0].isHazardous = false;
      var objcommodity = {};
      objcommodity["substanceDesc"] = "";
      objcommodity["commodity"] = {};
      lstCommodityWrapper = [objcommodity];
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;

      /*var hazardousSelctBox = component.find('hazardousSelctBox');
                if(!$A.util.isUndefined(hazardousSelctBox)){
                    if(hazardousSelctBox.length>0){
                        hazardousSelctBox.map((item) => {
                            item.reInit();
                        });
                    }else{
                        hazardousSelctBox.reInit();
                    }
                }*/
    }

    var commodityTypesId = component.find("commodityTypesId");
    if (commodityTypesId.length > 0) {
      commodityTypesId.map((item) => {
        item.reInit();
      });
    } else {
      commodityTypesId.reInit();
    }

    var containerTypesId = component.find("containerTypesId");
    if (containerTypesId.length > 0) {
      containerTypesId.map((item) => {
        item.reInit();
      });
    } else {
      containerTypesId.reInit();
    }

    component.set("v.lstCommodityWrapper", lstCommodityWrapper);
    component.set("v.cargoList", cargoList);
  },

  validateContainerData: function (component, event) {
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
          console.log("inputCmp[i].label" + inputCmp[i].get("v.label"));
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

    var allCommodityTypeValid = true;
    var commodityTypesId = component.find("commodityTypesId");
    if (commodityTypesId.length > 0) {
      allCommodityTypeValid = component
        .find("commodityTypesId")
        .reduce(function (validSoFar, selectCmp) {
          var commType = selectCmp.get("v.containerCode");
          var valid = true;
          if (typeof commType == "undefined" || commType == "") {
            selectCmp.showError();
            valid = false;
          }
          console.log("abcd");
          console.log("validSoFar " + validSoFar);
          return validSoFar && valid;
        }, true);
    } else {
      var commType = commodityTypesId.get("v.containerCode");
      if (typeof commType == "undefined" || commType == "") {
        allCommodityTypeValid = false;
        commodityTypesId.showError();
      } else {
        allCommodityTypeValid = true;
      }
    }

    var allContainerTypeValid = true;
    var containerTypeId = component.find("containerTypesId");
    if (containerTypeId.length > 0) {
      allContainerTypeValid = component
        .find("containerTypesId")
        .reduce(function (validSoFar, selectCmp) {
          var commType = selectCmp.get("v.containerCode");
          var valid = true;
          if (typeof commType == "undefined" || commType == "") {
            selectCmp.showError();
            valid = false;
          }
          return validSoFar && valid;
        }, true);
    } else {
      var commType = containerTypeId.get("v.containerCode");
      if (typeof commType == "undefined" || commType == "") {
        allContainerTypeValid = false;
        containerTypeId.showError();
      } else {
        allContainerTypeValid = true;
      }
    }

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

    var selectType = component.find("selectId");
    var allSelectValid = true;
    if (selectType) {
      if (selectType.length > 0) {
        console.log("total selectTypes : " + selectType.length);
        allSelectValid = component
          .find("selectId")
          .reduce(function (validSoFar, selectCmp) {
            selectCmp.showHelpMessageIfInvalid();
            return validSoFar && !selectCmp.get("v.validity").valueMissing;
          }, true);
      } else {
        console.log("inside else");
        selectType.showHelpMessageIfInvalid();
        allSelectValid = !selectType.get("v.validity").valueMissing;
      }
    }

    return (
      isAllValid &&
      allCommodityTypeValid &&
      allContainerTypeValid &&
      allOptionalServicesValid &&
      allSelectValid
    );
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: type,
      title: title,
      message: message
    });
    toastEvent.fire();
  },
  getIMDGClassesList: function (component, event, helper) {
    var action = component.get("c.fetchIMDGClassesList");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        var imdgClass = [];
        for (var i in responseData) {
          imdgClass.push({ label: i, value: responseData[i] });
        }
        component.set("v.imdgClassesList", imdgClass);
      }
    });
    $A.enqueueAction(action);
  }
});
