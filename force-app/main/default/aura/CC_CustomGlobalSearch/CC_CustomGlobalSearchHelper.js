({
  getSObjectsLabels: function (component, event) {
    var action = component.get("c.getSObjects");
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var mapSobjects = [];
        var responseData = response.getReturnValue();
        for (var key in responseData) {
          mapSobjects.push({ key: key, value: responseData[key] });
        }
        component.set("v.sobjectLabels", mapSobjects);
      }
    });
    $A.enqueueAction(action);
  },
  searchHelper: function (component, event, getInputkeyWord) {
    var selectedApiName = component.find("select").get("v.value");
    var mapSobjects = component.get("v.sobjectLabels");
    var searchlen = getInputkeyWord.length;
    if (searchlen > 2) {
      if (selectedApiName == "All") {
        this.findResults(
          component,
          event,
          getInputkeyWord,
          selectedApiName,
          selectedApiName
        );
      } else {
        var selectedOption = this.getByValue(mapSobjects, selectedApiName);
        this.findResults(
          component,
          event,
          getInputkeyWord,
          selectedOption,
          selectedApiName
        );
      }
    } else {
      component.set("v.Message", "Keep typing... Type some more characters");
      component.set("v.showmessageDialog", true);
      component.set("v.loading", false);
      component.set("v.listOfSearchRecords", null);
    }
  },
  findResults: function (
    component,
    event,
    getInputkeyWord,
    selectedOption,
    selectedApiName
  ) {
    var action = component.get("c.searchAllObjects");
    action.setParams({
      searchKeyWord: getInputkeyWord,
      selValueLabel: selectedOption,
      selValApiName: selectedApiName
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseData = response.getReturnValue();
        if (responseData.length == 0) {
          component.set("v.resultMessage", "No Results Found.");
          component.set(
            "v.Message",
            "The Record you are searching for is unavailable."
          );
          component.set("v.showmessageDialog", true);
        } else {
          component.set("v.resultMessage", "Search Result...");
          component.set("v.showmessageDialog", false);
        }
        component.set("v.listOfSearchRecords", responseData);
      } else if (state === "ERROR") {
        console.log("Error in fetching Results !");
      }
      component.set("v.loading", false);
    });
    $A.enqueueAction(action);
  },
  getByValue: function (map, searchValue) {
    for (var index in map) {
      if (map[index].value == searchValue) {
        return map[index].key;
      }
    }
  }
});
