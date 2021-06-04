public with sharing class QuotePDFController {
  public Id quoteId { get; set; }
  public transient Quote__c quoteRecord { get; set; }
  public transient Map<String, String> quoteDetails { get; set; }
  public transient Map<String, Date> quoteDates { get; set; }
  public transient Map<String, Decimal> quoteDecimals { get; set; }
  public transient List<ChargeLineWrapper> chargeLines { get; set; }
  public transient List<String> termsAndConditions { get; set; }
  public transient Map<String, String> orgDestVsMovementType { get; set; }
  public transient Map<String, String> orgDestVsLocationName { get; set; }
  public transient Map<String, String> orgDestVsLocationCode { get; set; }
  public transient Map<String, String> transitTime { get; set; }
  public transient List<RateWrapper> extraRateList { get; set; }
  public transient Decimal subTotalAmount { get; set; }
  public transient List<CargoDetailWrapper> CargoDetails { get; set; }

  public QuotePDFController() {
    this.quoteId = System.currentPageReference()
      .getParameters()
      .get(CC_Constants.ID_STRING);
    System.debug('quoteId <----> ' + this.quoteId);
    //this.quoteId = 'a38V0000000NUbv';
    if (this.quoteId != null) {
      CC_QuoteUtility.QuoteWrapper quoteWrapper = getQuoteWrapper(this.quoteId);
      this.quoteRecord = quoteWrapper.quoteRecord;
      System.debug('quoteRecord -' + this.quoteRecord);
      this.quoteDetails = processQuoteDetails(quoteWrapper.quoteRecord);
      this.quoteDates = processQuoteDates(quoteWrapper.quoteRecord);
      this.quoteDecimals = processQuoteDecimals(quoteWrapper.quoteRecord);
      this.chargeLines = processChargeLines(quoteWrapper.chargeLines);
      this.transitTime = processTransitTime(quoteWrapper.quoteRecord);
      this.termsAndConditions = quoteWrapper.termsAndConditions;
      this.orgDestVsMovementType = quoteWrapper.orgDestVsMovementType;
      this.orgDestVsLocationName = quoteWrapper.orgDestVsLocationName;
      this.orgDestVsLocationCode = quoteWrapper.orgDestVsLocationCode;
      this.CargoDetails = ProcessCargoDetails(quoteWrapper);
    }
  }

  private CC_QuoteUtility.QuoteWrapper getQuoteWrapper(String quoteId) {
    CC_QuoteUtility.QuoteWrapper quoteWrapper = CC_QuoteUtility.getQuoteDetails(
      quoteId,
      true
    );
    if (quoteWrapper != null) {
      if (
        quoteWrapper.termsAndConditions != null &&
        !quoteWrapper.termsAndConditions.isEmpty()
      ) {
        quoteWrapper.termsAndConditions = getLabelValues(
          quoteWrapper.termsAndConditions
        );
      }
    }
    System.debug('return result ' + quoteWrapper.chargeLines);
    return quoteWrapper;
  }

  private Map<String, String> processQuoteDetails(Quote__c quoteRecord) {
    Map<String, String> quoteDetails = new Map<String, String>();
    String quotationCompanyName = quoteRecord.Company_Name__c != null
      ? quoteRecord.Company_Name__c
      : 'NA';
    String quotationContactName = quoteRecord.Contact_Name__c != null
      ? quoteRecord.Contact_Name__c
      : 'NA';
    String setQuoteAccountName = quoteRecord.Account__r.Name != null
      ? quoteRecord.Account__r.Name
      : quotationCompanyName;
    String setQuoteName = quoteRecord.Contact__r.Name != null
      ? quoteRecord.Contact__r.Name
      : quotationContactName;
    quoteDetails.put('Name', quoteRecord.Name);
    quoteDetails.put(
      'Status',
      quoteRecord.Status__c != null ? quoteRecord.Status__c : 'NA'
    );
    quoteDetails.put(
      'CustomerEmail',
      quoteRecord.Customer_Email__c != null
        ? quoteRecord.Customer_Email__c
        : 'NA'
    );
    quoteDetails.put(
      'ContactNumber',
      quoteRecord.Contact_Number__c != null
        ? quoteRecord.Contact_Number__c
        : 'NA'
    );
    quoteDetails.put(
      'ContractName',
      quoteRecord.Contract_Number__c != null
        ? quoteRecord.Contract_Number__c
        : 'NA'
    );
    quoteDetails.put(
      'Transportation_Management_System_Origin__c',
      (quoteRecord.Transportation_Management_System_Origin__c != null
        ? quoteRecord.Transportation_Management_System_Origin__c
        : 'NA')
    );
    quoteDetails.put(
      'Transportation_Management_System_Destina__c',
      (quoteRecord.Transportation_Management_System_Destina__c != null
        ? quoteRecord.Transportation_Management_System_Destina__c
        : 'NA')
    );
    quoteDetails.put('AccountName', setQuoteAccountName);
    quoteDetails.put('ContactName', setQuoteName);
    quoteDetails.put(
      'LoadingPort',
      quoteRecord.Port_of_Load__c != null ? quoteRecord.Port_of_Load__c : 'NA'
    );
    quoteDetails.put(
      'DischargePort',
      quoteRecord.Port_of_Discharge__c != null
        ? quoteRecord.Port_of_Discharge__c
        : 'NA'
    );
    quoteDetails.put(
      'CaseNumber',
      (quoteRecord.Cases__r.size() > 0 &&
        quoteRecord.Cases__r[0].CaseNumber != null)
        ? quoteRecord.Cases__r[0].CaseNumber
        : 'NA'
    );
    return quoteDetails;
  }

  private List<CargoDetailWrapper> ProcessCargoDetails(
    CC_QuoteUtility.QuoteWrapper quoteWrapper
  ) {
    List<CargoDetailWrapper> CargoDetails = new List<CargoDetailWrapper>();
    List<FreightDetail__c> freights = quoteWrapper.listfreights;
    List<Requirement__c> requirements = quoteWrapper.listrequirements;
    List<Map<String, String>> containerTypes = quoteWrapper.containerTypes;
    String cargoType = quoteWrapper.CargoType;
    Integer serialNumber = 1;
    if (cargoType == CC_Constants.EQUIP_STRING) {
      for (Requirement__c req : requirements) {
        CargoDetailWrapper item = new CargoDetailWrapper();
        item.serialNumber = serialNumber;
        if (req.Container_Type__c != null) {
          system.debug('@@@' + containerTypes);
          for (Map<String, String> var : containerTypes) {
            if (var.get('label') == req.Container_Type__c) {
              item.containerName = var.get('value');
            }
            system.debug('@@' + var.get('label') + '@@' + var.get('value'));
          }
        }
        if (req.Commodity_Name__c != null) {
          item.commodityDesc = '(' + req.Commodity_Name__c + ')';
        }
        if (req.Quantity__c != null) {
          item.quantity = req.Quantity__c;
        }
        CargoDetails.add(item);
        serialNumber++;
      }
    }
    if (cargoType == CC_Constants.AUTO_STRING) {
      serialNumber = 1;
      for (FreightDetail__c fr : freights) {
        CargoDetailWrapper item = new CargoDetailWrapper();
        item.serialNumber = serialNumber;
        if (fr.Vehicle_Name__c != null) {
          item.containerName = fr.Vehicle_Name__c;
        }
        if (
          fr.Package_Type__c != null ||
          fr.Length__c != null ||
          fr.Width__c != null ||
          fr.Height__c != null ||
          fr.Declared_Weight_Value__c != null
        ) {
          String units = fr.Measure_Unit__c != null ? fr.Measure_Unit__c : '';
          String weightunits = fr.Declared_Weights_Unit_of_Measure__c != null
            ? fr.Declared_Weights_Unit_of_Measure__c
            : '';
          String packageType = '';
          if (fr.Package_Type__c == 'PVEH') {
            packageType = '(Passenger)';
          } else if (fr.Package_Type__c == 'CVEH') {
            packageType = '(Commercial)';
          }
          String Length = fr.Length__c != null
            ? fr.Length__c + ' ' + units
            : '';
          String Width = fr.Width__c != null ? fr.Width__c + ' ' + units : '';
          String Height = fr.Height__c != null
            ? fr.Height__c + ' ' + units
            : '';
          String Weight = fr.Declared_Weight_Value__c != null
            ? fr.Declared_Weight_Value__c + ' ' + weightunits
            : '';
          item.commodityDesc =
            packageType +
            '\n' +
            '(' +
            Length +
            ' x ' +
            Width +
            ' x ' +
            Height +
            ' , ' +
            Weight +
            ')';
        }
        if (fr.Freight_Quantity__c != null) {
          item.quantity = fr.Freight_Quantity__c;
        }
        CargoDetails.add(item);
        serialNumber++;
      }
    }
    if (cargoType == CC_Constants.BBULK_STRING) {
      serialNumber = 1;
      for (FreightDetail__c fr : freights) {
        CargoDetailWrapper item = new CargoDetailWrapper();
        item.serialNumber = serialNumber;
        system.debug('item->' + item.serialNumber);
        if (fr.Package_Type__c != null) {
          String packageType = '';
          if (fr.Package_Type__c == 'BOAT') {
            packageType = 'Boat on Trailer';
          } else if (fr.Package_Type__c == 'NIT') {
            packageType = 'Cargo, Not In Container';
          }
          item.containerName = packageType;
          system.debug('item->' + item.containerName);
        }
        if (
          fr.Length__c != null ||
          fr.Width__c != null ||
          fr.Height__c != null ||
          fr.Declared_Weight_Value__c != null
        ) {
          String units = fr.Measure_Unit__c != null ? fr.Measure_Unit__c : '';
          String weightunits = fr.Declared_Weights_Unit_of_Measure__c != null
            ? fr.Declared_Weights_Unit_of_Measure__c
            : '';
          String Length = fr.Length__c != null
            ? fr.Length__c + ' ' + units
            : '';
          String Width = fr.Width__c != null ? fr.Width__c + ' ' + units : '';
          String Height = fr.Height__c != null
            ? fr.Height__c + ' ' + units
            : '';
          String Weight = fr.Declared_Weight_Value__c != null
            ? fr.Declared_Weight_Value__c + ' ' + weightunits
            : '';
          item.commodityDesc =
            '(' +
            Length +
            ' x ' +
            Width +
            ' x ' +
            Height +
            ' , ' +
            Weight +
            ')';
          system.debug('item->' + item.commodityDesc);
        }
        if (fr.Package_Quantity__c != null) {
          item.quantity = fr.Package_Quantity__c;
          system.debug('item->' + item.quantity);
        }
        system.debug('item->' + item);
        CargoDetails.add(item);
        serialNumber++;
      }
    }
    return CargoDetails;
  }

  private Map<String, Date> processQuoteDates(Quote__c quoteRecord) {
    Map<String, Date> quoteDates = new Map<String, Date>();
    quoteDates.put('CreatedDate', Date.valueOf(quoteRecord.CreatedDate));
    quoteDates.put(
      'Ready_Date__c',
      quoteRecord.Ready_Date__c != null
        ? Date.valueOf(quoteRecord.Ready_Date__c)
        : null
    );
    quoteDates.put(
      'ValidToDate',
      quoteRecord.Valid_To__c != null
        ? Date.valueOf(quoteRecord.Valid_To__c)
        : null
    );
    return quoteDates;
  }

  private Map<String, Decimal> processQuoteDecimals(Quote__c quoteRecord) {
    Map<String, Decimal> quoteDecimals = new Map<String, Decimal>();
    quoteDecimals.put(
      'Transit_Time__c',
      (quoteRecord.Transit_Time__c != null
        ? Integer.valueOf(quoteRecord.Transit_Time__c / 24)
        : 0)
    );
    quoteDecimals.put(
      'TransitTimeInHours',
      (quoteRecord.Transit_Time__c != null
        ? Integer.valueOf(
            Math.mod(Integer.valueOf(quoteRecord.Transit_Time__c), 24)
          )
        : 0)
    );
    quoteDecimals.put(
      'SubTotal',
      (quoteRecord.Total_Amount__c != null ? quoteRecord.Total_Amount__c : 0)
    );
    Decimal totalAmount = (quoteRecord.Total_Amount__c != null
      ? quoteRecord.Total_Amount__c
      : 0);
    //Decimal EEIAmount = (quoteRecord.EEI_Charges__c != null ? quoteRecord.EEI_Charges__c : 0);
    //Decimal INSAmount = (quoteRecord.INS_Charge__c != null ? quoteRecord.INS_Charge__c : 0);
    /*Decimal EEIAmount = Decimal.ValueOf(System.Label.CC_EEI_Charge);
        Decimal INSCharge = Decimal.ValueOf(System.Label.CC_INS_Charge);
        Decimal INSAmount = (quoteRecord.Charge_Lines__r[0].Quantity__c * INSCharge ); */
    quoteDecimals.put('Total_Amount__c', totalAmount);
    //quoteDecimals.put('SEDCharge', EEIAmount);
    //quoteDecimals.put('INSCharge', INSAmount);
    return quoteDecimals;
  }

  private Map<String, String> processTransitTime(Quote__c quoteRecord) {
    Map<String, String> transitTime = new Map<String, String>();
    transitTime.put(
      'Transit_Time_Day_Hours__c',
      (quoteRecord.Transit_Time_Day_Hours__c != null
        ? quoteRecord.Transit_Time_Day_Hours__c
        : 'NA')
    );
    return transitTime;
  }

  private List<ChargeLineWrapper> processChargeLines(
    List<Charge_Line__c> chargeLines
  ) {
    extraRateList = new List<RateWrapper>();
    List<ChargeLineWrapper> chargeLineList = new List<ChargeLineWrapper>();
    if (chargeLines != null && !chargeLines.isEmpty()) {
      Map<String, List<RateWrapper>> containerSeqVsRateWrapperList = new Map<String, List<RateWrapper>>();
      Map<String, String> containerSeqVsContainerName = new Map<String, String>();
      Map<String, Integer> containerSeqVsQuantity = new Map<String, Integer>();
      Map<String, Decimal> containerSeqVsAmountTotal = new Map<String, Decimal>();
      Map<String, String> containerSeqVsModelYear = new Map<String, String>();
      subTotalAmount = 0.00;
      for (Charge_Line__c chargeLine : chargeLines) {
        if (chargeLine.Item_Sequence__c != '0') {
          containerSeqVsRateWrapperList = getcontainerSeqVsRateWrapperList(
            containerSeqVsRateWrapperList,
            chargeLine
          );
          containerSeqVsAmountTotal = getContainerSeqVsAmountTotal(
            containerSeqVsAmountTotal,
            chargeLine
          );
          containerSeqVsContainerName.put(
            chargeLine.Item_Sequence__c,
            chargeLine.Item_Name__c
          );
          containerSeqVsQuantity.put(
            chargeLine.Item_Sequence__c,
            Integer.valueOf(chargeLine.Quantity__c)
          );
          containerSeqVsModelYear.put(
            chargeLine.Item_Sequence__c,
            chargeLine.Item_Year__c != null ? chargeLine.Item_Year__c : ''
          );
          subTotalAmount += chargeLine.Amount_Target__c;
        } else {
          RateWrapper rateWrapper = new RateWrapper();
          rateWrapper.description = chargeLine.ChargeDescription__c;
          rateWrapper.amountTarget = chargeLine.Amount_Target__c;
          extraRateList.add(rateWrapper);
        }
      }
      Integer serialNumber = 1;
      for (String containerSeq : containerSeqVsRateWrapperList.keySet()) {
        ChargeLineWrapper chargeLineWrapper = new ChargeLineWrapper();
        chargeLineWrapper.serialNumber = serialNumber;
        chargeLineWrapper.containerName = getContainerNameAndCommodity(
          containerSeqVsContainerName.get(containerSeq),
          true
        );
        chargeLineWrapper.commodityDesc = getContainerNameAndCommodity(
          containerSeqVsContainerName.get(containerSeq),
          false
        );
        chargeLineWrapper.containerSeq = containerSeq;
        chargeLineWrapper.modelYear = containerSeqVsModelYear.get(containerSeq);
        chargeLineWrapper.quantity = containerSeqVsQuantity.get(containerSeq);
        chargeLineWrapper.totalAmount = containerSeqVsAmountTotal.get(
          containerSeq
        );
        chargeLineWrapper.ratesList = containerSeqVsRateWrapperList.get(
          containerSeq
        );
        serialNumber++;
        chargeLineList.add(chargeLineWrapper);
      }
    }
    System.debug('charge List ' + chargeLineList);
    return chargeLineList;
  }

  private static String getContainerNameAndCommodity(
    String value,
    Boolean isBefore
  ) {
    if (value != null) {
      String result = '';
      if (isBefore) {
        result = value.substringBefore('___');
      } else {
        result = value.substringAfter('___');
        if (!String.isBlank(result)) {
          result = '(' + result + ')';
        }
      }
      return result;
    } else {
      return '';
    }
  }

  private Map<String, Decimal> getContainerSeqVsAmountTotal(
    Map<String, Decimal> containerSeqVsAmountTotal,
    Charge_Line__c chargeLine
  ) {
    if (
      containerSeqVsAmountTotal != null &&
      containerSeqVsAmountTotal.get(chargeLine.Item_Sequence__c) != null
    ) {
      Decimal amountTarget = containerSeqVsAmountTotal.get(
        chargeLine.Item_Sequence__c
      );
      amountTarget += chargeLine.Amount_Target__c;
      containerSeqVsAmountTotal.put(chargeLine.Item_Sequence__c, amountTarget);
    } else {
      containerSeqVsAmountTotal.put(
        chargeLine.Item_Sequence__c,
        chargeLine.Amount_Target__c
      );
    }
    return containerSeqVsAmountTotal;
  }

  private Map<String, List<RateWrapper>> getcontainerSeqVsRateWrapperList(
    Map<String, List<RateWrapper>> containerSeqVsRateWrapperList,
    Charge_Line__c chargeLine
  ) {
    if (
      containerSeqVsRateWrapperList != null &&
      containerSeqVsRateWrapperList.get(chargeLine.Item_Sequence__c) != null
    ) {
      List<RateWrapper> rateWrapperList = containerSeqVsRateWrapperList.get(
        chargeLine.Item_Sequence__c
      );
      rateWrapperList.add(getRateWrapper(chargeLine));
      //rateWrapperList.sort();
      containerSeqVsRateWrapperList.put(
        chargeLine.Item_Sequence__c,
        rateWrapperList
      );
    } else {
      List<RateWrapper> rateWrapperList = new List<RateWrapper>();
      rateWrapperList.add(getRateWrapper(chargeLine));
      containerSeqVsRateWrapperList.put(
        chargeLine.Item_Sequence__c,
        rateWrapperList
      );
    }
    return containerSeqVsRateWrapperList;
  }

  private RateWrapper getRateWrapper(Charge_Line__c chargeLine) {
    RateWrapper rateWrapper = new RateWrapper();
    rateWrapper.description = chargeLine.ChargeDescription__c;
    rateWrapper.amountTarget = chargeLine.Amount_Target__c;
    return rateWrapper;
  }

  private List<String> getLabelValues(List<String> allLabels) {
    List<String> allLabelsValues = new List<String>();
    Component.Apex.OutputText output = new Component.Apex.OutputText();
    for (String label : allLabels) {
      output.expressions.value =
        CC_Constants.CURLY_BRACE_OPEN +
        CC_Constants.EXCLAMATION_MARK +
        CC_Constants.DOLLAR_SYMBOL +
        CC_Constants.CUSTOM_LABEL +
        CC_Constants.DOT_STRING +
        label +
        CC_Constants.CURLY_BRACE_CLOSE;
      allLabelsValues.add(String.valueOf(output.value));
    }
    return allLabelsValues;
  }

  public class CargoDetailWrapper {
    public Integer serialNumber { get; set; }
    public String containerName { get; set; }
    public String commodityDesc { get; set; }
    public Decimal quantity { get; set; }
  }

  public class ChargeLineWrapper {
    public Integer serialNumber { get; set; }
    public String containerName { get; set; }
    public String commodityDesc { get; set; }
    public String containerSeq { get; set; }
    public String modelYear { get; set; }
    public Integer quantity { get; set; }
    public Decimal totalAmount { get; set; }
    public List<RateWrapper> ratesList { get; set; }
  }

  public class RateWrapper implements Comparable {
    public String description { get; set; }
    public Decimal amountTarget { get; set; }

    public Integer compareTo(Object compareTo) {
      RateWrapper other = (RateWrapper) compareTo;
      if (this.amountTarget > other.amountTarget) {
        return 1;
      } else if (this.amountTarget == other.amountTarget) {
        return 0;
      }
      return -1;
    }
  }
  public PageReference downloadPDF() {
    this.quoteId = System.currentPageReference()
      .getParameters()
      .get(CC_Constants.ID_STRING);
    if (this.quoteId != null) {
      CC_QuoteUtility.QuoteWrapper quoteWrapper = getQuoteWrapper(this.quoteId);
      this.quoteRecord = quoteWrapper.quoteRecord;
      System.debug('quoteRecord -' + this.quoteRecord);
      this.quoteDetails = processQuoteDetails(quoteWrapper.quoteRecord);
      this.quoteDates = processQuoteDates(quoteWrapper.quoteRecord);
      this.quoteDecimals = processQuoteDecimals(quoteWrapper.quoteRecord);
      this.chargeLines = processChargeLines(quoteWrapper.chargeLines);
      this.termsAndConditions = quoteWrapper.termsAndConditions;
      this.orgDestVsMovementType = quoteWrapper.orgDestVsMovementType;
      this.orgDestVsLocationName = quoteWrapper.orgDestVsLocationName;
      this.orgDestVsLocationCode = quoteWrapper.orgDestVsLocationCode;
    }
    System.PageReference pageRef = new System.PageReference(
      '/apex/CC_EmployeeQuoteRecordPDF'
    );
    pageRef.getHeaders()
      .put(
        'content-disposition',
        'attachment; filename=' +
        this.quoteRecord.Name +
        '.pdf'
      );
    pageRef.getParameters().put('Id', this.quoteId);
    return pageRef;
  }
}
