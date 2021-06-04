/*
 * 08-10-2020 – Drupad Preenja – Created this class for handling functionality related to Quote Summary Section on the Veloz Community.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 08-10-2020
 * @author      : Nagarro
 * @description : Used as Controller class for CC_VelozQuoteDetailSum Aura Component
 * @history     : Version 1.0
 * @test class  : CC_VelozQuoteDetailSumCtrlTest
 */
public with sharing class CC_VelozQuoteDetailSumCtrl {
  /*
   * @purpose     : Method to get Quote Details depending on the Quote Id provided
   * @parameter   : quoteId - Quote Id
   * @return      : CC_QuoteUtility.QuoteWrapper - QuoteWrapper from CC_QuoteUtility Apex class conatining all the Quote Details
   */
  @AuraEnabled
  public static CC_QuoteUtility.QuoteWrapper getQuoteDetails(String quoteId) {
    return CC_QuoteUtility.getQuoteDetails(quoteId, true);
  }

  @AuraEnabled
  public static Boolean isInternalCommunity() {
    String communityName = CommonUtility.getCommunityName();
    System.debug('comm Name - ' + communityName);
    if (
      communityName != System.Label.OpenCommunityName ||
      communityName == null
    ) {
      return true;
    }
    return false;
  }

  @AuraEnabled
  public static String fetchIframeUrl(String qId) {
    String quoteUrl;
    String communityUrlPathPrefix = getCommunityUrlPathPrefix();
    if (Network.getNetworkId() != null) {
      quoteUrl =
        '/' +
        communityUrlPathPrefix +
        '/apex/CC_EmployeeQuoteRecordPDF?Id=' +
        qId;
    } else {
      quoteUrl =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/QuoteRecordPDF?Id=' +
        qId;
    }
    System.debug('quoteURL is ' + quoteUrl);
    return quoteUrl;
  }

  private static String getCommunityUrlPathPrefix() {
    String nwid = Network.getNetworkId();
    if (!String.isBlank(nwid)) {
      String communityUrlPathPrefix = [
        SELECT urlPathPrefix
        FROM Network
        WHERE id = :nwid
      ][0]
      .urlPathPrefix;
      return communityUrlPathPrefix;
    } else {
      return null;
    }
  }
}
