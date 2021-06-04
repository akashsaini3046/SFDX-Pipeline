@isTest
public class CC_SoftshipRatingRequestTest {
  @isTest
  static void TestInitialiseCC_SoftshipRatingRequest() {
    Test.startTest();
    CC_SoftshipRatingRequest newRequest = new CC_SoftshipRatingRequest();
    newRequest.Booking = null;
    newRequest.Action = 'action test';
    //newRequest.CalcRule='Test Rule';
    newRequest.maxRoutes = 2;
    newRequest.MaxNumberOfSchedules = 5;
    newRequest.DefaultOptionalServices = 'True';
    newRequest.SelectedRoute = 1;
    Test.stopTest();
  }
}
