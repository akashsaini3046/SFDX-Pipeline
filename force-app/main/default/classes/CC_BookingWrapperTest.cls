@isTest
public class CC_BookingWrapperTest {
  @isTest
  static void TestgetBookingWrapper() {
    Test.startTest();

    CC_BookingWrapper newBookingWrap = new CC_BookingWrapper();
    newBookingWrap = CC_BookingWrapper.getBookingWrapper();
    Test.stopTest();
    System.assertNotEquals(
      null,
      newBookingWrap,
      'BookingWrapper should not be null '
    );
  }

  @isTest
  static void TestHazardousSubstanceWrapper() {
    Test.startTest();
    CC_BookingWrapper.HazardousSubstanceWrapper hazWrap = new CC_BookingWrapper.HazardousSubstanceWrapper();
    Test.stopTest();
    System.assertNotEquals(
      null,
      hazWrap,
      'Hazardous Substance Wrapper should not be null '
    );
  }

  @isTest
  static void TestVinWrapper() {
    Test.startTest();
    CC_BookingWrapper.VinWrapper VinWrap = new CC_BookingWrapper.VinWrapper();
    Test.stopTest();
    System.assertNotEquals(null, VinWrap, 'VinWrapper should not be null ');
  }
}
