/*
 * 08-10-2020 – Drupad Preenja – Created this class for handling functionality related to Routes Section on the Veloz Community.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 08-10-2020
 * @author      : Nagarro
 * @description : Used as Controller class for CC_VelozRoutes Aura Component
 * @history     : Version 1.0
 * @test class  : CC_VelozRoutesCtrlTest
 */
public with sharing class CC_VelozRoutesCtrl {
  /*
   * @purpose     : Method to get Terms and Conditions to be shown on the UI
   * @return      : List<String> - List of String containing Custom Labels for all the Terms and Conditions
   */
  @AuraEnabled
  public static List<String> fetchTermsAndConditions() {
    return CC_QuoteUtility.fetchTermsAndConditions();
  }
}
