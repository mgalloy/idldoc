var html;           // accumulated results page
var searchString;   // original search string
var nResults = 0;   // number of search results

// indices into a libdata entry
var URL          = 0;
var NAME         = 1;
var TYPE         = 2;
var FILENAME     = 3;
var AUTHORS      = 4;
var ROUTINE_NAME = 5;
var COMMENTS     = 6;
var PARAMETERS   = 7;
var MATCH_TYPE   = 8;
var N_MATCHES    = 9;
var SCORE        = 10;
var MATCHES      = 11;
var SORT         = 12;


/*
   Find results from the search.
*/



//  Returns true for a-zA-Z0-9 and &, false otherwise.
function isAlnum(ch) {
  if ((ch >= "a" && ch <= "z") || (ch == "&") || (ch >= "A" && ch <= "Z") || (ch >= "0" && ch <="9")) {
    return true;
  } else {
    return false;
  }
}


// find all the matches in a single item
function searchElement(item, matchType, upperSearchString) {
  var element = libdata[item][matchType].toUpperCase();
  var pos, origPos = 0;
  
  libdata[item][N_MATCHES] = 0;
  pos = element.indexOf(upperSearchString);
  
  while (pos >= 0) {
    origPos += pos + 1;
    
    libdata[item][MATCHES + libdata[item][N_MATCHES]] = origPos - 1;
    libdata[item][N_MATCHES]++;

    element = element.substring(pos + 1, element.length);
    while (isAlnum(element.charAt(0)) && element.length > 0) {
      element = element.substring(1, element.length);
      origPos++;
    }
    
    pos = element.indexOf(upperSearchString);
  }  
}


function searchItem(item, upperSearchString) {
  var matchType = TYPE;
  
  //html += "Searching " + item + "<br/>";
  
  // mark item as not matching
  libdata[item][MATCH_TYPE] = -1;
  
  // search FILENAME, AUTHORS, ROUTINE_NAME, COMMENTS, and PARAMETERS fields
  while (++matchType <= PARAMETERS && libdata[item][MATCH_TYPE] == -1) {
    searchElement(item, matchType, upperSearchString);
    if (libdata[item][N_MATCHES] > 0) {
      libdata[item][MATCH_TYPE] = matchType;
    }
  }
}


function sortResults() {
  for (item = 0; item < libdata.length; item++) {
    libdata[item][SORT] = item;
  }
  
  for (item = 1; item < libdata.length; item++) {
    tempScore = libdata[item][SCORE];
    tempSort = libdata[item][SORT];
  
    for (i = item; i > 1 && tempScore > libdata[i-1][SCORE]; i--) {
      libdata[i][SCORE] = libdata[i-1][SCORE];
      libdata[i][SORT] = libdata[i-1][SORT];
    }
  
    libdata[i][SCORE] = tempScore;
    libdata[i][SORT] = tempSort;
  }
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


function putItem(item) {
  html += "<li>";
  html += "<a href=\"" + libdata[item][URL] + "\" target=\"main_frame\">" + libdata[item][NAME] + "</a>";
  html += " - " + libdata[item][TYPE];
  html += "</li>";
}


function putResults() {
  for (var item = 0; item < libdata.length; item++) {
    if (libdata[item][N_MATCHES] > 0) {
    nResults++;
    }
  }
  
  if (nResults > 0) {
    html += "<ol>";
  }
  
  for (var item = 0; item < libdata.length; item++) {
    if (libdata[libdata[item][SORT]][N_MATCHES] > 0) {
    putItem(libdata[item][SORT]);
    }
  }
  
  if (nResults > 0) {
    html += "</ol>";
  }
}


function putFooter() {
  var plural = nResults == 1 ? "" : "s";
  html += "<p>" + nResults + " item" + plural + " found.</p>"
  
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
  
  putHeader();
    
  findResults();
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