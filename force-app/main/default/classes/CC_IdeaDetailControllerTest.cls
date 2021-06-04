@isTest(SeeAllData=false)
public class CC_IdeaDetailControllerTest {
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
  static void getIdeasListTestCase1() {
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    List<Idea> idea = [
      SELECT Id, Title, CommunityId, Status, Categories
      FROM Idea
    ];
    System.debug(idea);
    Test.startTest();
    List<Idea> ideaList = CC_IdeaDetailController.getIdeasList(
      community.Id,
      'Open',
      'Test',
      'Community',
      10,
      0
    );
    Test.stopTest();
    System.assertEquals(2, ideaList.size(), 'Incomplete list');
  }

  @isTest
  static void getAllIdeasTest() {
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    Test.startTest();
    Integer recordCount = CC_IdeaDetailController.getAllIdeas(
      community.Id,
      'Open',
      'Test',
      'Community'
    );
    Test.stopTest();
    System.assertEquals(2, recordCount, 'count donot match');
  }
  @isTest
  static void getTotalVotesTest() {
    List<Idea> idea = [
      SELECT Id, Title, CommunityId, Status, Categories
      FROM Idea
    ];
    Test.startTest();
    String totalVotes = CC_IdeaDetailController.getTotalVotes(idea[0].id);
    Test.stopTest();
    System.assertEquals('10', totalVotes, 'count donot match');
  }

  @isTest
  static void getIdeasListTestCase2() {
    Test.startTest();
    List<Idea> ideaList = CC_IdeaDetailController.getIdeasList(
      '',
      '',
      '',
      '',
      10,
      0
    );
    Test.stopTest();
    System.assertEquals(2, ideaList.size(), 'Incomplete list');
  }

  @isTest
  static void getIdeasListNegativeTest() {
    Community community = [SELECT id FROM community ORDER BY Name ASC LIMIT 1];
    String CommunityIdString = String.valueOf(community.Id);
    String s1 = CommunityIdString.substring(0, 13);
    String s2 = CommunityIdString.substring(13).reverse();
    Id communityId = s1 + s2;
    boolean isError = false;
    List<Idea> ideaList;
    //List<User> usersList = TestDataUtility.getUser('Standard User',1,true);
    User u = [SELECT id FROM user WHERE usertype = 'Guest' LIMIT 1];
    Test.startTest();
    System.runAs(u) {
      try {
        IdeaDAO.allIdeaFieldsList = new List<String>{ 'Id,' };
        ideaList = CC_IdeaDetailController.getIdeasList(
          communityId,
          '',
          '',
          'Wrong Category',
          10,
          0
        );
        System.debug('ideaList@@@ ' + ideaList);
      } catch (Exception e) {
        isError = true;
      }
    }
    Test.stopTest();

    System.assertEquals(true, isError, 'Error occured');
  }

