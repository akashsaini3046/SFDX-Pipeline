public without sharing class RoutePDFController {
  public List<CC_SoftshipRatingResponse.Schedules> scheduleWrapper { get; set; }

  public String recId { get; set; }
  public List<ScheduleInfo> schedules { get; set; }
  public Booking__c booking { get; set; }
  public Integer numberOfSchedules { get; set; }
  public RoutePDFController() {
    System.debug('@@@inside controller');
    this.recId = System.currentPageReference()
      .getParameters()
      .get(CC_Constants.ID_STRING);
    System.debug('this.recId ' + this.recId);
    Log__c route = new Log__c();
    route = [
      SELECT ScheduleWrapper__c, StringBooking__c
      FROM Log__c
      WHERE id = :this.recId
    ];
    List<CC_SoftshipRatingResponse.Schedules> schedulesList = (List<CC_SoftshipRatingResponse.Schedules>) JSON.deserialize(
      route.ScheduleWrapper__c,
      List<CC_SoftshipRatingResponse.Schedules>.class
    );
    Booking__c booking = (Booking__c) JSON.deserialize(
      route.StringBooking__c,
      Booking__c.class
    );
    this.booking = booking;
    // List<CC_SoftshipRatingResponse.Schedules> schedulesList = (List<CC_SoftshipRatingResponse.Schedules>)JSON.deserialize((String)Cache.Session.getPartition('local.myPartition').get('schedules'),List<CC_SoftshipRatingResponse.Schedules>.class);
    // List<CC_SoftshipRatingResponse.Schedules> schedulesList  = new  List<CC_SoftshipRatingResponse.Schedules>();
    this.numberOfSchedules = schedulesList.size();
    List<ScheduleInfo> schList = new List<ScheduleInfo>();
    for (Integer k = 0; k < schedulesList.size(); k++) {
      CC_SoftshipRatingResponse.Schedules schedule = schedulesList[k];
      ScheduleInfo s = new ScheduleInfo();

      if (schedule != null) {
        s.scheduleStartDate = schedule.StartDate.LocalPortTime;
        s.scheduleEndDate = schedule.EndDate.LocalPortTime;
        s.scheduleTransitDays = schedule.totalDays;
        s.scheduleTransitHours = schedule.totalHours;
        s.startMode = schedule.startMode;
        s.endMode = schedule.endMode;
        s.originMove = schedule.originMove;
        s.destMove = schedule.destMove;
        s.startLocation = schedule.startLocation;
        s.endLocation = schedule.endLocation;
        s.startPoint = schedule.startPoint;
        s.endPoint = schedule.endPoint;

        Map<String, String> betPort = new Map<String, String>();
        List<Map<String, String>> betPortList = new List<Map<String, String>>();
        if (schedule.betweenPortsOnly.size() > 0) {
          for (Integer i = 0; i < schedule.betweenPortsOnly.size(); i++) {
            betPort = setLegsData(schedule.betweenPortsOnly[i]);
            betPortList.add(betPort);
          }
        }
        s.betweenPortsOnly = betPortList;

        Map<String, String> betLoc = new Map<String, String>();
        List<Map<String, String>> betLocList = new List<Map<String, String>>();
        if (schedule.betweenLocations.size() > 0) {
          for (Integer i = 0; i < schedule.betweenLocations.size(); i++) {
            betLoc = setLegsData(schedule.betweenLocations[i]);
            betLocList.add(betLoc);
          }
        }

        s.betweenLocations = betLocList;
        s.startLoc = setLegsData(schedule.startLoc);
        s.endLoc = setLegsData(schedule.endLoc);
        schList.add(s);
      }
    }
    this.schedules = schList;
  }
  public Map<String, String> setLegsData(CC_ProcessesedScheduleData location) {
    Map<String, String> loc = new Map<String, String>();
    if (location.orgDest != null)
      loc.put('orgDest', location.orgDest);
    else
      loc.put('orgDest', '');

    if (location.displayName != null)
      loc.put('displayName', location.displayName);
    else
      loc.put('displayName', '');

    if (location.displayCode != null)
      loc.put('displayCode', location.displayCode);
    else
      loc.put('displayCode', '');

    if (location.displayNameSubLoc != null)
      loc.put('displayNameSubLoc', location.displayNameSubLoc);
    else
      loc.put('displayNameSubLoc', '');

    if (location.displayCodeSubLoc != null)
      loc.put('displayCodeSubLoc', location.displayCodeSubLoc);
    else
      loc.put('displayCodeSubLoc', '');

    if (location.iconShown != null)
      loc.put('iconShown', location.iconShown);
    else
      loc.put('iconShown', '');

    if (location.arrival != null)
      loc.put('arrival', location.arrival);
    else
      loc.put('arrival', '');

    if (location.departure != null)
      loc.put('departure', location.departure);
    else
      loc.put('departure', '');

    if (location.displayName != null)
      loc.put('vesselName', location.vesselName);
    else
      loc.put('vesselName', '');

    if (location.displayName != null)
      loc.put('voyageNumber', location.voyageNumber);
    else
      loc.put('voyageNumber', '');
    return loc;
  }
  public class ScheduleInfo {
    public Booking__c booking { get; set; }
    public String scheduleStartDate { get; set; }
    public String scheduleEndDate { get; set; }
    public Integer scheduleTransitDays { get; set; }
    public Integer scheduleTransitHours { get; set; }
    public String startMode { get; set; }
    public String endMode { get; set; }
    public String startLocation { get; set; }
    public String endLocation { get; set; }
    public String startPoint { get; set; }
    public String endPoint { get; set; }
    public String originMove { get; set; }
    public String destMove { get; set; }
    public Map<String, String> startLoc { get; set; }
    public Map<String, String> endLoc { get; set; }
    public List<Map<String, String>> betweenPortsOnly { get; set; }
    public List<Map<String, String>> betweenLocations { get; set; }
  }
  public void setScheduleWrapper(String schedulesString) {
    this.scheduleWrapper = (List<CC_SoftshipRatingResponse.Schedules>) JSON.deserialize(
      (String) schedulesString,
      List<CC_SoftshipRatingResponse.Schedules>.class
    );
  }
}
