public without sharing class CC_LoginController {
  @AuraEnabled
  public static String checkPortal(
    String username,
    String password,
    String currentURL
  ) {
    System.PageReference lgn = Site.login(username, password, currentURL);
    if (lgn != null) {
      aura.redirect(lgn);
      return CC_Constants.TRUE_MESSAGE;
    }
    return CC_Constants.FALSE_MESSAGE;
  }
  @AuraEnabled
  public static String getCommunityUrlPathPrefix() {
    return CommonUtility.getCommunityUrlPathPrefix();
  }
  @AuraEnabled
  public static String usernameExists(String username) {
    List<User> commUser = new List<User>();

    commUser = [
      SELECT Id, Username
      FROM User
      WHERE Username = :username
      LIMIT 1
    ];
    if (!commUser.isEmpty()) {
      Boolean emailSent = Site.forgotPassword(username);
      if (emailSent)
        return CC_Constants.TRUE_MESSAGE;
    }
    return CC_Constants.FALSE_MESSAGE;
  }

  @AuraEnabled
  public static String setNewPassword(String idContact, String password) {
    List<User> commUser = new List<User>();

    try {
      Id idCon = Id.valueOf(idContact);
      if (idCon.getSObjectType().getDescribe().getName() == 'Contact') {
        commUser = [
          SELECT Id, Username
          FROM User
          WHERE contactId = :idContact
          LIMIT 1
        ];
      } else if (idCon.getSObjectType().getDescribe().getName() == 'User') {
        commUser = [
          SELECT Id, Username
          FROM User
          WHERE id = :idContact
          LIMIT 1
        ];
      }
      if (!commUser.isEmpty()) {
        System.setPassword(commUser[0].Id, password);
        return commUser[0].Username;
      } else {
        return CC_Constants.FALSE_MESSAGE;
      }
    } catch (Exception ex) {
      return CC_Constants.FALSE_MESSAGE;
    }
  }
  @AuraEnabled
  public static String Login(
    String username,
    String password,
    String currentURL
  ) {
    String navigateUser = CC_LoginController.checkPortal(
      username,
      password,
      currentURL
    );
    if (navigateUser == 'True') {
      return CC_Constants.TRUE_MESSAGE;
    }
    return CC_Constants.FALSE_MESSAGE;
  }
}
