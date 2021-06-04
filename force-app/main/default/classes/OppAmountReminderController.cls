/*
 * Name: OppAmountReminderController
 * Purpose: Controller to display pop up to remind the sales person of the the opportunity amount
 * Author: Nagarro
 * Created Date: 10/09/2018
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 *
 */
public class OppAmountReminderController {
  /*
   * Method Name: getOpportunityStageValue
   * Purpose: This methods fetches the stage value from Opportunity
   * Created By:  Nagarro
   */
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

  /*
   * Method Name: getOpportunityStageValue
   * Purpose: This methods fetches the Opportunity Amount
   * Created By:  Nagarro
   */
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
