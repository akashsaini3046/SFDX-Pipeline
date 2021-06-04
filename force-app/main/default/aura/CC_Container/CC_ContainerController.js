({
  doInit: function (component, event, helper) {
    component.set("v.isLoading", true);
    var cargoList = component.get("v.cargoList");
    helper.getPicklistValues(component, event, helper);
    if (cargoList.length > 0) {
      helper.editCargoToContainer(component, event);
    } else {
      helper.addCargoToContainer(component, event);
    }
    helper.getCommodityTypes(component, event);
    helper.getEquipments(component, event, helper);
    helper.getIMDGClassesList(component, event, helper);

    var ventoptions = [];
    var ventoption1 = {
      label: "N",
      value: "Customer has not specified.",
      isShowIcon: false
    };
    var ventoption2 = {
      label: "0",
      value: "Vent should be closed",
      isShowIcon: false
    };
    var ventoption3 = { label: "10", value: "open 10%", isShowIcon: false }; //Edit:001
    var ventoption4 = { label: "25", value: "open 25%", isShowIcon: false }; //Edit:001
    ventoptions.push(ventoption1);
    ventoptions.push(ventoption2);
    ventoptions.push(ventoption3);
    ventoptions.push(ventoption4);
    component.set("v.lstVentSettings", ventoptions);

    component.set("v.isLoading", false);
  },
  addItem: function (component, event, helper) {
    //if(helper.validateContainer(component, event)){
    //}
    var container = document.getElementById("containerId").focus();
    console.log(document.getElementById("containerId"));

    helper.addItem(component, event, helper);
  },
  addCommodityItem: function (component, event, helper) {
    var container = document.getElementById("containerId").focus();
    console.log(document.getElementById("containerId"));
    helper.addCommItem(component, event, helper);
  },
  removeItem: function (component, event, helper) {
    helper.removeItem(component, event, helper);
  },
  removeCommodityItem: function (component, event, helper) {
    helper.removeCommItem(component, event, helper);
  },
  changeItemId: function (component, event, helper) {
    var selectedId = event.getParams()["selectedItemID"];
    var selectedItem = event.getParams()["selectedItem"];
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
    if (event.getParams()["functionality"] === "Container:commodityType") {
      var cargoList = component.get("v.cargoList");
      if (
        selectedItem === "Empty Container" ||
        selectedItem === "Empty Return"
      ) {
        cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
          index
        ].requirement.Is_Empty__c = true;
      } else {
        cargoList[0].listFreightDetailWrapper[0].listRequirementWrapper[
          index
        ].requirement.Is_Empty__c = false;
      }
      component.set("v.cargoList", cargoList);
    }
  },
  validateContainerData: function (component, event, helper) {
    return helper.validateContainerData(component, event);
  },
  changeOutOfGauge: function (component, event, helper) {
    //var outOfGauge = component.get('')
  },
  handleFileUploadEvent: function (cmp, event, helper) {
    var state = event.getParam("state");
    if (state == "SUCCESS") {
      //helper.showToast("success", "Success", "File Uploaded Successfully.");
    } else {
      helper.showToast("error", "Failed", event.getParam("message"));
    }
  },
  handleMaxSizeError: function (cmp, event, helper) {
    var fileStatus = event.getParam("fileStatus");
    if (fileStatus == "false") {
      helper.showToast(
        "error",
        "Failed",
        "Please select the file less than 4.5 mb"
      );
    } else {
      helper.showToast("Success", "Success", "File Uploaded Successfully.");
    }
  },
  onChangeSearchStr: function (component, event, helper) {
    //console.log('Id:'+event.target.id);
    var index = event.getSource().get("v.id");
    var searchString = event.getSource().get("v.value");
    component.set("v.hazardSearchStr", searchString);
    if (index != "searchIcon") {
      var cargoList = component.get("v.cargoList");
      var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
      var searchStr = lstCommodityWrapper[index].substanceDesc;

      console.log("str:" + searchStr);
      if (searchStr != "" && searchStr != "undefined" && searchStr.length > 2) {
        component.set("v.hazardIndex", index);
        component.set("v.hazardSearchStr", searchStr);

        helper.findHazardSubstance(component, event, searchStr);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "warning",
          title: "Warning!!",
          message: "Keep typing... Type some more characters"
        });
        toastEvent.fire();
      }
    } else {
      var indexComm = component.get("v.hazardIndex");
      var searchStr = component.get("v.hazardSearchStr");
      var cargoList = component.get("v.cargoList");
      var lstCommodityWrapper = component.get("v.lstCommodityWrapper");

      lstCommodityWrapper[indexComm].substanceDesc = searchStr;
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
      component.set("v.lstCommodityWrapper", lstCommodityWrapper);
      component.set("v.cargoList", cargoList);

      //var searchStr = component.get("v.hazardSearchStr");
      if (searchStr != "" && searchStr != "undefined" && searchStr.length > 2) {
        helper.findHazardSubstance(component, event, searchStr);
      } else {
        component.set("v.lstHazardSubstance", []);
      }
    }
  },
  handleCancel: function (component, event, helper) {
    var index = component.get("v.hazardIndex");
    if (index) {
      var cargoList = component.get("v.cargoList");
      var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
      if (
        $A.util.isUndefined(lstCommodityWrapper[index].commodity.Name__c) ||
        $A.util.isEmpty(lstCommodityWrapper[index].commodity.Name__c)
      ) {
        lstCommodityWrapper[index].substanceDesc = "";
      } else {
        lstCommodityWrapper[index].substanceDesc =
          lstCommodityWrapper[index].commodity.Prefix__c +
          lstCommodityWrapper[index].commodity.Number__c;
      }
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
      component.set("v.lstCommodityWrapper", lstCommodityWrapper);
      component.set("v.cargoList", cargoList);
    }
    var modal = component.find("popupModal");
    $A.util.addClass(modal, "hideDiv");
  },
  handlePopupChange: function (component, event, helper) {
    var index = component.get("v.hazardIndex");
    var searchStr = component.get("v.hazardSearchStr");
    var cargoList = component.get("v.cargoList");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");

    lstCommodityWrapper[index].substanceDesc = searchStr;
    cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
    component.set("v.lstCommodityWrapper", lstCommodityWrapper);
    component.set("v.cargoList", cargoList);
  },
  onRadioChange: function (component, event, helper) {
    //var index = event.getSource().get('v.id');
    //var isSelected = event.getSource().get('v.value');
    var index = event.target.id;
    var lstHazardSubstance = component.get("v.lstHazardSubstance");
    lstHazardSubstance[index].isSelected = true;

    for (var i = 0; i < lstHazardSubstance.length; i++) {
      if (i != index) {
        lstHazardSubstance[i].isSelected = false;
      }
    }
    component.set("v.lstHazardSubstance", lstHazardSubstance);
  },
  handleConfirmPopup: function (component, event, helper) {
    var index = component.get("v.hazardIndex");
    var cargoList = component.get("v.cargoList");
    var lstHazardSubstance = component.get("v.lstHazardSubstance");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
    var commodity = lstCommodityWrapper[index].commodity;
    var countSelected = 0;
    for (var i = 0; i < lstHazardSubstance.length; i++) {
      if (lstHazardSubstance[i].isSelected) {
        countSelected++;
        commodity.Name__c = lstHazardSubstance[i].SubstanceName;
        commodity.Primary_Class__c = lstHazardSubstance[i].PrimaryClass;
        commodity.Secondary_Class__c = lstHazardSubstance[i].SecondaryClass;
        commodity.Tertiary_Class__c = lstHazardSubstance[i].TertiaryClass;
        commodity.Variation__c = lstHazardSubstance[i].Variation;
        commodity.Package_Group__c = lstHazardSubstance[i].PackingGroup;
        commodity.Marine_Pollutant_Indicator__c =
          lstHazardSubstance[i].MarinePollutant;
        commodity.Limited_Quantity_Indicator__c =
          lstHazardSubstance[i].LimitedQuantity;
        commodity.Is_Hazardous__c = true;
        commodity.Suffix__c = lstHazardSubstance[i].Suffix;
        commodity.Prefix__c = lstHazardSubstance[i].Prefix;
        commodity.Number__c = lstHazardSubstance[i].Code;
        commodity.UN_Number__c =
          lstHazardSubstance[i].Prefix +
          lstHazardSubstance[i].Code +
          " - " +
          lstHazardSubstance[i].SubstanceName;
        lstCommodityWrapper[index].substanceDesc =
          lstHazardSubstance[i].UnNumber;
      }
    }
    if (countSelected > 0) {
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
      component.set("v.lstCommodityWrapper", lstCommodityWrapper);
      component.set("v.cargoList", cargoList);
      console.log(
        "cargo List:: " + JSON.stringify(component.get("v.cargoList"))
      );
      var inputCmp = component.find("inputFieldId");
      if (inputCmp.length > 0) {
        for (var i = 0; i < inputCmp.length; i++) {
          if (inputCmp[i].get("v.label") == "UN Number") {
            inputCmp[i].reportValidity();
          }
        }
      }
      var modal = component.find("popupModal");
      $A.util.addClass(modal, "hideDiv");
    } else {
      helper.showToast("Warning", "Info", "Please select a record.");
    }
  },
  changeSubstance: function (component, event, helper) {
    var index = event.target.id;
    var cargoList = component.get("v.cargoList");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
    var searchStr = lstCommodityWrapper[index].substanceDesc;

    console.log("str:" + searchStr);
    if (searchStr != "" && searchStr != "undefined" && searchStr.length > 2) {
      component.set("v.hazardIndex", index);
      component.set("v.hazardSearchStr", searchStr);
      helper.findHazardSubstance(component, event, searchStr);
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "warning",
        title: "Warning!!",
        message: "Keep typing... Type some more characters"
      });
      toastEvent.fire();
    }
  },
  changeHazardToggle: function (component, event, helper) {
    //var source = event.getSource().get('v.id');
    var isChecked = event.getSource().get("v.value");
    var cargoList = component.get("v.cargoList");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
    if (!isChecked) {
      var objcommodity = {};
      objcommodity["substanceDesc"] = "";
      objcommodity["commodity"] = {};
      lstCommodityWrapper = [objcommodity];
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
    }
    component.set("v.lstCommodityWrapper", lstCommodityWrapper);
    component.set("v.cargoList", cargoList);
  },
  uploadfile: function (component, event, helper) {
    //Call this method to upload the file on te record
    var childComponent = component.find("fileUploadCmp");
    var bookingId = component.get("v.bookingId");
    var message = childComponent.saveFile(bookingId);
    console.log("message@@" + message);
  },
  inputValueChange: function (component, event, helper) {
    var index = event.getSource().get("v.id");
    var value = event.getSource().get("v.value");
    var label = event.getSource().get("v.label");

    if (
      label == "UN Number" &&
      (value == "" || value == null || value == undefined)
    ) {
      component.set("v.hazardIndex", index);
      component.set("v.hazardSearchStr", "");
      var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
      var lstHazardSubstance = component.get("v.lstHazardSubstance");
      var cargoList = component.get("v.cargoList");
      var commodity = lstCommodityWrapper[index].commodity;
      commodity.Name__c = "";
      commodity.Primary_Class__c = "";
      commodity.Secondary_Class__c = "";
      commodity.Tertiary_Class__c = "";
      commodity.Variation__c = "";
      commodity.Package_Group__c = "";
      commodity.Marine_Pollutant_Indicator__c = "";
      commodity.Limited_Quantity_Indicator__c = "";
      commodity.Is_Hazardous__c = false;
      commodity.Suffix__c = "";
      commodity.Prefix__c = "";
      commodity.Number__c = "";
      commodity.UN_Number__c = "";

      lstCommodityWrapper[index].substanceDesc = "";
      cargoList[0].listFreightDetailWrapper[0].listCommodityWrapper = lstCommodityWrapper;
      component.set("v.lstCommodityWrapper", lstCommodityWrapper);
      component.set("v.cargoList", cargoList);
      component.set("v.lstHazardSubstance", []);
      var modal = component.find("popupModal");
      $A.util.removeClass(modal, "hideDiv");
    }
    component.set(
      "v.lstCommodityWrapper",
      component.get("v.lstCommodityWrapper")
    );
  },
  onSubstanceSearch: function (component, event, helper) {
    var index = event.getSource().get("v.id");
    var existingIndex = component.get("v.hazardIndex");
    var lstCommodityWrapper = component.get("v.lstCommodityWrapper");
    if (
      !$A.util.isUndefined(existingIndex) &&
      !$A.util.isEmpty(existingIndex)
    ) {
      if (index != existingIndex) {
        component.set("v.lstHazardSubstance", []);
        component.set("v.hazardSearchStr", "");
      }
    }
    component.set("v.hazardIndex", index);
    var inputBox = event.getSource();
    inputBox.blur();
    var modal = component.find("popupModal");
    $A.util.removeClass(modal, "hideDiv");
    setTimeout(function () {
      component.find("searchIcon").focus();
    }, 500);
  }
});
