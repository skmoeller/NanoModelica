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
  for i in 1:inEquations.size loop
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
    outlist:=treeSearch(DAE.UNARY(DAE.SUB(inEqn.lhs,inEqn.rhs)),inVar);
  end setListAdjacency;

  function treeSearch
    input DAE.Exp inEqn;
    input DAE.VariableArray inVar;
    output list<int> lIndx;

  protected
    Integer indx;

  algorithm
    lIndx:={};
    _ := match()
      local DAE.Exp a,b;
            DAE.ComponentRef v;
    case DAE.CREF(v) then
      (indx,_):=BackendVariable.getVariableByCref(v,inVar);
      if not listMember(indx,lIndx) then
        lIndx:=addIndx2list(indx::lIndx,indx);
      end;
    case DAE.CALL(_,a) then
      _:match a
       local DAE.Exp lvar;
             list<DAE.Exp> restlist;
       case lvar::restlist then
         treeSearch(lavar);
       else then "";
       end match;
    case DAE.BINARY(a,_,b) then
      treeSearch(a);
      treeSearch(b);
    case DAE.UNARY(_,a) then
        treeSearch(a);
    else then "";
    end match;

  end treeSearch

  function addIndx2list /*Insertion Sort*/
    input list<Integer> inlindx;
    input Integer indx;
    output list<Integer> outlindx;

  protected
    array<Integer> indxArray;
    list<Integer> restlist;
    Integer val;
    Integer iterationVar;
  algorithm
    indxArray:=listArray(inlindx);
    for i in 2 to arrayLength(indxArray)
       val:=indxArray[i];
       iterationVar:=i;
       while j>1 and A[iterationVar-1]>val loop
         indxArray[iterationVar]:=indxArray[iterationVar-1];
         iterationVar:=iterationVar-1;
       end;
      indxArray[iterationVar]:=val;
      outlindx:=arrayList(indxArray);
     end;
  end addIndx2list;


end BackendDAEUtil;