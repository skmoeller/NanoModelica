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
function adjacencyMatrix
"
"
  input DAE.VariableArray inVariables;
  input DAE.EquationArray inEquations;
  output DAE.AdjacencyMatrix outAdjacencyMatrix;
  output DAE.AdjacencyMatrix outAdjacencyMatrixT;
protected
Integer i;
algorithm
  for i in inEquations.size:-1:1 loop
    (outAdjacencyMatrix[i],outAdjacencyMatrixT):=setListAdjacency(inVariables,inEquations.equations[i],i);
  end for;
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
    input Integer equationIndex;
    output list<int> outlist;
    output DAE.AdjacencyMatrix matrixTranspose;

  protected

  algorithm
    (outlist,matrixTranspose):=treeSearch(DAE.UNARY(DAE.SUB(inEqn.lhs,inEqn.rhs)),inVar,equationIndex);
  end setListAdjacency;

  function treeSearch
    input DAE.Exp inEqn;
    input DAE.VariableArray inVar;
    input Integer equationIndex;
    output list<int> lIndx;
    output DAE.AdjacencyMatrix matrixTranspose;
  protected
    Integer indx;
  algorithm
    lIndx:={};
    _ := match(inEqn)
      local DAE.Exp a,b;
            DAE.ComponentRef cref;
    case DAE.CREF(cref)
      algorithm
      (indx,_):=BackendVariable.getVariableByCref(cref,inVar);
      if not listMember(indx,lIndx) then
        lIndx:=addIndx2list(indx::lIndx,indx);
        MatrixTranspose:=setAdjacencyTranspose(matrixTranspose,equationIndex,indx);
      end if;
      then "";
    case DAE.CALL(_,a)
      algorithm
      _:=match(a)
       local DAE.Exp lvar;
             list<DAE.Exp> restlist;
       case lvar::restlist then
         treeSearch(lavar);
       else then "";
       end match;
       then "";
    case DAE.BINARY(a,_,b)
      algorithm
      treeSearch(a);
      treeSearch(b);
      then "";
    case DAE.UNARY(_,a) then
      treeSearch(a);
    else then "";
    end match;

  end treeSearch;

  function addIndx2list
    input list<Integer> inlindx;
    input Integer indx;
    output list<Integer> outlindx;

  protected
    array<Integer> indxArray;
    list<Integer> restlist;
    Integer val;
    Integer helpVal;
    Integer iterationVar;
  algorithm
    indxArray:=listArray(inlindx);
    for i in 2 to arrayLength(indxArray)
       val:=indxArray[i];
       iterationVar:=i;
       while j>1 and A[iterationVar-1]>val loop
         helpVal:=indxArray[iterationVar];
         indxArray[iterationVar]:=indxArray[iterationVar-1];
         indxArray[iterationVar-1]:=helpVal;
         iterationVar:=iterationVar-1;
       end while;
      indxArray[iterationVar]:=val;
      outlindx:=arrayList(indxArray);
    end for;
  end addIndx2list;

function setAdjacencyTranspose
  input DAE.AdjacencyMatrix inAdjacencyMatrix;
  input Integer equationIndex;
  input Integer variableIndex;
  output DAE.AdjacencyMatrix outAdjacency;
protected

algorithm
    outAdjacency[variableIndex]:=equationIndex::outAdjacency[variableIndex];
  end setadjacencyTranspose;

end BackendDAEUtil;




 end match;
