public with sharing class CustomAccountLookupController {
  public User user { get; set; } // new account to create
  public List<User> results { get; set; } // search results
  public string searchString { get; set; } // search keyword
  public string Photolink { get; set; }

  public CustomAccountLookupController(ApexPages.StandardController acc) {
    user = new User();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    runSearch();
  }

  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }

  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);
  }

  // run the search and return the records found.
  private List<User> performSearch(string searchString) {
    String soql = 'select id, name, email, FullPhotoUrl from user';
    if (searchString != '' && searchString != null) {
      soql =
        soql +
        ' where isActive = TRUE AND name LIKE \'%' +
        searchString +
        '%\'';
    }
    soql = soql + ' limit 500';
    return database.query(soql);
  }

  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }

  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
}
