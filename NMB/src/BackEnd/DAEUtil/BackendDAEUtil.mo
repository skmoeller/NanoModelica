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
  list<Integer>listVariables;
  Integer sizeEquations;
algorithm
  sizeEquations:=inEquations.size;
  outAdjacencyMatrix:=arrayCreate(sizeEquations,{});
  outAdjacencyMatrixT:=arrayCreate(sizeEquations,{});
  for i in inEquations.size:-1:1 loop
    (listVariables,outAdjacencyMatrixT):=setListAdjacency(inVariables,inEquations.equations[i],i,outAdjacencyMatrixT,sizeEquations);
    outAdjacencyMatrix[i]:=listVariables;
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
    input DAE.AdjacencyMatrix inAdjacencyMatrixT;
    input Integer sizeEquations;
    output list<Integer> outList;
    output DAE.AdjacencyMatrix outAdjacencyMatrixT;
  protected
    DAE.Exp eqnExp;
  algorithm
    outAdjacencyMatrixT:=arrayCreate(sizeEquations,{});
    eqnExp:=DAE.BINARY(inEqn.lhs,DAE.SUB(),inEqn.rhs);
    (outList,outAdjacencyMatrixT):=getList(eqnExp,inVar,equationIndex,inAdjacencyMatrixT,sizeEquations);
  end setListAdjacency;

  function getList
    input DAE.Exp inEqn;
    input DAE.VariableArray inVar;
    input Integer equationIndex;
    input DAE.AdjacencyMatrix inAdjacencyMatrixT;
    input Integer sizeEquations;
    output list<Integer> lIndx;
    output DAE.AdjacencyMatrix outAdjacencyMatrixT;
  protected
    Integer indx;
    list<DAE.ComponentRef> crefs;
  algorithm
    outAdjacencyMatrixT:=arrayCreate(sizeEquations,{});
    lIndx:={};

    crefs:=treeSearch(inEqn);
    for i in crefs loop
      (indx,_):=BackendVariable.getVariableByCref(i,inVar);
      if not listMember(indx,lIndx) then
        lIndx:=addIndx2list(indx::lIndx,indx);
        outAdjacencyMatrixT:=setAdjacencyTranspose(inAdjacencyMatrixT,equationIndex,indx,sizeEquations);
      end if;
    end for;
  end getList;

  function treeSearch
    input DAE.Exp inEqn;
    output list<DAE.ComponentRef> c;
  algorithm
    c:=match(inEqn)
      local DAE.Exp exp1,exp2;
            DAE.ComponentRef cref;
            list<DAE.Exp> lExp;
    case DAE.CREF(cref)
      then cref::c;
    case DAE.CALL(_,lExp)
      algorithm
        exp1:=listGet(lExp,1);
        _:=match(lExp)
          local DAE.Exp exp;
                list<DAE.Exp> lexp;
        case exp::lexp then treeSearch(exp);
      end match;
      then treeSearch(exp1);
    case DAE.BINARY(exp1,_,exp2) then listAppend(treeSearch(exp1),treeSearch(exp2));
    case DAE.UNARY(_,exp1) then treeSearch(exp1);
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
  input DAE.AdjacencyMatrix inAdjacency;
  input Integer equationIndex;
  input Integer variableIndex;
  input Integer sizeEquations;
  output DAE.AdjacencyMatrix outAdjacency;
algorithm
  outAdjacency:=arrayCreate(sizeEquations,{});
  outAdjacency[variableIndex]:=equationIndex::inAdjacency[variableIndex];
  end setAdjacencyTranspose;

end BackendDAEUtil;
