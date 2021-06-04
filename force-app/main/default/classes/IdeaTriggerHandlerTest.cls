@isTest
public class IdeaTriggerHandlerTest {
  @testSetup
  static void setup() {
    Community community = [
      SELECT id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    TestDataUtility.getIdeaRecords(community.Id, 'category', 1, true);
  }

  @isTest
  static void insertIdea() {
    Community community = [
      SELECT id
      FROM Community
      WHERE IsActive = TRUE
      ORDER BY Name ASC
      LIMIT 1
    ];
    List<Idea> ideaList = TestDataUtility.getIdeaRecords(
      community.Id,
      'category',
      1,
      false
    );

    Test.startTest();
    insert ideaList;
    Test.stopTest();

    List<Idea> ideas = [SELECT id FROM Idea];
    System.assertEquals(2, ideas.size(), 'Idea not inserted');
  }
  @isTest
  static void updateIdea() {
    Idea idea = [SELECT id FROM Idea LIMIT 1];
    idea.Status = 'Implemented and Closed';

    Test.startTest();
    update idea;
    Test.stopTest();

    Idea ideaRec = [SELECT id, Status FROM Idea LIMIT 1];
    System.assertEquals(
      'Implemented and Closed',
      ideaRec.Status,
      'Idea not updated'
    );
  }

  @isTest
  static void deleteIdea() {
    Idea idea = [SELECT id FROM Idea LIMIT 1];

    Test.startTest();
    delete idea;
    Test.stopTest();

    List<Idea> ideas = [SELECT id FROM Idea];
    System.assertEquals(0, ideas.size(), 'Idea not deleted');
  }
}
