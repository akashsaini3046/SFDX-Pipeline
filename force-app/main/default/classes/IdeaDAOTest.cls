@isTest
public class IdeaDAOTest {
  @testSetup
  static void setup() {
    Community community = [
      SELECT Id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    List<Idea> ideaList = TestDataUtility.getIdeaRecords(
      community.Id,
      'Community',
      2,
      true
    );
    Set<Id> ideaIds = new Set<Id>();
    for (Idea idea : ideaList) {
      ideaIds.add(idea.Id);
    }
    List<IdeaComment> ideaCommentsList = TestDataUtility.getIdeaComment(
      ideaIds,
      'I liked the idea',
      2,
      true
    );
  }

  @isTest
  static void getUserDetailsTest() {
    Id userId = (Id) UserInfo.getUserId();

    Test.startTest();
    User userfetched = IdeaDAO.getUserDetails(userId);
    Test.stopTest();

    System.assertEquals(userId, userfetched.Id, 'User Id Check');
  }

  @isTest
  static void getIdeaListByIdsTest() {
    List<Idea> ideas = [SELECT id, title FROM Idea];
    Map<Id, Idea> ideasMap = new Map<Id, Idea>(ideas);

    Test.startTest();
    List<Idea> ideasListFetched = IdeaDAO.getIdeaListByIds(ideasMap.keySet());
    Test.stopTest();

    System.assertEquals(
      ideasMap.keySet().size(),
      ideasListFetched.size(),
      'Number of Ideas check'
    );
  }

  @isTest
  static void getIdeaWithAllFieldsTest() {
    Idea idea = [SELECT id, title FROM Idea LIMIT 1];

    Test.startTest();
    Idea i = IdeaDAO.getIdeaWithAllFields(idea.Id);
    Test.stopTest();

    System.assertEquals(idea.title, i.Title, 'Expected idea not fetched');
  }

  @isTest
  static void getIdeaWithAllFieldsNegativeTest() {
    Idea idea = new Idea();

    Test.startTest();
    Idea i = IdeaDAO.getIdeaWithAllFields(null);
    Test.stopTest();

    System.assertEquals(idea, i, 'Expected idea not fetched');
  }

  @isTest
  static void getIdeaCommentsTest() {
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    IdeaComment comment = [
      SELECT id
      FROM IdeaComment
      WHERE IdeaId = :ideaRecord.id
      LIMIT 1
    ];
    Set<Id> commentsIds = new Set<Id>();
    commentsIds.add(comment.id);
    TestDataUtility.getIdeaCommentVote(commentsIds, true);

    Test.startTest();
    List<IdeaComment> ideaComments = IdeaDAO.getIdeaComments(ideaRecord.id);
    Test.stopTest();

    System.assertNotEquals(null, ideaComments, 'All idea comments not fetched');
  }

  @isTest
  static void getIdeaVotesTest() {
    List<User> usersList = TestDataUtility.getUser(
      'System Administrator',
      1,
      true
    );
    Idea ideaRecord = [SELECT Id FROM Idea LIMIT 1];
    List<Vote> fetchedVotes;

    Test.startTest();
    System.runAs(usersList[0]) {
      Vote vote = new Vote(ParentId = ideaRecord.Id, Type = 'Up');
      insert vote;
      fetchedVotes = IdeaDAO.getIdeaVotes(ideaRecord.id);
    }
    Test.stopTest();

    System.assertEquals(1, fetchedVotes.size(), 'Votes fetched check');
  }

  @isTest
  static void getIdeaCommentVotesTest() {
    List<User> usersList = TestDataUtility.getUser(
      'System Administrator',
      1,
      true
    );
    Idea ideaRecord = [SELECT Id FROM Idea LIMIT 1];
    IdeaComment ideaCommentRecord = [
      SELECT Id
      FROM IdeaComment
      WHERE IdeaId = :ideaRecord.id
      LIMIT 1
    ];
    List<Vote> fetchedVotes;

    Test.startTest();
    System.runAs(usersList[0]) {
      Vote vote = new Vote(ParentId = ideaCommentRecord.Id, Type = 'Up');
      insert vote;
      fetchedVotes = IdeaDAO.getIdeaCommentVotes(ideaCommentRecord.id);
    }
    Test.stopTest();

    System.assertEquals(1, fetchedVotes.size(), 'Votes fetched check');
  }

  @isTest
  static void getIdeaCommentRecordTest() {
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    IdeaComment ideaCommentRecord = [
      SELECT id
      FROM IdeaComment
      WHERE IdeaId = :ideaRecord.id
      LIMIT 1
    ];

    Test.startTest();
    IdeaComment ideaCommentFetched = IdeaDAO.getIdeaCommentRecord(
      ideaCommentRecord.Id
    );
    Test.stopTest();

    System.assertEquals(
      ideaCommentRecord.Id,
      ideaCommentFetched.Id,
      'Idea Comment Id check'
    );
  }

  @isTest
  static void getIdeasListWithDynamicConditionsTest() {
    Id communityId = [
      SELECT Id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ]
    .id;
    System.debug(communityId);
    List<Idea> ideas = [
      SELECT Id, CommunityId, Status, Categories, Title
      FROM Idea
    ];
    System.debug(ideas);
    Test.startTest();
    List<Idea> ideasList = IdeaDAO.getIdeasListWithDynamicConditions(
      communityId,
      'Open',
      'Test',
      'Community',
      10,
      0
    );
    Test.stopTest();

    System.assertEquals(ideasList.size(), ideas.size(), 'Ideas number check');
  }

  @isTest
  static void getIdeasListWithDynamicConditionsNullCommunityTest() {
    List<Idea> ideas = [
      SELECT Id, CommunityId, Status, Categories, Title
      FROM Idea
    ];

    Test.startTest();
    List<Idea> ideasList = IdeaDAO.getIdeasListWithDynamicConditions(
      null,
      'Open',
      'Test',
      'Community',
      10,
      0
    );
    Test.stopTest();

    System.assertEquals(ideasList.size(), ideas.size(), 'Ideas number check');
  }

  @isTest
  static void getGroupByNameTest() {
    List<Group> groupList = TestDataUtility.getPublicGroup('My Group', 1, true);

    Test.startTest();
    Group grp = IdeaDAO.getGroupByName('My Group');
    Test.stopTest();

    System.assertEquals(groupList[0].id, grp.id, 'Group Id check');
  }

  @isTest
  static void getEmailTemplateByNameTest() {
    List<EmailTemplate> emailTempList = TestDataUtility.getEmailTemplate(
      'MyEmailTemplate',
      1,
      true
    );

    Test.startTest();
    EmailTemplate emailTemp = IdeaDAO.getEmailTemplateByName('MyEmailTemplate');
    Test.stopTest();

    System.assertEquals(
      emailTempList[0].id,
      emailTemp.id,
      'EmailTemplate Id check'
    );
  }

  @isTest
  static void getGroupMembersTest() {
    List<Group> groupList = TestDataUtility.getPublicGroup('My Group', 1, true);
    Set<Id> userIds = new Set<Id>();
    userIds.add(UserInfo.getUserId());
    TestDataUtility.getGroupMember(groupList[0].id, userIds, true);

    Test.startTest();
    List<GroupMember> members = IdeaDAO.getGroupMembers(groupList[0].id);
    Test.stopTest();

    System.assertEquals(1, members.size(), 'GroupMembers count check');
  }

  @isTest
  static void getAllIdeasTest() {
    Community community = [
      SELECT Id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    String idSelectedZone = community.id;
    Test.startTest();
    Integer result = IdeaDAO.getAllIdeas(
      idSelectedZone,
      'Open',
      'Test Idea 0',
      'Community'
    );
    Test.stopTest();
    System.assertEquals(0, result, 'result is zero');
  }
}
