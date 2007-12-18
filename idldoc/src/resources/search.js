var html;
var searchString;

var URL          = 0;
var TYPE         = 1;
var FILENAME     = 2;
var ROUTINE_NAME = 3;
var COMMENTS     = 4;
var PARAMETERS   = 5;
var KEYWORDS     = 6;
var MATCH_TYPE   = 7;
var N_MATCHES    = 8;
var SCORE        = 9;
var MATCHES      = 10;


/*
   Find results from the search.
*/
function searchItem(item, upperSearchString) {

}


function findResults() {
  upperSearchString = searchString.toUpperCase();
  for (var item = 0; item < libdata.length; item++) {
    searchItem(item, upperSearchString);
  }
  sortResults();
}


/*
   Create results web page. Results are written to the html variable
   and then sent to the browser.
*/

function putHeader() {
  html = "<html><head><title>Search results</title>";
  html += "<link rel=\"stylesheet\" type=\"text/css\" href=\"idldoc-resources/main.css\" />";
  html += "</head><body>";
  
  html += "<div class=\"header smaller\">";
  html += "<h1>" + title + "</h1>";
  html += "<h2>" + subtitle + "</h2>";  
  html += "</div";
  
  html += "<div class=\"content\">";
  html += "<h2>Search results for \"" + searchString + "\"</h2>";  
}


function putResults() {

}


function putFooter() {
  html += "</div></body></html>";
}


function writeResultsPage() {
  var htmlCode = html;
  
  iu = open("", "Object", "resizable=yes,scrollbars=yes,toolbar=no,menubar=no,location=no,directories=no,width=475,height=600");
  
  iu.document.open();
  iu.document.write(htmlCode);
  iu.document.close();
}

/* 
   Event handlers for forms on search page.
*/

function basicsearch() {
  searchString = document.basicForm.basicText.value;
  
  //alert("Searching...\n\nSearch terms = " + searchString);
  
  findResults();
  
  putHeader();
  putResults();
  putFooter();
  
  writeResultsPage();
}


function advancedsearch() {
  routineName = document.advancedForm.routinename.value;
  comments = document.advancedForm.comments.value;
  parameters = document.advancedForm.parameters.value;
  authors = document.advancedForm.authors.value;
  
  alert("Advanced searching...\n\nRoutine name = " + routineName + "\nComments = " + comments + "\nParameters = " + parameters + "\nAuthors = " + authors);
}