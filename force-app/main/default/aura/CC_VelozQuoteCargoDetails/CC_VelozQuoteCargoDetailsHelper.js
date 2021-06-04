({
  setValues: function (component, event) {
    var cargotype = component.get("v.CargoType");
    this.modifyData(component, event, cargotype);
  },

  modifyData: function (component, event, cargotype) {
    var cargoDetails = [];
    var freights = component.get("v.freights");
    var requirements = component.get("v.requirements");
    var containers = component.get("v.containerTypes");
    if (cargotype == "EQUIP") {
      if (requirements && requirements.length > 0) {
        for (var index = 0; index < requirements.length; index++) {
          var modItem = {};
          if (requirements[index].Container_Type__c) {
            containers.map((container) => {
              if (container.label == requirements[index].Container_Type__c) {
                modItem.containerName = this.checkValue(container.value);
              }
            });
          } else {
            modItem.containerName = "NA";
          }
          if (requirements[index].Commodity_Name__c) {
            modItem.commodityDesc = this.checkCommodityValue(
              requirements[index].Commodity_Name__c
            );
          }
          if (requirements[index].Quantity__c) {
            modItem.quantity = this.checkValue(requirements[index].Quantity__c);
          } else {
            modItem.quantity = "NA";
          }
          cargoDetails.push(modItem);
        }
      }
    } else if (cargotype == "AUTO") {
      if (freights && freights.length > 0) {
        for (var index = 0; index < freights.length; index++) {
          var modItem = {};
          if (freights[index].Vehicle_Name__c) {
            modItem.containerName = this.checkValue(
              freights[index].Vehicle_Name__c
            );
          } else {
            modItem.containerName = "NA";
          }
          if (
            freights[index].Package_Type__c ||
            freights[index].Length__c ||
            freights[index].Width__c ||
            freights[index].Height__c ||
            freights[index].Declared_Weight_Value__c
          ) {
            var units = this.checkValue(freights[index].Measure_Unit__c);
            var weightUnits = this.checkValue(
              freights[index].Declared_Weights_Unit_of_Measure__c
            );
            modItem.commodityDesc =
              this.checkVehTypeValue(freights[index].Package_Type__c) +
              "<br>" +
              this.checkCommodityValue(
                this.checkValue(freights[index].Length__c) +
                  " " +
                  units +
                  " x " +
                  this.checkValue(freights[index].Width__c) +
                  " " +
                  units +
                  " x " +
                  this.checkValue(freights[index].Height__c) +
                  " " +
                  units +
                  " , " +
                  this.checkValue(freights[index].Declared_Weight_Value__c) +
                  " " +
                  weightUnits
              );
          }
          if (freights[index].Freight_Quantity__c) {
            modItem.quantity = this.checkValue(
              freights[index].Freight_Quantity__c
            );
          } else {
            modItem.quantity = "NA";
          }
          cargoDetails.push(modItem);
        }
      }
    } else if (cargotype == "BBULK") {
      if (freights && freights.length > 0) {
        for (var index = 0; index < freights.length; index++) {
          var modItem = {};
          if (freights[index].Package_Type__c) {
            modItem.containerName = this.checkBBulkValue(
              freights[index].Package_Type__c
            );
          } else {
            modItem.containerName = "NA";
          }
          if (
            freights[index].Length__c ||
            freights[index].Width__c ||
            freights[index].Height__c ||
            freights[index].Declared_Weight_Value__c
          ) {
            var units = this.checkValue(freights[index].Measure_Unit__c);
            var weightUnits = this.checkValue(
              freights[index].Declared_Weights_Unit_of_Measure__c
            );
            modItem.commodityDesc = this.checkCommodityValue(
              this.checkValue(freights[index].Length__c) +
                " " +
                units +
                " x " +
                this.checkValue(freights[index].Width__c) +
                " " +
                units +
                " x " +
                this.checkValue(freights[index].Height__c) +
                " " +
                units +
                " , " +
                this.checkValue(freights[index].Declared_Weight_Value__c) +
                " " +
                weightUnits
            );
          }
          if (freights[index].Package_Quantity__c) {
            modItem.quantity = this.checkValue(
              freights[index].Package_Quantity__c
            );
          } else {
            modItem.quantity = "NA";
          }
          cargoDetails.push(modItem);
        }
      }
    }
    component.set("v.cargoDetails", cargoDetails);
  },

  checkValue: function (value) {
    if (value) {
      return value;
    } else {
      return "";
    }
  },

  checkCommodityValue: function (value) {
    if (value) {
      return "(" + value + ")";
    } else {
      return "";
    }
  },

  checkVehTypeValue: function (value) {
    if (value == "PVEH") {
      return "(Passenger)";
    } else if (value == "CVEH") {
      return "(Commercial)";
    } else {
      return "";
    }
  },

  checkBBulkValue: function (value) {
    if (value == "BOAT") {
      return "Boat on Trailer";
    } else if (value == "NIT") {
      return "Cargo, Not In Container";
    } else {
      return "";
    }
  }
});
