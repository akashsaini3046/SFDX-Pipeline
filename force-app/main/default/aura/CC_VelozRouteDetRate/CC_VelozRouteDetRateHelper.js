({
  setValues: function (component, event, helper, routeRecord) {
    var chargeLines = component.get("v.chargeLines");
    if (chargeLines && chargeLines.length > 0) {
      this.resolveChargeLines(component, event, helper, chargeLines);
    } else if (routeRecord) {
      this.resolveRouteRecord(component, event, helper, routeRecord);
    }
  },

  resolveChargeLines: function (component, event, helper, chargeLines) {
    var rateItems = [];
    var itemSeqVsDetails = {};
    var detailsArray = [];
    var extraRateItems = [];
    var subTotalAmount = 0;
    chargeLines.map((chargeLine) => {
      if (
        chargeLine.Item_Sequence__c &&
        chargeLine.Item_Sequence__c != null &&
        chargeLine.Item_Sequence__c != "" &&
        chargeLine.Item_Sequence__c != "0"
      ) {
        var detail = {};
        detail.AmountTarget = this.checkNullNumber(chargeLine.Amount_Target__c);
        detail.Description = this.checkNullString(
          chargeLine.ChargeDescription__c
        );
        subTotalAmount += detail.AmountTarget;
        if (itemSeqVsDetails[chargeLine.Item_Sequence__c]) {
          detailsArray = itemSeqVsDetails[chargeLine.Item_Sequence__c].items;
        } else {
          detailsArray = [];
          itemSeqVsDetails[chargeLine.Item_Sequence__c] = {};
          itemSeqVsDetails[
            chargeLine.Item_Sequence__c
          ].name = this.checkNullString(chargeLine.Item_Name__c);
          itemSeqVsDetails[
            chargeLine.Item_Sequence__c
          ].quantity = this.checkNullNumber(chargeLine.Quantity__c);
          itemSeqVsDetails[
            chargeLine.Item_Sequence__c
          ].year = this.checkNullString(chargeLine.Item_Year__c);
        }
        detailsArray.push(detail);
        itemSeqVsDetails[chargeLine.Item_Sequence__c].items = detailsArray;
      } else {
        var detailExtra = {};
        detailExtra.AmountTarget = this.checkNullNumber(
          chargeLine.Amount_Target__c
        );
        detailExtra.Description = this.checkNullString(
          chargeLine.ChargeDescription__c
        );
        extraRateItems.push(detailExtra);
      }
    });
    var totalQuantity = 0;
    Object.entries(itemSeqVsDetails).map((item) => {
      var finalItem = {};
      var totalSum = 0;
      var rates = item[1];
      if (rates.name && rates.name !== null) {
        if (rates.name.includes("___")) {
          finalItem.containerName = rates.name.substr(
            0,
            rates.name.indexOf("___")
          );
          if (
            rates.name.substr(rates.name.indexOf("___")).replace("___", "") !=
            ""
          ) {
            finalItem.commodityDesc =
              "( " +
              rates.name.substr(rates.name.indexOf("___")).replace("___", "") +
              " )";
          } else {
            finalItem.commodityDesc = "";
          }
        } else {
          finalItem.containerName = rates.name;
          finalItem.commodityDesc = "";
        }
      } else {
        finalItem.containerName = "";
        finalItem.commodityDesc = "";
      }
      if (rates.year && rates.year !== null) {
        finalItem.year = rates.year;
      } else {
        finalItem.year = "";
      }
      finalItem.itemValues = this.sortByAmount(rates.items);
      finalItem.quantity = rates.quantity;
      totalQuantity += parseInt(rates.quantity);
      rates.items.map((it) => {
        totalSum += it.AmountTarget;
      });
      finalItem.totalSum = totalSum;
      rateItems.push(finalItem);
    });

    var totalExtraAmount = 0;
    extraRateItems.map((rate) => {
      totalExtraAmount += rate.AmountTarget;
    });

    component.set("v.extraRateItems", extraRateItems);

    var INSAmount = parseInt($A.get("$Label.c.CC_INS_Charge"));
    var SEDAmount = parseInt($A.get("$Label.c.CC_EEI_Charge"));

    component.set("v.subTotalAmount", subTotalAmount);
    //component.set("v.INSAmount", INSAmount*totalQuantity);
    // component.set("v.SEDAmount", SEDAmount);
    //totalAmount = totalAmount+(INSAmount*totalQuantity)+SEDAmount;
    // totalAmount = totalAmount+totalExtraAmount;
    var totalAmount = parseInt(component.get("v.totalAmount"));
    component.set("v.totalAmount", totalAmount);
    console.log(rateItems);
    component.set("v.rateItems", rateItems);
  },

  resolveRouteRecord: function (component, event, helper, routeRecord) {
    var rateMapping = component.get("v.rateMapping");
    var sortedRateMapping = this.sortData("itemNum", "asc", rateMapping);
    var ratesList = [];

    var finalItemValueList = [];
    var itemValues = routeRecord.CalculatedContributionResult.ItemValues;
    itemValues.map((itemValue) => {
      if (itemValue.ValuesDataRevenue) {
        itemValue.ValuesDataRevenue.map((valueDataRevenue) => {
          if (valueDataRevenue.ValuesGroup) {
            valueDataRevenue.ValuesGroup.map((valueGroup) => {
              if (valueGroup.DocValuesData) {
                finalItemValueList = finalItemValueList.concat(
                  valueGroup.DocValuesData
                );
              }
            });
          }
        });
      }
    });

    var itemNumVsDovValueList = {};
    var itemNumVsTotalSum = {};
    var itemNumVsSubTotalSum = {};
    var INSAmount = parseInt($A.get("$Label.c.CC_INS_Charge"));
    var SEDAmount = parseInt($A.get("$Label.c.CC_EEI_Charge"));
    finalItemValueList.map((docValueData) => {
      if (itemNumVsDovValueList[docValueData.ItemNumber]) {
        var docValueList = itemNumVsDovValueList[docValueData.ItemNumber];
        docValueList.push(docValueData);
        itemNumVsDovValueList[docValueData.ItemNumber] = docValueList;

        var sum = itemNumVsTotalSum[docValueData.ItemNumber];
        sum += docValueData.AmountTarget;
        itemNumVsTotalSum[docValueData.ItemNumber] = sum;

        var subTotal = itemNumVsSubTotalSum[docValueData.ItemNumber];
        subTotal += docValueData.AmountTarget;
        itemNumVsSubTotalSum[docValueData.ItemNumber] = subTotal;
      } else {
        var docValueList = [];
        docValueList.push(docValueData);
        itemNumVsDovValueList[docValueData.ItemNumber] = docValueList;

        var sum = docValueData.AmountTarget;
        itemNumVsTotalSum[docValueData.ItemNumber] = sum;

        var subTotal = docValueData.AmountTarget;
        itemNumVsSubTotalSum[docValueData.ItemNumber] = subTotal;
      }

      /*if(docValueData.ChargeCode=='INS'){
            	INSAmount += docValueData.AmountTarget;
        	}
			if(docValueData.ChargeCode=='SED' || docValueData.ChargeCode=='EEI'){
            	SEDAmount += docValueData.AmountTarget;
        	}*/
    });

    var totalQuantity = 0;
    sortedRateMapping.map((rateItem) => {
      var rate = {};
      if (rateItem.containerName && rateItem.containerName !== null) {
        if (rateItem.containerName.includes("___")) {
          rate.containerName = rateItem.containerName.substr(
            0,
            rateItem.containerName.indexOf("___")
          );
          if (
            rateItem.containerName
              .substr(rateItem.containerName.indexOf("___"))
              .replace("___", "") != ""
          ) {
            rate.commodityDesc =
              "( " +
              rateItem.containerName
                .substr(rateItem.containerName.indexOf("___"))
                .replace("___", "") +
              " )";
          } else {
            rate.commodityDesc = "";
          }
        } else {
          rate.containerName = rateItem.containerName;
          rate.commodityDesc = "";
        }
        if (rateItem.year && rateItem.year != null && rateItem.year !== "") {
          rate.year = rateItem.year;
        } else {
          rate.year = "";
        }
      } else {
        rate.containerName = "";
        rate.commodityDesc = "";
      }
      rate.quantity = rateItem.quantity;
      totalQuantity += parseInt(rateItem.quantity);
      rate.itemNum = rateItem.itemNum;
      ratesList.push(rate);
    });

    var finalRateList = [];
    var totalAmount = 0;
    var subTotalAmount = 0;
    ratesList.map((rate) => {
      rate.itemValues = this.sortByAmount(itemNumVsDovValueList[rate.itemNum]);
      rate.totalSum = itemNumVsTotalSum[rate.itemNum];
      rate.subTotalSum = itemNumVsSubTotalSum[rate.itemNum];
      subTotalAmount += itemNumVsSubTotalSum[rate.itemNum];
      totalAmount += itemNumVsTotalSum[rate.itemNum];
      finalRateList.push(rate);
    });

    var extraRateItems = [];
    var totalExtraAmount = 0;
    if (itemNumVsDovValueList["0"]) {
      extraRateItems = this.sortByAmount(itemNumVsDovValueList["0"]);
      extraRateItems.map((rate) => {
        totalExtraAmount += rate.AmountTarget;
      });
    }

    component.set("v.extraRateItems", extraRateItems);
    //component.set("v.totalAmount", totalAmount);
    component.set("v.subTotalAmount", subTotalAmount);
    component.set("v.INSAmount", INSAmount * totalQuantity);
    component.set("v.SEDAmount", SEDAmount);
    //totalAmount = totalAmount+(INSAmount*totalQuantity)+SEDAmount;
    totalAmount = totalAmount + totalExtraAmount;
    component.set("v.totalAmount", totalAmount);
    console.log(finalRateList);
    component.set("v.rateItems", finalRateList);
  },
  sortByAmount: function (itemValues) {
    return this.sortData("AmountTarget", "desc", itemValues);
  },
  sortData: function (fieldname, direction, parsedJson) {
    var parseData = parsedJson;
    var isReverse = direction === "asc" ? 1 : -1;
    parseData.sort((x, y) => {
      x = x[fieldname] ? x[fieldname] : "";
      y = y[fieldname] ? y[fieldname] : "";
      return isReverse * ((x > y) - (y > x));
    });
    return parseData;
  },

  checkNullString: function (value) {
    return value && value != null ? value : "";
  },

  checkNullNumber: function (value) {
    return value && value != null ? value : 0;
  }
});
