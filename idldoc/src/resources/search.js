var html;
var searchString;


function putResults() {

}


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


function basicsearch() {
  searchString = document.basicForm.basicText.value;
  
  //alert("Searching...\n\nSearch terms = " + searchString);
  
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