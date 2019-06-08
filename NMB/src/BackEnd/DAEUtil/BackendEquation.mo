package BackendEquation
"
Brief:
contains all functions related to the
DAE.EquationArray and the DAE.Equation type.
"
import DAE;  
/* 
 *
 * public functions section 
 *
 */
public

function get
  input DAE.EquationArray inEqs;
  input Integer idx;
  output DAE.Equation outEq;
protected 
  array<DAE.Equation> eqs;
algorithm
  eqs := inEqs.equations;
  outEq := eqs[idx];
end get;

function equationListToArray 
  input list<DAE.Equation> inEqnList;
  output DAE.EquationArray outEqnsArray;
algorithm
   outEqnsArray := DAE.EQUATION_ARRAY(listLength(inEqnList), 
                    listArray(inEqnList));
end equationListToArray;

/* 
 *
 * protected functions section 
 *
 */
protected

  
end BackendEquation;