/*
 * @company     : Nagarro Inc.
 * @date        : 08-10-2020
 * @author      : Nagarro
 * @description : DAO for Quote Custom Object
 * @history     : Version 1.0
 * @test class  : QuoteDAOTest
 */
public inherited sharing class QuoteDAO implements IQuoteDAO {
  /*
   * @company     : Nagarro Inc.
   * @date        : 08-10-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IQuoteDAO {
    List<Quote__c> getQuoteWithChargeLineByQuoteIds(Set<Id> quoteIds);
    List<FreightDetail__c> getFreightDetailsByQuoteIds(Set<Id> quoteIds);
    List<Requirement__c> getRequirementByFreightDetailIds(
      Set<Id> freightDetailIds
    );
    List<Requirement__c> getRequirementsByContainerType(String containerType);
    List<Quote__c> getQuoteByOriginDestinationCode(
      List<String> originCodes,
      List<String> destinationCodes
    );
    Integer getTotalQuotesByQueryAccountIds(String query, List<Id> accountIds);
    List<Quote__c> getQuoteByQuery(String query, List<Id> accountIds);
    List<Requirement__c> getRequirementByQuoteIds(Set<Id> QuoteIds);
  }

  /*
   * @purpose     : Method to get List of Quote Records with Child Charge Line Records
   * @parameter   : quoteIds - Set of Quote Ids provided
   * @return      : List<Quote__c> - List of Quote Records with Child Charge Line Records
   */
  public static List<Quote__c> getQuoteWithChargeLineByQuoteIds(
    Set<Id> quoteIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Ready_Date__c,
        Createddate,
        toLabel(Transportation_Management_System_Origin__c),
        toLabel(Transportation_Management_System_Destina__c),
        Route_Id__c,
        Transit_Time__c,
        Customer_Origin_City__c,
        Customer_Origin_State__c,
        Customer_Origin_Country__c,
        Customer_Origin_Zip__c,
        EEI_Charges__c,
        INS_Charge__c,
        Customer_Destination_City__c,
        Customer_Destination_State__c,
        Customer_Destination_Country__c,
        Customer_Destination_Zip__c,
        Port_of_Discharge__c,
        Port_of_Load__c,
        Customer_Destination_Code__c,
        Customer_Origin_Code__c,
        Description__c,
        Total_Amount__c,
        Customer_Email__c,
        Valid_To__c,
        Contact_Name__c,
        Contact_Number__c,
        Status__c,
        Company_Name__c,
        Contract__c,
        Account__c,
        Contact__c,
        Contract__r.Name,
        Account__r.Name,
        Contact__r.Name,
        Transit_Time_Day_Hours__c,
        Contract_Number__c,
        (
          SELECT
            Id,
            Amount_Target__c,
            Item_Code__c,
            Item_Name__c,
            Item_Year__c,
            Quantity__c,
            Charge_Code__c,
            ChargeDescription__c,
            Item_Sequence__c
          FROM Charge_Lines__r
          ORDER BY Amount_Target__c DESC
        ),
        (SELECT id, CaseNumber FROM Cases__r LIMIT 1)
      FROM Quote__c
      WHERE Id IN :quoteIds
    ];
  }

  /*
   * @purpose     : Method to get Quote Records by account Ids.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : List<Quote__c > - List of Quote
   */
  public static List<Quote__c> getQuoteByQuery(
    String query,
    List<Id> accountIds
  ) {
    return Database.query(query);
  }

  /*
   * @purpose     : Method to get List of FreightDetail Records with given QuoteIds
   * @parameter   : quoteIds - Set of Quote Ids provided
   * @return      : List<FreightDetail__c> - List of FreightDetail Records with given QuoteIds
   */
  public static List<FreightDetail__c> getFreightDetailsByQuoteIds(
    Set<Id> quoteIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Cargo_Type__c,
        Commodity_Name__c,
        Commodity_Code__c,
        Height_Major__c,
        Height_Minor__c,
        Length_Major__c,
        Length_Minor__c,
        Width_Major__c,
        Width_Minor__c,
        Vehicle_Name__c,
        Height__c,
        Length__c,
        Width__c,
        Measure_Unit__c,
        Model__c,
        Manufacturer__c,
        Privately_Owned_Dealer_Owned_Vehicle__c,
        Package_Type__c,
        Description__c,
        Freight_Quantity__c,
        Package_Quantity__c,
        Declared_Weight_Value__c,
        Declared_Weights_Unit_of_Measure__c,
        FreightDetail__c.Shipment__r.Quote__c,
        Year__c,
        Additional_Binders__c,
        Additional_Binders_Qty__c,
        Additional_BoLs__c,
        Additional_Chains__c,
        Additional_Chains_Qty__c,
        Additional_Straps__c,
        Additional_Straps_Qty__c,
        Additional_Tarps__c,
        Additional_Tarps_Qty__c,
        BOL_Processing_Fee__c,
        Bonded_Cargo_Doc_Fee__c,
        Caricom_Invoice_Preparation__c,
        Customs_Brokerage__c,
        Document_Change_Fee__c,
        Excess_Fuel_in_Vehicles_RO_RO__c,
        VGM_Certification__c,
        EEI_Preparation__c,
        Diversion_or_Reconsignment__c,
        Importer_Security_Filing__c,
        Labels_Placards__c,
        Late_Documentation_Fee__c,
        LoadLast_HotHatch__c,
        Marine_Cargo_Insurance__c,
        Multiple_BoL_Fee__c,
        Wire_Pick_End_Down_Charge__c
      FROM FreightDetail__c
      WHERE FreightDetail__c.Shipment__r.Quote__c = :quoteIds
    ];
  }

  /*
   * @purpose     : Method to get List of Requirement Records with given FreightDetailIds
   * @parameter   : FreightDetailIds - Set of FreightDetail Ids provided
   * @return      : List<Requirement__c> - List of Requirement Records with given FreightDetailIds
   */
  public static List<Requirement__c> getRequirementByFreightDetailIds(
    Set<Id> freightDetailIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Category__c,
        OutOfGauge__c,
        Freight__c,
        Length__c,
        Quantity__c,
        Commodity_Code__c,
        Commodity_Name__c,
        Container_Type__c,
        Container_Code__c,
        Weight__c,
        Weights_Unit_of_Measure__c,
        Additional_Binders__c,
        Additional_Binders_Qty__c,
        Additional_BoLs__c,
        Additional_Chains__c,
        Additional_Chains_Qty__c,
        Additional_Straps__c,
        Additional_Straps_Qty__c,
        Additional_Tarps__c,
        Additional_Tarps_Qty__c,
        BOL_Processing_Fee__c,
        Bonded_Cargo_Doc_Fee__c,
        Caricom_Invoice_Preparation__c,
        Customs_Brokerage__c,
        Document_Change_Fee__c,
        Excess_Fuel_in_Vehicles_RO_RO__c,
        VGM_Certification__c,
        EEI_Preparation__c,
        Diversion_or_Reconsignment__c,
        Importer_Security_Filing__c,
        Labels_Placards__c,
        Late_Documentation_Fee__c,
        LoadLast_HotHatch__c,
        Marine_Cargo_Insurance__c,
        Multiple_BoL_Fee__c,
        Wire_Pick_End_Down_Charge__c,
        IMDG_Class__c,
        IsShippersOwn__c,
        Running_Reefer__c,
        IsNonOperativeReefer__c
      FROM Requirement__c
      WHERE Freight__c = :freightDetailIds
    ];
  }

  /*
   * @purpose     : Method to get List of Requirement Records with given QuoteIds
   * @parameter   : QuoteIds - Set of Quote Ids provided
   * @return      : List<Requirement__c> - List of Requirement Records with given QuoteIds
   */
  public static List<Requirement__c> getRequirementByQuoteIds(
    Set<Id> QuoteIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Category__c,
        Commodity_Name__c,
        OutOfGauge__c,
        Freight__c,
        Length__c,
        Quantity__c,
        Commodity_Code__c,
        Container_Type__c,
        Container_Code__c,
        Requirement__c.Freight__r.Shipment__r.Quote__c
      FROM Requirement__c
      WHERE Requirement__c.Freight__r.Shipment__r.Quote__c = :QuoteIds
    ];
  }

  /*
   * @purpose     : Method to get Requirment Records by Container Type.
   * @parameter   : containerType - Container Type Value
   * @return      : List<Requirement__c > - List of Requirment Records
   */
  public static List<Requirement__c> getRequirementsByContainerType(
    String containerType
  ) {
    return [
      SELECT Id, Freight__r.Shipment__r.Quote__c
      FROM Requirement__c
      WHERE Container_Type__c = :containerType
    ];
  }

  /*
   * @purpose     : Method to get Requirment Records by commodityName.
   * @parameter   : commodityName - commodityName Value
   * @return      : List<Requirement__c > - List of Requirment Records
   */
  public static List<Requirement__c> getRequirementsByCommodityName(
    String commodityName
  ) {
    return [
      SELECT Id, Freight__r.Shipment__r.Quote__c
      FROM Requirement__c
      WHERE Commodity_Name__c = :commodityName
    ];
  }

  /*
   * @purpose     : Method to get FreightDetail Records by commodityName.
   * @parameter   : commodityName - commodityName Value
   * @return      : List<FreightDetail__c > - List of FreightDetail Records
   */
  public static List<FreightDetail__c> getFreightDetailsByCommodityName(
    String commodityName
  ) {
    return [
      SELECT Id, Shipment__r.Quote__c
      FROM FreightDetail__c
      WHERE Commodity_Name__c = :commodityName
    ];
  }

  /*
   * @purpose     : Method to get Quote Records by Origin and Destination Codes.
   * @parameter   : originCodes - List of Origin Codes
   * @parameter   : destinationCodes - List of Destination Codes
   * @return      : List<Quote__c > - List of Quote Records
   */
  public static List<Quote__c> getQuoteByOriginDestinationCode(
    List<String> originCodes,
    List<String> destinationCodes
  ) {
    return [
      SELECT Id, Customer_Origin_Code__c, Customer_Destination_Code__c
      FROM Quote__c
      WHERE
        Customer_Origin_Code__c IN :originCodes
        OR Customer_Destination_Code__c IN :destinationCodes
    ];
  }

  /*
   * @purpose     : Method to get Total Quotes by List of Account Id.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : Integer - Number of Quotes
   */
  public static Integer getTotalQuotesByQueryAccountIds(
    String query,
    List<Id> accountIds
  ) {
    AggregateResult results = Database.query(query);
    Integer totalRecords = (Integer) results.get('Total');
    return totalRecords;
  }
}
