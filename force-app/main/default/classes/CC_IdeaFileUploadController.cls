/*
 * @company     : Nagarro Inc.
 * @date        : 16-07-2020
 * @author      : Nagarro
 * @description : Controller to upload files in idea record.
 * @history     : Version 1.0
 * @test class  : CC_IdeaFileUploadControllerTest
 */
public class CC_IdeaFileUploadController {
  /*
   * @purpose     : Method to save the fileUploaded.
   * @parameter   : parentId - Id of the idea Record on which file has to be uploaded
   * @parameter   : fileName - Name of the file to be uploded
   * @parameter   : base64Data - base64 form of the file to be uploded
   * @parameter   : contentType - contentType of the file to be uploded
   * @parameter   : fileId - contentType of the file to be uploded(Blank in case of first chunk)
   * @return      : Id - fileId ie. parentId after the first chunk is executed
   */
  @AuraEnabled
  public static Id saveChunk(
    Id parentId,
    String fileName,
    String base64Data,
    String contentType,
    String fileId
  ) {
    try {
      // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
      //  which is save the check data and return the attachemnt Id after insert,
      //  next time (in else) we are call the appentTOFile() method
      //   for update the attachment with reamins chunks
      if (fileId == '') {
        fileId = saveTheFile(parentId, fileName, base64Data, contentType);
      } else {
        appendToFile(fileId, base64Data);
      }

      return Id.valueOf(fileId);
    } catch (Exception ex) {
      LogFactory.error(
        'CC_IdeaFileUploadController',
        'saveChunk',
        'ERROR',
        ex.getLineNumber() +
        '  ' +
        ex.getMessage()
      );
      LogFactory.saveLog();
      throw new CC_IdeaCustomException(ex.getMessage());
    }
  }

  /*
   * @purpose     : Method to save the fileUploaded.
   * @parameter   : parentId - Id of the idea Record on which file has to be uploaded
   * @parameter   : fileName - Name of the file to be uploded
   * @parameter   : base64Data - base64 form of the file to be uploded
   * @parameter   : contentType - contentType of the file to be uploded
   * @return      : Id - fileId ie. parentId after the first chunk is executed
   */
  public static Id saveTheFile(
    Id parentId,
    String fileName,
    String base64Data,
    String contentType
  ) {
    base64Data = EncodingUtil.urlDecode(
      base64Data,
      CC_Constants.URL_ENCODE_FORMAT
    );
    List<Idea> ideas = [
      SELECT Id, AttachmentBody, AttachmentName, AttachmentContentType
      FROM Idea
      WHERE Id = :parentId
    ];
    if (!ideas.isEmpty()) {
      ideas[0].AttachmentBody = EncodingUtil.base64Decode(base64Data);
      ideas[0].AttachmentName = fileName;
      ideas[0].AttachmentContentType = String.isBlank(contentType)
        ? CC_Constants.PLAIN_TEXT_CONTENTTYPE
        : contentType;
      DMLUtility.updateRecords(ideas, true);
    }

    return parentId;
  }

  /*
   * @purpose     : Method to save the fileUploaded , second chunk onwards.
   * @parameter   : fileId - fileId (parentId after the execution of first chunk)
   * @parameter   : base64Data - base64 form of the file to be uploded
   */
  private static void appendToFile(Id fileId, String base64Data) {
    base64Data = EncodingUtil.urlDecode(
      base64Data,
      CC_Constants.URL_ENCODE_FORMAT
    );

    List<Idea> ideas = [
      SELECT Id, AttachmentBody, AttachmentName, AttachmentContentType
      FROM Idea
      WHERE Id = :fileId
    ];
    if (!ideas.isEmpty()) {
      String existingBody = EncodingUtil.base64Encode(ideas[0].AttachmentBody);

      ideas[0].AttachmentBody = EncodingUtil.base64Decode(
        existingBody + base64Data
      );
      DMLUtility.updateRecords(ideas, true);
    }
  }
  public class CC_IdeaCustomException extends Exception {
  }
}
