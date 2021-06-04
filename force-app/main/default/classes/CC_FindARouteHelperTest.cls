@isTest
public class CC_FindARouteHelperTest {
  @isTest
  static void TestgetSchedulesTest() {
    String jsonResponseString = '{"success":true,"result":[{"Success":false,"Schedules":[{"TotalDuration":"3.11:30:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-08T03:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-08T03:00:00","LocalPortTime":"2020-09-08T03:10:12"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"NZV0108"},"VesselName":"Paradero","VesselCode":{"Code":"PAR"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"Puerto Cortes Term, Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-12T00:00:00","LocalPortTime":"2020-09-08T03:11:15"},"Arrival":{"Utc":"2020-09-11T11:30:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"Port Everglades, FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"Puerto Cortes, Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":true,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-08T03:00:00","LocalPortTime":"2020-09-08T03:11:15"},"Arrival":{"Utc":"2020-09-07T11:00:00","LocalPortTime":"2020-09-08T03:11:15"}}]},"FromSubDisplayName":"Port Everglades Term, FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-08T03:00:00","LocalPortTime":"2020-09-08T03:11:15"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-11T16:30:00","LocalPortTime":"2020-09-08T03:11:01"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-11T16:30:00","LocalPortTime":"2020-09-08T03:10:12"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-11T16:30:00","LocalPortTime":"2020-09-08T03:11:00"},"addedHours":null}]}]}';
    CC_SoftshipRatingResponse resWrap = (CC_SoftshipRatingResponse) JSON.deserialize(
      jsonResponseString,
      CC_SoftshipRatingResponse.class
    );

    test.startTest();
    List<CC_SoftshipRatingResponse.Schedules> schedules = CC_FindARouteHelper.getSchedules(
      resWrap
    );
    test.stopTest();
    System.assertNotEquals(null, schedules, 'Should not be null');
  }
  @isTest
  static void NegativegetSchedulesTest() {
    String jsonResponseString = '{"success":true,"result":[{"Success":false,"Schedules":[{"TotalDuration":"3.11:30:00","totalDays":null,"StartSailingDate":{"Utc":"2020-09-08T03:00:00"},"startLocationCode":null,"startLocation":null,"StartDate":{"Utc":"2020-09-08T03:00:00","LocalPortTime":"2020-09-08T03:10:12"},"sequenceNumber":null,"Segments":[{"VoyageNumber":{"NumberX":"NZV0108"},"VesselName":"Paradero","VesselCode":{"Code":"PAR"},"TransportModeCode":{"Type":"O","Code":"OWN"},"ToSubDisplayName":"Puerto Cortes Term, Honduras","ToLocation":{"Code":"HNPCR"},"To":{"Berths":[{"Departure":{"Utc":"2020-09-12T00:00:00","LocalPortTime":"2020-09-08T03:11:15"},"Arrival":{"Utc":"2020-09-11T11:30:00"}}]},"StopSequence":null,"Leg":{"TransshipmentMatrixDetailId":922,"TransportMode":{"Type":"O","Code":"OWN"},"StayTimePol":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StayTimePod":{"TimeUnit":"d","AmountInDays":0.208333333333333,"Amount":0.208333333333333},"StartPosition":{"SubLocationCode":{"Code":"PEFT001"},"LocationCode":{"Code":"USPEF"},"DisplayName":"Port Everglades, FL"},"LegSeqNumber":1,"EndPosition":{"SubLocationCode":{"Code":"PCRT001"},"LocationCode":{"Code":"HNPCR"},"DisplayName":"Puerto Cortes, Honduras"},"Duration":{"TimeUnit":"d","AmountinMinuteRounded":3600.00,"AmountinHours":60.00,"AmountInDays":2.5,"Amount":2.5}},"IsTBN":false,"IsOcean":false,"FromX":{"Berths":[{"Departure":{"Utc":"2020-09-08T03:00:00","LocalPortTime":"2020-09-08T03:11:15"},"Arrival":{"Utc":"2020-09-07T11:00:00","LocalPortTime":"2020-09-08T03:11:15"}}]},"FromSubDisplayName":"Port Everglades Term, FL","FromLocation":{"Code":"USPEF"},"DepartureTime":{"Utc":"2020-09-08T03:00:00","LocalPortTime":"2020-09-08T03:11:15"},"arrivalToDisplay":null,"ArrivalTime":{"Utc":"2020-09-11T16:30:00","LocalPortTime":"2020-09-08T03:11:01"}}],"numberOfStops":null,"EndSailingDate":{"Utc":"2020-09-11T16:30:00","LocalPortTime":"2020-09-08T03:10:12"},"endLocationCode":null,"endLocation":null,"EndDate":{"Utc":"2020-09-11T16:30:00","LocalPortTime":"2020-09-08T03:11:00"},"addedHours":null}]}]}';
    CC_SoftshipRatingResponse resWrap = (CC_SoftshipRatingResponse) JSON.deserialize(
      jsonResponseString,
      CC_SoftshipRatingResponse.class
    );

    test.startTest();
    List<CC_SoftshipRatingResponse.Schedules> schedules = CC_FindARouteHelper.getSchedules(
      resWrap
    );
    test.stopTest();
    System.assertNotEquals(null, schedules, 'Should not be null');
  }
  @isTest
  static void getDateTimeTest() {
    String LocalPortTime = '2020-09-08T03:12:13';
    String res;
    test.startTest();
    res = CC_FindARouteHelper.getDateTime(LocalPortTime);
    test.stopTest();
    System.assertNotEquals(res, null);
  }
}
