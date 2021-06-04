public without sharing class CC_BOLDAO {
  public static List<BOL_Number__c> getBOLNumberFromBucket() {
    return [
      SELECT Id, Name, Is_Used__c
      FROM BOL_Number__c
      WHERE Is_Used__c != TRUE
      ORDER BY Name
      LIMIT 1
    ];
  }

  public static List<Booking__c> getBolWithBooking(String strBookingId) {
    return [
      SELECT
        Id,
        Bill_of_Lading_Number__c,
        (SELECT Id FROM Bill_Of_Ladings__r LIMIT 1)
      FROM Booking__c
      WHERE Id = :strBookingId
    ];
  }

  public static List<Booking__c> getBooking(String bookingId) {
    return [
      SELECT
        Id,
        Payment_Terms__c,
        Contract_Number__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Description__c,
        Customer_Origin_Code__c,
        Customer_Destination_Code__c,
        Is_Hazardous__c,
        Ready_Date__c,
        Booking_Number__c,
        Customer_Destination_City__c,
        Customer_Destination_State__c,
        (
          SELECT
            Id,
            Name,
            REF_Number__c,
            Tax_ID__c,
            Address_Line1__c,
            Address_Line2__c,
            Address_Line3__c,
            Address_Line4__c,
            Phone_Number__c,
            Email_Address__c,
            FMC__c,
            CHB_Number__c,
            Type__c,
            Destination_Tax_Id_Number__c
          FROM Parties__r
        )
      FROM Booking__c
      WHERE Id = :bookingId
    ];
  }

  public static List<Shipment__c> getShipment(String bookingId) {
    return [
      SELECT
        Id,
        Internal_Transaction_Number__c,
        Exempt_Code__c,
        Origin_Country__c,
        Origin_State__c,
        Origin_Code__c,
        Destination_Code__c,
        Destination_Port__c,
        Origin_Port__c,
        Destination_City__c,
        Destination_State__c,
        (SELECT Id, Vessel_Name__c, Voyage_Number__c, Name FROM Voyages__r),
        (SELECT Id FROM Freight_Details__r)
      FROM Shipment__c
      WHERE Booking__c = :bookingId
      ORDER BY CreatedDate ASC
      LIMIT 1
    ];
  }

  public static List<Dock_Receipt__c> getDockReceipt(String shipmentId) {
    return [
      SELECT Id, ReceiptNumber__c, Equipment_Number__c, Equipment_Prefix__c
      FROM Dock_Receipt__c
      WHERE Shipment__c = :shipmentId AND Shipment__c != NULL
    ];
  }

  public static List<Location__c> getLocation(
    Map<String, String> mapWhereClauseFieldAndValue
  ) {
    String strQuery = 'SELECT Id,Location_Name__c,Name, Location_Type__c FROM Location__c ';
    String strWhereClause = '';
    for (String strKey : mapWhereClauseFieldAndValue.keySet()) {
      if (
        String.isNotBlank(strKey) &&
        String.isNotBlank(mapWhereClauseFieldAndValue.get(strKey))
      ) {
        strWhereClause +=
          ' ' +
          strKey +
          ' = \'' +
          mapWhereClauseFieldAndValue.get(strKey) +
          '\' AND ';
      }
    }

    if (String.isNotBlank(strWhereClause)) {
      strWhereClause = strWhereClause.removeEnd(' AND ');
      strQuery += ' WHERE ' + strWhereClause;
      System.debug('strQuery ==> ' + strQuery);
      return Database.query(strQuery);
    }
    return new List<Location__c>();
  }

  public static List<Requirement__c> getRequirements(
    Set<Id> freightdetailIdset
  ) {
    return [
      SELECT
        Id,
        Ventilated__c,
        (
          SELECT
            Id,
            Prefix__c,
            Number__c,
            Seal_Numbers__c,
            Cargo_Unit_Quantity__c,
            Cargo_Unit_of_measure__c,
            Value_of_Cargo_Weight__c,
            VGM_Weight__c,
            Unit_of_Measure_for_Cargo_Weight__c,
            Unit_of_Measure_for_VGM__c,
            Requested_Temp_Value__c,
            Requested_Unit_of_Measure__c
          FROM Equipments__r
        )
      FROM Requirement__c
      WHERE Freight__c IN :freightdetailIdset
    ];
  }

  public static List<Commodity__c> getCommodities(Set<Id> freightdetailIdset) {
    return [
      SELECT
        Id,
        Description__c,
        Name__c,
        UN_Number__c,
        Content_Type__c,
        Number__c,
        Prefix__c,
        Permit_Number__c,
        Ex_Number__c,
        Technical_Name__c,
        IMO_Class__c,
        Variation__c,
        Package_Group__c,
        Secondary_Class__c,
        Tertiary_Class__c,
        Is_Marine_Pollutant__c,
        Is_Limited_Quantity__c,
        Flash_Temperature_value__c,
        Flash_Temperature_Unit_of_Measure__c,
        Reportable_Quantity__c,
        Reported_Quantity__c,
        Quantity_Unit_of_Measure__c,
        Weight_value__c,
        Weight_Unit_of_Measure__c,
        Quantity_value__c,
        Type_of_Package__c
      FROM Commodity__c
      WHERE Freight__c IN :freightdetailIdset
    ];
  }

  public static List<Charge_Line__c> getChargeLine(String bookingId) {
    return [
      SELECT
        Id,
        ChargeDescription__c,
        Quantity__c,
        Basis__c,
        Rate__c,
        Amount_Target__c,
        Item_Sequence__c,
        Item_Code__c,
        Item_Name__c,
        Name
      FROM Charge_Line__c
      WHERE Booking__c = :bookingId
    ];
  }

  public static List<Booking__c> getBookingForCompare(String bookingId) {
    return [
      SELECT
        Id,
        Contract_Number__c,
        Customer_Origin_Country__c,
        Customer_Origin_State__c,
        Description__c,
        Customer_Origin_Code__c,
        Customer_Destination_Code__c,
        Customer_Destination_City__c,
        Customer_Destination_State__c,
        Is_Hazardous__c,
        Ready_Date__c,
        Booking_Number__c
      FROM Booking__c
      WHERE Id = :bookingId
    ];
  }

  public static List<Shipment__c> getShipmentForCompare(String bookingId) {
    return [
      SELECT
        Id,
        Internal_Transaction_Number__c,
        Exempt_Code__c,
        Origin_Country__c,
        Origin_State__c,
        Origin_Code__c,
        Destination_Code__c,
        Destination_State__c,
        Destination_City__c,
        Destination_Port__c,
        Origin_Port__c
      FROM Shipment__c
      WHERE Booking__c = :bookingId
      ORDER BY CreatedDate ASC
      LIMIT 1
    ];
  }

  public static List<Bill_Of_Lading__c> getBOL(
    String bolId,
    Boolean isForEdit
  ) {
    if (isForEdit) {
      return [
        SELECT
          Id,
          Booking_Number__r.Description__c,
          Place_of_Delivery_Location_Type__c,
          Place_of_Delivery_Location_Code__c,
          Loading_Pier_Location_Code__c,
          Loading_Pier_Location_Type__c,
          Load_Port_Description__c,
          Discharge_Port_Description__c,
          Place_of_Receipt_Location_Type__c,
          Place_Of_Receipt_Description__c,
          Relay_Point_Description__c,
          Booking_Reference_Number__c,
          Booking_Number__r.Booking_Number__c,
          Relay_Point_Type__c,
          Bill_of_lading_Status__c,
          Booking_Number__c,
          Copy_the_description_for_all_containers__c,
          Customer_Send_Date__c,
          EEI_Preparation_Support_Required__c,
          Contract_Number__c,
          SCAC_Code__c,
          ITN_Number__c,
          Secoundry_ITN_Number__c,
          Inbound_Type__c,
          Inbound_Number__c,
          Consignee_Reference_Number__c,
          Customer_Billing_Reference_Number__c,
          Forwarder_Reference_Number__c,
          Shipper_Reference_Number__c,
          Notify_Reference_Number__c,
          Also_Notify_Reference_Number__c,
          CNB_Reference_Number__c,
          FPT_Reference_Number__c,
          X3RD_Reference_Number__c,
          Other_Party_Reference_Number__c,
          EIN_Reference_Number__c,
          SED_Exemption_Code__c,
          SED_Exception_OPT4__c,
          Tax_Identification_Number__c,
          Bill_Of_Lading_Number__c,
          Relay_Point__c,
          Point_Of_Origin_Country__c,
          Place_Of_Receipt__c,
          Load_Port__c,
          IE_Inbound_Number__c,
          WI_Inbound_Number__c,
          WT_Inbound_Number__c,
          IT_Inbound_Number__c,
          TE_Inbound_Number__c,
          BOL_Load_Pier_Terminal_1__c,
          Discharge_Port__c,
          Place_of_Delivery_1__c,
          Originals_to_be_Released_at__c,
          Flag__c,
          Routing_Details__c,
          Cargo_Available_for_Transport__c,
          Bill_Of_Lading_Instructions__c,
          Hazardous__c,
          Hazardous_Emergency_Phone_Number_1__c,
          Hazardous_Emergency_Contact__c,
          Hazardous_Emergency_Phone_Number_2__c,
          Booking_Description__c,
          (
            SELECT
              Id,
              Prefix__c,
              Number__c,
              Seal_Numbers__c,
              Cargo_Unit_Quantity__c,
              Type__c,
              Value_of_Cargo_Weight__c,
              Unit_of_Measure_for_Cargo_Weight__c,
              Cargo_Cube__c,
              Cargo_Unit_of_measure__c,
              Vent_Settings__c,
              Temperature_1__c,
              Unit_of_measure_Temperature_1__c,
              VMG_Scale_Weight_Kilo__c,
              VGM_Weight_Kilos__c,
              Equipment_Number_Copy__c,
              VGM_Scale_Weight_Pounds__c,
              VGM_Weight_Pounds__c,
              Cube_Unit_of_measure__c
            FROM Equipments__r
          )
        FROM Bill_Of_Lading__c
        WHERE Id = :bolId
      ];
    } else {
      return [
        SELECT
          Id,
          Booking_Number__r.Description__c,
          Place_of_Delivery_Location_Type__c,
          Place_of_Delivery_Location_Code__c,
          Loading_Pier_Location_Code__c,
          Loading_Pier_Location_Type__c,
          Load_Port_Description__c,
          Discharge_Port_Description__c,
          Place_of_Receipt_Location_Type__c,
          Place_Of_Receipt_Description__c,
          Relay_Point_Description__c,
          Booking_Reference_Number__c,
          Booking_Number__r.Booking_Number__c,
          Relay_Point_Type__c,
          Bill_of_lading_Status__c,
          Booking_Number__c,
          Copy_the_description_for_all_containers__c,
          Customer_Send_Date__c,
          EEI_Preparation_Support_Required__c,
          Contract_Number__c,
          SCAC_Code__c,
          ITN_Number__c,
          Secoundry_ITN_Number__c,
          Inbound_Type__c,
          Inbound_Number__c,
          Consignee_Reference_Number__c,
          Customer_Billing_Reference_Number__c,
          Forwarder_Reference_Number__c,
          Shipper_Reference_Number__c,
          Notify_Reference_Number__c,
          Also_Notify_Reference_Number__c,
          CNB_Reference_Number__c,
          FPT_Reference_Number__c,
          X3RD_Reference_Number__c,
          Other_Party_Reference_Number__c,
          EIN_Reference_Number__c,
          SED_Exemption_Code__c,
          SED_Exception_OPT4__c,
          Tax_Identification_Number__c,
          Bill_Of_Lading_Number__c,
          Relay_Point__c,
          Point_Of_Origin_Country__c,
          Place_Of_Receipt__c,
          Load_Port__c,
          IE_Inbound_Number__c,
          WI_Inbound_Number__c,
          WT_Inbound_Number__c,
          IT_Inbound_Number__c,
          TE_Inbound_Number__c,
          BOL_Load_Pier_Terminal_1__c,
          Discharge_Port__c,
          Place_of_Delivery_1__c,
          Originals_to_be_Released_at__c,
          Flag__c,
          Routing_Details__c,
          Cargo_Available_for_Transport__c,
          Bill_Of_Lading_Instructions__c,
          Hazardous__c,
          Hazardous_Emergency_Phone_Number_1__c,
          Hazardous_Emergency_Contact__c,
          Hazardous_Emergency_Phone_Number_2__c,
          Booking_Description__c,
          (
            SELECT
              Id,
              Prefix__c,
              Number__c,
              Seal_Numbers__c,
              Cargo_Unit_Quantity__c,
              Type__c,
              Value_of_Cargo_Weight__c,
              Unit_of_Measure_for_Cargo_Weight__c,
              Cargo_Cube__c,
              Cargo_Unit_of_measure__c,
              toLabel(Vent_Settings__c),
              Temperature_1__c,
              Unit_of_measure_Temperature_1__c,
              VMG_Scale_Weight_Kilo__c,
              VGM_Weight_Kilos__c,
              Equipment_Number_Copy__c,
              VGM_Scale_Weight_Pounds__c,
              VGM_Weight_Pounds__c,
              Cube_Unit_of_measure__c
            FROM Equipments__r
          )
        FROM Bill_Of_Lading__c
        WHERE Id = :bolId
      ];
    }
  }

  public static List<Party__c> getBolParty(String bolId) {
    return [
      SELECT
        Id,
        Name,
        Reference_Number__c,
        Address_Line1__c,
        Address_Line2__c,
        Address_Line3__c,
        Address_Line4__c,
        Email_Address__c,
        Phone_Number__c,
        Type__c,
        Destination_Tax_Id_Type__c,
        Destination_Tax_Id_Number__c,
        Registration_Id__c,
        EIN_Reference_Number__c,
        CHB_Number__c,
        FMC__c,
        Booking_Party__r.Id,
        Booking_Party__r.Name,
        Booking_Party__r.Address_Line1__c,
        Booking_Party__r.Address_Line2__c,
        Booking_Party__r.Address_Line3__c,
        Booking_Party__r.Address_Line4__c,
        Booking_Party__r.Phone_Number__c,
        Booking_Party__r.Email_Address__c,
        Booking_Party__r.Tax_ID__c,
        Booking_Party__r.FMC__c,
        Booking_Party__r.CHB_Number__c
      FROM Party__c
      WHERE Bill_Of_Lading_Number__c = :bolId
      ORDER BY LastModifiedDate DESC
    ];
  }

  public static List<Bill_Item__c> getBillItems(String bolId) {
    return [
      SELECT
        Id,
        Booking_Instructions__c,
        Schedule_B_Number__c,
        Schedule_B_Number_Type__c,
        Secondary_Schedule_B_Number__c,
        Items_Text_DSC__c,
        Items_Text_DSC_F__c,
        Shipper_Declare_value__c,
        (
          SELECT
            Id,
            Equipment_Number__c,
            Dock_Receipt_Number__c,
            Number__c,
            UN_Number__c,
            Content_Type__c,
            Permit_Number__c,
            Ex_Number__c,
            Technical_Name__c,
            IMO_Class__c,
            Variation__c,
            Package_Group__c,
            Secondary_Class__c,
            Tertiary_Class__c,
            Marine_Pollutant_Indicator__c,
            Limited_Quantity_Indicator__c,
            Flashpoint__c,
            Unit_of_Measure__c,
            Reportable_Quantity__c,
            Quantity_Unit_of_Measure__c,
            Weight_Unit_of_Measure__c,
            Weight_value__c,
            Quantity_value__c,
            Name__c,
            Type_of_Package__c,
            Description__c,
            Equipment_Number_Copy__c,
            Primary_Class__c,
            Emergency_Contact_Name__c,
            Emergency_Contact_Number__c
          FROM Commodities__r
        )
      FROM Bill_Item__c
      WHERE Bill_Of_Lading_Number__c = :bolId
    ];
  }

  public static List<HTS_Master__c> getHTS(Set<String> htsNumberSet) {
    return [
      SELECT Id, Name, Type__c, Description__c
      FROM HTS_Master__c
      WHERE Name IN :htsNumberSet
    ];
  }
  public static List<Voyage__c> getOldVoyage(String bolId) {
    return [
      SELECT Id, Bill_Of_Lading_Number__c
      FROM Voyage__c
      WHERE Bill_Of_Lading_Number__c = :bolId
      LIMIT 1
    ];
  }
}
