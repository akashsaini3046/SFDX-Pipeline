({
  onFileUploaded: function (component, event, helper) {
    helper.show(component, event);
    var files = component.get("v.fileToBeUploaded");
    if (files && files.length > 0) {
      var file = files[0][0];
      var reader = new FileReader();
      reader.onloadend = function () {
        var dataURL = reader.result;
        var content = dataURL.match(/,(.*)$/)[1];
        helper.upload(component, file, content, function (answer) {
          if (answer) {
            helper.hide(component, event);
            // Success
          } else {
            // Failure
          }
        });
      };
      reader.readAsDataURL(file);
    } else {
      helper.hide(component, event);
    }
  },

  saveFile: function (component, event, helper) {
    //get method paramaters
    var params = event.getParam("arguments");
    var parentId = null;
    if (params && params.parentId) {
      component.set("v.parentId", params.parentId);
    }

    if (
      component.find("fileId").get("v.files") &&
      component.find("fileId").get("v.files").length > 0
    ) {
      helper.uploadHelper(component, event);
    } else {
      helper.fireFileUploadEvent(component, "SUCCESS", null, null);
    }
  },

  handleFilesChange: function (component, event, helper) {
    var MAX_FILE_SIZE = 4500000;
    var fileName = "No File Selected..";
    if (event.getSource().get("v.files").length > 0) {
      fileName = event.getSource().get("v.files")[0]["name"];
      var fileInput = component.find("fileId").get("v.files");
      var file = fileInput[0];
      if (file.size > MAX_FILE_SIZE) {
        helper.maxFileSize(component, event, "false");
      } else if (file.size < MAX_FILE_SIZE) {
        helper.maxFileSize(component, event, "true");
      }
    }
    component.set("v.fileName", fileName);
  }
});
