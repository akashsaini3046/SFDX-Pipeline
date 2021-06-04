/*
 * 29-05-2020 – Drupad Preenja – Created this class for handling functionality related to API Callouts.
 * 17-07-2020 – Drupad Preenja – Added urlSuffix to the callAPIResponseService for dynamic values in the url.
 */

/*
 * @company     : Nagarro Inc.
 * @date        : 29-05-2020
 * @author      : Nagarro
 * @description : Utility for API callouts
 * @history     : Version 1.0
 * @test class  : APICalloutUtilityTest
 */
public without sharing class APICalloutUtility {
  /*
   * @purpose     : Method to get the API response for the Service
   * @parameter   : serviceName - The name of the service from the Integration_Service__mdt Custom Metadata
   * @parameter   : requestBody - The JSON Request body in the form of String for the callout request
   * @parameter   : queryParams - The Map containing the key value pair of the query parameters for the request
   * @parameter   : queryParams - The Map containing the key value pair of the query parameters for the request
   * @return      : JSON response in the form of String
   */
  public static String callAPIResponseService(
    String serviceName,
    String requestBody,
    Map<String, String> queryParams,
    String urlSuffix
  ) {
    if (serviceName == null && serviceName == CC_Constants.BLANK_STRING) {
      return CC_Constants.BLANK_STRING;
    }
    Integration_Service__mdt apiService = getIntegrationServiceMdt(serviceName);
    if (apiService == null) {
      return CC_Constants.BLANK_STRING;
    }
    Service_Environment_Param__mdt serviceParameter = getServiceEnvironmentParams(
      apiService
    );
    if (serviceParameter == null) {
      return CC_Constants.BLANK_STRING;
    }

    Map<String, String> headers = null;
    if (
      serviceParameter != null &&
      serviceParameter.Client_Id__c != null &&
      serviceParameter.Client_Secret__c != null
    ) {
      headers = new Map<String, String>();
      headers.put(CC_Constants.CLIENT_ID_STRING, serviceParameter.Client_Id__c);
      headers.put(
        CC_Constants.CLIENT_SECRET_STRING,
        serviceParameter.Client_Secret__c
      );
    }
    if (apiService.Content_Type__c != null) {
      headers = headers != null ? headers : new Map<String, String>();
      headers.put(CC_Constants.CONTENT_TYPE, apiService.Content_Type__c);
    }
    String certificateName = null;
    if (serviceParameter.Certificate_Name__c != null) {
      certificateName = serviceParameter.Certificate_Name__c;
    }

    String endpointUrl =
      serviceParameter.Baseurl__c +
      apiService.Service__c +
      (urlSuffix != null ? urlSuffix : CC_Constants.BLANK_STRING);
    if (
      apiService.Request_Type__c.equalsIgnoreCase(
        CC_Constants.GET_REQUEST_METHOD
      )
    ) {
      endpointUrl = getEndpointUrlWithQueryParams(endpointUrl, queryParams);
      return sendGet(
        endpointUrl,
        headers,
        Integer.valueOf(apiService.Timeout__c),
        certificateName
      );
    } else if (
      apiService.Request_Type__c.equalsIgnoreCase(
        CC_Constants.POST_REQUEST_METHOD
      )
    ) {
      return sendPost(
        endpointUrl,
        headers,
        requestBody,
        Integer.valueOf(apiService.Timeout__c),
        certificateName
      );
    } else if (
      apiService.Request_Type__c.equalsIgnoreCase(
        CC_Constants.PUT_REQUEST_METHOD
      )
    ) {
      return sendPut(
        endpointUrl,
        headers,
        requestBody,
        Integer.valueOf(apiService.Timeout__c),
        certificateName
      );
    } else if (
      apiService.Request_Type__c.equalsIgnoreCase(
        CC_Constants.DELETE_REQUEST_METHOD
      )
    ) {
      return sendDelete(
        endpointUrl,
        headers,
        requestBody,
        Integer.valueOf(apiService.Timeout__c),
        certificateName
      );
    }
    return CC_Constants.BLANK_STRING;
  }

  /*
   * @purpose     : Method to get the Service Environment Param Metadata from the apiService provided
   * @parameter   : apiService - The Integration Service Metadata
   * @return      : Service Environment Param corresponding to the Integration Service
   */
  private static Service_Environment_Param__mdt getServiceEnvironmentParams(
    Integration_Service__mdt apiService
  ) {
    Service_Environment_Param__mdt serviceParameter = null;
    Service_Environment__c serviceEnvironment = null;
    if (
      apiService != null &&
      apiService.Related_Service_Environment_Name__c != null
    ) {
      String serviceEnvName = apiService.Related_Service_Environment_Name__c;
      if (serviceEnvironCSMap.get(serviceEnvName.toLowerCase()) != null) {
        serviceEnvironment = serviceEnvironCSMap.get(
          serviceEnvName.toLowerCase()
        );
      }
    }
    if (
      serviceEnvironment != null &&
      serviceEnvironment.Environment__c != null
    ) {
      serviceParameter = getServiceParamteres(
        serviceEnvironment.Name.toLowerCase() +
        serviceEnvironment.Environment__c.toLowerCase()
      );
    }
    return serviceParameter;
  }

  /*
   * @purpose     : Method to get the Endpoint URL with query parameters
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : queryParams - The Map containing the key value pair of the query parameters for the request
   * @return      : Enpoint URL (With Query Parameters) String
   */
  private static String getEndpointUrlWithQueryParams(
    String endpointUrl,
    Map<String, String> queryParams
  ) {
    if (queryParams != null && !queryParams.isEmpty()) {
      endpointUrl += CC_Constants.QUESTION_MARK_STRING;
      for (String key : queryParams.keySet()) {
        endpointUrl +=
          key +
          CC_Constants.EQUAL_STRING +
          EncodingUtil.urlEncode(
            queryParams.get(key),
            CC_Constants.URL_ENCODE_FORMAT
          );
      }
    }
    return endpointUrl;
  }

  /*
   * @purpose     : Method to send the GET request with headers
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : JSON response in the form of String
   */
  private static String sendGet(
    String endpointUrl,
    Map<String, String> headers,
    Integer requestTimeout,
    String certificateName
  ) {
    return sendRequestCheckResult(
      endpointUrl,
      headers,
      CC_Constants.GET_REQUEST_METHOD,
      null,
      requestTimeout,
      certificateName
    );
  }

  /*
   * @purpose     : Method to send the POST request with headers
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : requestBody - The Request body in the form of String
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : JSON response in the form of String
   */
  private static String sendPost(
    String endpointUrl,
    Map<String, String> headers,
    String requestBody,
    Integer requestTimeout,
    String certificateName
  ) {
    return sendRequestCheckResult(
      endpointUrl,
      headers,
      CC_Constants.POST_REQUEST_METHOD,
      requestBody,
      requestTimeout,
      certificateName
    );
  }

  /*
   * @purpose     : Method to send the PUT request with headers
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : requestBody - The Request body in the form of String
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : JSON response in the form of String
   */
  private static String sendPut(
    String endpointUrl,
    Map<String, String> headers,
    String requestBody,
    Integer requestTimeout,
    String certificateName
  ) {
    return sendRequestCheckResult(
      endpointUrl,
      headers,
      CC_Constants.PUT_REQUEST_METHOD,
      requestBody,
      requestTimeout,
      certificateName
    );
  }

  /*
   * @purpose     : Method to send the GET request with headers
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : requestBody - The Request body in the form of String
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : JSON response in the form of String
   */
  private static String sendDelete(
    String endpointUrl,
    Map<String, String> headers,
    String requestBody,
    Integer requestTimeout,
    String certificateName
  ) {
    return sendRequestCheckResult(
      endpointUrl,
      headers,
      CC_Constants.DELETE_REQUEST_METHOD,
      requestBody,
      requestTimeout,
      certificateName
    );
  }

  /*
   * @purpose     : Method to send the request with all the details of the request
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : method - The Request Method
   * @parameter   : requestBody - The Request body in the form of String
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : JSON response in the form of String
   */
  private static String sendRequestCheckResult(
    String endpointUrl,
    Map<String, String> headers,
    String method,
    String requestBody,
    Integer requestTimeout,
    String certificateName
  ) {
    HttpResponse response;
    response = sendRequest(
      endpointUrl,
      headers,
      method,
      requestBody,
      requestTimeout,
      certificateName
    );
    if (response == null) {
      return null;
    }
    if (response.getStatusCode() < 200 || response.getStatusCode() >= 400) {
      throw new APICalloutUtilityException(
        'Error in sending callout to: ' +
        endpointUrl +
        ' with body: ' +
        requestBody +
        '. Response from server: ' +
        response.getBody()
      );
    }
    return response.getBody();
  }

  /*
   * @purpose     : Method to send the request and retreive the response
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : method - The Request Method
   * @parameter   : requestBody - The Request body in the form of String
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : HttpResponse object containing the response from the callout request
   */
  private static HttpResponse sendRequest(
    String endpointUrl,
    Map<String, String> headers,
    String method,
    String requestBody,
    Integer requestTimeout,
    String certificateName
  ) {
    HttpResponse result = null;
    if (endpointUrl == null || endpointUrl == CC_Constants.BLANK_STRING) {
      return null;
    }
    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint(endpointUrl);
      request.setMethod(method);
      if (requestTimeout != null) {
        request.setTimeout(requestTimeout);
      } else {
        request.setTimeout(CC_Constants.DEFAULT_TIMEOUT);
      }
      if (
        certificateName != null &&
        certificateName != CC_Constants.BLANK_STRING
      ) {
        request.setClientCertificateName(certificateName);
      }
      if (requestBody != null) {
        request.setBody(requestBody);
      }
      if (headers != null) {
        for (String key : headers.keySet()) {
          request.setHeader(key, headers.get(key));
        }
      }
      //LogFactory.info('APICalloutUtility', 'sendRequest', 'API Callout Request', endpointUrl + ' - '+ method+'*** Sending request to: ' + endpointUrl + '. Content header: ' + request.getHeader('content-type') + '. Body: ' + requestBody);
      result = http.send(request);

      //LogFactory.info('APICalloutUtility', 'sendRequest', 'API Callout Response', '*** Response: ' + result.getStatus() + '. Body: ' + result.getBody());
    } catch (Exception ex) {
      LogFactory.error(
        'APICalloutUtility',
        'sendRequest',
        'API Callout',
        'Line Number : ' +
        ex.getLineNumber() +
        ' Message : ' +
        ex.getMessage() +
        ' Stack Trace :' +
        ex.getStackTraceString()
      );
    }
    LogFactory.saveLog();
    return result;
  }

  /*
   * @purpose     : Method to create Continuation API Request
   * @parameter   : endpointUrl - The Endpoint URL of the request
   * @parameter   : headers - The Map of headers for the request
   * @parameter   : method - The Request Method
   * @parameter   : requestBody - The Request body in the form of String
   * @parameter   : requestTimeout - The Time-Out value for the request
   * @parameter   : certificateName - The name of the Client Certificate for the request
   * @return      : HttpRequest object containing the Request for the requested service
   */
  public static HttpRequest createContinuationAPIRequest(
    String serviceName,
    String requestBody,
    Map<String, String> queryParams,
    String urlSuffix
  ) {
    if (serviceName == null && serviceName == CC_Constants.BLANK_STRING) {
      return null;
    }
    Integration_Service__mdt apiService = getIntegrationServiceMdt(serviceName);
    if (apiService == null) {
      return null;
    }
    Service_Environment_Param__mdt serviceParameter = getServiceEnvironmentParams(
      apiService
    );
    if (serviceParameter == null) {
      return null;
    }
    Map<String, String> headers = null;
    if (
      serviceParameter.Client_Id__c != null &&
      serviceParameter.Client_Secret__c != null
    ) {
      headers = new Map<String, String>();
      headers.put(CC_Constants.CLIENT_ID_STRING, serviceParameter.Client_Id__c);
      headers.put(
        CC_Constants.CLIENT_SECRET_STRING,
        serviceParameter.Client_Secret__c
      );
    }
    if (apiService != null && apiService.Content_Type__c != null) {
      headers = headers != null ? headers : new Map<String, String>();
      headers.put(CC_Constants.CONTENT_TYPE, apiService.Content_Type__c);
    }
    String certificateName = null;
    if (serviceParameter.Certificate_Name__c != null) {
      certificateName = serviceParameter.Certificate_Name__c;
    }

    String endpointUrl =
      serviceParameter.Baseurl__c +
      apiService.Service__c +
      (urlSuffix != null ? urlSuffix : CC_Constants.BLANK_STRING);
    if (
      apiService.Request_Type__c.equalsIgnoreCase(
        CC_Constants.GET_REQUEST_METHOD
      )
    ) {
      endpointUrl = getEndpointUrlWithQueryParams(endpointUrl, queryParams);
    }

    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpointUrl);
    request.setMethod(apiService.Request_Type__c);
    request.setTimeout(120);
    if (
      certificateName != null &&
      certificateName != CC_Constants.BLANK_STRING
    ) {
      request.setClientCertificateName(certificateName);
    }
    if (requestBody != null) {
      request.setBody(requestBody);
    }
    if (headers != null) {
      for (String key : headers.keySet()) {
        system.debug('key--->>>>' + key);
        request.setHeader(key, headers.get(key));
      }
    }
    return request;
  }

  /*
   * @purpose     : Method to get Integration Parameter for the service name provided
   * @parameter   : serviceName - The name of the service request in the metadata
   * @return      : Integration_Parameters__mdt - a metadata containing the details of the callout request
   */
  private static Integration_Service__mdt getIntegrationServiceMdt(
    String serviceName
  ) {
    if (
      integrationServiceMdtMap != null &&
      integrationServiceMdtMap.containsKey(serviceName)
    ) {
      return integrationServiceMdtMap.get(serviceName);
    }
    return null;
  }

  /*
   * @purpose     : Method to get Service Environment Parameter for the service name provided
   * @parameter   : masterlabel - Combination of Service Name and Enviroment.
   * @return      : Service_Environment_Param__mdt - a metadata containing Service Enviroment Paramter details for the callout request
   */
  private static Service_Environment_Param__mdt getServiceParamteres(
    String masterlabel
  ) {
    if (
      serviceParamsMdtMap != null &&
      serviceParamsMdtMap.containsKey(masterlabel)
    ) {
      return serviceParamsMdtMap.get(masterlabel);
    }
    return null;
  }

  // Getter and Setter for Map of Service Name as key and Integration_Parameters__mdt as value
  public static Map<String, Integration_Service__mdt> integrationServiceMdtMap {
    get {
      if (integrationServiceMdtMap == null) {
        integrationServiceMdtMap = new Map<String, Integration_Service__mdt>();
        for (Integration_Service__mdt metadataRecord : [
          SELECT
            Id,
            MasterLabel,
            Content_Type__c,
            Request_Type__c,
            Timeout__c,
            Service__c,
            Related_Service_Environment_Name__c
          FROM Integration_Service__mdt
        ]) {
          integrationServiceMdtMap.put(
            metadataRecord.MasterLabel,
            metadataRecord
          );
        }
      }
      return integrationServiceMdtMap;
    }
    set;
  }

  // Getter and Setter for Map of Masterlabel of custom setting as key and Service_Environment__c as value
  public static Map<String, Service_Environment__c> serviceEnvironCSMap {
    get {
      if (serviceEnvironCSMap == null) {
        serviceEnvironCSMap = new Map<String, Service_Environment__c>();
        for (String name : Service_Environment__c.getAll().keySet()) {
          serviceEnvironCSMap.put(
            name.toLowerCase(),
            Service_Environment__c.getAll().get(name)
          );
        }
      }
      return serviceEnvironCSMap;
    }
    set;
  }

  // Getter and Setter for Map of Service Name as key and Service_Environment_Param__mdt as value
  public static Map<String, Service_Environment_Param__mdt> serviceParamsMdtMap {
    get {
      if (serviceParamsMdtMap == null) {
        serviceParamsMdtMap = new Map<String, Service_Environment_Param__mdt>();
        for (Service_Environment_Param__mdt metadataRecord : [
          SELECT
            Id,
            MasterLabel,
            Baseurl__c,
            Client_Id__c,
            Client_Secret__c,
            Certificate_Name__c
          FROM Service_Environment_Param__mdt
        ]) {
          serviceParamsMdtMap.put(
            metadataRecord.MasterLabel.toLowerCase(),
            metadataRecord
          );
        }
      }
      return serviceParamsMdtMap;
    }
    set;
  }

  /*
   * @company     : Nagarro Inc.
   * @date        : 29-05-2020
   * @author      : Nagarro
   * @description : Exception Class for the API callout Utility Service
   * @history     : Version 1.0
   */
  public class APICalloutUtilityException extends Exception {
  }
}
