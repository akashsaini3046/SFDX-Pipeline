({
  doInit: function (component, event, helper) {
    var ObjData = component.get("v.data"); //JSON.parse(component.get('v.data'));
    var lstInvoices = [];
    var totalSum = 0.0;
    for (var key in ObjData) {
      var label = "";
      let uiLabel = "";
      var currentCommodityValueSum = 0.0;
      if ($A.util.isEmpty(ObjData[key]) == false) {
        for (var i = 0; i < ObjData[key].length; i++) {
          if ($A.util.isEmpty(ObjData[key][i].strValue) == false) {
            currentCommodityValueSum += parseInt(ObjData[key][i].strValue);
          }
        }
      }
      if ($A.util.isEmpty(key) == false) {
        try {
          if (key.includes(">Hazardous<")) {
            uiLabel =
              key.substring(0, key.indexOf("___")) +
              "( " +
              key.substr(key.indexOf("___")).replace("___", "") +
              " )";
          } else {
            uiLabel =
              key.substring(0, key.indexOf("___")) +
              " ( " +
              key.substring(key.indexOf("___") + 3, key.length) +
              " )";
          }
        } catch (objerr) {
          uiLabel = "(" + key.replace("___", " ") + ")";
        }
        label = "(" + key.replace("___", " ") + ")";
      }
      totalSum = totalSum + currentCommodityValueSum;
      lstInvoices.push({
        value: ObjData[key],
        key: key,
        amount: currentCommodityValueSum,
        label: uiLabel
      });
    }
    component.set("v.invoicingData", lstInvoices);
    component.set("v.totalSum", "" + totalSum);
    console.log(JSON.stringify(component.get("v.invoicingData")));
  },
  handleCollapse: function (component, event, helper) {
    if (component.get("v.isExpand") == true) {
      component.set("v.collapseExpand", "EXPAND");
    } else if (component.get("v.isExpand") == false) {
      component.set("v.collapseExpand", "COLLAPSE");
    }
    component.set("v.isExpand", !component.get("v.isExpand"));
  }
});
