public class CC_Utility {
  public static String getMonth(Integer month) {
    Map<Integer, String> monthMap = new Map<Integer, String>();
    monthMap.put(1, 'Jan');
    monthMap.put(2, 'Feb');
    monthMap.put(3, 'Mar');
    monthMap.put(4, 'Apr');
    monthMap.put(5, 'May');
    monthMap.put(6, 'Jun');
    monthMap.put(7, 'Jul');
    monthMap.put(8, 'Aug');
    monthMap.put(9, 'Sep');
    monthMap.put(10, 'Oct');
    monthMap.put(11, 'Nov');
    monthMap.put(12, 'Dec');
    return monthMap.get(month);
  }

  public static String getHours(Integer hour) {
    Map<Integer, String> hoursMap = new Map<Integer, String>();
    hoursMap.put(0, '12');
    hoursMap.put(1, '01');
    hoursMap.put(2, '02');
    hoursMap.put(3, '03');
    hoursMap.put(4, '04');
    hoursMap.put(5, '05');
    hoursMap.put(6, '06');
    hoursMap.put(7, '07');
    hoursMap.put(8, '08');
    hoursMap.put(9, '09');
    hoursMap.put(10, '10');
    hoursMap.put(11, '11');
    hoursMap.put(12, '12');
    hoursMap.put(13, '01');
    hoursMap.put(14, '02');
    hoursMap.put(15, '03');
    hoursMap.put(16, '04');
    hoursMap.put(17, '05');
    hoursMap.put(18, '06');
    hoursMap.put(19, '07');
    hoursMap.put(20, '08');
    hoursMap.put(21, '09');
    hoursMap.put(22, '10');
    hoursMap.put(23, '11');
    return hoursMap.get(hour);
  }
}
