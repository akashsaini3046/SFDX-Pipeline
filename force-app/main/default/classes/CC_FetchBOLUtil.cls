public without sharing class CC_FetchBOLUtil {
  public BOLEditController.BolView fetchBOLData(
    String bookingId,
    String bolId,
    Boolean isForEdit
  ) {
    BOLEditController.BolView bolView = new BOLEditController.BolView();
    CC_BolCustomerReferenceWrapper customerReference = new CC_BolCustomerReferenceWrapper();
    CC_BOLRouteDetailsWrapper routingDetails = new CC_BOLRouteDetailsWrapper();
    List<CC_BOLCargoEquipmentWrapper> bOLCargoEquipmentWrapperLst = new List<CC_BOLCargoEquipmentWrapper>();
    Map<String, Equipment__c> mapEquipmentId = new Map<String, Equipment__c>();

    // These variables will be used to query locations;
    Set<String> locationNames = new Set<String>();
    Set<String> locationTypes = new Set<String>();

    String bookingDescription = '';
    Bill_Of_Lading__c billOfLading = new Bill_Of_Lading__c();
    // Query old booking
    Shipment__c objOldShipment = new Shipment__c();
    Booking__c objOldBooking = new Booking__c();

    //get old data for compare
    if (isForEdit == true) {
      for (Booking__c objBooking : CC_BOLDAO.getBookingForCompare(bookingId)) {
        objOldBooking = objBooking;
        break;
      }
      for (
        Shipment__c objShipment : CC_BOLDAO.getShipmentForCompare(bookingId)
      ) {
        objOldShipment = objShipment;
        break;
      }
    }

    //Get bol data and create a map with equipment number and equipment
    for (Bill_Of_Lading__c bol : CC_BOLDAO.getBOL(bolId, isForEdit)) {
      billOfLading = bol;
      for (Equipment__c objEquipment : bol.Equipments__r) {
        if (String.isNotBlank(objEquipment.Equipment_Number_Copy__c)) {
          mapEquipmentId.put(
            objEquipment.Equipment_Number_Copy__c,
            objEquipment
          );
        } else if (String.isNotBlank(objEquipment.Number__c)) {
          mapEquipmentId.put(objEquipment.Number__c, objEquipment);
        }
      }
      break;
    }

    //fetch customerReference
    bolView = setBolCustomerReferenceWrapper(
      bolView,
      billOfLading,
      objOldBooking,
      objOldShipment
    );
    //Set party
    bolView = setParty(bolView, billOfLading, isForEdit);
    //Set routing instructions
    bolView.routingInstructions = billOfLading.Bill_Of_Lading_Instructions__c;
    //Set routing details
    bolView.routingDetails = setRoutingDetails(
      bolView,
      billOfLading,
      objOldBooking,
      objOldShipment,
      isForEdit
    );
    //Set Cargo Equipment Details
    bolView = setCargoEquipmentDetails(
      bolView,
      billOfLading,
      objOldBooking,
      objOldShipment,
      isForEdit,
      mapEquipmentId
    );
    // Set charge Line
    bolView.chargeLine = loadChargeLineFromBOL(bolId);
    // Set additional Information
    bolView.additionalInformation = loadAdditionalInformation(bolId);

    return bolView;
  }

  private CC_BolAdditionalInformationWrapper loadAdditionalInformation(
    String strBOLId
  ) {
    CC_BolAdditionalInformationWrapper objAdditionalInfo = new CC_BolAdditionalInformationWrapper();
    if (String.isNotBlank(strBOLId)) {
      Bill_Of_Lading__c objBOL = [
        SELECT
          Id,
          ORIGINAL_BILL_OF_LADDING__c,
          WAYBILL__c,
          Freighted__c,
          Print_Cargo__c,
          Prnt_Excl_Charg__c,
          Prnt_INB_NBR__c,
          Comments__c,
          Release_Instructions__c,
          Letter_Of_Credit__c
        FROM Bill_Of_Lading__c
        WHERE Id = :strBOLId
      ];
      objAdditionalInfo.boolOriginalBillOfLading = objBOL.ORIGINAL_BILL_OF_LADDING__c;
      objAdditionalInfo.boolWayBill = objBOL.WAYBILL__c;
      objAdditionalInfo.boolFreighted = objBOL.Freighted__c;
      objAdditionalInfo.boolPrintCargo = objBOL.Print_Cargo__c;
      objAdditionalInfo.boolPrintExclCharge = objBOL.Prnt_Excl_Charg__c;
      objAdditionalInfo.boolPrintInbNumber = objBOL.Prnt_INB_NBR__c;
      objAdditionalInfo.comments = objBOL.Comments__c;
      objAdditionalInfo.releaseInstructions = objBOL.Release_Instructions__c;
      objAdditionalInfo.boolLetterOfCredit = objBOL.Letter_Of_Credit__c;
    }
    return objAdditionalInfo;
  }

  private Map<String, List<CC_ChargeLineWrapper>> loadChargeLineFromBOL(
    String strBOLId
  ) {
    Map<String, List<CC_ChargeLineWrapper>> mapChargeLine = new Map<String, List<CC_ChargeLineWrapper>>();
    if (String.isBlank(strBOLId)) {
      return mapChargeLine;
    }
    for (Charge_Line__c objChargeLine : [
      SELECT
        Id,
        ChargeDescription__c,
        Quantity__c,
        Basis__c,
        Rate__c,
        Amount_Target__c,
        Amount__c,
        Item_Sequence__c,
        Item_Code__c,
        Item_Name__c,
        Name,
        Prepaid_Collect__c,
        Payer_Name__c,
        Payment_Location__c
      FROM Charge_Line__c
      WHERE Bill_Of_Lading_Number__c = :strBOLId
    ]) {
      CC_ChargeLineWrapper objChargeLineWrapper = new CC_ChargeLineWrapper();
      objChargeLineWrapper.chargeLineId = objChargeLine.Id;
      objChargeLineWrapper.strFreightCharge = objChargeLine.ChargeDescription__c;
      objChargeLineWrapper.strRatedAs = (objChargeLine.Quantity__c != null
        ? String.valueOf(objChargeLine.Quantity__c)
        : '');
      objChargeLineWrapper.strPer = (objChargeLine.Basis__c != null
        ? String.valueOf(objChargeLine.Basis__c)
        : '');
      objChargeLineWrapper.strRateTarrif = (objChargeLine.Rate__c != null
        ? String.valueOf(objChargeLine.Rate__c)
        : '');
      objChargeLineWrapper.strPaymentTerm = objChargeLine.Prepaid_Collect__c;
      objChargeLineWrapper.strPayerName = objChargeLine.Payer_Name__c;
      objChargeLineWrapper.strPaymentLocation = objChargeLine.Payment_Location__c;
      objChargeLineWrapper.strValue = (objChargeLine.Amount_Target__c != null
        ? String.valueOf(objChargeLine.Amount_Target__c)
        : (objChargeLine.Amount__c != null
            ? String.valueOf(objChargeLine.Amount__c)
            : ''));
      //objChargeLineWrapper.strValue = (objChargeLine.Amount_Target__c != null ? String.valueOf(objChargeLine.Amount_Target__c) : '');
      if (mapChargeLine.containsKey(objChargeLine.Item_Name__c)) {
        mapChargeLine.get(objChargeLine.Item_Name__c).add(objChargeLineWrapper);
      } else {
        mapChargeLine.put(
          objChargeLine.Item_Name__c,
          new List<CC_ChargeLineWrapper>{ objChargeLineWrapper }
        );
      }
    }

    return mapChargeLine;
  }
  private BOLEditController.BolView setCargoEquipmentDetails(
    BOLEditController.BolView bolView,
    Bill_Of_Lading__c billOfLading,
    Booking__c objOldBooking,
    Shipment__c objOldShipment,
    Boolean isForEdit,
    Map<String, Equipment__c> mapEquipmentId
  ) {
    List<Bill_Item__c> lstBillItem = CC_BOLDAO.getBillItems(billOfLading.Id);
    Map<String, String> equipmentSizeTypeMap = getEquipmentSizeTypeMap(
      isForEdit
    );
    Map<String, String> mapScheduleNumbers = getHtsNumberWithDescription(
      lstBillItem,
      isForEdit
    );
    List<CC_BOLCargoEquipmentWrapper> bOLCargoEquipmentWrapperLst = new List<CC_BOLCargoEquipmentWrapper>();

    //set hazardous
    bolView.isHazardious = billOfLading.Hazardous__c;

    for (Bill_Item__c objBillItem : lstBillItem) {
      CC_BOLCargoEquipmentWrapper bolCargoEquipmentWrapper = new CC_BOLCargoEquipmentWrapper();

      bolCargoEquipmentWrapper.billItemId = objBillItem.Id;
      bolCargoEquipmentWrapper.isDeleted = false;

      //Setting hts number
      bolCargoEquipmentWrapper.htsNumbers = setHtsWrapper(
        objBillItem,
        isForEdit,
        mapScheduleNumbers
      );

      bolCargoEquipmentWrapper.cargoDescription = String.isNotBlank(
          objBillItem.Items_Text_DSC__c
        )
        ? objBillItem.Items_Text_DSC__c
        : '';
      bolCargoEquipmentWrapper.cargoDescriptionS = String.isNotBlank(
          objBillItem.Items_Text_DSC_F__c
        )
        ? objBillItem.Items_Text_DSC_F__c
        : '';
      bolCargoEquipmentWrapper.cargovalue = objBillItem.Shipper_Declare_value__c !=
        null
        ? String.valueOf(objBillItem.Shipper_Declare_value__c)
        : '';
      bolCargoEquipmentWrapper.bookingInst = objBillItem.Booking_Instructions__c;

      //Set commodity
      bolCargoEquipmentWrapper = setCommodities(
        objBillItem,
        bolCargoEquipmentWrapper
      );

      //Set Equipment
      bolCargoEquipmentWrapper = setEquipment(
        objBillItem,
        bolCargoEquipmentWrapper,
        mapEquipmentId,
        equipmentSizeTypeMap
      );

      bOLCargoEquipmentWrapperLst.add(bolCargoEquipmentWrapper);
    }

    if (bOLCargoEquipmentWrapperLst.size() == 0) {
      CC_BOLCargoEquipmentWrapper bolCargoEquipmentWrapper = new CC_BOLCargoEquipmentWrapper();
      bolCargoEquipmentWrapper.htsNumbers.add(new HTSNumberWrapper('', ''));
      bolCargoEquipmentWrapper.dockReceiptNumbers.add(
        new DockReceiptWrapper('')
      );
      bolCargoEquipmentWrapper.sealNumbers.add(new SealNumberWrapper(''));
      HazardousCommodityWrapper hazardousCommodity = new HazardousCommodityWrapper();
      hazardousCommodity.commodityWrap = new HazardousCommodityWrapper.CommodityWrapper();
      bolCargoEquipmentWrapper.hazardousCommodityLst.add(hazardousCommodity);
      bOLCargoEquipmentWrapperLst.add(bolCargoEquipmentWrapper);
    }

    bolView.cargoEquipment = bOLCargoEquipmentWrapperLst;

    return bolView;
  }

  /**
   * @Purpose :   This method retruen map of vessel name to id.
   *
   * @Returns :   Map<String, String> - Return map of vessel name to id.
   */
  private Map<String, String> getVesselMap() {
    Map<String, String> mapVesselNameToIdMap = new Map<String, String>();
    for (Vessel_Flag__c objVesselFlag : [SELECT Id, Name FROM Vessel_Flag__c]) {
      mapVesselNameToIdMap.put(objVesselFlag.Name, objVesselFlag.Id);
    }
    return mapVesselNameToIdMap;
  }

  private CC_BOLCargoEquipmentWrapper setEquipment(
    Bill_Item__c objBillItem,
    CC_BOLCargoEquipmentWrapper bolCargoEquipmentWrapper,
    Map<String, Equipment__c> mapEquipmentId,
    Map<String, String> equipmentSizeTypeMap
  ) {
    Equipment__c objEquipment;
    for (Commodity__c objCommodity : objBillItem.Commodities__r) {
      if (
        String.isNotBlank(objCommodity.Equipment_Number_Copy__c) &&
        mapEquipmentId.containsKey(objCommodity.Equipment_Number_Copy__c)
      ) {
        objEquipment = mapEquipmentId.get(
          objCommodity.Equipment_Number_Copy__c
        );
        break;
      } else if (
        String.isNotBlank(objCommodity.Equipment_Number__c) &&
        mapEquipmentId.containsKey(objCommodity.Equipment_Number__c)
      ) {
        objEquipment = mapEquipmentId.get(objCommodity.Equipment_Number__c);
        break;
      }
    }
    //If equipment is blank then set the default field and returen
    if (objEquipment == null) {
      bolCargoEquipmentWrapper.sealNumbers.add(new SealNumberWrapper(''));
      return bolCargoEquipmentWrapper;
    }

    bolCargoEquipmentWrapper.equipmentId = objEquipment.Id;
    bolCargoEquipmentWrapper.equipmentNumberCopy = objEquipment.Equipment_Number_Copy__c;
    bolCargoEquipmentWrapper.containerNO1 = objEquipment.Prefix__c;
    bolCargoEquipmentWrapper.containerNO2 = objEquipment.Number__c;
    bolCargoEquipmentWrapper.quantity = objEquipment.Cargo_Unit_Quantity__c;
    bolCargoEquipmentWrapper.packageType = objEquipment.Cargo_Unit_of_measure__c;
    // container size
    bolCargoEquipmentWrapper.containerSizeType = (equipmentSizeTypeMap !=
      null &&
      equipmentSizeTypeMap.get(objEquipment.Type__c) != null
      ? equipmentSizeTypeMap.get(objEquipment.Type__c)
      : objEquipment.Type__c);
    //This is UI functionality
    //bolCargoEquipmentWrapper.copyCheckbox = billOfLading.Copy_the_description_for_all_containers__c;
    bolCargoEquipmentWrapper.weight = objEquipment.Value_of_Cargo_Weight__c !=
      null
      ? String.valueOf(objEquipment.Value_of_Cargo_Weight__c)
      : '';
    bolCargoEquipmentWrapper.weightUnit = objEquipment.Unit_of_Measure_for_Cargo_Weight__c;
    //Set weight LBS
    if (
      String.isNotBlank(bolCargoEquipmentWrapper.weightUnit) &&
      (bolCargoEquipmentWrapper.weightUnit.toUpperCase() == 'KG' ||
      bolCargoEquipmentWrapper.weightUnit.toUpperCase() == 'KGS')
    ) {
      Decimal weightLbsValue = objEquipment.Value_of_Cargo_Weight__c != null
        ? (objEquipment.Value_of_Cargo_Weight__c * 2.2046)
        : 0.00;
      weightLbsValue = weightLbsValue.setScale(2);
      bolCargoEquipmentWrapper.weightLBS = String.valueOf(weightLbsValue);
    } else {
      bolCargoEquipmentWrapper.weightLBS = objEquipment.Value_of_Cargo_Weight__c !=
        null
        ? String.valueOf(objEquipment.Value_of_Cargo_Weight__c)
        : '0.00';
    }

    if (String.isNotBlank(objEquipment.VMG_Scale_Weight_Kilo__c)) {
      bolCargoEquipmentWrapper.vgmweight = objEquipment.VMG_Scale_Weight_Kilo__c;
      bolCargoEquipmentWrapper.vgmweightUnit = 'kg';
    } else if (String.isNotBlank(objEquipment.VGM_Scale_Weight_Pounds__c)) {
      bolCargoEquipmentWrapper.vgmweight = objEquipment.VGM_Scale_Weight_Pounds__c;
      bolCargoEquipmentWrapper.vgmweightUnit = 'lb';
    }
    //Set VGMweight LBS
    if (
      String.isNotBlank(bolCargoEquipmentWrapper.vgmweightUnit) &&
      bolCargoEquipmentWrapper.vgmweightUnit.toUpperCase() == 'KG' ||
      bolCargoEquipmentWrapper.vgmweightUnit.toUpperCase() == 'KGS'
    ) {
      Decimal vgmWeightLbsValue = string.isNotBlank(
          objEquipment.VMG_Scale_Weight_Kilo__c
        ) && isDecimal(objEquipment.VMG_Scale_Weight_Kilo__c)
        ? (Decimal.valueOf(objEquipment.VMG_Scale_Weight_Kilo__c) * 2.2046)
        : 0.00;
      vgmWeightLbsValue = vgmWeightLbsValue.setScale(2);
      bolCargoEquipmentWrapper.vgmweightLBS = String.valueOf(vgmWeightLbsValue);
    } else {
      bolCargoEquipmentWrapper.vgmweightLBS = objEquipment.VGM_Scale_Weight_Pounds__c !=
        null
        ? String.valueOf(objEquipment.VGM_Scale_Weight_Pounds__c)
        : '0.00';
    }
    bolCargoEquipmentWrapper.volume = objEquipment.Cargo_Cube__c != null
      ? String.valueOf(objEquipment.Cargo_Cube__c)
      : '';
    bolCargoEquipmentWrapper.volumeUnit = objEquipment.Cube_Unit_of_measure__c;
    bolCargoEquipmentWrapper.ventSettings = objEquipment.Vent_Settings__c;
    bolCargoEquipmentWrapper.temperature = objEquipment.Temperature_1__c;
    bolCargoEquipmentWrapper.temperatureUnit = objEquipment.Unit_of_measure_Temperature_1__c;

    //Set temperature Farenheit
    if (
      String.isNotBlank(bolCargoEquipmentWrapper.temperatureUnit) &&
      bolCargoEquipmentWrapper.temperatureUnit.toUpperCase() == 'C'
    ) {
      Decimal tempValueF = string.isNotBlank(objEquipment.Temperature_1__c) &&
        isDecimal(objEquipment.Temperature_1__c)
        ? (Decimal.valueOf(objEquipment.Temperature_1__c) * 1.8000 + 32.00)
        : 0.00;
      tempValueF = tempValueF.setScale(2);
      bolCargoEquipmentWrapper.temperatureF = String.valueOf(tempValueF);
    } else {
      bolCargoEquipmentWrapper.temperatureF = objEquipment.Temperature_1__c !=
        null
        ? String.valueOf(objEquipment.Temperature_1__c)
        : '';
    }

    //Set seal number
    Boolean isSealNumberBlank = true;
    if (String.isNotBlank(objEquipment.Seal_Numbers__c)) {
      for (String strSealNumber : objEquipment.Seal_Numbers__c.split(',')) {
        if (String.isNotBlank(strSealNumber)) {
          bolCargoEquipmentWrapper.sealNumbers.add(
            new SealNumberWrapper(strSealNumber)
          );
          isSealNumberBlank = false;
        }
      }
    }

    if (isSealNumberBlank) {
      bolCargoEquipmentWrapper.sealNumbers.add(new SealNumberWrapper(''));
    }
    return bolCargoEquipmentWrapper;
  }

  private Boolean isDecimal(String strDecimal) {
    Boolean returnValue;
    try {
      Decimal.valueOf(strDecimal);
      returnValue = true;
    } catch (Exception e) {
      returnValue = false;
    }
    return returnValue;
  }

  private CC_BOLCargoEquipmentWrapper setCommodities(
    Bill_Item__c objBillItem,
    CC_BOLCargoEquipmentWrapper bolCargoEquipmentWrapper
  ) {
    Boolean isFirstIteration = true;
    Boolean isDockBlank = true;
    for (Commodity__c objCommodity : objBillItem.Commodities__r) {
      if (isFirstIteration) {
        bolCargoEquipmentWrapper.commodity = objCommodity.Description__c;
        bolCargoEquipmentWrapper.commodityId = objCommodity.Id;
        isFirstIteration = false;
      }
      if (
        String.isNotBlank(objCommodity.Dock_Receipt_Number__c) && isDockBlank
      ) {
        bolCargoEquipmentWrapper.dockReceiptNumbers = new List<DockReceiptWrapper>();
        for (
          String strDockNumber : objCommodity.Dock_Receipt_Number__c.split(',')
        ) {
          if (String.isNotBlank(strDockNumber)) {
            bolCargoEquipmentWrapper.dockReceiptNumbers.add(
              new DockReceiptWrapper(strDockNumber)
            );
            isDockBlank = false;
          }
        }
      }
      HazardousCommodityWrapper hazardousCommodity = new HazardousCommodityWrapper();
      hazardousCommodity.commodityWrap.commodity = objCommodity;
      hazardousCommodity.isDeleted = false;
      hazardousCommodity.commodityId = objCommodity.Id;
      hazardousCommodity.commodityWrap.substanceDesc = objCommodity.UN_Number__c;
      bolCargoEquipmentWrapper.hazardousCommodityLst.add(hazardousCommodity);
    }
    if (isDockBlank) {
      bolCargoEquipmentWrapper.dockReceiptNumbers.add(
        new DockReceiptWrapper('')
      );
    }

    return bolCargoEquipmentWrapper;
  }

  private List<HTSNumberWrapper> setHtsWrapper(
    Bill_Item__c objBillItem,
    Boolean isForEdit,
    Map<String, String> mapScheduleNumbers
  ) {
    List<HTSNumberWrapper> lstHTSNumberWrapper = new List<HTSNumberWrapper>();
    String htsNumberKey = '';
    //get primary HTS
    if (isForEdit == true) {
      htsNumberKey =
        objBillItem.Schedule_B_Number_Type__c +
        ' ' +
        objBillItem.Schedule_B_Number__c;
    } else {
      htsNumberKey = objBillItem.Schedule_B_Number__c;
    }
    if (String.isNotBlank(htsNumberKey)) {
      lstHTSNumberWrapper.add(
        new HTSNumberWrapper(
          '',
          mapScheduleNumbers.get(htsNumberKey),
          mapScheduleNumbers.get(htsNumberKey)
        )
      );
    }

    //get secondary HTS
    if (String.isNotBlank(objBillItem.Secondary_Schedule_B_Number__c)) {
      for (String hts : objBillItem.Secondary_Schedule_B_Number__c.split(',')) {
        htsNumberKey = '';
        if (isForEdit == true) {
          htsNumberKey = hts;
        } else {
          htsNumberKey = hts.substringAfter(' ');
        }
        if (String.isNotBlank(htsNumberKey)) {
          lstHTSNumberWrapper.add(
            new HTSNumberWrapper(
              '',
              mapScheduleNumbers.get(htsNumberKey),
              mapScheduleNumbers.get(htsNumberKey)
            )
          );
        }
      }
    }

    if (lstHTSNumberWrapper.size() == 0) {
      lstHTSNumberWrapper.add(new HTSNumberWrapper('', '', ''));
    }
    return lstHTSNumberWrapper;
  }

  private Map<String, String> getHtsNumberWithDescription(
    List<Bill_Item__c> lstBillItem,
    Boolean isForEdit
  ) {
    Set<String> htsNumberSet = new Set<String>();
    Map<String, String> mapScheduleNumbers = new Map<String, String>();
    for (Bill_Item__c objBillItem : lstBillItem) {
      htsNumberSet.add(objBillItem.Schedule_B_Number__c);
      if (String.isNotBlank(objBillItem.Secondary_Schedule_B_Number__c)) {
        for (
          String hts : objBillItem.Secondary_Schedule_B_Number__c.split(',')
        ) {
          htsNumberSet.add(hts.substringAfter(' '));
        }
      }
    }

    //query HTS for description
    for (HTS_Master__c hts : CC_BOLDAO.getHTS(htsNumberSet)) {
      if (isForEdit == true) {
        mapScheduleNumbers.put(
          hts.Type__c +
          ' ' +
          hts.Name,
          hts.Type__c +
          ' ' +
          hts.Name +
          ' - ' +
          hts.Description__c
        );
      } else {
        mapScheduleNumbers.put(hts.Name, hts.Name);
      }
    }
    return mapScheduleNumbers;
  }

  private CC_BOLRouteDetailsWrapper setRoutingDetails(
    BOLEditController.BolView bolView,
    Bill_Of_Lading__c bol,
    Booking__c objOldBooking,
    Shipment__c objOldShipment,
    Boolean isForEdit
  ) {
    CC_BOLRouteDetailsWrapper routingDetails = new CC_BOLRouteDetailsWrapper();
    Bill_Of_Lading__c tempBillOfLading = new Bill_Of_Lading__c();
    tempBillOfLading = CC_BOLUtil.setLocationPointOfOrigin(
      tempBillOfLading,
      objOldBooking,
      objOldShipment
    );
    if (
      String.isNotBlank(bol.Relay_Point_Type__c) &&
      String.isNotBlank(bol.Relay_Point_Description__c) &&
      String.isNotBlank(bol.Relay_Point__c)
    ) {
      routingDetails.relayPoint = getLocationWithDescription(
        bol.Relay_Point_Type__c,
        bol.Relay_Point_Description__c,
        bol.Relay_Point__c
      );
    }
    if (isForEdit == false) {
      routingDetails.relayPoint = String.isNotBlank(
          bol.Relay_Point_Description__c
        )
        ? bol.Relay_Point_Description__c
        : bol.Relay_Point__c;
    }
    routingDetails.pointAndCountry = bol.Point_Of_Origin_Country__c; //New
    routingDetails.oldPointAndCountry = tempBillOfLading.Point_Of_Origin_Country__c; //Old

    //Map<String, Location__c> locationForCurrentLocationTypeMap = getLocationForCurrentLocationType(bol.Booking_Description__c, bol, isForEdit);
    Map<String, Location__c> locationForOldLocationTypeMap = getLocationForOldLocationType(
      objOldBooking,
      objOldShipment
    );
    //Place of receipt starts
    //Setting place of receipt for current
    //Location__c placeOfRecieptLocation = locationForCurrentLocationTypeMap.get('PLACE_OF_RECEIPT');
    String strPlaceOfReciept = getLocationWithDescription(
      bol.Place_of_Receipt_Location_Type__c,
      bol.Place_Of_Receipt_Description__c,
      bol.Place_Of_Receipt__c
    );
    if (isForEdit == false) {
      strPlaceOfReciept = String.isNotBlank(bol.Place_Of_Receipt_Description__c)
        ? bol.Place_Of_Receipt_Description__c
        : bol.Place_Of_Receipt__c;
    }
    routingDetails.placeOfReciept = strPlaceOfReciept;
    routingDetails.placeOfRecieptId = strPlaceOfReciept;
    routingDetails.placeOfRecieptSelectedItem = strPlaceOfReciept;

    //Setting place of receipt for OLD
    Location__c placeOfRecieptLocationOld = locationForOldLocationTypeMap.get(
      'PLACE_OF_RECEIPT'
    );
    String strPlaceOfRecieptOld = '';
    if (placeOfRecieptLocationOld != null) {
      strPlaceOfRecieptOld = getLocationWithDescription(
        placeOfRecieptLocationOld.Location_Type__c,
        placeOfRecieptLocationOld.Location_Name__c,
        placeOfRecieptLocationOld.Name
      );
    }
    routingDetails.oldPlaceOfReciept = strPlaceOfRecieptOld;

    //Place of receipt ends

    //Port of Loading starts

    //Setting Port of Loading for current
    //Location__c portOfLoadingLocation = locationForCurrentLocationTypeMap.get('PORT_OF_LOAD');
    String strPortOfLoading = getLocationWithDescription(
      'PORT',
      bol.Load_Port_Description__c,
      bol.Load_Port__c
    );
    if (isForEdit == false) {
      strPortOfLoading = String.isNotBlank(bol.Load_Port_Description__c)
        ? bol.Load_Port_Description__c
        : bol.Load_Port__c;
    }
    routingDetails.portOfLoading = strPortOfLoading;
    routingDetails.portOfLoadingId = strPortOfLoading;
    routingDetails.portOfLoadingSelectedItem = strPortOfLoading;

    //Setting Port of Loading for OLD
    Location__c portOfLoadingLocationOld = locationForOldLocationTypeMap.get(
      'PORT_OF_LOAD'
    );
    String strportOfLoadingOld = '';
    if (portOfLoadingLocationOld != null) {
      strportOfLoadingOld = getLocationWithDescription(
        portOfLoadingLocationOld.Location_Type__c,
        portOfLoadingLocationOld.Location_Name__c,
        portOfLoadingLocationOld.Name
      );
    }
    routingDetails.oldPortOfLoading = strportOfLoadingOld;

    //Port of Loading ends

    //Port of Discharge starts

    //Setting Port of Discharge for current
    //Location__c portOfDischargeLocation = locationForCurrentLocationTypeMap.get('PORT_OF_DISCHARGE');
    String strPortOfDischarge = getLocationWithDescription(
      'PORT',
      bol.Discharge_Port_Description__c,
      bol.Discharge_Port__c
    );
    if (isForEdit == false) {
      strPortOfDischarge = String.isNotBlank(bol.Discharge_Port_Description__c)
        ? bol.Discharge_Port_Description__c
        : bol.Discharge_Port__c;
    }
    routingDetails.portOfDischarge = strPortOfDischarge;
    routingDetails.portOfDischargeId = strPortOfDischarge;
    routingDetails.portOfDischargeSelectedItem = strPortOfDischarge;

    //Setting Port of Discharge for OLD
    Location__c portOfDischargeLocationOld = locationForOldLocationTypeMap.get(
      'PORT_OF_DISCHARGE'
    );
    String strPortOfDischargeOld = '';
    if (portOfDischargeLocationOld != null) {
      strPortOfDischargeOld = getLocationWithDescription(
        portOfDischargeLocationOld.Location_Type__c,
        portOfDischargeLocationOld.Location_Name__c,
        portOfDischargeLocationOld.Name
      );
    }
    routingDetails.oldPortOfDischarge = strPortOfDischargeOld;

    routingDetails = getRoutingVessel(routingDetails, bol.Id, objOldShipment);

    //routingDetails.relayPoint = getLocationWithDescription(bol.Relay_Point_Type__c , bol.Relay_Point_Description__c ,bol.Relay_Point__c );
    if (isForEdit == true) {
      routingDetails.loadingPier = getLocationWithDescription(
        bol.Loading_Pier_Location_Type__c,
        bol.BOL_Load_Pier_Terminal_1__c,
        bol.Loading_Pier_Location_Code__c
      );
    } else {
      routingDetails.loadingPier = String.isNotBlank(
          bol.BOL_Load_Pier_Terminal_1__c
        )
        ? bol.BOL_Load_Pier_Terminal_1__c
        : bol.Loading_Pier_Location_Code__c;
    }

    routingDetails.loadingPierSelectedItem = routingDetails.loadingPier;
    routingDetails.loadingPierId = routingDetails.loadingPier;

    routingDetails.pointAndCountry = bol.Point_Of_Origin_Country__c;

    if (isForEdit == true) {
      routingDetails.placeOfDelivery = getLocationWithDescription(
        bol.Place_of_Delivery_Location_Type__c,
        bol.Place_of_Delivery_1__c,
        bol.Place_of_Delivery_Location_Code__c
      );
    } else {
      routingDetails.placeOfDelivery = String.isNotBlank(
          bol.Place_of_Delivery_1__c
        )
        ? bol.Place_of_Delivery_1__c
        : bol.Place_of_Delivery_Location_Code__c;
    }
    routingDetails.placeOfDeliverySelectedItem = routingDetails.placeOfDelivery;
    routingDetails.placeOfDeliveryId = routingDetails.placeOfDelivery;
    //Set Old Place of Delivery
    tempBillOfLading = CC_BOLUtil.setPlaceOfDelivery(
      tempBillOfLading,
      objOldBooking,
      objOldShipment
    );
    routingDetails.oldPlaceOfDelivery = tempBillOfLading.Place_of_Delivery_1__c;

    routingDetails.originalsToBeReleasedAt = bol.Originals_to_be_Released_at__c;
    routingDetails.flag = bol.Flag__c;
    routingDetails.routingDetails = bol.Routing_Details__c;
    return routingDetails;
  }

  private CC_BOLRouteDetailsWrapper getRoutingVessel(
    CC_BOLRouteDetailsWrapper routingDetails,
    String bolId,
    Shipment__c objOldShipment
  ) {
    Map<String, String> mapVesselNameId = getVesselMap();

    for (Voyage__c voyage : [
      SELECT Id, Voyage_Number__c, Vessel_Name__c
      FROM Voyage__c
      WHERE Bill_Of_Lading_Number__c = :bolId
      ORDER BY LastModifiedDate
      LIMIT 1
    ]) {
      routingDetails.voyageNumber = voyage.Voyage_Number__c;
      routingDetails.vesselName = voyage.Vessel_Name__c;
      routingDetails.vesselNameSelectedItem = routingDetails.vesselName;
      routingDetails.vesselId = (mapVesselNameId != null &&
        mapVesselNameId.get(voyage.Vessel_Name__c) != null
        ? mapVesselNameId.get(voyage.Vessel_Name__c)
        : voyage.Vessel_Name__c);
      routingDetails.voyageId = voyage.Id;
    }
    if (objOldShipment != null) {
      for (Voyage__c voyage : [
        SELECT Id, Voyage_Number__c, Vessel_Name__c
        FROM Voyage__c
        WHERE Shipment__c = :objOldShipment.Id
        ORDER BY LastModifiedDate
        LIMIT 1
      ]) {
        routingDetails.oldVoyageNumber = voyage.Voyage_Number__c;
        routingDetails.oldVesselName = voyage.Vessel_Name__c;
        routingDetails.isOldRoute = true;
      }
    }
    return routingDetails;
  }

  private Map<String, Location__c> getLocationForOldLocationType(
    Booking__c booking,
    Shipment__c shipment
  ) {
    Set<String> locationAbbrSet = new Set<String>();
    Set<String> locationTypeSet = new Set<String>();
    Map<String, Location__c> uiOldRouteTypeToLocationMap = new Map<String, Location__c>();

    Bill_Of_Lading__c tempBillOfLading = new Bill_Of_Lading__c();
    tempBillOfLading = CC_BOLUtil.setLocationPlaceOfReceipt(
      tempBillOfLading,
      booking,
      shipment
    );

    if (
      tempBillOfLading != null &&
      String.isNotBlank(tempBillOfLading.Place_Of_Receipt__c)
    ) {
      locationAbbrSet.add(tempBillOfLading.Place_Of_Receipt__c);
    }
    // TODO :- do similar for Load_Port__c & Discharge_Port__c
    tempBillOfLading.Load_Port__c = shipment.Origin_Port__c;

    if (
      tempBillOfLading != null &&
      String.isNotBlank(tempBillOfLading.Load_Port__c)
    ) {
      locationAbbrSet.add(tempBillOfLading.Load_Port__c);
    }

    tempBillOfLading.Discharge_Port__c = shipment.Destination_Port__c;
    if (
      tempBillOfLading != null &&
      String.isNotBlank(tempBillOfLading.Discharge_Port__c)
    ) {
      locationAbbrSet.add(tempBillOfLading.Discharge_Port__c);
    }

    String placeOfReceiptLocationType = '';
    if (String.isNotBlank(booking.Description__c)) {
      placeOfReceiptLocationType = CC_BOLUtil.getLocationType(
        booking.Description__c.subString(0, 1)
      );
      locationTypeSet.add(placeOfReceiptLocationType);
    }
    locationTypeSet.add('PORT');

    //TODO - Move query to DAO
    for (Location__c objLocation : [
      SELECT Id, Name, Location_Name__c, Location_Type__c
      FROM Location__c
      WHERE Name IN :locationAbbrSet AND Location_Type__c IN :locationTypeSet
    ]) {
      if (
        String.isNotBlank(tempBillOfLading.Place_Of_Receipt__c) &&
        objLocation.Name == tempBillOfLading.Place_Of_Receipt__c &&
        objLocation.Location_Type__c == placeOfReceiptLocationType
      ) {
        uiOldRouteTypeToLocationMap.put('PLACE_OF_RECEIPT', objLocation);
      }

      if (
        String.isNotBlank(tempBillOfLading.Load_Port__c) &&
        objLocation.Name == tempBillOfLading.Load_Port__c &&
        objLocation.Location_Type__c == 'PORT'
      ) {
        uiOldRouteTypeToLocationMap.put('PORT_OF_LOAD', objLocation);
      }

      if (
        String.isNotBlank(tempBillOfLading.Discharge_Port__c) &&
        objLocation.Name == tempBillOfLading.Discharge_Port__c &&
        objLocation.Location_Type__c == 'PORT'
      ) {
        uiOldRouteTypeToLocationMap.put('PORT_OF_DISCHARGE', objLocation);
      }
    }

    return uiOldRouteTypeToLocationMap;
  }

  /* This method is not required currently, has kept if required later for any scenario later
	private Map<String, Location__c> getLocationForCurrentLocationType(String strBOLBookingDescription, Bill_Of_Lading__c billOfLading, Boolean isForEdit) {
		Set<String> locationAbbrSet = new Set<String>();
		Set<String> locationTypeSet = new Set<String>();
		Map<String, Location__c> uiRouteTypeToLocationMap = new Map<String, Location__c>();
		
		locationAbbrSet.add(billOfLading.Place_Of_Receipt__c);
		locationAbbrSet.add(billOfLading.Load_Port__c);
		locationAbbrSet.add(billOfLading.Discharge_Port__c);
		
		//For place of receipt location type
		String placeOfReceiptLocationType = '';
		if(String.isNotBlank(billOfLading.Booking_Description__c)) {
			placeOfReceiptLocationType = CC_BOLUtil.getLocationType(billOfLading.Booking_Description__c.subString(0,1));
			locationTypeSet.add(placeOfReceiptLocationType);
		} else if(isForEdit == false && String.isNotBlank(billOfLading.Booking_Number__r.Description__c)) {
			billOfLading.Booking_Description__c = billOfLading.Booking_Number__r.Description__c;
			placeOfReceiptLocationType = CC_BOLUtil.getLocationType(billOfLading.Booking_Description__c.subString(0,1));
			locationTypeSet.add(placeOfReceiptLocationType);
		}
		locationTypeSet.add('PORT');
		
		//TODO - Move query to DAO
		for(Location__c objLocation : [Select Id, Name, Location_Name__c, Location_Type__c FROM Location__c WHERE Name IN :locationAbbrSet AND Location_Type__c IN :locationTypeSet]) {
			if(String.isNotBlank(billOfLading.Place_Of_Receipt__c) && objLocation.Name == billOfLading.Place_Of_Receipt__c && objLocation.Location_Type__c == placeOfReceiptLocationType) {
				uiRouteTypeToLocationMap.put('PLACE_OF_RECEIPT', objLocation);
			}
			
			if(String.isNotBlank(billOfLading.Load_Port__c) && objLocation.Name == billOfLading.Load_Port__c && objLocation.Location_Type__c == 'PORT') {
				uiRouteTypeToLocationMap.put('PORT_OF_LOAD', objLocation);
			}
			
			if(String.isNotBlank(billOfLading.Discharge_Port__c) && objLocation.Name == billOfLading.Discharge_Port__c && objLocation.Location_Type__c == 'PORT') {
				uiRouteTypeToLocationMap.put('PORT_OF_DISCHARGE', objLocation);
			}
		}
		
		return uiRouteTypeToLocationMap;
	}
	*/
  private String getLocationWithDescription(
    String locType,
    String description,
    String abbr
  ) {
    String locationWithDescription = '';
    if (
      String.isNotBlank(locType) &&
      String.isNotBlank(description) &&
      String.isNotBlank(abbr)
    ) {
      locationWithDescription =
        locType +
        ' - ' +
        description +
        ' (' +
        abbr +
        ')';
    }
    return locationWithDescription;
  }

  private BOLEditController.BolView setParty(
    BOLEditController.BolView bolView,
    Bill_Of_Lading__c bol,
    Boolean isForEdit
  ) {
    List<CC_BolPartyWrapper> forwarderLst = new List<CC_BolPartyWrapper>();
    List<CC_BolPartyWrapper> consigneeLst = new List<CC_BolPartyWrapper>();
    List<CC_BolPartyWrapper> shipperLst = new List<CC_BolPartyWrapper>();
    List<CC_BolPartyWrapper> notifyPartyLst = new List<CC_BolPartyWrapper>();
    List<CC_BolPartyWrapper> alsoNotifyPartyLst = new List<CC_BolPartyWrapper>();

    for (Party__c party : CC_BOLDAO.getBolParty(bol.Id)) {
      CC_BolPartyWrapper newUiParty = new CC_BolPartyWrapper();
      //Get data for compare
      if (String.isNotBlank(party.Booking_Party__r.Id)) {
        newUiParty.bookingPartyId = party.Booking_Party__r.Id;
        newUiParty.bookingPartyName = party.Booking_Party__r.Name;
        newUiParty.bookingPartyAddressLine1 = party.Booking_Party__r.Address_Line1__c;
        newUiParty.bookingPartyAddressLine2 = party.Booking_Party__r.Address_Line2__c;
        newUiParty.bookingPartyAddressLine3 = party.Booking_Party__r.Address_Line3__c;
        newUiParty.bookingPartyAddressLine4 = party.Booking_Party__r.Address_Line4__c;
        newUiParty.bookingPartyPhone = party.Booking_Party__r.Phone_Number__c;
        newUiParty.bookingPartyEmail = party.Booking_Party__r.Email_Address__c;
        newUiParty.bookingPartyTaxIdNumber = party.Booking_Party__r.Tax_ID__c;
        newUiParty.bookingFMCNumber = party.Booking_Party__r.FMC__c;
        newUiParty.bookingCHBNumber = party.Booking_Party__r.CHB_Number__c !=
          null
          ? String.valueOf(party.Booking_Party__r.CHB_Number__c)
          : '';
      }

      //Set party data
      newUiParty.partyId = party.Id;
      newUiParty.name = party.Name;
      newUiParty.addressLine1 = party.Address_Line1__c;
      newUiParty.addressLine2 = party.Address_Line2__c;
      newUiParty.addressLine3 = party.Address_Line3__c;
      newUiParty.addressLine4 = party.Address_Line4__c;
      newUiParty.email = party.Email_Address__c;
      newUiParty.phone = party.Phone_Number__c;
      newUiParty.partyType = party.Type__c;

      //Set reference number
      if (String.isNotBlank(party.Reference_Number__c)) {
        newUiParty.referenceNumber.addAll(party.Reference_Number__c.split(','));
        for (String strRefNum : party.Reference_Number__c.split(',')) {
          ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
          objReferenceNumberWrapper.strRefNumber = strRefNum;
          newUiParty.referenceNumbers.add(objReferenceNumberWrapper);
        }
      } else if (newUiParty.referenceNumbers.size() == 0) {
        //If no reference number then set blank in wrapper
        ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
        objReferenceNumberWrapper.strRefNumber = '';
        newUiParty.referenceNumbers.add(objReferenceNumberWrapper);
      }

      //Put party in specific list based on party type
      if (String.isNotBlank(party.Type__c)) {
        if (party.Type__c.containsIgnoreCase('SHP') && shipperLst.size() < 1) {
          shipperLst.add(newUiParty);
        } else if (party.Type__c.containsIgnoreCase('NOT')) {
          notifyPartyLst.add(newUiParty);
        } else if (party.Type__c.containsIgnoreCase('NO2')) {
          alsoNotifyPartyLst.add(newUiParty);
        } else if (
          party.Type__c.containsIgnoreCase('CON') && consigneeLst.size() < 1
        ) {
          //Set consignee specific fields
          newUiParty.destinationTaxIdType = party.Destination_Tax_Id_Type__c;
          newUiParty.destinationTaxIdNumber = party.Destination_Tax_Id_Number__c;
          newUiParty.registrationId = party.Registration_Id__c;
          newUiParty.taxIdNumber = bol.Tax_Identification_Number__c;
          newUiParty.EINSSNumber = party.EIN_Reference_Number__c;
          consigneeLst.add(newUiParty);
        } else if (party.Type__c.containsIgnoreCase('FOR')) {
          //Set consignee specific fields
          newUiParty.CHBNumber = party.CHB_Number__c != null
            ? String.valueOf(party.CHB_Number__c)
            : '';
          newUiParty.FMCNumber = party.FMC__c;
          newUiParty.isDeleted = false;
          forwarderLst.add(newUiParty);
        }
      }
    }

    //Set the party type blank in wrapper if there is no party for a type
    if (forwarderLst.size() == 0 && isForEdit != true) {
      CC_BolPartyWrapper blankParty = new CC_BolPartyWrapper();
      ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
      objReferenceNumberWrapper.strRefNumber = '';
      blankParty.referenceNumbers.add(objReferenceNumberWrapper);
      blankParty.partyType = 'FOR';
      forwarderLst.add(blankParty);
    }
    if (consigneeLst.size() == 0) {
      CC_BolPartyWrapper blankParty = new CC_BolPartyWrapper();
      ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
      objReferenceNumberWrapper.strRefNumber = '';
      blankParty.referenceNumbers.add(objReferenceNumberWrapper);
      blankParty.partyType = 'CON';
      consigneeLst.add(blankParty);
    }
    if (alsoNotifyPartyLst.size() == 0 && isForEdit != true) {
      CC_BolPartyWrapper blankParty = new CC_BolPartyWrapper();
      ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
      objReferenceNumberWrapper.strRefNumber = '';
      blankParty.referenceNumbers.add(objReferenceNumberWrapper);
      blankParty.partyType = 'NO2';
      alsoNotifyPartyLst.add(blankParty);
    }
    if (notifyPartyLst.size() == 0 && isForEdit != true) {
      CC_BolPartyWrapper blankParty = new CC_BolPartyWrapper();
      ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
      objReferenceNumberWrapper.strRefNumber = '';
      blankParty.referenceNumbers.add(objReferenceNumberWrapper);
      blankParty.partyType = 'NOT';
      notifyPartyLst.add(blankParty);
    }
    if (shipperLst.size() == 0) {
      CC_BolPartyWrapper blankParty = new CC_BolPartyWrapper();
      ReferenceNumberWrapper objReferenceNumberWrapper = new ReferenceNumberWrapper();
      objReferenceNumberWrapper.strRefNumber = '';
      blankParty.referenceNumbers.add(objReferenceNumberWrapper);
      blankParty.partyType = 'SHP';
      shipperLst.add(blankParty);
    }

    bolView.alsoNotifyPartyLst = alsoNotifyPartyLst;
    bolView.notifyPartyLst = notifyPartyLst;
    bolView.forwarderLst = forwarderLst;
    bolView.shipperLst = shipperLst;
    bolView.consigneeLst = consigneeLst;

    return bolView;
  }

  private BOLEditController.BolView setBolCustomerReferenceWrapper(
    BOLEditController.BolView bolView,
    Bill_Of_Lading__c bol,
    Booking__c objOldBooking,
    Shipment__c objOldShipment
  ) {
    CC_BolCustomerReferenceWrapper customerReference = new CC_BolCustomerReferenceWrapper();
    customerReference.bookingNumber = (bol.Booking_Number__r.Booking_Number__c !=
      null
      ? bol.Booking_Number__r.Booking_Number__c
      : bol.Booking_Reference_Number__c);

    customerReference.contractNumber = bol.Contract_Number__c;
    customerReference.oldContractNumber = objOldBooking.Contract_Number__c;
    customerReference.exemptionClause = bol.SED_Exemption_Code__c;
    customerReference.oldExemptionClause = objOldShipment.Exempt_Code__c;
    bolView.emergencyContactPhone = bol.Hazardous_Emergency_Phone_Number_1__c;
    bolView.emergencyHazContactPhone = bol.Hazardous_Emergency_Phone_Number_2__c;
    bolView.emergencyContactName = bol.Hazardous_Emergency_Contact__c;
    customerReference.cargoAvailableForTransportDate = bol.Cargo_Available_for_Transport__c;
    customerReference.sentDate = bol.Customer_Send_Date__c;
    customerReference.eeiSupport = bol.EEI_Preparation_Support_Required__c;
    customerReference.scacCode = bol.SCAC_Code__c;
    customerReference.billOfLadingNumber = bol.Bill_Of_Lading_Number__c;
    customerReference.bolStatus = bol.Bill_of_lading_Status__c;
    customerReference.einNumber = bol.EIN_Reference_Number__c;
    customerReference.exemptionClause = bol.SED_Exemption_Code__c;
    customerReference.option4Date = bol.SED_Exception_OPT4__c;

    //Map ITN starts
    if (String.isNotBlank(bol.ITN_Number__c)) {
      //customerReference.itnNumberLst.add(bol.ITN_Number__c);
      ITNNumberWrapper objITNNumberWrapper = new ITNNumberWrapper();
      objITNNumberWrapper.strItnNumber = bol.ITN_Number__c;
      customerReference.itnNumberLst.add(objITNNumberWrapper);
    }

    //Map ITN secondary
    if (String.isNotBlank(bol.Secoundry_ITN_Number__c)) {
      //customerReference.itnNumberLst.addAll(bol.Secoundry_ITN_Number__c.split(','));
      for (String strItn : bol.Secoundry_ITN_Number__c.split(',')) {
        ITNNumberWrapper objITNNumberWrapper = new ITNNumberWrapper();
        objITNNumberWrapper.strItnNumber = strItn;
        customerReference.itnNumberLst.add(objITNNumberWrapper);
      }
    }

    //If no ITN then add blank entry in the wrapper
    if (
      customerReference.itnNumberLst != null &&
      customerReference.itnNumberLst.size() == 0
    ) {
      ITNNumberWrapper objITNNumberWrapper = new ITNNumberWrapper();
      objITNNumberWrapper.strItnNumber = '';
      customerReference.itnNumberLst.add(objITNNumberWrapper);
    }
    //Map ITN ends

    //Inbond mapping starts
    Map<String, String> inboundTypeFieldMap = getInboundTypeFieldMap();
    Boolean isInboundBlank = true;
    for (String inboundType : inboundTypeFieldMap.keySet()) {
      String fieldName = inboundTypeFieldMap.get(inboundType);
      if (bol.get(fieldName) != null) {
        isInboundBlank = false;
        String reference = String.valueOf(bol.get(fieldName));
        for (String currReference : reference.split(',')) {
          customerReference.inbondList.add(
            new CC_BolCustomerReferenceWrapper.Inbond(
              inboundType,
              currReference
            )
          );
        }
      }
    }

    // Set blank if Inbond is blank
    if (isInboundBlank) {
      customerReference.inbondList.add(
        new CC_BolCustomerReferenceWrapper.Inbond('IT', '')
      );
    }
    //Inbond mapping ends

    //Party reference number mapping starts
    Map<String, String> partyTypeFieldMap = getPartyTypeFieldMap();
    Boolean isPartyBlank = true;
    for (String partyType : partyTypeFieldMap.keySet()) {
      String fieldName = partyTypeFieldMap.get(partyType);
      if (bol.get(fieldName) != null) {
        isPartyBlank = false;
        String reference = String.valueOf(bol.get(fieldName));
        if (String.isNotBlank(reference)) {
          for (String currReference : reference.split(',')) {
            customerReference.partyList.add(
              new CC_BolCustomerReferenceWrapper.CustomerParty(
                partyType,
                currReference
              )
            );
          }
        }
      }
    }
    // set blank if no party reference number
    if (isPartyBlank) {
      customerReference.partyList.add(
        new CC_BolCustomerReferenceWrapper.CustomerParty('CON', '')
      );
    }

    bolView.customerReference = customerReference;

    return bolView;
  }

  private Map<String, String> getInboundTypeFieldMap() {
    Map<String, String> custInboundTypeFieldMap = new Map<String, String>();
    custInboundTypeFieldMap.put('IE', 'IE_Inbound_Number__c');
    custInboundTypeFieldMap.put('WI', 'WI_Inbound_Number__c');
    custInboundTypeFieldMap.put('WT', 'WT_Inbound_Number__c');
    custInboundTypeFieldMap.put('IT', 'IT_Inbound_Number__c');
    custInboundTypeFieldMap.put('TE', 'TE_Inbound_Number__c');
    return custInboundTypeFieldMap;
  }

  private Map<String, String> getPartyTypeFieldMap() {
    Map<String, String> custPartyTypeFieldMap = new Map<String, String>();
    custPartyTypeFieldMap.put('CON', 'Consignee_Reference_Number__c');
    custPartyTypeFieldMap.put('CUST', 'Customer_Billing_Reference_Number__c');
    custPartyTypeFieldMap.put('FOR', 'Forwarder_Reference_Number__c');
    custPartyTypeFieldMap.put('SHP', 'Shipper_Reference_Number__c');
    custPartyTypeFieldMap.put('NO2', 'Also_Notify_Reference_Number__c');
    custPartyTypeFieldMap.put('NOT', 'Notify_Reference_Number__c');
    custPartyTypeFieldMap.put('CNB', 'CNB_Reference_Number__c');
    custPartyTypeFieldMap.put('FPT', 'FPT_Reference_Number__c');
    custPartyTypeFieldMap.put('3RD', 'X3RD_Reference_Number__c');
    custPartyTypeFieldMap.put('OTH', 'Other_Party_Reference_Number__c');
    return custPartyTypeFieldMap;
  }

  /**
   * @Purpose :   This method retruen map of cics equipment code to its description or name.
   * @Param   :   isForEdit - This specified whether this data is requird for edit or read purpose.
   *
   * @Returns :   Map<String, String> - Return map of cics equipment code to its description or name.
   */
  private Map<String, String> getEquipmentSizeTypeMap(Boolean isForEdit) {
    Map<String, String> strEquipmentMap = new Map<String, String>();
    for (Container__c objContainer : [
      SELECT Id, Name, CICS_ISO_Code__c, Description__c, CICS_EQ_Types__c
      FROM Container__c
    ]) {
      if (String.isNotBlank(objContainer.CICS_EQ_Types__c)) {
        for (
          String strCICSEquipCode : objContainer.CICS_EQ_Types__c.split(',')
        ) {
          if (isForEdit) {
            strEquipmentMap.put(strCICSEquipCode, objContainer.Name);
          } else {
            strEquipmentMap.put(strCICSEquipCode, objContainer.Description__c);
          }
        }
      }
      if (isForEdit) {
        strEquipmentMap.put(objContainer.Name, objContainer.Name);
      } else {
        strEquipmentMap.put(objContainer.Name, objContainer.Description__c);
      }
    }

    return strEquipmentMap;
  }
}
