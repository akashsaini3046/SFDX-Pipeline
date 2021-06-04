public class CC_FindARouteHelper {
  public static List<CC_SoftshipRatingResponse.Schedules> getSchedules(
    CC_SoftshipRatingResponse response
  ) {
    List<CC_SoftshipRatingResponse.Schedules> schedules = new List<CC_SoftshipRatingResponse.Schedules>();
    for (CC_SoftshipRatingResponse.result result : response.result) {
      for (CC_SoftshipRatingResponse.Schedules schedule : result.Schedules) {
        schedule.totalDays = getDays(schedule.TotalDuration);
        schedule.totalHours = getHours(schedule.TotalDuration);
        System.debug(schedule);
        String dateStr = schedule.StartDate.LocalPortTime;
        dateStr = dateStr.replaceAll('[^0-9]', '');
        schedule.startDateNumber = Long.valueOf(dateStr.substring(0, 13));
        schedule.StartDate.LocalPortTime = getDateTime(
          schedule.StartDate.LocalPortTime
        );
        schedule.EndDate.LocalPortTime = getDateTime(
          schedule.EndDate.LocalPortTime
        );
        integer polCount = 0;
        for (CC_SoftshipRatingResponse.Segments segment : schedule.Segments) {
          if (segment.IsOcean) {
            /*  if(polCount ==0){
                            if(segment.FromSubDisplayName != null)                                 
                                schedule.POL = segment.FromSubDisplayName+'  '+segment.FromLocation.Code;
                            else
                                schedule.POL = segment.Leg.StartPosition.DisplayName+'  '+segment.FromLocation.Code;  
                            polCount++;
                        }
                        else{
                            if(segment.FromSubDisplayName != null)                                 
                                schedule.POD = segment.FromSubDisplayName+'  '+segment.FromLocation.Code;
                            else
                                schedule.POD = segment.Leg.StartPosition.DisplayName+'  '+segment.FromLocation.Code;  
                        }
                        */
            segment.FromX.Berths[0].Departure.LocalPortTime = getDateTime(
              segment.FromX.Berths[0].Departure.LocalPortTime
            );
            segment.To.Berths[0].Arrival.LocalPortTime = getDateTime(
              segment.To.Berths[0].Arrival.LocalPortTime
            );
          } else {
            segment.DepartureTime.LocalPortTime = getDateTime(
              segment.DepartureTime.LocalPortTime
            );
            segment.ArrivalTime.LocalPortTime = getDateTime(
              segment.ArrivalTime.LocalPortTime
            );
          }
        }
        schedules.add(schedule);
      }
    }
    system.debug('schedules--->>>' + json.serialize(schedules));
    return schedules;
  }

  /*  public static Integer getDays(String totalDuration){    
        system.debug('----->'+totalDuration);
         if(!totalDuration.contains('.')){
            totalDuration='0.'+totalDuration;
        }      
        Integer days= 0;
        if(String.isNotBlank(totalDuration)){
            List<String> listString = new List<String>();
        	listString = totalDuration.split(':');
            system.debug('----->'+listString);
            if(listString.size()>0){
                listString = listString[0].split('\\.');
                days = Integer.valueOf(listString[0]);
                 system.debug('----->'+listString);
                if(listString.size()>1 && listString[1].length()>0){
                    Integer hours = (listString[1].length()==1) ? Integer.valueOf(listString[1].substring(0, 1)) : Integer.valueOf(listString[1].substring(0, 2)) ;
                    if(hours>12){
                   	 days++;
                    }
                }
            }
        } 
        if(days==0){
            days = 1;
		}       
        return days;
    }
    */
  public static Integer getDays(String totalDuration) {
    system.debug('----->' + totalDuration);
    if (!totalDuration.contains('.')) {
      totalDuration = '0.' + totalDuration;
    }
    Integer days = 0;
    if (String.isNotBlank(totalDuration)) {
      List<String> listString = new List<String>();
      listString = totalDuration.split(':');
      system.debug('----->' + listString);
      if (listString.size() > 0) {
        listString = listString[0].split('\\.');
        days = Integer.valueOf(listString[0]);
        system.debug('----->' + listString);
      }
    }
    return days;
  }

  public static Integer getHours(String totalDuration) {
    system.debug('----->' + totalDuration);
    if (!totalDuration.contains('.')) {
      totalDuration = '0.' + totalDuration;
    }
    Integer hours = 0;
    if (String.isNotBlank(totalDuration)) {
      List<String> listString = new List<String>();
      listString = totalDuration.split(':');
      system.debug('----->' + listString);
      if (listString.size() > 0) {
        listString = listString[0].split('\\.');
        if (listString.size() > 1 && listString[1].length() > 0) {
          hours = (listString[1].length() == 1)
            ? Integer.valueOf(listString[1].substring(0, 1))
            : Integer.valueOf(listString[1].substring(0, 2));
        }
      }
    }
    return hours;
  }

  public static String getDateTime(String LocalPortTime) {
    String strDateTime = LocalPortTime;
    if (String.isNotBlank(strDateTime)) {
      List<String> listString = new List<String>();
      listString = strDateTime.split('T');
      List<String> dateSplit = listString[0].split('-');
      List<String> timeSplit = listString[1].split(':');
      Integer hours = Integer.valueOf(timeSplit[0]);
      string AMPM = (hours > 11) ? 'PM' : 'AM';
      //strDateTime = CC_Utility.getMonth(Integer.valueOf(dateSplit[1])) +' '+dateSplit[2]+', '+dateSplit[0]+'. '+ CC_Utility.getHours(hours)+':'+timeSplit[1]+' '+AMPM;
      strDateTime =
        CC_Utility.getMonth(Integer.valueOf(dateSplit[1])) +
        ' ' +
        dateSplit[2] +
        ', ' +
        dateSplit[0];
    }
    return strDateTime;
  }
}
