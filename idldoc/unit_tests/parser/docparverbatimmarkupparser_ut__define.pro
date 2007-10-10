;+
; Test a simple three lines of text.
;
; :Returns: 1 for pass, 0 for fail
;-
function docparverbatimmarkupparser_ut::test_simple
  compile_opt strictarr
  
  code = ['This is a comment', 'Another comment', 'Last comment']
  tree = self.parser->parse(code)
  
  tree->getProperty, n_children=nChildren
  assert, obj_isa(tree, 'MGtmTag'), 'wrong class for tree'
  assert, nChildren eq 6, 'wrong number of children'
  
  child = tree->getChild(0)
  assert, obj_isa(child, 'MGtmText'), 'wrong class for child 0'
  child->getProperty, text=text
  assert,  text eq code[0], 'wrong text for child 0'
  
  child = tree->getChild(1)
  assert, obj_isa(child, 'MGtmTag'), 'wrong class for child 1'
  child->getProperty, type=type
  assert,  type eq 'newline', 'wrong type for child 1'
      
  child = tree->getChild(2)
  assert, obj_isa(child, 'MGtmText'), 'wrong class for child 2'
  child->getProperty, text=text
  assert,  text eq code[1], 'wrong text for child 2'

  child = tree->getChild(3)
  assert, obj_isa(child, 'MGtmTag'), 'wrong class for child 3'
  child->getProperty, type=type
  assert,  type eq 'newline', 'wrong type for child 3'
    
  child = tree->getChild(4)
  assert, obj_isa(child, 'MGtmText'), 'wrong class for child 4'
  child->getProperty, text=text
  assert,  text eq code[2], 'wrong text for child 4'    

  child = tree->getChild(5)
  assert, obj_isa(child, 'MGtmTag'), 'wrong class for child 5'
  child->getProperty, type=type
  assert,  type eq 'newline', 'wrong type for child 5'
    
  obj_destroy, tree
  
  return, 1
end


;+
; Setup parser.
;-
pro docparverbatimmarkupparser_ut::setup
  compile_opt strictarr

  root = filepath('', $
                  subdir=['unit_tests', 'examples'], $
                  root=self.root)
  output = filepath('', $
                    subdir=['unit_tests', 'examples-docs'], $
                    root=self.root)
  self.system = obj_new('DOC_System', root=root, output=output, /silent)
    
  self.parser = obj_new('DOCparVerbatimMarkupParser', system=self.system)
end


;+
; Free parser.
;-
pro docparverbatimmarkupparser_ut::teardown
  compile_opt strictarr
  
  obj_destroy, [self.system, self.parser]
end


;+
; Define instance variables.
; 
; :Fields:
;    `parser` verbatim parser to test
;-
pro docparverbatimmarkupparser_ut__define
  compile_opt strictarr
  
  define = { DOCparVerbatimMarkupParser_ut, inherits DOCutTestCase, $
             system: obj_new(), $
             parser: obj_new() $
           }
end