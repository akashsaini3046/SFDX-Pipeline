public class CC_UserPermissionUtility {
  public static permissionReport checkUserPermission(
    Id userId,
    String entityType,
    String entityName
  ) {
    List<ObjectPermissions> listObjPermissions = new List<ObjectPermissions>();
    List<PermissionSetAssignment> listPermissionAssignment = new List<PermissionSetAssignment>();
    List<Customer_Community_User_Permission__mdt> listMetadataPermissions = new List<Customer_Community_User_Permission__mdt>();
    permissionReport userPermissions = new permissionReport();
    Set<Id> setParentId = new Set<Id>();
    Set<String> setEntityType = new Set<String>();
    Set<String> setPermissionName = new Set<String>();
    Schema.DescribeFieldResult fieldResult = Customer_Community_User_Permission__mdt.EntityType__c.getDescribe();
    List<Schema.PicklistEntry> ple;

    if (fieldResult != null) {
      ple = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry pickListVal : ple)
        setEntityType.add(pickListVal.getLabel());
    }

    userPermissions.readPermission = false;
    userPermissions.editPermission = false;
    userPermissions.deletePermission = false;
    userPermissions.createPermission = false;
    userPermissions.viewAllPermission = false;
    userPermissions.modifyAllPermission = false;

    if (
      userId == null ||
      entityType == null ||
      entityType == '' ||
      entityName == null ||
      entityName == ''
    )
      userPermissions.errorMessage = 'User Id, EntityType and EntityName are required.';
    else {
      userPermissions.entityName = entityName;
      userPermissions.userId = String.valueOf(userId);
      listPermissionAssignment = [
        SELECT
          Id,
          AssigneeId,
          PermissionSetId,
          PermissionSet.isOwnedByProfile,
          PermissionSet.Profile.Name,
          PermissionSet.Label
        FROM PermissionSetAssignment
        WHERE AssigneeId = :userId
      ];
      if (!listPermissionAssignment.isEmpty()) {
        for (PermissionSetAssignment psa : listPermissionAssignment)
          setParentId.add(psa.PermissionSetId);
        if (entityType == 'sObject') {
          listObjPermissions = [
            SELECT
              Id,
              ParentId,
              PermissionsCreate,
              PermissionsDelete,
              PermissionsEdit,
              PermissionsModifyAllRecords,
              PermissionsRead,
              PermissionsViewAllRecords,
              SobjectType
            FROM ObjectPermissions
            WHERE SobjectType = :entityName AND ParentId IN :setParentId
          ];
          for (ObjectPermissions objPerm : listObjPermissions) {
            if (objPerm.PermissionsCreate)
              userPermissions.createPermission = true;
            if (objPerm.PermissionsEdit)
              userPermissions.editPermission = true;
            if (objPerm.PermissionsDelete)
              userPermissions.deletePermission = true;
            if (objPerm.PermissionsRead)
              userPermissions.readPermission = true;
            if (objPerm.PermissionsViewAllRecords)
              userPermissions.viewAllPermission = true;
            if (objPerm.PermissionsModifyAllRecords)
              userPermissions.modifyAllPermission = true;
          }
        } else if (
          !setEntityType.isEmpty() && setEntityType.contains(entityType)
        ) {
          for (PermissionSetAssignment psa : listPermissionAssignment) {
            if (
              psa.PermissionSet.isOwnedByProfile &&
              psa.PermissionSet.Profile.Name != null
            )
              setPermissionName.add(psa.PermissionSet.Profile.Name);
            if (psa.PermissionSet.Label != null)
              setPermissionName.add(psa.PermissionSet.Label);
          }
          if (!setPermissionName.isEmpty()) {
            listMetadataPermissions = [
              SELECT
                Id,
                Permission_Set_Name__c,
                EntityName__c,
                EntityType__c,
                ViewPermission__c
              FROM Customer_Community_User_Permission__mdt
              WHERE
                Permission_Set_Name__c IN :setPermissionName
                AND EntityName__c = :entityName
                AND EntityType__c = :entityType
            ];
            for (
              Customer_Community_User_Permission__mdt customPermission : listMetadataPermissions
            ) {
              if (customPermission.ViewPermission__c)
                userPermissions.readPermission = true;
            }
          }
        } else {
          userPermissions.errorMessage = 'Entity Type Not found.';
        }
      } else {
        userPermissions.errorMessage = 'No permissions found for the user.';
      }
    }
    return userPermissions;
  }

  public class permissionReport {
    @AuraEnabled
    public Boolean readPermission { get; set; }
    @AuraEnabled
    public Boolean editPermission { get; set; }
    @AuraEnabled
    public Boolean deletePermission { get; set; }
    @AuraEnabled
    public Boolean createPermission { get; set; }
    @AuraEnabled
    public Boolean viewAllPermission { get; set; }
    @AuraEnabled
    public Boolean modifyAllPermission { get; set; }
    @AuraEnabled
    public String entityName { get; set; }
    @AuraEnabled
    public String userId { get; set; }
    @AuraEnabled
    public String errorMessage { get; set; }
  }
}
