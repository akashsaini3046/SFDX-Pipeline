public class CC_Constants {
  public static final String GET_REQUEST_METHOD = 'GET';
  public static final String POST_REQUEST_METHOD = 'POST';
  public static final String PUT_REQUEST_METHOD = 'PUT';
  public static final String DELETE_REQUEST_METHOD = 'DELETE';
  public static final String BLANK_STRING = '';
  public static final String SPACE_STRING = ' ';
  public static final String DOT_STRING = '.';
  public static final String QUESTION_MARK_STRING = '?';
  public static final String EQUAL_STRING = '=';
  public static final String URL_ENCODE_FORMAT = 'UTF-8';
  public static final Integer DEFAULT_TIMEOUT = 30000;
  public static final String CLIENT_ID_STRING = 'client_id';
  public static final String CLIENT_SECRET_STRING = 'client_secret';
  public static final String CONTENT_TYPE = 'Content-Type';
  public static final String HEADERPANELRESPONSE_LASTNAME = 'LastName';
  public static final String HEADERPANELRESPONSE_FIRSTNAME = 'FirstName';
  public static final String SPANISH_LANGUAGECODE = 'es';
  public static final String SPANISH_LANGUAGE = 'Espanol';
  public static final String ENGLISH_LANGUAGE = 'English';
  public static final String HEADERPANELRESPONSE_LANGUAGE = 'language';
  public static final String ATTACHMENTLENGTH = 'attachmentlength';
  public static final String ATTACHMENTCONTENTTYPE = 'attachmentcontenttype';
  public static final String ATTACHMENTBODY = 'attachmentbody';
  public static final String COMMUNITYNAME = 'Community.Name';
  public static final String CREATEBYALIAS = 'CreatedBy.Alias';
  public static final String CREATEDBYNAME = 'CreatedBy.Name';
  public static final String IDEASFORWARDSLASH = 'idea-detail/';
  public static final String IMPLEMENTED_AND_CLOSED = 'Implemented';
  public static final String STATUS = 'status';
  public static final String IDEA = 'idea';
  public static final String UP = 'Up';
  public static final String DOWN = 'Down';
  public static final String DESCRIBELAYOUTGET = 'DescribeLayoutGET';
  public static final String DETAILLAYOUTSECTIONS = 'detailLayoutSections';
  public static final String LAYOUTROWS = 'layoutRows';
  public static final String LAYOUTITEMS = 'layoutItems';
  public static final String LABEL = 'label';
  public static final String LAYOUTCOMPONENTS = 'layoutComponents';
  public static final String DETAILS = 'details';
  public static final String PICKLISTVALUES = 'picklistValues';
  public static final String VALUE = 'value';
  public static final String ACTIVE = 'active';
  public static final String IDEA_MODERATOR_GROUP = 'Idea Moderator Group';
  public static final String CC_NEWIDEAPOSTED = 'CC_NewIdeaPosted';
  public static final String CC_IDEADELIVERED = 'CC_IdeaDelivered';
  public static final String PLAIN_TEXT_CONTENTTYPE = 'text/plain';
  public static final String TRUE_MESSAGE = 'True';
  public static final String FALSE_MESSAGE = 'False';
  public static final String ERROR_MESSAGE = 'Error';
  public static final String ACCOUNT_APINAME = 'Account';
  public static final String CONTACT_APINAME = 'Contact';
  public static final String CONTRACT_APINAME = 'Contract';
  public static final String ACCOUNT_DETAIL_SEARCH_CHILD_ACC_FIELDSET = 'Account_Detail_Search_Child_Acc';
  public static final String ACCOUNT_DETAIL_SEARCH_CONTACT_FIELDSET = 'Account_Detail_Search_Contact';
  public static final String ACCOUNT_DETAIL_SEARCH_CONTRACT_FIELDSET = 'Account_Detail_Search_Contract';
  public static final String LIMIT_STRING = 'LIMIT';
  public static final String OFFSET_STRING = 'OFFSET';
  public static final String AND_STRING = 'AND';
  public static final String GREATER_EQUAL_STRING = '>=';
  public static final String LESS_EQUAL_STRING = '<=';
  public static final String LABEL_STRING = 'label';
  public static final String VALUE_STRING = 'value';
  public static final String PAYMENT_COLLECT = 'CO';
  public static final String CONSIGNEE = 'CON';
  public static final String PREPAID = 'PP';
  public static final String SHIPPER = 'SHP';
  public static final String ID_STRING = 'Id';
  public static final String CURLY_BRACE_OPEN = '{';
  public static final String CURLY_BRACE_CLOSE = '}';
  public static final String EXCLAMATION_MARK = '!';
  public static final String DOLLAR_SYMBOL = '$';
  public static final String CUSTOM_LABEL = 'Label';
  public static final String ORIGIN_STRING = 'origin';
  public static final String DESTINATION_STRING = 'destination';
  public static final String DOOR_STRING = 'Door';
  public static final String PORT_STRING = 'Port';
  public static final String RAIL_STRING = 'Rail';
  public static final String D_CHAR = 'D';
  public static final String P_CHAR = 'P';
  public static final String R_CHAR = 'R';
  public static Set<string> PREPAID_SET = new Set<String>{ 'PP', 'Prepaid' };
  public static Set<string> COLLECT_SET = new Set<String>{
    'CC',
    'Collect',
    'Collected',
    'CO'
  };
  public static Set<string> SHIPPER_CONSIGNEE = new Set<String>{ 'CON', 'SHP' };
  public static final String QUOTE_STATUS = 'Sent to Pricing';
  public static final String PRICING_RECORDTYPE = 'Create_Pricing_Rate_Issue';
  public static final String PRICING_QUEUE = 'Pricing_Rate_Issue';
  public static final String PRICING_SUBJECT = 'Custom pricing request';
  public static final String PRICING_ORIGIN = 'Veloz';
  public static final String PRICING_STATUS = 'Open';
  public static final String PRICING_TYPE = 'Rate Request';
  public static final String PRICING_SERVICELOCATION = 'Unidentified';
  public static final String PRIORITY = 'Urgent';
  public static final String READY_DATE = 'Ready Date';
  public static final String PORT_TO_PORT = 'PP';
  public static final String DOOR_TO_DOOR = 'DD';
  public static final String PORT_TO_DOOR = 'PD';
  public static final String DOOR_TO_PORT = 'DP';
  public static final String RAIL_TO_PORT = 'RP';
  public static final String PORT_TO_RAIL = 'PR';
  public static final String DOOR_TO_RAIL = 'DR';
  public static final String RAIL_TO_DOOR = 'RD';
  public static final String RAIL_TO_RAIL = 'RR';
  public static final String ORIGIN_PORT = 'Origin Port';
  public static final String DESTINATION_PORT = 'Destination Port';
  public static final String ORIGIN_RAIL = 'Origin Rail';
  public static final String DESTINATION_RAIL = 'Destination Rail';
  public static final String ORIGIN = 'Origin';
  public static final String DESTINATION = 'Destination';
  public static final String BBULK_STRING = 'BBULK';
  public static final String AUTO_STRING = 'AUTO';
  public static final String EQUIP_STRING = 'EQUIP';
  public static final String EQUIP_DRY_STRING = 'EQUIP - DRY';
  public static final String LENGTH_STRING = 'Length';
  public static final String WIDTH_STRING = 'Width';
  public static final String HEIGHT_STRING = 'Height';
  public static final String QUANTITY_STRING = 'Quantity';
  public static final String WEIGHT_STRING = 'Weight';
  public static final String CARGO_WEIGHT_STRING = 'Cargo Weight';
  public static final String FREIGHTDETAILS = 'Freight Details';
  public static final String EQUIPMENTDETAILS = 'Equipment Details';
  public static final String LB_STRING = 'lb';
  public static final String FT_STRING = 'ft';
  public static final String M_STRING = 'm';
  public static final String CM_String = 'cm';
  public static final String IN_String = 'in';
  public static final String ADDITIONAL_INFO = 'Additional Information';
  public static final String QUOTE_STRING = 'Expired';
  public static final String MODEL_MANUFACTURER = 'Manufacturer-Model';
  public static final String OTHERS_STRING = 'Others';
  public static final String RAIL_RAMP_STRING = 'Rail Ramp';
  public static final String OUT_OF_GAUGE = 'Out Of Gauge';
  public static final String ISHAZARDOUS = 'Hazardous';
  public static final String COUNTRY_US = 'US';
  public static final String YES = 'Yes';
  public static final String NO = 'No';
}