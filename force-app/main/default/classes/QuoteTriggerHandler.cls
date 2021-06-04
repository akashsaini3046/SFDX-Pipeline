public without sharing class QuoteTriggerHandler extends TriggerHandler {
  private static Boolean recursionVarBeforeInsert = true;
  private static Boolean recursionVarAfterInsert = true;
  private static Boolean recursionVarBeforeUpdate = true;
  private static Boolean recursionVarAfterUpdate = true;
  private static Boolean recursionVarBeforeDelete = true;
  private static Boolean recursionVarAfterDelete = true;
  private static Boolean Flag = true;
  private static Boolean recflag;
  List<Quote__c> newQuoteList;
  List<Quote__c> oldQuoteList;
  Map<Id, Quote__c> newQuoteMap;
  Map<Id, Quote__c> oldQuoteMap;

  public QuoteTriggerHandler() {
    this.newQuoteList = (List<Quote__c>) Trigger.new;
    this.oldQuoteList = (List<Quote__c>) Trigger.old;
    this.newQuoteMap = (Map<Id, Quote__c>) Trigger.newMap;
    this.oldQuoteMap = (Map<Id, Quote__c>) Trigger.oldMap;
  }

  public override void beforeInsert() {
    if (recursionVarBeforeInsert) {
      recursionVarBeforeInsert = false;
    }
  }

  public override void afterInsert() {
    if (recursionVarAfterInsert) {
      recursionVarAfterInsert = false;
    }
  }

  public override void beforeUpdate() {
    if (recursionVarBeforeUpdate) {
      recursionVarBeforeUpdate = false;
      createPricingRateIssueCase(newQuoteList);
    }
  }

  public override void afterUpdate() {
    if (recursionVarAfterUpdate) {
      recursionVarAfterUpdate = false;
    }
  }

  public override void beforeDelete() {
    if (recursionVarBeforeDelete) {
      recursionVarBeforeDelete = false;
    }
  }

  public override void afterDelete() {
    if (recursionVarAfterDelete) {
      recursionVarAfterDelete = false;
    }
  }

  public static void createPricingRateIssueCase(List<Quote__c> newQuoteList) {
    List<Quote__c> listQuotes = new List<Quote__c>();
    Set<String> CustomerEmails = new Set<String>();
    Set<Id> setQuoteIds = new Set<Id>();
    Set<Id> setEquipFDIds = new Set<Id>();
    List<FreightDetail__c> freightDetails = new List<FreightDetail__c>();
    List<Requirement__c> Requirements = new List<Requirement__c>();
    Map<Id, List<FreightDetail__c>> QuoteFDMap = new Map<Id, List<FreightDetail__c>>();
    Map<Id, List<Requirement__c>> FDRequirementMap = new Map<Id, List<Requirement__c>>();
    Map<String, Contact> ContactEmailMap = new Map<String, Contact>();
    List<Case> newPricingCases = new List<Case>();
    List<Contact> contacts = new List<Contact>();
    RecordType caseRecordType = new RecordType();
    Group PricingQueue = new Group();

    List<Open_Tariff_Commodities__mdt> openTariffCommoditiesList = new List<Open_Tariff_Commodities__mdt>();
    Map<String, String> commodityCodeNameMap = new Map<String, String>();
    openTariffCommoditiesList = CustomMetadataTypeDAO.getOpenTariffCommodities();
    for (Open_Tariff_Commodities__mdt OTCobj : openTariffCommoditiesList) {
      if (
        commodityCodeNameMap.isEmpty() ||
        !commodityCodeNameMap.containsKey(OTCobj.Commodity_Code__c)
      ) {
        commodityCodeNameMap.put(
          OTCobj.Commodity_Code__c,
          OTCobj.Commodity_Name__c
        );
      }
    }

    List<Container__c> listContainers = [
      SELECT
        Id,
        Name,
        CICS_ISO_Code__c,
        Description__c,
        EBR__c,
        Genset_Type__c,
        Genset__c,
        Group__c,
        Handle_As__c,
        Height__c,
        Hide__c,
        Reefer__c,
        Size__c,
        Softship_ISO_Code__c,
        Tare__c,
        Type__c,
        Width__c,
        Used_For__c
      FROM Container__c
      ORDER BY NAME ASC
    ];
    Map<String, String> containerNameDescMap = new Map<String, String>();
    for (Container__c contVar : listContainers) {
      if (
        containerNameDescMap.isEmpty() ||
        !containerNameDescMap.containsKey(contVar.Name)
      ) {
        containerNameDescMap.put(contVar.Name, contVar.Description__c);
      }
    }

    for (Quote__c quoteobj : newQuoteList) {
      if (
        quoteobj.Status__c == CC_Constants.QUOTE_STATUS &&
        quoteobj.Pricing_Case_Created__c == false
      ) {
        listQuotes.add(quoteobj);
        setQuoteIds.add(quoteobj.Id);
        if (
          !String.isEmpty(quoteobj.Customer_Email__c) &&
          !String.isBlank(quoteobj.Customer_Email__c) &&
          !quoteobj.Customer_Email__c.contains('crowley')
        ) {
          CustomerEmails.add(quoteobj.Customer_Email__c);
        }
      }
    }
    if (CustomerEmails.size() > 0) {
      contacts = ContactDAO.getContactsByEmails(CustomerEmails);
    }
    if (contacts.size() > 0) {
      for (Contact con : contacts) {
        if (
          ContactEmailMap.isEmpty() || !ContactEmailMap.containsKey(con.Email)
        ) {
          ContactEmailMap.put(con.Email, con);
        }
      }
    }
    if (setQuoteIds.size() > 0) {
      freightDetails = QuoteDAO.getFreightDetailsByQuoteIds(setQuoteIds);
      caseRecordType = [
        SELECT Id, DeveloperName
        FROM RecordType
        WHERE DeveloperName = :CC_Constants.PRICING_RECORDTYPE
      ];
      PricingQueue = [
        SELECT Id, DeveloperName
        FROM Group
        WHERE DeveloperName = :CC_Constants.PRICING_QUEUE
      ];
    }
    for (FreightDetail__c fdVar : freightDetails) {
      if (fdVar.Cargo_Type__c == CC_Constants.EQUIP_STRING) {
        setEquipFDIds.add(fdVar.Id);
      }
      if (
        QuoteFDMap.isEmpty() ||
        !QuoteFDMap.containsKey(fdVar.Shipment__r.Quote__c)
      ) {
        QuoteFDMap.put(
          fdVar.Shipment__r.Quote__c,
          new List<FreightDetail__c>{ fdVar }
        );
      } else if (QuoteFDMap.containsKey(fdVar.Shipment__r.Quote__c)) {
        List<FreightDetail__c> listFDs = new List<FreightDetail__c>();
        listFDs = QuoteFDMap.get(fdVar.Shipment__r.Quote__c);
        listFDs.add(fdVar);
        QuoteFDMap.put(fdVar.Shipment__r.Quote__c, listFDs);
      }
    }
    if (setEquipFDIds.size() > 0) {
      Requirements = QuoteDAO.getRequirementByFreightDetailIds(setEquipFDIds);
    }
    for (Requirement__c reqVar : Requirements) {
      if (
        reqVar.Commodity_Code__c != null &&
        commodityCodeNameMap.containsKey(reqVar.Commodity_Code__c)
      ) {
        reqVar.Category__c = commodityCodeNameMap.get(reqVar.Commodity_Code__c);
      }
      if (
        reqVar.Container_Code__c != null &&
        containerNameDescMap.containsKey(reqVar.Container_Code__c)
      ) {
        reqVar.Container_Type__c = containerNameDescMap.get(
          reqVar.Container_Code__c
        );
      }
      if (
        FDRequirementMap.isEmpty() ||
        !FDRequirementMap.containsKey(reqVar.Freight__c)
      ) {
        FDRequirementMap.put(
          reqVar.Freight__c,
          new List<Requirement__c>{ reqVar }
        );
      } else if (FDRequirementMap.containsKey(reqVar.Freight__c)) {
        List<Requirement__c> listReqs = new List<Requirement__c>();
        listReqs = FDRequirementMap.get(reqVar.Freight__c);
        listReqs.add(reqVar);
        FDRequirementMap.put(reqVar.Freight__c, listReqs);
      }
    }
    for (Quote__c quoteobj : listQuotes) {
      if (quoteobj.Pricing_Case_Created__c == false) {
        quoteobj.Pricing_Case_Created__c = true;
        List<FreightDetail__c> ListfreightDetails = new List<FreightDetail__c>();
        if (!QuoteFDMap.isEmpty() && QuoteFDMap.containsKey(quoteobj.Id)) {
          ListfreightDetails = QuoteFDMap.get(quoteobj.Id);
        }
        Case newCase = populateCaseDescription(
          quoteobj,
          ListfreightDetails,
          FDRequirementMap
        );
        newCase.RecordTypeId = caseRecordType.Id;
        newCase.Subject = CC_Constants.PRICING_SUBJECT + ' : ' + quoteobj.Name;
        newCase.Origin = CC_Constants.PRICING_ORIGIN;
        newCase.Status = CC_Constants.PRICING_STATUS;
        newCase.Pricing_Type__c = CC_Constants.PRICING_TYPE;
        newCase.Priority = CC_Constants.PRIORITY;
        newCase.Assignee_Pricing_Location__c = CC_Constants.PRICING_SERVICELOCATION;
        newCase.OwnerId = PricingQueue.Id;
        newCase.Quote__c = quoteobj.Id;
        if (
          (quoteobj.Customer_Email__c != null ||
          quoteobj.Customer_Email__c != '') &&
          ContactEmailMap.containsKey(quoteobj.Customer_Email__c) &&
          !ContactEmailMap.isEmpty()
        ) {
          newCase.ContactId = ContactEmailMap.get(quoteobj.Customer_Email__c)
            .Id;
        }
        if (
          (quoteobj.Customer_Email__c != null ||
          quoteobj.Customer_Email__c != '')
        ) {
          newCase.SuppliedEmail = quoteobj.Customer_Email__c;
        }
        if (
          (quoteobj.Contact_Number__c != null ||
          quoteobj.Contact_Number__c != '')
        ) {
          newCase.SuppliedPhone = quoteobj.Contact_Number__c;
        }
        if (
          (quoteobj.Contact_Name__c != null ||
          quoteobj.Contact_Name__c != '')
        ) {
          newCase.SuppliedName = quoteobj.Contact_Name__c;
        }
        if (
          (quoteobj.Company_Name__c != null ||
          quoteobj.Company_Name__c != '')
        ) {
          newCase.SuppliedCompany = quoteobj.Company_Name__c;
        }
        newPricingCases.add(newCase);
      }
    }
    if (!newPricingCases.isEmpty() && newPricingCases.Size() > 0) {
      insert newPricingCases;
    }
  }

  private static Case populateCaseDescription(
    Quote__c quote,
    List<FreightDetail__c> freightDetails,
    Map<Id, List<Requirement__c>> FDRequirementMap
  ) {
    Case newCase = new Case();
    List<Requirement__c> ListReqs = new List<Requirement__c>();
    String CargoDescription = '', Origin = '', Destination = '';
    String date1 = quote.Ready_Date__c != null
      ? String.valueOf(quote.Ready_Date__c)
      : '';
    String readyDate = CC_Constants.READY_DATE + ' : ' + date1 + '\n';
    String additionalInfo = quote.Additional_Information__c != null
      ? quote.Additional_Information__c
      : '';
    String ishazardous = quote.Is_Hazardous__c
      ? CC_Constants.YES
      : CC_Constants.NO;
    String hazardousValue =
      CC_Constants.ISHAZARDOUS +
      ' : ' +
      ishazardous +
      '\n';
    String majlength, minlength, majwidth, minwidth, majheight, minheight;
    Integer i;
    if (quote.Description__c != null && quote.Description__c != '') {
      if (
        quote.Description__c.contains(CC_Constants.PORT_TO_PORT) ||
        quote.Description__c.contains(CC_Constants.RAIL_TO_PORT) ||
        quote.Description__c.contains(CC_Constants.PORT_TO_RAIL) ||
        quote.Description__c.contains(CC_Constants.RAIL_TO_RAIL)
      ) {
        String OriginRailorPort = quote.Description__c.contains(
            CC_Constants.PORT_TO_PORT
          ) || quote.Description__c.contains(CC_Constants.PORT_TO_RAIL)
          ? CC_Constants.ORIGIN_PORT
          : CC_Constants.ORIGIN_RAIL;
        String originCode = quote.Customer_Origin_Code__c != null
          ? quote.Customer_Origin_Code__c
          : '';
        String oCity = quote.Customer_Origin_City__c != null
          ? quote.Customer_Origin_City__c + ', '
          : '';
        String oState = quote.Customer_Origin_State__c != null
          ? quote.Customer_Origin_State__c + ', '
          : '';
        String oCountry = quote.Customer_Origin_Country__c != null
          ? quote.Customer_Origin_Country__c + ', '
          : '';
        String oStateValue = showState(quote.Customer_Origin_Country__c)
          ? oState
          : '';
        Origin =
          OriginRailorPort +
          ' : ' +
          oCity +
          oStateValue +
          oCountry +
          Origincode +
          '\n';
        String DestRailorPort = quote.Description__c.contains(
            CC_Constants.PORT_TO_PORT
          ) || quote.Description__c.contains(CC_Constants.RAIL_TO_PORT)
          ? CC_Constants.DESTINATION_PORT
          : CC_Constants.DESTINATION_RAIL;
        String destCode = quote.Customer_Destination_Code__c != null
          ? quote.Customer_Destination_Code__c
          : '';
        String dCity = quote.Customer_Destination_City__c != null
          ? quote.Customer_Destination_City__c + ', '
          : '';
        String dState = quote.Customer_Destination_State__c != null
          ? quote.Customer_Destination_State__c + ', '
          : '';
        String dCountry = quote.Customer_Destination_Country__c != null
          ? quote.Customer_Destination_Country__c + ', '
          : '';
        String dStateValue = showState(quote.Customer_Destination_Country__c)
          ? dState
          : '';
        Destination =
          DestRailorPort +
          ' : ' +
          dCity +
          dStateValue +
          dCountry +
          destCode +
          '\n';
      } else if (quote.Description__c.contains(CC_Constants.DOOR_TO_DOOR)) {
        String oCity = quote.Customer_Origin_City__c != null
          ? quote.Customer_Origin_City__c + ', '
          : '';
        String oState = quote.Customer_Origin_State__c != null
          ? quote.Customer_Origin_State__c + ', '
          : '';
        String oCountry = quote.Customer_Origin_Country__c != null
          ? quote.Customer_Origin_Country__c + ', '
          : '';
        String oStateValue = showState(quote.Customer_Origin_Country__c)
          ? oState
          : '';
        String oZip = quote.Customer_Origin_Zip__c != null
          ? quote.Customer_Origin_Zip__c
          : '';
        Origin =
          CC_Constants.ORIGIN +
          ' : ' +
          oCity +
          oStateValue +
          oCountry +
          oZip +
          '\n';
        String dCity = quote.Customer_Destination_City__c != null
          ? quote.Customer_Destination_City__c + ', '
          : '';
        String dState = quote.Customer_Destination_State__c != null
          ? quote.Customer_Destination_State__c + ', '
          : '';
        String dCountry = quote.Customer_Destination_Country__c != null
          ? quote.Customer_Destination_Country__c + ', '
          : '';
        String dStateValue = showState(quote.Customer_Destination_Country__c)
          ? dState
          : '';
        String dZip = quote.Customer_Destination_Zip__c != null
          ? quote.Customer_Destination_Zip__c
          : '';
        Destination =
          CC_Constants.DESTINATION +
          ' : ' +
          dCity +
          dStateValue +
          dCountry +
          dZip +
          '\n';
      } else if (
        quote.Description__c.contains(CC_Constants.DOOR_TO_PORT) ||
        quote.Description__c.contains(CC_Constants.DOOR_TO_RAIL)
      ) {
        String oCity = quote.Customer_Origin_City__c != null
          ? quote.Customer_Origin_City__c
          : '';
        String oState = quote.Customer_Origin_State__c != null
          ? quote.Customer_Origin_State__c
          : '';
        String oCountry = quote.Customer_Origin_Country__c != null
          ? quote.Customer_Origin_Country__c
          : '';
        String oStateValue = showState(quote.Customer_Origin_Country__c)
          ? oState
          : '';
        String oZip = quote.Customer_Origin_Zip__c != null
          ? quote.Customer_Origin_Zip__c
          : '';
        Origin =
          CC_Constants.ORIGIN +
          ' : ' +
          oCity +
          oStateValue +
          oCountry +
          oZip +
          '\n';
        String DestRailorPort = quote.Description__c.contains(
            CC_Constants.PORT_TO_PORT
          ) || quote.Description__c.contains(CC_Constants.RAIL_TO_PORT)
          ? CC_Constants.DESTINATION_PORT
          : CC_Constants.DESTINATION_RAIL;
        String destCode = quote.Customer_Destination_Code__c != null
          ? quote.Customer_Destination_Code__c
          : '';
        String dCity = quote.Customer_Destination_City__c != null
          ? quote.Customer_Destination_City__c + ', '
          : '';
        String dState = quote.Customer_Destination_State__c != null
          ? quote.Customer_Destination_State__c + ', '
          : '';
        String dCountry = quote.Customer_Destination_Country__c != null
          ? quote.Customer_Destination_Country__c + ', '
          : '';
        String dStateValue = showState(quote.Customer_Destination_Country__c)
          ? dState
          : '';
        Destination =
          DestRailorPort +
          ' : ' +
          dCity +
          dStateValue +
          dCountry +
          destCode +
          '\n';
      } else if (
        quote.Description__c.contains(CC_Constants.PORT_TO_DOOR) ||
        quote.Description__c.contains(CC_Constants.RAIL_TO_DOOR)
      ) {
        String OriginRailorPort = quote.Description__c.contains(
            CC_Constants.PORT_TO_PORT
          ) || quote.Description__c.contains(CC_Constants.PORT_TO_RAIL)
          ? CC_Constants.ORIGIN_PORT
          : CC_Constants.ORIGIN_RAIL;
        String originCode = quote.Customer_Origin_Code__c != null
          ? quote.Customer_Origin_Code__c
          : '';
        String oCity = quote.Customer_Origin_City__c != null
          ? quote.Customer_Origin_City__c + ', '
          : '';
        String oState = quote.Customer_Origin_State__c != null
          ? quote.Customer_Origin_State__c + ', '
          : '';
        String oCountry = quote.Customer_Origin_Country__c != null
          ? quote.Customer_Origin_Country__c + ', '
          : '';
        String oStateValue = showState(quote.Customer_Origin_Country__c)
          ? oState
          : '';
        Origin =
          OriginRailorPort +
          ' : ' +
          oCity +
          oStateValue +
          oCountry +
          Origincode +
          '\n';
        String dCity = quote.Customer_Destination_City__c != null
          ? quote.Customer_Destination_City__c + ', '
          : '';
        String dState = quote.Customer_Destination_State__c != null
          ? quote.Customer_Destination_State__c + ', '
          : '';
        String dCountry = quote.Customer_Destination_Country__c != null
          ? quote.Customer_Destination_Country__c + ', '
          : '';
        String dStateValue = showState(quote.Customer_Destination_Country__c)
          ? dState
          : '';
        String dZip = quote.Customer_Destination_Zip__c != null
          ? quote.Customer_Destination_Zip__c
          : '';
        Destination =
          CC_Constants.DESTINATION +
          ' : ' +
          dCity +
          dStateValue +
          dCountry +
          dZip +
          '\n';
      }
    }
    if (freightDetails.size() > 0) {
      i = 0;
      for (FreightDetail__c fdVar : freightDetails) {
        i++;
        if (fdVar.Cargo_Type__c != null) {
          String weight = fdVar.Declared_Weight_Value__c != null
            ? String.valueOf(fdVar.Declared_Weight_Value__c)
            : '';
          String quantity = fdVar.Package_Quantity__c != null
            ? String.valueOf(fdVar.Package_Quantity__c)
            : '';
          String lengthUnits = fdVar.Declared_Weights_Unit_of_Measure__c !=
            null &&
            fdVar.Length__c != null
            ? fdVar.Declared_Weights_Unit_of_Measure__c ==
                CC_Constants.LB_STRING
                ? CC_Constants.FT_STRING
                : CC_Constants.M_STRING
            : '';
          String WeightUnits = fdVar.Declared_Weights_Unit_of_Measure__c !=
            null &&
            fdVar.Declared_Weight_Value__c != null
            ? fdVar.Declared_Weights_Unit_of_Measure__c
            : '';
          if (lengthUnits == CC_Constants.FT_STRING) {
            majlength = fdVar.Length_Major__c != null
              ? fdVar.Length_Major__c + ' ' + CC_Constants.FT_STRING
              : '';
            minlength = fdVar.Length_Minor__c != null
              ? fdVar.Length_Minor__c + ' ' + CC_Constants.IN_String
              : '';
            majwidth = fdVar.Width_Major__c != null
              ? fdVar.Width_Major__c + ' ' + CC_Constants.FT_STRING
              : '';
            minwidth = fdVar.Width_Minor__c != null
              ? fdVar.Width_Minor__c + ' ' + CC_Constants.IN_String
              : '';
            majheight = fdVar.Height_Major__c != null
              ? fdVar.Height_Major__c + ' ' + CC_Constants.FT_STRING
              : '';
            minheight = fdVar.Height_Minor__c != null
              ? fdVar.Height_Minor__c + ' ' + CC_Constants.IN_String
              : '';
          } else if (lengthUnits == CC_Constants.M_STRING) {
            majlength = fdVar.Length_Major__c != null
              ? fdVar.Length_Major__c + ' ' + CC_Constants.M_STRING
              : '';
            minlength = fdVar.Length_Minor__c != null
              ? fdVar.Length_Minor__c + ' ' + CC_Constants.CM_String
              : '';
            majwidth = fdVar.Width_Major__c != null
              ? fdVar.Width_Major__c + ' ' + CC_Constants.M_STRING
              : '';
            minwidth = fdVar.Width_Minor__c != null
              ? fdVar.Width_Minor__c + ' ' + CC_Constants.CM_String
              : '';
            majheight = fdVar.Height_Major__c != null
              ? fdVar.Height_Major__c + ' ' + CC_Constants.M_STRING
              : '';
            minheight = fdVar.Height_Minor__c != null
              ? fdVar.Height_Minor__c + ' ' + CC_Constants.CM_String
              : '';
          }
          if (fdVar.Cargo_Type__c == CC_Constants.BBULK_STRING) {
            newCase.Freight_Type__c = CC_Constants.BBULK_STRING;
            newCase.Non_Containerized_Comments__c =
              CC_Constants.LENGTH_STRING +
              ' : ' +
              majlength +
              ' ' +
              minlength +
              '\n' +
              CC_Constants.WIDTH_STRING +
              ' : ' +
              majwidth +
              ' ' +
              minwidth +
              '\n' +
              CC_Constants.HEIGHT_STRING +
              ' : ' +
              majheight +
              ' ' +
              minheight +
              '\n' +
              CC_Constants.CARGO_WEIGHT_STRING +
              ' : ' +
              weight +
              ' ' +
              WeightUnits;
            CargoDescription =
              CargoDescription +
              CC_Constants.FREIGHTDETAILS +
              ' ' +
              i +
              ': \n' +
              CC_Constants.LENGTH_STRING +
              ' : ' +
              majlength +
              ' ' +
              minlength +
              '\n' +
              CC_Constants.WIDTH_STRING +
              ' : ' +
              majwidth +
              ' ' +
              minwidth +
              '\n' +
              CC_Constants.HEIGHT_STRING +
              ' : ' +
              majheight +
              ' ' +
              minheight +
              '\n' +
              CC_Constants.QUANTITY_STRING +
              ' : ' +
              quantity +
              '\n' +
              CC_Constants.WEIGHT_STRING +
              ' : ' +
              weight +
              ' ' +
              WeightUnits +
              '\n\n';
          }
          if (fdVar.Cargo_Type__c == CC_Constants.AUTO_STRING) {
            newCase.Freight_Type__c = CC_Constants.AUTO_STRING;
            String vehicleName = fdVar.Vehicle_Name__c != null
              ? fdVar.Vehicle_Name__c
              : CC_Constants.OTHERS_STRING;
            CargoDescription =
              CargoDescription +
              CC_Constants.MODEL_MANUFACTURER +
              ' : ' +
              vehicleName +
              '\n' +
              CC_Constants.FREIGHTDETAILS +
              ' ' +
              i +
              ': \n' +
              CC_Constants.LENGTH_STRING +
              ' : ' +
              majlength +
              ' ' +
              minlength +
              '\n' +
              CC_Constants.WIDTH_STRING +
              ' : ' +
              majwidth +
              ' ' +
              minwidth +
              '\n ' +
              CC_Constants.HEIGHT_STRING +
              ' : ' +
              majheight +
              ' ' +
              minheight +
              '\n' +
              CC_Constants.QUANTITY_STRING +
              ' : ' +
              quantity +
              '\n' +
              CC_Constants.WEIGHT_STRING +
              ' : ' +
              weight +
              ' ' +
              WeightUnits +
              '\n\n';
          }
          if (fdVar.Cargo_Type__c == CC_Constants.EQUIP_STRING) {
            if (
              !FDRequirementMap.isEmpty() &&
              FDRequirementMap.containsKey(fdVar.Id)
            ) {
              ListReqs = FDRequirementMap.get(fdVar.Id);
            }
            newCase.Freight_Type__c = CC_Constants.EQUIP_DRY_STRING;
          }
        }
      }
    }
    if (ListReqs.size() > 0) {
      i = 0;
      for (Requirement__c req : ListReqs) {
        i++;
        String length = req.Container_Type__c != null
          ? String.valueOf(req.Container_Type__c)
          : '';
        String category = req.Category__c != null ? req.Category__c : '';
        String quantity = req.Quantity__c != null
          ? String.valueOf(req.Quantity__c)
          : '';
        String outOfGauge = req.OutOfGauge__c
          ? CC_Constants.YES
          : CC_Constants.NO;
        String gaugeValue = CC_Constants.OUT_OF_GAUGE + ' : ' + outOfGauge;
        CargoDescription =
          CargoDescription +
          CC_Constants.EQUIPMENTDETAILS +
          ' ' +
          i +
          ' : \n' +
          length +
          ' / ' +
          category +
          ' * ' +
          quantity +
          '\n' +
          gaugeValue +
          ' \n';
      }
    }
    if (additionalInfo != null && additionalInfo != '') {
      additionalInfo = CC_Constants.ADDITIONAL_INFO + ' : \n' + additionalInfo;
    }
    newCase.Description =
      Origin +
      Destination +
      readyDate +
      hazardousValue +
      CargoDescription +
      additionalInfo;
    return newCase;
  }

  private static Boolean showState(String country) {
    if (country == CC_Constants.COUNTRY_US) {
      return true;
    } else {
      return false;
    }
  }
}
