/*
 * Name: ADAccountDashboardController
 * Purpose: Controller class for Account Dashboard Component
 * Author: Nagarro
 * Created Date: 18-Jan-2019
 * Modification History
 *  Modification #   Story/Defect#      Modified By     Date   Description
 */
public class ADAccountDashboardController {
  //This method returns current year
  @AuraEnabled
  public static String getCurrentYear() {
    return ADAccountDashboardUtil.getCurrentYear();
  }
}
