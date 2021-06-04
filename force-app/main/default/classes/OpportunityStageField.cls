public class OpportunityStageField {
  @AuraEnabled
  public static boolean getOpportunityStageValue(Id opportunityId) {
    Opportunity opp = [
      SELECT StageName
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];
    String stageValues = Label.OpportunityStagePopupMessage;
    if (stageValues.contains(opp.StageName))
      return true;
    else
      return false;
  }

  @AuraEnabled
  public static string getQuotedPriceOfOpportunity(Id opportunityId) {
    Opportunity opp = [
      SELECT amount, id
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];
    if (opp.amount != null) {
      String amountValue = String.valueOf(opp.amount);
      for (Integer i = amountValue.length() - 3; i > 3; i = i - 3) {
        amountValue =
          amountValue.subString(0, i - 3) +
          ',' +
          amountValue.subString(i - 3);
      }
      return amountValue;
    } else
      return null;
  }
}
