public class CC_SoftshipRatingResponse {
  @AuraEnabled
  public boolean success;
  @AuraEnabled
  public List<result> result;
  @AuraEnabled
  public boolean isTimeoutError;
  @auraEnabled
  public String errorMessage;

  public class result {
    @AuraEnabled
    public Integer RouteId;
    @AuraEnabled
    public boolean Success;
    @AuraEnabled
    public CalculatedContributionResult CalculatedContributionResult;
    @AuraEnabled
    public BookingRouteResult BookingRouteResult;
    @AuraEnabled
    public boolean IsSelectedRoute;
    @AuraEnabled
    public String ExpectedTimeOfDeparture;
    @AuraEnabled
    public Duration Duration;
    @AuraEnabled
    public List<Legs> Legs;
    @AuraEnabled
    public List<Schedules> Schedules;
  }
  public class CalculatedContributionResult {
    @AuraEnabled
    public List<Errors> Errors;
    @AuraEnabled
    public List<ItemValues> ItemValues;
    @AuraEnabled
    public boolean Success;
  }
  public class Errors {
  }
  public class ItemValues {
    @AuraEnabled
    public Integer ItemNumber;
    @AuraEnabled
    public List<ValuesDataRevenue> ValuesDataRevenue;
    @AuraEnabled
    public List<ContributionData> ContributionData;
    @AuraEnabled
    public List<ValuesDataRevenue> ValuesDataCost;
  }

  public class ValuesDataRevenue {
    @AuraEnabled
    public String TargetCurrency;
    @AuraEnabled
    public List<ValuesGroup> ValuesGroup;
  }
  public class ValuesGroup {
    @AuraEnabled
    public List<DocValuesData> DocValuesData;
    @AuraEnabled
    public Decimal SumOfValues;
    @AuraEnabled
    public Decimal SumOfVat;
    @AuraEnabled
    public Decimal TotalSum;
  }
  public class DocValuesData {
    @AuraEnabled
    public Decimal AmountTarget;
    @AuraEnabled
    public Decimal Basis;
    @AuraEnabled
    public String ChargeCode;
    @AuraEnabled
    public String CurrencyCode;
    @AuraEnabled
    public String Description;
    @AuraEnabled
    public String GroupName;
    @AuraEnabled
    public String MinMaxFlag;
    @AuraEnabled
    public String Per;
    @AuraEnabled
    public Decimal Rate;
    @AuraEnabled
    public String TargetCurCode;
    @AuraEnabled
    public Decimal TariffManr;
    @AuraEnabled
    public String Unit;
    @AuraEnabled
    public Integer ItemNumber;
  }
  public class ContributionData {
    @AuraEnabled
    public String TargetCurrency;
    @AuraEnabled
    public Decimal SumCost;
    @AuraEnabled
    public Decimal SumRevenue;
    @AuraEnabled
    public Decimal ContributionAmount;
  }
  public class BookingRouteResult {
    @AuraEnabled
    public Integer RouteId;
    @AuraEnabled
    public List<Integer> AllPurchaseTariffIds;
    @AuraEnabled
    public List<Integer> AllSalesTariffIds;
  }
  public class Duration {
    @AuraEnabled
    public Decimal Amount;
    @AuraEnabled
    public String TimeUnit;
    @AuraEnabled
    public Decimal AmountInDays;
    @AuraEnabled
    public Decimal AmountinMinuteRounded;
    @AuraEnabled
    public Decimal AmountinHours;
  }
  public class Legs {
    @AuraEnabled
    public Integer LegSeqNumber;
    @AuraEnabled
    public StartPosition StartPosition;
    @AuraEnabled
    public EndPosition EndPosition;
    @AuraEnabled
    public TransportMode TransportMode;
    @AuraEnabled
    public Duration Duration;
    @AuraEnabled
    public StayTimePod StayTimePod;
    @AuraEnabled
    public StayTimePol StayTimePol;
    @AuraEnabled
    public Integer TransshipmentMatrixDetailId;
  }
  public class StartPosition {
    @AuraEnabled
    public LocationCode LocationCode;
    @AuraEnabled
    public SubLocationCode SubLocationCode;
    @AuraEnabled
    public String DisplayName;
    @AuraEnabled
    public String SublocationCodeDisplayName;
  }
  public class LocationCode {
    @AuraEnabled
    public String Code;
  }
  public class SubLocationCode {
    @AuraEnabled
    public String Code;
  }
  public class EndPosition {
    @AuraEnabled
    public LocationCode LocationCode;
    @AuraEnabled
    public SubLocationCode SubLocationCode;
    @AuraEnabled
    public String DisplayName;
    @AuraEnabled
    public String SublocationCodeDisplayName;
  }
  public class TransportMode {
    @AuraEnabled
    public String Code;
    @AuraEnabled
    public String Type;
  }
  public class StayTimePod {
    @AuraEnabled
    public Decimal Amount;
    @AuraEnabled
    public String TimeUnit;
    @AuraEnabled
    public Decimal AmountInDays;
  }
  public class StayTimePol {
    @AuraEnabled
    public Decimal Amount;
    @AuraEnabled
    public String TimeUnit;
    @AuraEnabled
    public Decimal AmountInDays;
  }

