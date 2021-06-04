public class CC_HeaderPanelController {
  @AuraEnabled
  public static String getUserName() {
    Id userId = UserInfo.getUserId();
    System.debug('userId@@' + userId);
    User userDetail = new User();
    Map<String, Object> mapUserDetails = new Map<String, Object>();

    userDetail = [
      SELECT Id, LastName, FirstName, LanguageLocaleKey
      FROM User
      WHERE Id = :userId
    ];
    System.debug('userDetail@@' + userDetail);
    mapUserDetails.put(
      CC_Constants.HEADERPANELRESPONSE_LASTNAME,
      userDetail.LastName
    );
    mapUserDetails.put(
      CC_Constants.HEADERPANELRESPONSE_FIRSTNAME,
      userDetail.FirstName
    );
    mapUserDetails.put('UserId', userDetail.Id);
    if (userDetail.LanguageLocaleKey == CC_Constants.SPANISH_LANGUAGECODE)
      mapUserDetails.put(
        CC_Constants.HEADERPANELRESPONSE_LANGUAGE,
        CC_Constants.SPANISH_LANGUAGE
      );
    else
      mapUserDetails.put(
        CC_Constants.HEADERPANELRESPONSE_LANGUAGE,
        CC_Constants.ENGLISH_LANGUAGE
      );
    return JSON.serialize(mapUserDetails);
  }
}
