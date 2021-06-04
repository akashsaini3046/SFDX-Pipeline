/*
 * Name: UserFinderUtility
 * Purpose: This class returns hierarchie users details based on role
 * Author: Nagarro
 * Created Date: 03-Jan-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class UserFinderUtility {
  Map<String, List<String>> mapRoleUser;
  Map<String, String> mapRoleParentRole;
  public Map<String, String> mapUserIdToRole;
  public static Set<String> setUserTopHierarchy = new Set<String>();
  static Set<String> setUserDownHierarchy = new Set<String>();

  //Constructor
  public UserFinderUtility(
    Map<String, List<String>> mapRoleUser,
    Map<String, String> mapRoleParentRole,
    Map<String, String> mapUserIdToRole
  ) {
    this.mapRoleUser = mapRoleUser;
    this.mapRoleParentRole = mapRoleParentRole;
    this.mapUserIdToRole = mapUserIdToRole;
  }

  /*
   * Method Name: getTopHierarchy
   * Input Parameters:
   * String strUserRoleId: This holds user role Id.
   * Return value: List<String>
   * Purpose: get user list who are on top heirarchy of strUserRoleId user.
   */
  public Set<String> getTopHierarchy(String strUserRoleId) {
    if (String.isNotBlank(strUserRoleId)) {
      List<String> lstUsers = mapRoleUser.get(
        mapRoleParentRole.get(strUserRoleId)
      );
      if (lstUsers != null && lstUsers.size() > 0) {
        setUserTopHierarchy.addAll(lstUsers);
      }
      if (mapRoleParentRole.get(strUserRoleId) != null) {
        getTopHierarchy(mapRoleParentRole.get(strUserRoleId));
      }
    }

    return setUserTopHierarchy;
  }

  /*
   * Method Name: getBottomHierarchy
   * Input Parameters:
   * String strUserRoleId: This holds user role Id.
   * Return value: List<String>
   * Purpose: get user list who are in down heirarchy of strUserRoleId user.
   */
  public Set<String> getBottomHierarchy(String strCurrentUserId) {
    if (String.isNotBlank(mapUserIdToRole.get(strCurrentUserId))) {
      for (String strUserId : mapUserIdToRole.keySet()) {
        if (
          String.isNotBlank(strUserId) && mapUserIdToRole.get(strUserId) != null
        ) {
          setUserTopHierarchy.clear();
          Set<String> setUserTopHierarchy = getTopHierarchy(
            mapUserIdToRole.get(strUserId)
          );
          if (setUserTopHierarchy.contains(strCurrentUserId)) {
            setUserDownHierarchy.add(strUserId);
          }
        }
      }
    }

    return setUserDownHierarchy;
  }

  /*
   * Method Name: getUsersByRole
   * Input Parameters:
   * Return value: Map<String, List<String>>
   * Purpose: get users by role map.
   */
  public static Map<String, List<String>> getUsersByRole() {
    Map<String, List<String>> mapRoleUser = new Map<String, List<String>>();
    Map<Id, Profile> mapProfileIds = new Map<id, profile>(
      [
        SELECT Id, UserLicenseId
        FROM Profile
        WHERE
          UserLicenseId IN (
            SELECT Id
            FROM UserLicense
            WHERE name = 'Salesforce'
          )
      ]
    );

    for (User objUser : [
      SELECT Id, UserRoleId
      FROM User
      WHERE UserRoleId != NULL AND profileId IN :mapProfileIds.Keyset()
      ORDER BY IsActive DESC
    ]) {
      if (mapRoleUser.containsKey(objUser.UserRoleId)) {
        mapRoleUser.get(objUser.UserRoleId).add(objUser.Id);
      } else {
        mapRoleUser.put(objUser.UserRoleId, new List<String>{ objUser.Id });
      }
    }
    return mapRoleUser;
  }

  /*
   * Method Name: getParentRole
   * Input Parameters:
   * Return value: Map<String, String>
   * Purpose: get role and its parent role map.
   */
  public static Map<String, String> getParentRole() {
    Map<String, String> mapRoleParentRole = new Map<String, String>();
    for (UserRole objUserRole : [SELECT Id, ParentRoleId FROM UserRole]) {
      mapRoleParentRole.put(objUserRole.Id, objUserRole.ParentRoleId);
    }
    return mapRoleParentRole;
  }

  /*
   * Method Name: getUserRole
   * Input Parameters:
   * Return value: Map<String, String>
   * Purpose: get role and user map.
   */
  public static Map<String, String> getUserRole() {
    Map<String, String> mapUserIdToRole = new Map<String, String>();
    Map<Id, Profile> mapProfileIds = new Map<id, profile>(
      [
        SELECT Id, UserLicenseId
        FROM Profile
        WHERE
          UserLicenseId IN (
            SELECT Id
            FROM UserLicense
            WHERE name = 'Salesforce'
          )
      ]
    );

    for (User objUser : [
      SELECT Id, UserRoleId
      FROM User
      WHERE profileId IN :mapProfileIds.Keyset()
    ]) {
      mapUserIdToRole.put(objUser.Id, objUser.UserRoleId);
    }
    return mapUserIdToRole;
  }

  /*
   * Method Name: getUserById
   * Input Parameters:
   * Return value: Map<String, String>
   * Purpose: get userId and user full name map.
   */
  public static Map<String, String> getUserById() {
    Map<String, String> mapUserIdToName = new Map<String, String>();
    Map<Id, Profile> mapProfileIds = new Map<id, profile>(
      [
        SELECT Id, UserLicenseId
        FROM Profile
        WHERE
          UserLicenseId IN (
            SELECT Id
            FROM UserLicense
            WHERE name = 'Salesforce'
          )
      ]
    );

    for (User objUser : [
      SELECT Id, Name
      FROM User
      WHERE profileId IN :mapProfileIds.Keyset()
    ]) {
      mapUserIdToName.put(objUser.Id, objUser.Name);
    }
    return mapUserIdToName;
  }
}
