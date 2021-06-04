/*
 * @company     : Nagarro Inc.
 * @date        : 04-09-2020
 * @author      : Nagarro
 * @description : DAO for Booking object
 * @history     : Version 1.0
 * @test class  : BookingDAOTest
 */
public inherited sharing class BookingDAO implements IBookingDAO {
  /*
   * @company     : Nagarro Inc.
   * @date        : 04-09-2020
   * @author      : Nagarro
   * @description : Interface for the DAO - Contains methods which must be implemented
   * @history     : Version 1.0
   */
  public interface IBookingDAO {
    List<Booking__c> getBookingDetails(Set<Id> setOfBookingId);
    List<Booking__c> getBookingByQuery(String query, List<Id> accountIds);
    List<Shipment__c> getShipmentByOriginDestinationCode(
      List<String> originCodes,
      List<String> destinationCodes
    );
    List<Requirement__c> getRequirementsByCommodityName(String commodityName);
    List<FreightDetail__c> getFreightDetailsByCommodityName(
      String commodityName
    );
    List<Shipment__c> getShipmentByBookingIds(Set<Id> bookingIds);
    List<Voyage__c> getVoyagesByBookingIds(Set<Id> bookingIds);
    List<Commodity__c> getCommoditiesByBookingIds(Set<Id> bookingIds);
    List<Requirement__c> getRequirementsByContainerType(String containerType);
    List<AggregateResult> getStopsCountByBookingId(Set<Id> bookingIds);
    List<Voyage__c> getVoyageswithBookingIdsbyVessalName(String VessalName);
    Integer getTotalBookingsByQueryAccountIds(
      String query,
      List<Id> accountIds
    );
    List<Party__c> getPartyDetails(Set<Id> bookingIds);
    List<Charge_Line__c> getChargelinesByBookingId(Set<Id> bookingIds);
    List<FreightDetail__c> getFreightDetailsByBookingIds(Set<Id> bookingIds);
    List<Requirement__c> getRequirementsByBookingIds(Set<Id> bookingIds);
    List<Requirement__c> getRequirementByFreightDetailIds(
      Set<Id> freightDetailIds
    );
    List<Stop__c> getStopDetailsByBookingIds(Set<Id> bookingIds);
    List<ContentVersion> getFilesbyBookingId(Id BookingId);
    List<Booking_Remark__c> getBookingRemarks(Set<Id> bookingIds);
    List<Transport__c> getTransportsByBookingIds(Set<Id> bookingIds);
    List<Equipment__c> getEquipmentsByBookingIds(Set<Id> bookingIds);
  }

  /*
   * @purpose     : Method to get booking detail by booking Ids.
   * @parameter   : setOfBookingId - set Of booking ids
   * @return      : List<Booking__c> - List of Booking
   */
  public static List<Booking__c> getBookingDetails(Set<Id> setOfBookingId) {
    return [
      SELECT
        Account__c,
        Account__r.Name,
        CreatedDate,
        Description__c,
        Contract_Number__c,
        Contact__c,
        Customer_Origin_City__c,
        Customer_Origin_Code__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Customer_Origin_Zip__c,
        Customer_Destination_Zip__c,
        Customer_Destination_Reference_Number__c,
        Contact__r.Email,
        Customer_Destination_State__c,
        Customer_Destination_Country__c,
        Customer_Destination_Code__c,
        Customer_Destination_City__c,
        Customer_Origin_Reference_Number__c,
        toLabel(Payment_Terms__c),
        Booked_Date__c,
        Ready_Date__c,
        Total_Amount__c,
        Id,
        toLabel(Status__c),
        Booking_Number__c,
        Customer_Email__c,
        Contact_Name__c,
        Company_Name__c,
        Is_Hazardous__c,
        Contact__r.Name,
        Pending_Reason__c,
        toLabel(Transportation_Management_System_Destina__c),
        toLabel(Transportation_Management_System_Origin__c),
        Booking_Step__c,
        Booking_Pending_Reasons__c
      FROM Booking__c
      WHERE id IN :setOfBookingId
    ];
  }

  /*
   * @purpose     : Method to get Party detail by booking Ids.
   * @parameter   : setOfBookingId - set Of booking ids
   * @return      : List<Party__c> - List of Party
   */
  public static List<Party__c> getPartyDetails(Set<Id> bookingIds) {
    return [
      SELECT
        Id,
        toLabel(Type__c),
        Account__c,
        Account__r.Name,
        Booking__c,
        Address_Line1__c,
        City__c,
        Booked_By__c,
        Contact_Name__c,
        Email_Address__c,
        Phone_Number__c,
        Country__c,
        State__c,
        Zip_Postal_Code__c,
        Reference_Number__c
      FROM Party__c
      WHERE Booking__c IN :bookingIds
      ORDER BY Type__c ASC NULLS LAST
    ];
  }

  /*
   * @purpose     : Method to get FreightDetail Records by set Of booking ids.
   * @parameter   : Set<Id> bookingIds - set Of booking ids
   * @return      : List<FreightDetail__c> - List of FreightDetail Records
   */
  public static List<FreightDetail__c> getFreightDetailsByBookingIds(
    Set<Id> bookingIds
  ) {
    return [
      SELECT
        Id,
        Shipment__r.Booking__c,
        Shipment__c,
        Shipment__r.Origin_Port__c,
        Shipment__r.Origin_Code__c,
        Shipment__r.Destination_Port__c,
        Shipment__r.Destination_Code__c,
        Freight_Reference_Number__c,
        Cargo_Type__c,
        Commodity_Name__c,
        Freight_Quantity__c,
        Length__c,
        Height__c,
        Width__c,
        Vehicle_Name__c,
        Type__c,
        Model__c,
        Manufacturer__c,
        Tolabel(Marine_Cargo_Insurance__c),
        EEI_Preparation__c,
        Importer_Security_Filing__c,
        Customs_Brokerage__c,
        Fumigate__c,
        VGM_Certification__c,
        Bonded_Cargo_Doc_Fee__c,
        Labels_Placards__c,
        Additional_Chains__c,
        VIN_Number__c,
        Additional_Chains_Qty__c,
        Additional_Straps__c,
        Additional_Straps_Qty__c,
        Additional_Tarps__c,
        Additional_Tarps_Qty__c,
        Package_Type__c,
        Wire_Pick_End_Down_Charge__c,
        BOL_Processing_Fee__c,
        Multiple_BoL_Fee__c,
        Caricom_Invoice_Preparation__c,
        Late_Documentation_Fee__c,
        Measure_Unit__c,
        Diversion_or_Reconsignment__c,
        Customs_Exam__c,
        LoadLast_HotHatch__c,
        Do_not_Advance__c,
        Do_not_Split__c,
        Excess_Fuel_in_Vehicles_RO_RO__c,
        Additional_Binders__c,
        Additional_Binders_Qty__c,
        Additional_BoLs__c,
        Package_Quantity__c,
        Privately_Owned_Dealer_Owned_Vehicle__c,
        Commodity_Code__c,
        Length_Major__c,
        Length_Minor__c,
        Width_Major__c,
        Width_Minor__c,
        Height_Major__c,
        Height_Minor__c,
        Description__c,
        Over_Dimension__c,
        Declared_Weights_Unit_of_Measure__c,
        Declared_Weight_Value__c,
        Year__c
      FROM FreightDetail__c
      WHERE Shipment__r.Booking__c IN :bookingIds
    ];
  }

  /*
   * @purpose     : Method to get Requirement Records by set Of booking ids.
   * @parameter   : Set<Id> bookingIds - set Of booking ids
   * @return      : List<Requirement__c> - List of Requirement Records
   */
  public static List<Requirement__c> getRequirementsByBookingIds(
    Set<Id> bookingIds
  ) {
    return [
      SELECT
        Id,
        Freight__r.Shipment__r.Booking__c,
        Category__c,
        Container_Type__c,
        Quantity__c,
        Length__c,
        Weight__c,
        Width__c,
        Crowley_Equipment__c,
        IsShippersOwn__c,
        Running_Reefer__c,
        Ventilated__c,
        Tolabel(Marine_Cargo_Insurance__c),
        EEI_Preparation__c,
        Importer_Security_Filing__c,
        Temperature__c,
        Customs_Brokerage__c,
        Fumigate__c,
        VGM_Certification__c,
        Bonded_Cargo_Doc_Fee__c,
        Labels_Placards__c,
        Additional_Chains__c,
        Commodity_Name__c,
        Additional_Chains_Qty__c,
        Additional_Straps__c,
        Additional_BoLs__c,
        Additional_Straps_Qty__c,
        Additional_Tarps__c,
        Additional_Tarps_Qty__c,
        Temperatures_Unit_of_Measure__c,
        Wire_Pick_End_Down_Charge__c,
        BOL_Processing_Fee__c,
        Multiple_BoL_Fee__c,
        Caricom_Invoice_Preparation__c,
        Late_Documentation_Fee__c,
        Container_Code__c,
        Diversion_or_Reconsignment__c,
        Customs_Exam__c,
        LoadLast_HotHatch__c,
        Do_not_Advance__c,
        Do_not_Split__c,
        Excess_Fuel_in_Vehicles_RO_RO__c,
        Additional_Binders__c,
        Additional_Binders_Qty__c
      FROM Requirement__c
      WHERE Freight__r.Shipment__r.Booking__c IN :bookingIds
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
        IsShippersOwn__c,
        Running_Reefer__c,
        IsNonOperativeReefer__c,
        Declared_value_of_Cargo_USD__c,
        TopValue__c,
        TopUnit__c,
        LeftValue__c,
        LeftUnit__c,
        RightValue__c,
        RightUnit__c,
        FrontValue__c,
        FrontUnit__c,
        DoorValue__c,
        DoorUnit__c,
        Temperature__c,
        Temperatures_Unit_of_Measure__c,
        Ventilated__c,
        Marine_Cargo_Insurance__c,
        Bonded_Cargo_Doc_Fee__c,
        Additional_Chains__c,
        Additional_Chains_Qty__c,
        BOL_Processing_Fee__c,
        Customs_Brokerage__c,
        Labels_Placards__c,
        VGM_Certification__c,
        EEI_Preparation__c,
        Additional_Straps__c,
        Additional_Straps_Qty__c,
        Excess_Fuel_in_Vehicles_RO_RO__c,
        Diversion_or_Reconsignment__c,
        LoadLast_HotHatch__c,
        Multiple_BoL_Fee__c,
        Additional_BoLs__c,
        Importer_Security_Filing__c,
        Fumigate__c,
        Wire_Pick_End_Down_Charge__c,
        Late_Documentation_Fee__c,
        Additional_Tarps__c,
        Caricom_Invoice_Preparation__c,
        Customs_Exam__c,
        Do_not_Advance__c,
        Do_not_Split__c
      FROM Requirement__c
      WHERE Freight__c = :freightDetailIds
    ];
  }

  /*
   * @purpose     : Method to get List of Requirement Records with given FreightDetailIds
   * @parameter   : FreightDetailIds - Set of FreightDetail Ids provided
   * @return      : List<Requirement__c> - List of Requirement Records with given FreightDetailIds
   */
  public static List<Commodity__c> getCommodityByFreightDetailIds(
    Set<Id> freightDetailIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Emergency_Contact_Name__c,
        Emergency_Contact_Number__c,
        Contract_Number__c,
        Content_Type__c,
        Permit_Number__c,
        Ex_Number__c,
        Name__c,
        Primary_Class__c,
        Prefix__c,
        Variation__c,
        Package_Group__c,
        Secondary_Class__c,
        Tertiary_Class__c,
        Number__c,
        Marine_Pollutant_Indicator__c,
        Limited_Quantity_Indicator__c,
        Flash_Temperature_value__c,
        Flash_Temperature_Unit_of_Measure__c,
        Reported_Quantity__c,
        Quantity_Unit_of_Measure__c,
        Weight_value__c,
        Weight_Unit_of_Measure__c,
        Type_of_Package__c,
        Suffix__c
      FROM Commodity__c
      WHERE Freight__c = :freightDetailIds
    ];
  }

  /*
   * @purpose     : Method to get Equipment Records by set Of booking ids.
   * @parameter   : Set<Id> bookingIds - set Of booking ids
   * @return      : List<Equipment__c> - List of Equipment Records
   */
  public static List<Equipment__c> getEquipmentsByBookingIds(
    Set<Id> bookingIds
  ) {
    return [
      SELECT
        Id,
        Name,
        Prefix__c,
        Requirement__r.Freight__r.Shipment__r.Booking__c,
        Type__c,
        Category__c,
        VGM_Weight__c,
        Unit_of_Measure_for_VGM__c,
        Receive_Date__c,
        Auth_Permission__c,
        Responsible_Party__c,
        Equipment_Length__c
      FROM Equipment__c
      WHERE Requirement__r.Freight__r.Shipment__r.Booking__c IN :bookingIds
    ];
  }

  /*
   * @purpose     : Method to get Stop Records by set Of booking ids.
   * @parameter   : Set<Id> bookingIds - set Of booking ids
   * @return      : List<Stop__c> - List of stop Records
   */
  public static List<Stop__c> getStopDetailsByBookingIds(Set<Id> bookingIds) {
    return [
      SELECT
        Id,
        Transport__c,
        Transport__r.Booking__c,
        Call_Time__c,
        CVIF__c,
        Country__c,
        Name,
        Contact_Name__c,
        Drop_Date__c,
        Drop_Time__c,
        Live_Load__c,
        State__c,
        Zip_Code_Postal_Code__c,
        Phone_Number__c,
        Address__c,
        Address_2__c,
        City__c,
        Call_Date__c,
        Pick_up_Date__c,
        Pick_up_Reference_Number__c,
        Pickup_Time__c,
        Pick_up_TimeTo__c,
        Drop_Time_To__c
      FROM Stop__c
      WHERE Transport__r.Booking__c IN :bookingIds
    ];
  }

  /*
   * @purpose     : Method to get Booking Records by account Ids.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : List<Booking__c > - List of Booking
   */
  public static List<Booking__c> getBookingByQuery(
    String query,
    List<Id> accountIds
  ) {
    return Database.query(query);
  }

  /*
   * @purpose     : Method to get Shipment Records by Origin and Destination Codes.
   * @parameter   : originCodes - List of Origin Codes
   * @parameter   : destinationCodes - List of Destination Codes
   * @return      : List<Shipment__c > - List of Shipment Records
   */
  public static List<Shipment__c> getShipmentByOriginDestinationCode(
    List<String> originCodes,
    List<String> destinationCodes
  ) {
    return [
      SELECT Id, Booking__c, Origin_Code__c, Destination_Code__c
      FROM Shipment__c
      WHERE
        Origin_Code__c IN :originCodes
        OR Destination_Code__c IN :destinationCodes
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
      SELECT Id, Freight__r.Shipment__r.Booking__c
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
      SELECT Id, Shipment__r.Booking__c
      FROM FreightDetail__c
      WHERE Commodity_Name__c = :commodityName
    ];
  }

  /*
   * @purpose     : Method to get Shipment Records by Booking Ids.
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : List<Shipment__c > - List of Shipment Records
   */
  public static List<Shipment__c> getShipmentByBookingIds(Set<Id> bookingIds) {
    return [
      SELECT
        Id,
        Booking__c,
        Destination_Code__c,
        Destination_City__c,
        Destination_Country__c,
        Destination_State__c,
        Origin_City__c,
        Origin_Code__c,
        Origin_Country__c,
        Origin_State__c
      FROM Shipment__c
      WHERE Booking__c IN :bookingIds
    ];
  }

  /*
   * @purpose     : Method to get Voyage Records by Booking Ids.
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : List<Voyage__c > - List of Voyage Records
   */
  public static List<Voyage__c> getVoyagesByBookingIds(Set<Id> bookingIds) {
    return [
      SELECT
        Id,
        Vessel_Name__c,
        Voyage_Number__c,
        Shipment__r.Booking__c,
        Estimate_Arrival_Date__c,
        Loading_Port__c,
        Discharge_Port__c,
        Loading_Sequence__c,
        Discharge_Sequence__c,
        Loading_Location_Code__c,
        Estimate_Sail_Date__c,
        Loading_City__c,
        Loading_State__c,
        Loading_Country__c,
        Loading_Zip__c,
        Discharge_Location_Code__c,
        Discharge_City__c,
        Discharge_State__c,
        Discharge_Country__c,
        Discharge_Zip__c
      FROM Voyage__c
      WHERE Shipment__r.Booking__c IN :bookingIds
    ];
  }

  /*
   * @purpose     : Method to get Transport Records by Booking Ids.
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : List<Transport__c > - List of Transport Records
   */
  public static List<Transport__c> getTransportsByBookingIds(
    Set<Id> bookingIds
  ) {
    return [
      SELECT Id, Booking__c, Control_Location__c, Origin_Destination_Code__c
      FROM Transport__c
      WHERE Booking__c IN :bookingIds
    ];
  }

  /*
   * @purpose     : Method to get Commodity Records by Booking Ids.
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : List<Commodity__c > - List of Commodity Records
   */
  public static List<Commodity__c> getCommoditiesByBookingIds(
    Set<Id> bookingIds
  ) {
    return [
      SELECT
        Id,
        Commodity__c,
        Freight__r.Shipment__r.Booking__c,
        Is_Hazardous__c,
        TLI_Number__c,
        Technical_Name__c,
        Quantity_value__c,
        Quantity_Unit_of_Measure__c,
        Weight_value__c,
        Weight_Unit_of_Measure__c,
        Volume_value__c,
        Volume_Unit_of_Measure__c,
        IMO_Class__c,
        Primary_Class__c,
        Secondary_Class__c,
        Sub_Risk_Class__c,
        Number__c,
        Tertiary_Class__c,
        Variation__c,
        Package_Group__c,
        Marine_Pollutant_Indicator__c,
        Limited_Quantity_Indicator__c,
        Flash_Temperature_value__c,
        Flash_Temperature_Unit_of_Measure__c,
        Reported_Quantity__c,
        Type_of_Package__c,
        Name,
        Contract_Number__c,
        Content_Type__c,
        Permit_Number__c,
        Ex_Number__c,
        Name__c,
        Prefix__c,
        Emergency_Contact_Name__c,
        Emergency_Contact_Number__c
      FROM Commodity__c
      WHERE Freight__r.Shipment__r.Booking__c IN :bookingIds
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
      SELECT Id, Freight__r.Shipment__r.Booking__c
      FROM Requirement__c
      WHERE Container_Type__c = :containerType
    ];
  }

  /*
   * @purpose     : Method to get Charge Line Records by Booking Ids.
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : List<Charge_Line__c > - List of Charge Line Records
   */
  public static List<Charge_Line__c> getChargelinesByBookingId(
    Set<Id> bookingIds
  ) {
    return [
      SELECT
        Id,
        Amount_Target__c,
        Booking__r.Total_Amount__c,
        Item_Code__c,
        Item_Name__c,
        Quantity__c,
        Charge_Code__c,
        ChargeDescription__c,
        Item_Sequence__c,
        Booking__c
      FROM Charge_Line__c
      WHERE Booking__c IN :bookingIds
      ORDER BY Amount_Target__c DESC
    ];
  }

  /*
   * @purpose     : Method to get Voyage Records by VessalName.
   * @parameter   : VessalName - Vessal Name
   * @return      : List<Voyage__c > - List of Voyage Records
   */
  public static List<Voyage__c> getVoyageswithBookingIdsbyVessalName(
    String VessalName
  ) {
    return [
      SELECT Id, Vessel_Name__c, Voyage_Number__c, Shipment__r.Booking__c
      FROM Voyage__c
      WHERE Vessel_Name__c = :VessalName
    ];
  }

  /*
   * @purpose     : Method to get Aggregated result of Stop Records by Booking Ids.
   * @parameter   : bookingIds - Set of Booking Ids
   * @return      : List<AggregateResult > - List of Aggregated Results
   */
  public static List<AggregateResult> getStopsCountByBookingId(
    Set<Id> bookingIds
  ) {
    return [
      SELECT Transport__r.Booking__c bookingId, count(Id) Total
      FROM Stop__c
      WHERE Transport__r.Booking__c IN :bookingIds
      GROUP BY Transport__r.Booking__c
    ];
  }

  /*
   * @purpose     : Method to get Total Bookings by List of Account Id.
   * @parameter   : query - Query String to be executed
   * @parameter   : List of account Ids
   * @return      : Integer - Number of Bookings
   */
  public static Integer getTotalBookingsByQueryAccountIds(
    String query,
    List<Id> accountIds
  ) {
    AggregateResult results = Database.query(query);
    Integer totalRecords = (Integer) results.get('Total');
    return totalRecords;
  }

  /*
   * @purpose     : Method to get files related to booking records.
   * @parameter   : bookingId - Id of a booking record
   * @return      : List<ContentVersion> - list of ContentVersions
   */
  public static List<ContentVersion> getFilesbyBookingId(Id BookingId) {
    List<ContentVersion> listcvs = new List<ContentVersion>();
    List<ContentDocumentLink> listCDLinks = new List<ContentDocumentLink>();
    Set<Id> contentDocIds = new Set<Id>();
    listCDLinks = [
      SELECT ContentDocumentId
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :BookingId
    ];
    system.debug(listCDLinks);
    for (ContentDocumentLink cdlink : listCDLinks) {
      contentDocIds.add(cdlink.ContentDocumentId);
    }
    listcvs = [
      SELECT
        Id,
        Title,
        Origin,
        OwnerId,
        FileType,
        FileExtension,
        ContentDocumentId,
        Type__c,
        CreatedDate,
        Owner.Name
      FROM ContentVersion
      WHERE ContentDocumentId IN :contentDocIds
    ];
    system.debug(listcvs);
    return listcvs;
  }

  /*
   * @purpose     : Method to get Booking Remarks related to booking records.
   * @parameter   : bookingId - Id of a booking record
   * @return      : List<Booking_Remark__c> - list of Booking Remarks
   */
  public static List<Booking_Remark__c> getBookingRemarks(Set<Id> bookingIds) {
    List<Booking_Remark__c> listBkRemarks = new List<Booking_Remark__c>();
    listBkRemarks = [
      SELECT
        Id,
        Name,
        Booking__c,
        Line_Number__c,
        Employee_Number__c,
        Remark__c,
        Source__c,
        Timestamp__c
      FROM Booking_Remark__c
      WHERE Booking__c IN :bookingIds
      ORDER BY CreatedDate ASC
    ];
    return listBkRemarks;
  }
}
