/*
 * Name: UserFinderUtilityTest
 * Purpose: TEst class for UserFinderUtility
 * Author: Nagarro
 * Created Date: 09-Jan-2020
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
@isTest(seeAllData=false)
public class UserFinderUtilityTest {
  @isTest
  static void testUserFinderUtility() {
    UserFinderUtility objUserFinderUtility = new UserFinderUtility(
      UserFinderUtility.getUsersByRole(),
      UserFinderUtility.getParentRole(),
      UserFinderUtility.getUserRole()
    );
    Set<String> setString = objUserFinderUtility.getBottomHierarchy(
      [SELECT Id FROM USER WHERE Email = 'manager123@test.com'][0]
      .Id
    );
    System.assert(setString != null);
  }
  @testsetup
  static void testSetup() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    USerRole objRole = [
      SELECT Id, ParentRoleId
      FROM UserRole
      WHERE ParentRoleId != NULL
      LIMIT 1
    ];
    User u1 = TestDataUtility.createUser(
      objRole.ParentRoleId,
      profileId,
      null,
      'User1',
      'manager123@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u1;
    User u2 = TestDataUtility.createUser(
      objRole.Id,
      profileId,
      null,
      'User1',
      'subordinate124@test.com',
      'en_US',
      'en_US',
      'UTF-8',
      'America/Los_Angeles',
      null,
      null
    );
    insert u2;
  }
}
