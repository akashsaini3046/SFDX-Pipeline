({
  setInitValues: function (component, event, helper, routeRecord) {
    var schedules = [];
    if (routeRecord.Schedules) {
      schedules = routeRecord.Schedules;
    }
    var scheduleItems = [];
    schedules.map((schedule) => {
      var sch = {};
      sch.departureDate = this.handleDates(schedule.StartDate.LocalPortTime);
      sch.arrivalDate = this.handleDates(schedule.EndDate.LocalPortTime);
      sch.transitTime = this.getTransitTime(schedule.TotalDuration);
      sch.transitTimeHrs = this.getTransitTimeHrs(schedule.TotalDuration);
      sch.departureDateSort = schedule.StartDate.LocalPortTime;
      scheduleItems.push(sch);
    });
    var sortedSchedules = scheduleItems;
    if (schedules.length > 0) {
      sortedSchedules = this.sortData(
        "departureDateSort",
        "asc",
        scheduleItems
      );
    }
    component.set("v.scheduleItems", sortedSchedules);
  },

  handleDates: function (dates) {
    dates = dates.substr(0, 10);
    return $A.localizationService.formatDate(dates, "MMM dd, yyyy");
  },
  getTransitTime: function (duration) {
    var day = 0;
    if (duration) {
      var daysVsHours = duration + "";
      if (daysVsHours.includes(".")) {
        daysVsHours = daysVsHours.split(".");
        day = daysVsHours[0] ? parseInt(daysVsHours[0]) : 0;
      }
    }
    return day;
  },
  getTransitTimeHrs: function (duration) {
    var time = 0;
    if (duration) {
      var daysVsHours = duration + "";
      if (daysVsHours.includes(".")) {
        daysVsHours = daysVsHours.split(".");
        time = daysVsHours[1]
          ? daysVsHours[1].split(":").length > 0
            ? parseInt(daysVsHours[1].split(":")[0])
            : 0
          : 0;
      }
    }
    return time;
  },
  /*getTransitTime: function(duration){
        var day = 0;
        if(duration){
            var daysVsHours = duration + '';
            if(daysVsHours.includes('.')){
                daysVsHours = daysVsHours.split('.');
            }else{
                var time = daysVsHours;
                daysVsHours = [];
                daysVsHours.push('0');
                daysVsHours.push(time);
            }
            day = daysVsHours[0] ? parseInt(daysVsHours[0]) : 0;
            var time = daysVsHours[1] ? (daysVsHours[1].split(':').length > 0 ? parseInt(daysVsHours[1].split(':')[0]) : 0) : 0;
            if (time > 12) {
              day++;
            }
            if(day == 0){
                day = 1;
            }
        }
        return day;
    },*/
  sortData: function (fieldname, direction, parsedJson) {
    var parseData = parsedJson;
    var isReverse = direction === "asc" ? 1 : -1;
    parseData.sort((x, y) => {
      x = x[fieldname] ? x[fieldname] : "";
      y = y[fieldname] ? y[fieldname] : "";
      return isReverse * ((x > y) - (y > x));
    });
    return parseData;
  }
});
