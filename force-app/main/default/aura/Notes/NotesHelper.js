({
  fetchAllNotes: function (component, objMasterFilter) {
    var action = component.get("c.fetchNotes");
    action.setParams({
      accountId: component.get("v.recordId"),
      objMasterFilter: objMasterFilter
    });

    // Register the callback function
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.notesControllerObj", response.getReturnValue());
        //Fetch map of notes id and description.
        var listNoteIdAndDescription = [];
        var mapNoteIdAndContent = component.get("v.notesControllerObj")
          .mapIdAndCsvAsString;
        for (var key in mapNoteIdAndContent) {
          var x = mapNoteIdAndContent[key]; //.replace(/<[^>]*>/g, '');
          listNoteIdAndDescription.push({ value: x, key: key });
        }
        component.set("v.listNoteIdAndDescription", listNoteIdAndDescription);

        //Fetch map of notes id and the object name. Convert it to list which will be used on the component.
        var listNoteIdAndParentObjectName = [];
        var mapNoteIdAndObjName = component.get("v.notesControllerObj")
          .mapNoteIdAndParentObjectName;
        for (var key in mapNoteIdAndObjName) {
          listNoteIdAndParentObjectName.push({
            value: mapNoteIdAndObjName[key],
            key: key
          });
        }
        component.set(
          "v.listNoteIdAndParentObjectName",
          listNoteIdAndParentObjectName
        );

        //Fetch map of notes id and the record name. Convert it to list which will be used on the component.
        var listNoteIdAndParentRecordName = [];
        var mapNoteIdAndRecName = component.get("v.notesControllerObj")
          .mapNoteIdAndParentRecordName;
        for (var key in mapNoteIdAndRecName) {
          listNoteIdAndParentRecordName.push({
            value: mapNoteIdAndRecName[key],
            key: key
          });
        }
        component.set(
          "v.listNoteIdAndParentRecordName",
          listNoteIdAndParentRecordName
        );
      }
    });

    $A.enqueueAction(action);
  },

  createAllNotesComponent: function (component, event, helper) {
    $A.createComponent(
      "c:AllNotes",
      {
        notesControllerObj: component.get("v.notesControllerObj"),
        listNoteIdAndDescription: component.get("v.listNoteIdAndDescription"),
        listNoteIdAndParentObjectName: component.get(
          "v.listNoteIdAndParentObjectName"
        ),
        listNoteIdAndParentRecordName: component.get(
          "v.listNoteIdAndParentRecordName"
        ),
        recordId: component.get("v.recordId"),
        strSelectedYear: component.get("v.strSelectedYear")
      },
      function (msgBox) {
        if (component.isValid()) {
          var targetCmp = component.find("AllNotesModalDialog");
          targetCmp.set("v.body", [msgBox]);
        }
      }
    );
  }
});