  public class Schedules {
    @AuraEnabled
    public UTCDate StartSailingDate;
    @AuraEnabled
    public UTCDate EndSailingDate;
    @AuraEnabled
    public UTCDate StartDate;
    @AuraEnabled
    public UTCDate EndDate;
    @AuraEnabled
    public String TotalDuration;
    @AuraEnabled
    public List<Segments> Segments;
    // Following data not coming from API response , processessed in controller
    @AuraEnabled
    public Integer sequenceNumber;
    @AuraEnabled
    public Integer numberOfSegments;
    @AuraEnabled
    public Integer numberOfStops;
    @AuraEnabled
    public String startLocation;
    @AuraEnabled
    public String endLocation;
    @AuraEnabled
    public String startLocationCode;
    @AuraEnabled
    public String endLocationCode;
    @AuraEnabled
    public Integer totalDays;
    @AuraEnabled
    public Integer addedHours;
    @AuraEnabled
    public Integer totalHours;
    @AuraEnabled
    public Long startDateNumber;
    @AuraEnabled
    public String POL;
    @AuraEnabled
    public String POD;
    @AuraEnabled
    public List<CC_ProcessesedScheduleData> betweenLocations;
    @AuraEnabled
    public List<CC_ProcessesedScheduleData> betweenPortsOnly;
    @AuraEnabled
    public CC_ProcessesedScheduleData startLoc;
    @AuraEnabled
    public CC_ProcessesedScheduleData endLoc;
    @AuraEnabled
    public String startMode;
    @AuraEnabled
    public String endMode;
    @AuraEnabled
    public String startPoint;
    @AuraEnabled
    public String endPoint;
    @AuraEnabled
    public String originMove;
    @AuraEnabled
    public String destMove;
  }

  public class UTCDate {
    @AuraEnabled
    public String Utc;
    @AuraEnabled
    public String LocalPortTime;
  }

  public class NumberX {
    @AuraEnabled
    public String NumberX;
  }

  public class Berths {
    @AuraEnabled
    public UTCDate Departure;
    @AuraEnabled
    public UTCDate Arrival;
  }
  public class ToFrom {
    @AuraEnabled
    public List<Berths> Berths;
  }

  public class Segments {
    @AuraEnabled
    public String VesselName;
    @AuraEnabled
    public NumberX VoyageNumber;
    @AuraEnabled
    public LocationCode FromLocation;
    @AuraEnabled
    public LocationCode ToLocation;
    @AuraEnabled
    public LocationCode VesselCode;
    @AuraEnabled
    public Boolean IsTBN;
    @AuraEnabled
    public Boolean IsOcean;
    @AuraEnabled
    public Legs Legs;
    @AuraEnabled
    public String FromSubDisplayName;
    @AuraEnabled
    public String ToSubDisplayName;
    @AuraEnabled
    public UTCDate DepartureTime;
    @AuraEnabled
    public UTCDate ArrivalTime;
    @AuraEnabled
    public TransportMode TransportModeCode;
    @AuraEnabled
    public ToFrom To;
    @AuraEnabled
    public ToFrom FromX;
    // Following data not coming from API response , processessed in controller
    @AuraEnabled
    public Integer StopSequence;
    @AuraEnabled
    public String arrivalToDisplay;
    @AuraEnabled
    public String departureToDisplay;
  }
}
