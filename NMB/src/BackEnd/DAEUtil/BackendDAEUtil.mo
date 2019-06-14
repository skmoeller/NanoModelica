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

protected
Integer i;

algorithm

  for i form 1 to inEquations.size loop
    outAdjacencyMatrix[i]:=setListAdjacency(inVariables,inEquations.equations[i]);
  end


end adjacencyMatrix;

/*
 *
 * protected functions section
 *
 */
protected

  function setListAdjacency
    input DAE.VariableArray inVar;
    input DAE.Equation inEqn;
    output list<int> outlist;

  protected

  algorithm


  end setListAdjacency;

  function hash_idx
    input String inVar;
    input DAE.VariableArray.variableIndices;
    output Integer index;

  protected
    Integer h;
    list<DAE.CREF_INDEX>lcref;

  algorithm
    h:=hash(inVar);



end BackendDAEUtil;
