public without sharing class CC_BillOfLadingVFController {
  public transient BOLEditController.BolView objBolView { get; set; }
  public List<ChargeLinePDFWrapper> lstInvoices { get; set; }
  public Decimal totalSum { get; set; }
  public Date Today {
    get {
      return Date.today();
    }
  }

  public CC_BillOfLadingVFController() {
    String strBolId = System.currentPageReference()
      .getParameters()
      .get('bolId');
    String strBookingId = System.currentPageReference()
      .getParameters()
      .get('bookingId');
    //objBolView = BOLEditController.getBol('a1e3F000001DjiuQAC','a223F000000fDMjQAM');
    objBolView = BOLEditController.getBol(strBookingId, strBolId, false);
    setInvoiceDataForPDF(objBolView);
  }

  private void setInvoiceDataForPDF(BOLEditController.BolView objBolView) {
    lstInvoices = new List<ChargeLinePDFWrapper>();
    Map<String, List<CC_ChargeLineWrapper>> invoiceMap = new Map<String, List<CC_ChargeLineWrapper>>();
    invoiceMap = objBolView.chargeLine;
    totalSum = 0.0;
    for (String key : invoiceMap.keySet()) {
      String label = '';
      Decimal currentCommodityValueSum = 0.0;
      if (invoiceMap.get(key) != null) {
        for (CC_ChargeLineWrapper chargeline : invoiceMap.get(key)) {
          if (String.isNotBlank(chargeline.strValue)) {
            currentCommodityValueSum += Decimal.valueOf(chargeline.strValue);
          }
        }
      }
      if (String.isNotBlank(key)) {
        label = '(' + key.replace('___', ' ') + ')';
      }
      totalSum = totalSum + currentCommodityValueSum;
      ChargeLinePDFWrapper chargePDF = new ChargeLinePDFWrapper();
      chargePDF.value = invoiceMap.get(key);
      chargePDF.key = key;
      chargePDF.amount = currentCommodityValueSum;
      chargePDF.label = label;
      lstInvoices.add(chargePDF);
    }
  }

  public class ChargeLinePDFWrapper {
    public List<CC_ChargeLineWrapper> value { get; set; }
    public String key { get; set; }
    public Decimal amount { get; set; }
    public String label { get; set; }
  }
}
