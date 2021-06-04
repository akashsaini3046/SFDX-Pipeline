({
  upload: function (component, file, base64Data, callback) {
    var action = component.get("c.uploadFile");
    console.log("type: " + file.type);
    action.setParams({
      fileName: file.name,
      base64Data: base64Data,
      contentType: file.type
    });
    action.setCallback(this, function (a) {
      var state = a.getState();
      if (state === "SUCCESS") {
        callback(a.getReturnValue());
      }
    });
    $A.enqueueAction(action);
  },
  show: function (cmp, event) {
    var spinner = cmp.find("mySpinner");
    $A.util.removeClass(spinner, "slds-hide");
    $A.util.addClass(spinner, "slds-show");
  },
  hide: function (cmp, event) {
    var spinner = cmp.find("mySpinner");
    $A.util.removeClass(spinner, "slds-show");
    $A.util.addClass(spinner, "slds-hide");
  },

  MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
  CHUNK_SIZE: 1000000, //Chunk Max size 750Kb

  uploadHelper: function (component, event) {
    // start/show the loading spinner
    component.set("v.showLoadingSpinner", true);
    // get the selected files using aura:id [return array of files]
    var fileInput = component.find("fileId").get("v.files");
    // get the first file using array index[0]
    var file = fileInput[0];
    var self = this;
    // check the selected file size, if select file size greter then MAX_FILE_SIZE,
    // then show a alert msg to user,hide the loading spinner and return from function
    if (file.size > self.MAX_FILE_SIZE) {
      component.set("v.showLoadingSpinner", false);
      component.set(
        "v.fileName",
        "Alert : File size cannot exceed " +
          self.MAX_FILE_SIZE +
          " bytes.\n" +
          " Selected file size: " +
          file.size +
          " bytes."
      );
      return;
    } else if (file.name.length > 40) {
      component.set("v.showLoadingSpinner", false);
      this.showToast(
        "error",
        "File name too long. Maximum 40 characters are allowed.",
        " "
      );
      return;
    }

    // create a FileReader object
    var objFileReader = new FileReader();
    // set onload function of FileReader object
    objFileReader.onload = $A.getCallback(function () {
      var fileContents = objFileReader.result;
      var base64 = "base64,";
      var dataStart = fileContents.indexOf(base64) + base64.length;

      fileContents = fileContents.substring(dataStart);
      // call the uploadProcess method
      self.uploadProcess(component, file, fileContents);
    });

    objFileReader.readAsDataURL(file);
  },

  uploadProcess: function (component, file, fileContents) {
    // set a default size or startpostiton as 0
    var startPosition = 0;
    // calculate the end size or endPostion using Math.min() function which is return the min. value
    var endPosition = Math.min(
      fileContents.length,
      startPosition + this.CHUNK_SIZE
    );

    // start with the initial chunk, and set the attachId(last parameter)is null in begin
    this.uploadInChunk(
      component,
      file,
      fileContents,
      startPosition,
      endPosition,
      ""
    );
  },

  uploadInChunk: function (
    component,
    file,
    fileContents,
    startPosition,
    endPosition,
    attachId
  ) {
    // call the apex method 'saveChunk'
    var getchunk = fileContents.substring(startPosition, endPosition);
    var action = component.get("c.saveChunk");
    action.setParams({
      parentId: component.get("v.parentId"),
      fileName: file.name,
      base64Data: encodeURIComponent(getchunk),
      contentType: file.type,
      fileId: attachId
    });

    // set call back
    action.setCallback(this, function (response) {
      // store the response / Attachment Id
      attachId = response.getReturnValue();
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Process chunk");
        // update the start position with end postion
        startPosition = endPosition;
        endPosition = Math.min(
          fileContents.length,
          startPosition + this.CHUNK_SIZE
        );
        // check if the start postion is still less then end postion
        // then call again 'uploadInChunk' method ,
        // else, diaply alert msg and hide the loading spinner
        if (startPosition < endPosition) {
          this.uploadInChunk(
            component,
            file,
            fileContents,
            startPosition,
            endPosition,
            attachId
          );
        } else {
          component.set("v.showLoadingSpinner", false);
          this.fireFileUploadEvent(component, "SUCCESS", null, null);
        }
        // handel the response errors
      } else if (state === "INCOMPLETE") {
        alert("From server: " + response.getReturnValue());
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
            this.fireFileUploadEvent(
              component,
              "ERROR",
              errors[0].message,
              null
            );
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    // enqueue the action
    $A.enqueueAction(action);
  },

  fireFileUploadEvent: function (cmp, state, message, key) {
    var cmpEvent = cmp.getEvent("fileUploadEvent");
    cmpEvent.setParams({
      message: message,
      state: state,
      key: key
    });
    cmpEvent.fire();
  },
  maxFileSize: function (cmp, event, status) {
    var cmpEvent = cmp.getEvent("MaxfileSizeEvent");
    cmpEvent.setParams({
      fileStatus: status
    });
    cmpEvent.fire();
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      sticky: true,
      type: type,
      title: title,
      message: message
    });
    toastEvent.fire();
  }
});
