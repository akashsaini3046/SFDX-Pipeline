/*
 * 08-10-2020 – Drupad Preenja – Created this class for handling functionality related to Quote Summary Section on the Veloz Community.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 08-10-2020
 * @author      : Nagarro
 * @description : Used in various Classes like CC_VelozRoutesCtrl, CC_VelozQuoteDetailSumCtrl
 * @history     : Version 1.0
 * @test class  : CC_QuoteUtilityTest
 */
public with sharing class CC_QuoteUtility {
  /*
   * @purpose     : Method to get Quote Details for the quote Id provided
   * @parameter   : quoteId - Quote Id
   * @parameter   : isWithoutSharing - Flag to Query quote with sharing or without
   * @return      : void
   */
  public static CC_QuoteUtility.QuoteWrapper getQuoteDetails(
    String quoteId,
    Boolean isWithoutSharing
  ) {
    QuoteWrapper quoteWrapper = new QuoteWrapper();
    quoteWrapper.quoteId = quoteId;
    List<Quote__c> allQuotes = new List<Quote__c>();
    if (isWithoutSharing) {
      allQuotes = CC_WithoutSharingUtility.getQuoteWithChargeLineByQuoteIds(
        new Set<Id>{ quoteId }
      );
    } else {
      allQuotes = QuoteDAO.getQuoteWithChargeLineByQuoteIds(
        new Set<Id>{ quoteId }
      );
    }

    if (allQuotes != null && !allQuotes.isEmpty()) {
      quoteWrapper.quoteRecord = allQuotes.get(0);
      quoteWrapper.chargeLines = getAllChargeLineListByQuote(
        quoteWrapper.quoteRecord
      );
      quoteWrapper.orgDestVsMovementType = getOrgDestVsMovementType(
        quoteWrapper.quoteRecord
      );
      if (
        quoteWrapper.orgDestVsMovementType != null &&
        !quoteWrapper.orgDestVsMovementType.isEmpty()
      ) {
        quoteWrapper.orgDestVsLocationName = getOrgDestVsLocationName(
          quoteWrapper.quoteRecord,
          quoteWrapper.orgDestVsMovementType
        );
        quoteWrapper.orgDestVsLocationCode = getOrgDestVsLocationCode(
          quoteWrapper.quoteRecord,
          quoteWrapper.orgDestVsMovementType
        );
      }
      quoteWrapper.listfreights = getAllFreightDetails(new Set<Id>{ quoteId });
      quoteWrapper.CargoType = getCargoType(quoteWrapper.listfreights);
      if (quoteWrapper.CargoType == CC_Constants.EQUIP_STRING) {
        quoteWrapper.listrequirements = getAllRequirements(
          new Set<Id>{ quoteId }
        );
      }
    }
    quoteWrapper.termsAndConditions = fetchTermsAndConditions();
    return quoteWrapper;
  }

  /*
   * @purpose     : Method to get a Map of Origin Destination as key and Movement Type as value for the provided Quote Record
   * @parameter   : quote - Quote Record
   * @return      : Map<String, String> - Map of Origin Destination as key and Movement Type as value for the provided Quote Record
   */
  private static Map<String, String> getOrgDestVsMovementType(Quote__c quote) {
    Map<String, String> orgDestVsMovementType = new Map<String, String>();
    if (quote.Description__c != null && quote.Description__c != '') {
      if (quote.Description__c.startsWith(CC_Constants.D_CHAR)) {
        orgDestVsMovementType.put(
          CC_Constants.ORIGIN_STRING,
          CC_Constants.DOOR_STRING
        );
      }
      if (quote.Description__c.startsWith(CC_Constants.P_CHAR)) {
        orgDestVsMovementType.put(
          CC_Constants.ORIGIN_STRING,
          CC_Constants.PORT_STRING
        );
      }
      if (quote.Description__c.startsWith(CC_Constants.R_CHAR)) {
        orgDestVsMovementType.put(
          CC_Constants.ORIGIN_STRING,
          CC_Constants.RAIL_STRING
        );
      }
      if (quote.Description__c.endsWith(CC_Constants.D_CHAR)) {
        orgDestVsMovementType.put(
          CC_Constants.DESTINATION_STRING,
          CC_Constants.DOOR_STRING
        );
      }
      if (quote.Description__c.endsWith(CC_Constants.P_CHAR)) {
        orgDestVsMovementType.put(
          CC_Constants.DESTINATION_STRING,
          CC_Constants.PORT_STRING
        );
      }
      if (quote.Description__c.endsWith(CC_Constants.R_CHAR)) {
        orgDestVsMovementType.put(
          CC_Constants.DESTINATION_STRING,
          CC_Constants.RAIL_STRING
        );
      }
    }
    return orgDestVsMovementType;
  }

  /*
   * @purpose     : Method to get a Map of Origin Destination as key and Location Name as value for the provided Quote Record
   * @parameter   : quote - Quote Record
   * @parameter   : orgDestVsMovementType - Map of Origin Destination as key and Movement Type as value
   * @return      : Map<String, String> - Map of Origin Destination as key and Location Name as value for the provided Quote Record
   */
  private static Map<String, String> getOrgDestVsLocationName(
    Quote__c quote,
    Map<String, String> orgDestVsMovementType
  ) {
    Map<String, String> orgDestVsLocationName = new Map<String, String>();
    if (
      orgDestVsMovementType.get(CC_Constants.ORIGIN_STRING) != null &&
      orgDestVsMovementType.get(CC_Constants.ORIGIN_STRING) != ''
    ) {
      orgDestVsLocationName.put(
        CC_Constants.ORIGIN_STRING,
        getLocationNameByMovementType(
          quote,
          CC_Constants.ORIGIN_STRING,
          orgDestVsMovementType.get(CC_Constants.ORIGIN_STRING)
        )
      );
    }
    if (
      orgDestVsMovementType.get(CC_Constants.DESTINATION_STRING) != null &&
      orgDestVsMovementType.get(CC_Constants.DESTINATION_STRING) != ''
    ) {
      orgDestVsLocationName.put(
        CC_Constants.DESTINATION_STRING,
        getLocationNameByMovementType(
          quote,
          CC_Constants.DESTINATION_STRING,
          orgDestVsMovementType.get(CC_Constants.DESTINATION_STRING)
        )
      );
    }
    return orgDestVsLocationName;
  }

  /*
   * @purpose     : Method to get a Map of Origin Destination as key and Location Code as value for the provided Quote Record
   * @parameter   : quote - Quote Record
   * @parameter   : orgDestVsMovementType - Map of Origin Destination as key and Movement Type as value
   * @return      : Map<String, String> - Map of Origin Destination as key and Location Code as value for the provided Quote Record
   */
  private static Map<String, String> getOrgDestVsLocationCode(
    Quote__c quote,
    Map<String, String> orgDestVsMovementType
  ) {
    Map<String, String> orgDestVsLocationCode = new Map<String, String>();
    if (
      orgDestVsMovementType.get(CC_Constants.ORIGIN_STRING) != null &&
      orgDestVsMovementType.get(CC_Constants.ORIGIN_STRING) != ''
    ) {
      orgDestVsLocationCode.put(
        CC_Constants.ORIGIN_STRING,
        getLocationCodeByMovementType(
          quote,
          CC_Constants.ORIGIN_STRING,
          orgDestVsMovementType.get(CC_Constants.ORIGIN_STRING)
        )
      );
    }
    if (
      orgDestVsMovementType.get(CC_Constants.DESTINATION_STRING) != null &&
      orgDestVsMovementType.get(CC_Constants.DESTINATION_STRING) != ''
    ) {
      orgDestVsLocationCode.put(
        CC_Constants.DESTINATION_STRING,
        getLocationCodeByMovementType(
          quote,
          CC_Constants.DESTINATION_STRING,
          orgDestVsMovementType.get(CC_Constants.DESTINATION_STRING)
        )
      );
    }
    return orgDestVsLocationCode;
  }

  /*
   * @purpose     : Method to get Location Name By Movement Type Provided
   * @parameter   : quote - Quote Record
   * @parameter   : orgDest - Origin or Destination
   * @parameter   : movementType - Movement Type
   * @return      : String - Location Name
   */
  private static String getLocationNameByMovementType(
    Quote__c quote,
    String orgDest,
    String movementType
  ) {
    String location = '';
    if (orgDest.equals(CC_Constants.ORIGIN_STRING)) {
      location =
        checkNullAddCommaString(quote.Customer_Origin_City__c) +
        checkNullAddCommaString(quote.Customer_Origin_State__c) +
        checkCountryUS(quote.Customer_Origin_Country__c);
    } else if (orgDest.equals(CC_Constants.DESTINATION_STRING)) {
      location =
        checkNullAddCommaString(quote.Customer_Destination_City__c) +
        checkNullAddCommaString(quote.Customer_Destination_State__c) +
        checkCountryUS(quote.Customer_Destination_Country__c);
    }
    if (location.trim().endsWith(',')) {
      location = location.trim().removeEnd(',');
    }
    return location;
  }

  /*
   * @purpose     : Method to get Location Code By Movement Type Provided
   * @parameter   : quote - Quote Record
   * @parameter   : orgDest - Origin or Destination
   * @parameter   : movementType - Movement Type
   * @return      : String - Location Code
   */
  private static String getLocationCodeByMovementType(
    Quote__c quote,
    String orgDest,
    String movementType
  ) {
    if (orgDest.equals(CC_Constants.ORIGIN_STRING)) {
      if (movementType.equals(CC_Constants.DOOR_STRING)) {
        String country = checkNullString(quote.Customer_Origin_Country__c);
        if (!country.equalsIgnoreCase('US')) {
          return '';
        }
        return checkNullString(quote.Customer_Origin_Zip__c);
      } else if (movementType.equals(CC_Constants.PORT_STRING)) {
        return checkNullString(quote.Customer_Origin_Code__c);
      } else if (movementType.equals(CC_Constants.RAIL_STRING)) {
        return checkNullString(quote.Customer_Origin_Code__c);
      }
    } else if (orgDest.equals(CC_Constants.DESTINATION_STRING)) {
      if (movementType.equals(CC_Constants.DOOR_STRING)) {
        String country = checkNullString(quote.Customer_Destination_Country__c);
        if (!country.equalsIgnoreCase('US')) {
          return '';
        }
        return checkNullString(quote.Customer_Destination_Zip__c);
      } else if (movementType.equals(CC_Constants.PORT_STRING)) {
        return checkNullString(quote.Customer_Destination_Code__c);
      } else if (movementType.equals(CC_Constants.RAIL_STRING)) {
        return checkNullString(quote.Customer_Destination_Code__c);
      }
    }
    return '';
  }

  private static List<FreightDetail__c> getAllFreightDetails(Set<Id> QuoteIds) {
    List<FreightDetail__c> FreightList = new List<FreightDetail__c>();
    FreightList = QuoteDAO.getFreightDetailsByQuoteIds(QuoteIds);
    return FreightList;
  }

  private static String getCargoType(List<FreightDetail__c> Listfreights) {
    String cargoType = '';
    for (FreightDetail__c fdVar : Listfreights) {
      cargoType = fdVar.Cargo_Type__c;
    }
    return cargoType.toUpperCase();
  }

  private static List<Requirement__c> getAllRequirements(Set<Id> QuoteIds) {
    List<Requirement__c> listRequirements = new List<Requirement__c>();
    listRequirements = QuoteDAO.getRequirementByQuoteIds(QuoteIds);
    return listRequirements;
  }

  /*
   * @purpose     : Method to get List of Map of Container Type Values
   * @return      : List of Map of Container Type Values
   */
  private static List<Map<String, String>> getContainerTypes() {
    List<Map<String, String>> containerTypes = new List<Map<String, String>>();
    for (String code : containersCICSCodeVsDescriptionCSMap.keySet()) {
      Map<String, String> codeVsType = CC_SharedUtility.convertToLabelValue(
        code,
        containersCICSCodeVsDescriptionCSMap.get(code)
      );
      containerTypes.add(codeVsType);
    }
    return containerTypes;
  }

  /*
   * @purpose     : Method to check if country is US
   * @parameter   : value - Value to check
   * @return      : String - returns Blank if Country is US
   */
  private static String checkCountryUS(String value) {
    return !checkNullString(value).equalsIgnoreCase('US') ? value : '';
  }

  /*
   * @purpose     : Method to check if value is Null if not null then value appended with comma is returned
   * @parameter   : value - Value to check
   * @return      : String - returns Blank if value is null otherwise returns value appended with comma
   */
  private static String checkNullAddCommaString(String value) {
    return checkNullString(value) != '' ? value + ', ' : '';
  }

  /*
   * @purpose     : Method to check if value is Null if not null then value is returned
   * @parameter   : value - Value to check
   * @return      : String - returns Blank if value is null otherwise returns value
   */
  private static String checkNullString(String value) {
    return (value != null) ? value.trim() : '';
  }

  /*
   * @purpose     : Method to get List of Charge Line for the provided Quote Record
   * @parameter   : quote - Quote Record
   * @return      : List<Charge_Line__c> - List of Charge Line Records for the provided Quote Record
   */
  private static List<Charge_Line__c> getAllChargeLineListByQuote(
    Quote__c quote
  ) {
    List<Charge_Line__c> chargeLines = new List<Charge_Line__c>();
    if (
      quote != null &&
      quote.Charge_Lines__r != null &&
      !quote.Charge_Lines__r.isEmpty()
    ) {
      chargeLines.addAll(quote.Charge_Lines__r);
    }
    return chargeLines;
  }

  /*
   * @purpose     : Method to get List of Custom Labels for the Terms and Conditions
   * @return      : List<String> - List of Custom Labels for the Terms and Conditions
   */
  public static List<String> fetchTermsAndConditions() {
    List<String> termsAndCond = new List<String>();
    termsAndConditions.sort();
    for (TermAndCondWrapper termAndCondWrapper : termsAndConditions) {
      termsAndCond.add(termAndCondWrapper.termAndCondition);
    }
    return termsAndCond;
  }

  // Getter and Setter for List of Routes Terms and Conditions
  public static List<TermAndCondWrapper> termsAndConditions {
    get {
      if (termsAndConditions == null) {
        termsAndConditions = new List<TermAndCondWrapper>();
        for (Routes_Terms_and_Condition__mdt metadataRecord : [
          SELECT Id, MasterLabel, Order__c
          FROM Routes_Terms_and_Condition__mdt
        ]) {
          TermAndCondWrapper termAndCondWrapper = new TermAndCondWrapper();
          termAndCondWrapper.termAndCondition = metadataRecord.MasterLabel;
          termAndCondWrapper.order = Integer.valueOf(metadataRecord.Order__c);
          termsAndConditions.add(termAndCondWrapper);
        }
      }
      return termsAndConditions;
    }
    set;
  }

  /*
   * @purpose     : Method to get Map of Origin and Destination with Blank Values
   * @return      : Map<String, String> - Map of Origin and Destination with Blank Values
   */
  public static Map<String, String> getEmptyOrgDestMap() {
    return new Map<String, String>{
      CC_Constants.ORIGIN_STRING => CC_Constants.BLANK_STRING,
      CC_Constants.DESTINATION_STRING => CC_Constants.BLANK_STRING
    };
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 08-10-2020
   * @author      : Nagarro
   * @description : Used as Inner Class for storing the Quote Details
   * @history     : Version 1.0
   */
  public class QuoteWrapper {
    @AuraEnabled
    public String quoteId;
    @AuraEnabled
    public Quote__c quoteRecord;
    @AuraEnabled
    public List<Charge_Line__c> chargeLines;
    @AuraEnabled
    public List<String> termsAndConditions;
    @AuraEnabled
    public Map<String, String> orgDestVsMovementType;
    @AuraEnabled
    public Map<String, String> orgDestVsLocationName;
    @AuraEnabled
    public Map<String, String> orgDestVsLocationCode;
    @AuraEnabled
    public String CargoType;
    @AuraEnabled
    public List<FreightDetail__c> listfreights;
    @AuraEnabled
    public List<Requirement__c> listrequirements;
    @AuraEnabled
    public List<Map<String, String>> containerTypes;

    //Constructor
    QuoteWrapper() {
      this.quoteRecord = new Quote__c();
      this.chargeLines = new List<Charge_Line__c>();
      this.termsAndConditions = new List<String>();
      this.orgDestVsMovementType = CC_QuoteUtility.getEmptyOrgDestMap();
      this.orgDestVsLocationName = CC_QuoteUtility.getEmptyOrgDestMap();
      this.orgDestVsLocationCode = CC_QuoteUtility.getEmptyOrgDestMap();
      this.listfreights = new List<FreightDetail__c>();
      this.listrequirements = new List<Requirement__c>();
      this.containerTypes = CC_QuoteUtility.getContainerTypes();
    }
  }

  // Getter and Setter for Map of Container Code as key and Description as Value
  public static Map<String, String> containersCICSCodeVsDescriptionCSMap {
    get {
      if (containersCICSCodeVsDescriptionCSMap == null) {
        containersCICSCodeVsDescriptionCSMap = new Map<String, String>();
        for (String name : Container__c.getAll().keySet()) {
          containersCICSCodeVsDescriptionCSMap.put(
            Container__c.getAll().get(name).CICS_ISO_Code__c,
            Container__c.getAll().get(name).Description__c
          );
        }
      }
      return containersCICSCodeVsDescriptionCSMap;
    }
    set;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 08-10-2020
   * @author      : Nagarro
   * @description : Used as Inner Class for storing Terms and Conditions with Order with Comparable Implemented
   * @history     : Version 1.0
   */
  public class TermAndCondWrapper implements Comparable {
    @AuraEnabled
    public String termAndCondition;
    @AuraEnabled
    public Integer order;

    /*
     * @purpose     : Method containing comparing logic
     * @return      : Integer - return 0, 1, -1 depending on the comparison
     */
    public Integer compareTo(Object compareTo) {
      TermAndCondWrapper other = (TermAndCondWrapper) compareTo;
      if (this.order > other.order) {
        return 1;
      } else if (this.order == other.order) {
        return 0;
      }
      return -1;
    }
  }
}
