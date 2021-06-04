public class CC_SoftshipRatingRequest {
  public Booking Booking;
  public String Action;
  //public String CalcRule; //Rating API Change 16/12/2020
  public Integer maxRoutes;
  public Integer MaxNumberOfSchedules;
  public String DefaultOptionalServices;
  public Integer SelectedRoute;
  public String TermsConditionsCode = 'QUOCTERM'; //Rating API Change 16/12/2020

  public class Booking {
    public BookingAgency BookingAgency;
    public Customer Customer;
    public RequestedBookingRoute RequestedBookingRoute;
    public List<BookingCargo> BookingCargo; //Rating API Change 16/12/2020
    public TransCurrency TransCurrency;
    public String ShipmentType;
    public Contract Contract;
    public String BookingDate;
    public String ShipmentCondition;
    //public String ReadyDate;
  }

  public class BookingAgency {
    public String Code;
  }

  public class Customer {
    public CustomerCode CustomerCode;
    public String CustomerName1;
  }

  public class CustomerCode {
    public String Code;
  }

  public class RequestedBookingRoute {
    public List<Legs> Legs;
    public Integer MaxTransshipments;
  }

  public class Legs {
    public Integer LegSequence;
    public String ReadyDate;

    public String StartLocation;
    public String StartSubLocationCode;
    public String EndLocation;
    public String EndSubLocationCode;

    public String ReceiptTermCode;
    public String ReceiptTermBehavior;
    public String ReceiptStopoverCode;
    public String ReceiptTypeCode;
    public String ReceiptDrayage;
    public String DeliveryTermCode;
    public String DeliveryTermBehavior;
    public String DeliveryStopoverCode;
    public String DeliveryTypeCode;
    public String DeliveryDrayage;
  }

  public class BookingCargo {
    public String type;
    public List<Cargo> Cargo; //Rating API Change 16/12/2020
    public OptionalServices OptionalServices; //Rating API Change 16/12/2020
    //public List<Values> values; //Rating API Change 16/12/2020
  }

  public class Values {
    //Commented for Rating API Change 16/12/2020
    //public List<Cargo> Cargo;
    //public Map<String,Integer> CargoItemId;
    //public OptionalServices OptionalServices;
    //ItemRunningNumber
  }

  public class Cargo {
    public CargoId Id; //Rating API Change 16/12/2020
    //ContainerRunningNumber
    public String Vin;
    public String ContainerNumber;
    public CarModelId CarModelId;
    public Integer ModelYear;
    public ValueUnit CargoGrossWeight;
    public String DescriptionOfGoods;
    public LengthCentimeter LengthCentimeter;
    public WidthCentimeter WidthCentimeter;
    public HeightCentimeter HeightCentimeter;
    public ValueUnit WeightKilogram;
    public ContainerType ContainerType;
    public KindOfPackage KindOfPackage;
    public LoadingType LoadingType;
    public ValueUnit CargoNetWeight;
    public UnitAmount Area;
    public UnitAmount Measurement;
    public OperationalStatus OperationalStatus;
    public Commodity Commodity;
    public Map<String, Decimal> NumberOfPackage;
    public Imdg Imdg;
    public Boolean IsEmpty;
    public Boolean IsShippersOwn;
    public Boolean IsHeavy;
    public OutOfGauge OutOfGauge;
    public Reefer Reefer;
  }

  public class OptionalServices {
    public List<BookingOptionalServiceModels> BookingOptionalServiceModels;
  }

  public class BookingOptionalServiceModels {
    public OptionalServiceCondition OptionalServiceCondition;
    public OptionalServiceTariffInformation OptionalServiceTariffInformation;
    public OptionalServiceCalculationBasis OptionalServiceCalculationBasis;
  }
  public class OptionalServiceCondition {
    public String ConditionValue;
  }
  public class OptionalServiceTariffInformation {
    public Integer Level;
  }
  public class OptionalServiceCalculationBasis {
    public CalculationBasis CalculationBasis;
  }
  public class CalculationBasis {
    public Decimal Value;
  }

  public class ContainerType {
    public Boolean IsReefer;
    public ContainerTypeCode ContainerTypeCode;
  }

  //Rating API Change 16/12/2020
  public class CargoId {
    public Map<String, Integer> CargoItemId;
    public Integer CargoRunningNumber;
  }

  public class ContainerTypeCode {
    public String Code;
    public String Description;
  }

  public class Reefer {
    public Boolean IsNonOperative;
  }

  public class OutOfGauge {
    public String RequestNumber;
    public Integer LostSlots;
    public ValueUnit Top;
    public ValueUnit Left;
    public ValueUnit Right;
    public ValueUnit Front;
    public ValueUnit Door;
  }

  public class ValueUnit {
    public Decimal Value;
    public Integer Unit;
  }

  public class UnitAmount {
    public Integer Unit;
    public Decimal Amount;
  }

  public class Imdg {
    public Code ClassCode;
  }

  public class Code {
    public String Code;
  }

  public class CarModelId {
    public String Manufacturer;
    public String Model;
    public String Type;
  }

  public class LengthCentimeter {
    public Integer Unit;
    public Double Amount;
  }

  public class WidthCentimeter {
    public Integer Unit;
    public Double Amount;
  }

  public class HeightCentimeter {
    public Integer Unit;
    public Double Amount;
  }

  public class KindOfPackage {
    public String Code;
    public String Description;
  }

  public class LoadingType {
    public String Code;
  }

  public class OperationalStatus {
    public String Status;
  }

  public class Commodity {
    public String Code;
    public String DescriptionOfGoods;
  }

  public class TransCurrency {
    public String Code;
  }

  public class Contract {
    public String ContractNumber;
  }
}
