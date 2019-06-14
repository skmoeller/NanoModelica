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
  outAdjacencyMatrixT:=adjacencyTranspose(outAdjacencyMatrix);
end adjacencyMatrix;

/*
 *
 * protected functions section
 *
 */
protected
  /*
  Function sets the Adjacency Matrix
  Calls treeSearchFunction to look up all variables
  */
  function setListAdjacency
    input DAE.VariableArray inVar;
    input DAE.Equation inEqn;
    output list<int> outlist;

  protected

  algorithm
    outlist:=treeSearch(DAE.UNARY(DAE.SUB(inEqn.lhs,inEqn.rhs)));
  end setListAdjacency;

  function treeSearch
    input DAE.Exp inEqn;
    output list<DAE.ComponentRef> lcref; //Hash function for index in another function

  algorithm
    lcref:={};
    _ := match()
      local Exp a,b;
      DAE.ComponentRef v;
    case DAE.CREF(v) then
      lcref:=v::lcref;
    case DAE.CALL(_,a) then
      /*Smart Stuff for expression list*/
    case DAE.BINARY(a,_,b) then
      treeSearch(a);
      treeSearch(b);
    case DAE.UNARY(_,a) then
        treeSearch(a);
    else then "";
    end match;


  end treeSearch


end BackendDAEUtil;
