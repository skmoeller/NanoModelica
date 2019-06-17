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
    output list<Integer> outlist;
    output DAE.AdjacencyMatrix matrixTranspose;

  protected

  algorithm
    (outlist,matrixTranspose):=treeSearch(DAE.BINARY(inEqn.lhs,DAE.SUB(),inEqn.rhs),inVar,equationIndex);
  end setListAdjacency;

  function treeSearch
    input DAE.Exp inEqn;
    input DAE.VariableArray inVar;
    input Integer equationIndex;
    output list<Integer> lIndx;                   /*Another Function!!!*/
    output DAE.AdjacencyMatrix matrixTranspose;
  protected
    Integer indx;
  algorithm
    lIndx:={};
    _:= match(inEqn)
      local DAE.Exp exp1,exp2;
            DAE.ComponentRef cref;
            list<DAE.Exp> lExp;
    case DAE.CREF(cref)
      algorithm
      (indx,_):=BackendVariable.getVariableByCref(cref,inVar);
      if not listMember(indx,lIndx) then
        lIndx:=addIndx2list(indx::lIndx,indx);
        matrixTranspose:=setAdjacencyTranspose(matrixTranspose,equationIndex,indx);
      end if;
      then "";
    case DAE.CALL(_,lExp)
      algorithm
        for expression in lExp loop
          treeSearch(expression,inVar,equationIndex);
        end for;
        then "";
    case DAE.BINARY(exp1,_,exp2)
      algorithm
      treeSearch(exp1,inVar,equationIndex);
      treeSearch(exp2,inVar,equationIndex);
      then "";
    case DAE.UNARY(_,exp1) then
      treeSearch(exp1,inVar,equationIndex);
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
    for i in 2:arrayLength(indxArray) loop
       val:=indxArray[i];
       iterationVar:=i;
       while iterationVar>1 and indxArray[iterationVar-1]>val loop
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
    outAdjacency[variableIndex]:=equationIndex::inAdjacencyMatrix[variableIndex];
  end setAdjacencyTranspose;

end BackendDAEUtil;
