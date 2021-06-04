@isTest
public class CC_UserPermissionUtilityTest {
  @testSetup
  public static void setup() {
    List<User> user = TestDataUtility.getUser('System Administrator', 1, true);
  }
  @isTest
  public static void checkUserPermissionTest() {
    Test.startTest();
    CC_UserPermissionUtility.checkUserPermission(null, '', '');
    Test.stopTest();
  }

  @isTest
  public static void checkUserPermissionTest1() {
    User u = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];
    Test.startTest();
    CC_UserPermissionUtility.checkUserPermission(
      u.id,
      'Page',
      'Shipment Tracking'
    );
    Test.stopTest();
  }
  @isTest
  public static void checkUserPermissionTest2() {
    System.debug([SELECT Id FROM User LIMIT 1][0].id);
    User u = [
      SELECT Id
      FROM User
      WHERE Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    Boolean perm;

    Test.startTest();
    CC_UserPermissionUtility.permissionReport userpermissions = CC_UserPermissionUtility.checkUserPermission(
      u.id,
      'sObject',
      'Idea'
    );

    Test.stopTest();
  }
}
