({
  fetchData: function (component, event, helper) {
    var action = component.get("c.fetchRecords");
    action.setParams({
      jsonString: component.get("v.tableJson")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var data = response.getReturnValue();
        if (data && data != null) {
          console.log("data from table : ", data);
          helper.processData(component, event, helper, data);
        } else {
          console.log("Error message: response null");
          component.set("v.showLoadingSpinner", false);
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
        component.set("v.showLoadingSpinner", false);
      }
    });
    $A.enqueueAction(action);
  },
  processData: function (component, event, helper, data) {
    component.set("v.showLoadingSpinner", true);
    var json = JSON.parse(component.get("v.tableJson"));
    component.set("v.cardClassName", json.cardClassName);

    var columns = [];
    var idObj = {
      label: "Id",
      order: 0,
      fieldName: "Id",
      isTableColumn: false,
      dataType: "text",
      isRef: true
    };
    var refColumns = [];
    columns.push(idObj);
    refColumns.push(idObj);
    json.fieldsToFetch.map((item) => {
      if (item.isTableColumn) {
        var colObj = {
          label: item.label,
          order: item.order,
          fieldName: item.fieldName,
          dataType: item.dataType,
          isTableColumn: item.isTableColumn,
          isRef: item.isRef
        };
        if (item.dataType === "date") {
          colObj["dateFormat"] = item.dateFormat;
        } else if (item.dataType === "url") {
          var redirectUrl = item.redirectUrl;
          var target = item.target;
          if (target) {
            colObj["target"] = target;
          }
          colObj["redirectUrl"] = redirectUrl;
        }
        if (
          json.sortBy &&
          json.sortBy[0] !== null &&
          (json.sortBy[0].fieldName === item.fieldName ||
            (json.sortBy[0].fieldLabel &&
              json.sortBy[0].fieldLabel === item.label))
        ) {
          colObj["isOrder"] = true;
          colObj["orderDirection"] = json.sortBy[0].order;
        } else {
          colObj["isOrder"] = false;
        }
        if (item.classNameRow) {
          colObj["classNameRow"] = item.classNameRow;
        } else {
          colObj["classNameRow"] = "";
        }
        columns.push(colObj);
      } else {
        refColumns.push({
          label: item.label,
          order: item.order,
          fieldName: item.fieldName,
          dataType: item.dataType,
          isTableColumn: item.isTableColumn
        });
      }
    });
    columns = this.sortData("order", "asc", columns);
    var finalData = [];
    var startRow = parseInt(json.offset);
    var finalRefData = [];
    data.map((item) => {
      var refData = [];
      var Id;
      refColumns.map((col) => {
        var field = col.fieldName;
        var dataType = col.dataType;
        if (field.includes(".")) {
          var fld = field;
          var fields = [];
          while (fld.indexOf(".") > 0) {
            fields.push(fld.substring(fld.lastIndexOf(".") + 1));
            fld = fld.substring(0, fld.lastIndexOf("."));
          }
          var parent = field.substring(0, field.indexOf("."));
          var value = item[parent];
          if (value) {
            fields.map((it) => {
              value = value[it];
            });
          }
        } else {
          var value = item[field];
        }
        if (field === "Id") {
          Id = value;
        } else {
          if (dataType === "date") {
            if (col.dateFormat) {
              value = $A.localizationService.formatDate(value, col.dateFormat);
            }
            refData.push({
              value: value,
              dataType: dataType,
              label: col.label,
              dateFormat: col.dateFormat,
              className: col.classNameRow
            });
          } else {
            refData.push({
              value: value,
              dataType: dataType,
              label: col.label,
              className: col.classNameRow
            });
          }
        }
      });
      finalRefData.push({
        Id: Id,
        refData: refData
      });
    });
    data.map((item) => {
      var rowData = [];
      var Id;
      if (json.hasRowNumber) {
        startRow++;
        rowData.push({
          value: startRow,
          dataType: "text",
          label: startRow,
          className: ""
        });
      }
      columns.map((col) => {
        var field = col.fieldName;
        var dataType = col.dataType;
        if (field.includes(".")) {
          var fld = field;
          var fields = [];
          while (fld.indexOf(".") > 0) {
            fields.push(fld.substring(fld.lastIndexOf(".") + 1));
            fld = fld.substring(0, fld.lastIndexOf("."));
          }
          var parent = field.substring(0, field.indexOf("."));
          var value = item[parent];
          if (value) {
            fields.map((it) => {
              value = value[it];
            });
          }
        } else {
          var value = item[field];
        }
        if (field === "Id") {
          Id = value;
        } else {
          if (col.isTableColumn && !col.isRef) {
            if (dataType === "date") {
              if (col.dateFormat) {
                value = $A.localizationService.formatDate(
                  value,
                  col.dateFormat
                );
              }
              rowData.push({
                value: value,
                dataType: dataType,
                label: col.label,
                dateFormat: col.dateFormat,
                className: col.classNameRow
              });
            } else if (dataType === "url") {
              var recordIdNoHyperlink = component.get("v.recordIdNoHyperlink");
              var target = col.target;
              var str = col.redirectUrl;
              var arr = [];
              while (str.indexOf("}") > 0) {
                arr.push(str.substring(str.indexOf("{") + 1, str.indexOf("}")));
                str = str.substring(str.indexOf("}") + 1);
              }
              var redirectUrl = col.redirectUrl;
              arr.map((fieldUrl) => {
                redirectUrl = redirectUrl.replace(
                  "{" + fieldUrl + "}",
                  item[fieldUrl]
                );
              });
              var obj = {
                value: value,
                dataType: dataType,
                label: col.label,
                redirectUrl: redirectUrl,
                className: col.classNameRow
              };
              if (target) {
                obj["target"] = target;
              }
              if (
                recordIdNoHyperlink &&
                obj.redirectUrl.includes(recordIdNoHyperlink)
              ) {
                obj.dataType = "text";
              }
              rowData.push(obj);
            } else {
              rowData.push({
                value: value,
                dataType: dataType,
                label: col.label,
                className: col.classNameRow
              });
            }
          }
          if (col.isRef) {
            var refData = [];
            finalRefData.map((ref) => {
              if (ref.Id == item.Id) {
                refData = ref.refData;
              }
            });
            var val = col.fieldName;
            refData.map((dat) => {
              val = val.replace("{" + dat.label + "}", dat.value);
            });
            rowData.push({
              value: val,
              dataType: dataType,
              label: col.label,
              className: col.classNameRow
            });
          }
        }
      });
      finalData.push(rowData);
    });
    columns = columns.filter((obj) => obj.isTableColumn);
    console.log("columns ", columns);
    console.log("final Data ", finalData);
    component.set("v.columns", columns);
    if (component.get("v.data") && component.get("v.data") > 0) {
      var preData = component.get("v.data");
      preData.push(finalData);
      component.set("v.data", preData);
    } else {
      component.set("v.data", finalData);
    }
    component.set("v.showLoadingSpinner", false);
  },

  sortData: function (fieldname, direction, parsedJson) {
    var parseData = parsedJson;
    var keyValue = (a) => {
      return a[fieldname];
    };
    var isReverse = direction === "asc" ? 1 : -1;
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : "";
      y = keyValue(y) ? keyValue(y) : "";
      return isReverse * ((x > y) - (y > x));
    });
    return parseData;
  }
  /*
    handleChangeOrder: function (component,event,helper) {
        component.set("v.showLoadingSpinner", true);
        var tableJson = component.get('v.tableJson');
        if (tableJson && tableJson != '') {
            tableJson = JSON.parse(tableJson);
            if (tableJson.sortBy && tableJson.sortBy.length > 0 && tableJson.sortBy[0].order) {
                var order = tableJson.sortBy[0].order;
                if (order === 'asc') {
                    tableJson.sortBy[0].order = 'desc';
                    component.set("v.sortByDirection", 'desc');
                } else {
                    tableJson.sortBy[0].order = 'asc';
                    component.set("v.sortByDirection", 'asc');
                }
                component.set("v.tableJson", JSON.stringify(tableJson));
                helper.fetchData(component, event, helper);
            }
        }
    }*/
});
