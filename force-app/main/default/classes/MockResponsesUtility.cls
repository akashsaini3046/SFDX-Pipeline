/*
 * @company     : Nagarro Inc.
 * @date        : 29-06-2020
 * @author      : Nagarro
 * @description : Utility for Mock Responsed to be Used in Apex test classes
 * @history     : Version 1.0
 */
public class MockResponsesUtility {
  /*
   * @company     : Nagarro Inc.
   * @date        : 29-06-2020
   * @author      : Nagarro
   * @description : Utility for Mock Responsed to be Used for Describe Layout service callout test class in Idea Community
   * @history     : Version 1.0
   */
  public class DescribeLayoutMockResponse implements HttpCalloutMock {
    public boolean isError;
    public DescribeLayoutMockResponse(boolean isError) {
      this.isError = isError;
    }
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource staticResRecord = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'describeLayoutMockResponse'
        LIMIT 1
      ];
      String jsonData = staticresRecord.Body.toString();
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      if (isError) {
        res.setBody('{"error" : true}');
        res.setStatusCode(500);
      } else {
        res.setBody(jsonData);
        res.setStatusCode(200);
      }
      return res;
    }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 29-06-2020
   * @author      : Nagarro
   * @description : Utility for Mock Responsed to be Used for API Callout Utility Test class
   * @history     : Version 1.0
   */
  public class APIUtilityMockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"success":true}');
      res.setStatusCode(200);
      if (req.getEndpoint().contains('getservice')) {
        System.assertEquals('GET', req.getMethod());
      } else if (req.getEndpoint().contains('postservice')) {
        System.assertEquals('POST', req.getMethod());
      } else if (req.getEndpoint().contains('putservice')) {
        System.assertEquals('PUT', req.getMethod());
      } else if (req.getEndpoint().contains('deleteservice')) {
        System.assertEquals('DELETE', req.getMethod());
      } else {
        res.setStatusCode(500);
      }
      return res;
    }
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 09-09-2020
   * @author      : Nagarro
   * @description : Utility for Mock Responsed to be Used for Softship Rating API callout test class
   * @history     : Version 1.0
   */
  public class SoftShipMockResponse implements HttpCalloutMock {
    public boolean isError;
    public SoftShipMockResponse(boolean isError) {
      this.isError = isError;
    }
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource staticResRecord = [
        SELECT Id, Body
        FROM StaticResource
        WHERE Name = 'SoftShipMockResponse'
        LIMIT 1
      ];
      String jsonData = staticresRecord.Body.toString();
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      if (isError) {
        res.setBody('{"error" : true}');
        res.setStatusCode(500);
      } else {
        res.setBody(jsonData);
        res.setStatusCode(200);
      }
      return res;
    }
  }
}
