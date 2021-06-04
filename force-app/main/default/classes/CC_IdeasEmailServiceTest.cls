@isTest(SeeAllData=false)
public class CC_IdeasEmailServiceTest {
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
      1,
      true
    );
  }
  @isTest
  static void sendNotificationIdeaPostTest() {
    List<Idea> ideaList = [SELECT id, communityId FROM Idea];
    Test.startTest();
    CC_IdeasEmailService.sendNotificationIdeaPost(ideaList);
    Test.stopTest();
  }

  @isTest
  static void sendNotificationIdeaImplemented() {
    List<Idea> ideaList = [SELECT id, communityId FROM Idea];
    List<Idea> ideas = new List<Idea>();
    for (Idea idea : ideaList) {
      idea.Status = 'Implemented';
      ideas.add(idea);
    }
    upsert (ideas);
    Test.startTest();
    CC_IdeasEmailService.sendNotificationIdeaPost(ideas);
    Test.stopTest();
  }
}