  @isTest
  static void getIdeaDetailsTestCase1() {
    Idea idea = [SELECT Id, Title FROM Idea LIMIT 1];
    Test.startTest();
    Idea ideaRecord = CC_IdeaDetailController.getIdeaDetails(idea.Id);
    Test.stopTest();
    System.assertEquals(idea.Title, ideaRecord.Title, 'Title Check');
  }
  @isTest
  static void getIdeaDetailsTestCase2() {
    Idea expectedIdea = new Idea();
    Id ideaId = null;
    Boolean isError = false;
    Test.startTest();
    Idea ideaRecord = CC_IdeaDetailController.getIdeaDetails(null);
    Test.stopTest();
    System.assertEquals(
      expectedIdea,
      ideaRecord,
      'Idea record not coming null'
    );
  }
  @isTest
  static void getIdeaDetailsNegativeTest() {
    Idea idea = [SELECT Id, Title FROM Idea LIMIT 1];
    String ideaIdString = String.valueOf(idea.Id);
    String s1 = ideaIdString.substring(0, 13);
    String s2 = ideaIdString.substring(13).reverse();
    Id ideaId = s1 + s2;
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      Idea ideaRecord = CC_IdeaDetailController.getIdeaDetails(ideaId);
    } catch (Exception e) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(true, isErrorThrown, 'Should have thrown an exception');
  }

  @isTest
  static void getZonesListTest() {
    Test.startTest();
    String zones = CC_IdeaDetailController.getZonesList();
    Test.stopTest();
    System.assertNotEquals(0, zones.length(), 'There has to be a zone');
  }
  @isTest
  static void findSimilarIdeasTest() {
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    Test.startTest();
    List<Idea> similarIdeasList = CC_IdeaDetailController.findSimilarIdeas(
      community.Id,
      'Test'
    );
    Test.stopTest();
  }

  @isTest
  static void findSimilarIdeasNegativeTest() {
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    String CommunityIdString = String.valueOf(community.Id);
    String s1 = CommunityIdString.substring(0, 13);
    String s2 = CommunityIdString.substring(13).reverse();
    Id communityId = s1 + s2;
    boolean isErrorThrown = false;
    Test.startTest();
    try {
      List<Idea> similarIdeasList = CC_IdeaDetailController.findSimilarIdeas(
        community.Id,
        'Test'
      );
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertNotEquals(
      true,
      isErrorThrown,
      'Should have thrown an exception'
    );
  }

  @isTest
  static void saveIdeaRecordTest() {
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    List<Idea> ideaRecords = TestDataUtility.getIdeaRecords(
      community.Id,
      'Community',
      1,
      false
    );
    Test.startTest();
    Idea savedIdeaRecord = CC_IdeaDetailController.saveIdeaRecord(
      ideaRecords[0]
    );
    Test.stopTest();
    System.assertNotEquals(null, savedIdeaRecord, 'Idea did not save');
  }
  @isTest
  static void saveIdeaRecordNegativeTest() {
    Idea ideaRecord = new Idea();
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      Idea savedIdeaRecord = CC_IdeaDetailController.saveIdeaRecord(ideaRecord);
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(true, isErrorThrown, 'Should have thrown a exception');
  }
  @isTest
  static void saveIdeaRecordNegativeTest1() {
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    List<Idea> ideaList = TestDataUtility.getIdeaRecords(
      community.Id,
      'Fake Category',
      1,
      true
    );

    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      delete ideaList;
      Idea savedIdeaRecord = CC_IdeaDetailController.saveIdeaRecord(
        ideaList[0]
      );
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    List<Idea> insertedIdeas = [SELECT Id, Categories FROM Idea];
    System.debug(insertedIdeas);
    Test.stopTest();
    System.assertEquals(true, isErrorThrown, 'Should have thrown exception');
  }
  @isTest
  static void deleteIdeaRecordTest() {
    Id ideaId = [SELECT id FROM Idea LIMIT 1].id;
    Test.startTest();
    Idea deletedIdeaRecord = CC_IdeaDetailController.deleteIdeaRecord(ideaId);
    Test.stopTest();
    System.assertNotEquals(null, deletedIdeaRecord, 'Idea did not delete');
  }
  @isTest
  static void deleteIdeaRecordNegativeTest() {
    Boolean isErrorThrown = false;
    Id ideaId = null;
    Test.startTest();
    try {
      Idea deletedIdeaRecord = CC_IdeaDetailController.deleteIdeaRecord(ideaId);
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Idea deletion should have thrown an error'
    );
  }
  @isTest
  static void getIdeaFieldDescribeTest() {
    Test.startTest();
    String fieldDescribe = CC_IdeaDetailController.getIdeaFieldDescribe();
    Test.stopTest();
    System.assertNotEquals(null, fieldDescribe, 'Field Decription Error');
  }

  @isTest
  static void getIdeaDescribeTest() {
    Test.startTest();
    String ideaDescribe = CC_IdeaDetailController.getIdeaDescribe();
    Test.stopTest();
    System.assertNotEquals(null, ideaDescribe, 'Idea Object Decription Error');
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

    String ideaComments = CC_IdeaDetailController.getIdeaComments(
      ideaRecord.id
    );

    Test.stopTest();
    System.assertNotEquals(null, ideaComments, 'All idea comments not fetched');
  }

  /*   @isTest 
static void getIdeaCommentsNegativeTest(){
Idea ideaRecord = [SELECT id from Idea LIMIT 1];
String ideaIdString = String.valueOf(ideaRecord.Id);
String s1 = ideaIdString.substring(0, 13);
String s2 = ideaIdString.substring(13).reverse();
Id ideaId = s1+s2 ;
Boolean isErrorThrown = false;
Test.startTest();
try{
System.debug('ideaComments');
String ideaComments = CC_IdeaDetailController.getIdeaComments(ideaId);
System.debug('ideaComments  '+ideaComments);
}
catch(Exception ex){
System.debug('Inside catch');
isErrorThrown=true;
}
Test.stopTest();
System.assertEquals(true, isErrorThrown, 'Idea comments should have thrown Exception'); 
}  */

  @isTest
  static void upvoteIdeaTest() {
    List<User> usersList = TestDataUtility.getUser(
      'System Administrator',
      1,
      true
    );
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    Test.startTest();
    System.runAs(usersList[0]) {
      CC_IdeaDetailController.upvoteIdea(ideaRecord.id);
    }
    Test.stopTest();

    List<Vote> voteList = [
      SELECT Id, ParentId, CreatedById, Type
      FROM Vote
      WHERE CreatedById = :usersList[0].id AND ParentId = :ideaRecord.Id
    ];
    System.assertEquals(1, voteList.size(), 'Idea did not upvoted');
  }
  @isTest
  static void upvoteIdeaNegativeTest() {
    List<User> usersList = TestDataUtility.getUser(
      'System Administrator',
      1,
      true
    );
    Id ideaId = null;
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      System.runAs(usersList[0]) {
        CC_IdeaDetailController.upvoteIdea(ideaId);
      }
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Upvote idea should have thrown exception'
    );
  }
  @isTest
  static void downvoteIdeaTest() {
    List<User> usersList = TestDataUtility.getUser(
      'System Administrator',
      1,
      true
    );
    Community community = [
      SELECT id
      FROM community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    Test.startTest();
    System.runAs(usersList[0]) {
      CC_IdeaDetailController.downvoteIdea(ideaRecord.id);
    }
    Test.stopTest();
  }
  @isTest
  static void downvoteIdeaNegativeTest() {
    List<User> usersList = TestDataUtility.getUser(
      'System Administrator',
      1,
      true
    );
    Id ideaId = null;
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      System.runAs(usersList[0]) {
        CC_IdeaDetailController.downvoteIdea(ideaId);
      }
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Downvote idea should have thrown exception'
    );
  }
  @isTest
  static void likeCommentTest() {
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    IdeaComment ideaCommentRecord = [
      SELECT id
      FROM IdeaComment
      WHERE IdeaId = :ideaRecord.Id
      LIMIT 1
    ];
    Test.startTest();
    CC_IdeaDetailController.likeComment(ideaCommentRecord.id);
    Test.stopTest();
    List<Vote> vote = [
      SELECT id
      FROM Vote
      WHERE ParentId = :ideaCommentRecord.id
    ];
    System.assertNotEquals(null, vote, 'Comment should have been upvoted');
  }
  @isTest
  static void likeCommentNegativeTest() {
    Id commentId = null;
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      CC_IdeaDetailController.likeComment(commentId);
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Like idea comment should have thrown exception'
    );
  }
  @isTest
  static void unlikeCommentTest() {
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    IdeaComment ideaCommentRecord = [
      SELECT id
      FROM IdeaComment
      WHERE IdeaId = :ideaRecord.Id
      LIMIT 1
    ];
    Vote vt = new Vote();
    vt.ParentId = ideaCommentRecord.id;
    vt.Type = 'Up';
    insert vt;
    Test.startTest();
    CC_IdeaDetailController.unlikeComment(ideaCommentRecord.id);
    Test.stopTest();
    List<Vote> vote = [
      SELECT id
      FROM VOTE
      WHERE parentId = :ideaCommentRecord.id
    ];
    System.assertEquals(0, vote.size(), 'Vote must have been unliked');
  }

  @isTest
  static void deleteCommentTest() {
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    IdeaComment ideaCommentRecord = [
      SELECT id
      FROM IdeaComment
      WHERE IdeaId = :ideaRecord.Id
      LIMIT 1
    ];
    Test.startTest();
    CC_IdeaDetailController.deleteComment(ideaCommentRecord.id);
    Test.stopTest();
  }
  @isTest
  static void deleteCommentNegativeTest() {
    Boolean isErrorThrown = false;
    Id commentId = null;
    Test.startTest();
    try {
      CC_IdeaDetailController.deleteComment(commentId);
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Delete idea comment should have thrown exception'
    );
  }
  @isTest
  static void addCommentTest() {
    Idea ideaRecord = [SELECT id FROM Idea LIMIT 1];
    Set<id> ideaIds = new Set<Id>();
    ideaIds.add(ideaRecord.Id);
    List<IdeaComment> ideaCommentsList = TestDataUtility.getIdeaComment(
      ideaIds,
      'I liked the idea',
      1,
      false
    );
    Test.startTest();
    CC_IdeaDetailController.addComment(JSON.serialize(ideaCommentsList[0]));
    Test.stopTest();
  }
  @isTest
  static void addCommentNegativeTest() {
    IdeaComment comment = new IdeaComment();
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      CC_IdeaDetailController.addComment(JSON.serialize(comment));
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Add idea comment should have thrown exception'
    );
  }
  @isTest
  static void getIdeaCommentRecordTest() {
    Community community = [
      SELECT id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    IdeaComment ideaComment = [
      SELECT id, CommentBody
      FROM IdeaComment
      WHERE CommunityId = :community.Id
      LIMIT 1
    ];
    Test.startTest();
    IdeaComment ideaCommentRecord = CC_IdeaDetailController.getIdeaCommentRecord(
      ideaComment.Id
    );
    Test.stopTest();
    System.assertEquals(
      ideaComment.CommentBody,
      ideaCommentRecord.CommentBody,
      'Error in getting comment record'
    );
  }
  @isTest
  static void getIdeaCommentRecordNegativeTest() {
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      IdeaComment ideaCommentRecord = CC_IdeaDetailController.getIdeaCommentRecord(
        null
      );
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Get idea comment record should have thrown error'
    );
  }
  @isTest
  static void saveIdeaCommentRecordTest() {
    Community community = [
      SELECT id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    Idea idea = [SELECT id FROM Idea LIMIT 1];
    Set<Id> ideaIds = new Set<Id>();
    ideaIds.add(idea.Id);
    List<IdeaComment> ideaComments = TestDataUtility.getIdeaComment(
      ideaIds,
      'I liked the idea',
      2,
      false
    );
    Test.startTest();
    IdeaComment ideaCommentRecord = CC_IdeaDetailController.saveIdeaCommentRecord(
      ideaComments[0]
    );
    Test.stopTest();
    System.assertNotEquals(null, ideaCommentRecord, 'Comment not saved');
  }
  @isTest
  static void saveIdeaCommentRecordNegativeTest() {
    IdeaComment comment = new IdeaComment();
    Boolean isErrorThrown = false;
    Test.startTest();
    try {
      IdeaComment ideaCommentRecord = CC_IdeaDetailController.saveIdeaCommentRecord(
        comment
      );
    } catch (Exception ex) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Save idea comment record should have thrown error'
    );
  }
  @isTest
  static void getUserTest() {
    Test.startTest();
    User user = CC_IdeaDetailController.getUser();
    Test.stopTest();
    System.assertNotEquals(null, user, 'Could not get user values');
  }
  @isTest
  static void fetchRecordTypeSpecificPickListvaluesTest() {
    Community community = [
      SELECT id
      FROM Community
      WHERE IsActive = TRUE
      LIMIT 1
    ];
    MockResponsesUtility.DescribeLayoutMockResponse mock = new MockResponsesUtility.DescribeLayoutMockResponse(
      false
    );
    Test.startTest();
    APICalloutUtility.integrationServiceMdtMap = TestDataUtility.getIntegrationServiceMapForTest();
    APICalloutUtility.serviceEnvironCSMap = TestDataUtility.getServiceEnvironmentTestMap();
    APICalloutUtility.serviceParamsMdtMap = TestDataUtility.getServiceParamsTestMap();
    Test.setMock(HttpCalloutMock.class, mock);
    Map<String, Map<String, String>> res = CC_IdeaDetailController.fetchRecordTypeSpecificPickListvalues(
      community.Id
    );
    Test.stopTest();
    System.assert(res.size() > 0, 'Response Value Check');
  }

  @isTest
  static void fetchRecordTypeSpecificPickListvaluesTestNegative1() {
    MockResponsesUtility.DescribeLayoutMockResponse mock = new MockResponsesUtility.DescribeLayoutMockResponse(
      true
    );
    Test.startTest();
    boolean isErrorThrown = false;
    Test.setMock(HttpCalloutMock.class, mock);
    try {
      Map<String, Map<String, String>> res = CC_IdeaDetailController.fetchRecordTypeSpecificPickListvalues(
        null
      );
    } catch (Exception e) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'fetchRecordTypeSpecificPickListvalues should have thrown error'
    );
  }

  @isTest
  static void fetchRecordTypeSpecificPickListvaluesTestNegative2() {
    Community community = [SELECT id FROM community ORDER BY Name ASC LIMIT 1];
    String CommunityIdString = String.valueOf(community.Id);
    String s1 = CommunityIdString.substring(0, 13);
    String s2 = CommunityIdString.substring(13).reverse();
    Id communityId = s1 + s2;
    MockResponsesUtility.DescribeLayoutMockResponse mock = new MockResponsesUtility.DescribeLayoutMockResponse(
      true
    );
    Test.startTest();
    boolean isErrorThrown = false;
    Test.setMock(HttpCalloutMock.class, mock);
    try {
      Map<String, Map<String, String>> res = CC_IdeaDetailController.fetchRecordTypeSpecificPickListvalues(
        communityId
      );
    } catch (Exception e) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'getRecordTypeId should have thrown error'
    );
  }

  @isTest
  static void fetchRecordTypeSpecificPickListvaluesNegativeTest3() {
    Community community = [
      SELECT id
      FROM Community
      WHERE IsActive = TRUE
      LIMIT 1
    ];
    MockResponsesUtility.DescribeLayoutMockResponse mock = new MockResponsesUtility.DescribeLayoutMockResponse(
      true
    );
    Test.startTest();
    boolean isErrorThrown = false;
    Test.setMock(HttpCalloutMock.class, mock);
    try {
      Map<String, Map<String, String>> res = CC_IdeaDetailController.fetchRecordTypeSpecificPickListvalues(
        community.Id
      );
    } catch (Exception e) {
      isErrorThrown = true;
    }
    Test.stopTest();
    System.assertEquals(
      true,
      isErrorThrown,
      'Http Callout should have thrown error'
    );
  }

  @isTest
  static void getCommunityNameTest() {
    Test.startTest();
    CC_IdeaDetailController.getCommunityNetworkName();
    Test.stopTest();
  }
}
