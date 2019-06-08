package BackendDAEUtil
"
Brief:
contains all functions related to manipulate BackendDAE.
"
public 
import DAE;

protected 
import BackendEquation;
import BackendVariable;
import AvlSetInt;

/* 
 *
 * public functions section 
 *
 */
public

/******************************************************************
 stuff to calculate Adjacency matrix
******************************************************************/

public function adjacencyMatrix
"
"
  input DAE.VariableArray inVariables;
  input DAE.EquationArray inEquations;
  output DAE.AdjacencyMatrix outAdjacencyMatrix;
  output DAE.AdjacencyMatrix outAdjacencyMatrixT;

end adjacencyMatrix;

/* 
 *
 * protected functions section 
 *
 */
protected


end BackendDAEUtil;