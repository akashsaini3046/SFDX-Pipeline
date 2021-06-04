({
  doInit: function (component, event, helper) {
    var ObjData = component.get("v.data"); //JSON.parse(component.get('v.data'));
    var lstInvoices = [];
    var totalSum = 0.0;
    for (var key in ObjData) {
      var label = "";
      var currentCommodityValueSum = 0.0;
      if ($A.util.isEmpty(ObjData[key]) == false) {
        for (var i = 0; i < ObjData[key].length; i++) {
          if ($A.util.isEmpty(ObjData[key][i].strValue) == false) {
            currentCommodityValueSum += parseInt(ObjData[key][i].strValue);
          }
        }
      }
      if ($A.util.isEmpty(key) == false) {
        label = "(" + key.replace("___", " ") + ")";
      }
      totalSum = totalSum + currentCommodityValueSum;
      lstInvoices.push({
        value: ObjData[key],
        key: key,
        amount: currentCommodityValueSum,
        label: label
      });
    }
    component.set("v.invoicingData", lstInvoices);
    component.set("v.totalSum", "" + totalSum);
    console.log(JSON.stringify(component.get("v.invoicingData")));
  }
});
