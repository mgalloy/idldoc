function basicsearch() {
  searchString = document.basicForm.basicText.value;
  
  alert("Searching...\n\nSearch terms = " + searchString);
}

function advancedsearch() {
  routineName = document.advancedForm.routinename.value;
  comments = document.advancedForm.comments.value;
  parameters = document.advancedForm.parameters.value;
  authors = document.advancedForm.authors.value;
  
  alert("Advanced searching...\n\nRoutine name = " + routineName + "\nComments = " + comments + "\nParameters = " + parameters + "\nAuthors = " + authors);
}