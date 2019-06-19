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
  input DAE.VariableArray inVariables;
  input DAE.EquationArray inEquations;
  output DAE.AdjacencyMatrix outAdjacencyMatrix;
  output DAE.AdjacencyMatrix outAdjacencyMatrixT;
protected
  Integer sizeEquations;
  Integer iterVar;
algorithm
  sizeEquations:=inEquations.size;
  outAdjacencyMatrix:=arrayCreate(sizeEquations,{});
  outAdjacencyMatrixT:=arrayCreate(sizeEquations,{});
  for i in sizeEquations:-1:1 loop
    iterVar:=i;
    outAdjacencyMatrix[iterVar]:=setAdjacency(inVariables,inEquations.equations[iterVar]);
    outAdjacencyMatrixT:=setAdjacencyT(outAdjacencyMatrixT,outAdjacencyMatrix[iterVar],iterVar,sizeEquations);
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
  function setAdjacency
    input DAE.VariableArray inVar;
    input DAE.Equation inEqn;
    output list<Integer> outList;
  algorithm
    outList:=getList(DAE.BINARY(inEqn.lhs,DAE.SUB(),inEqn.rhs),inVar);
  end setAdjacency;

  function getList
    input DAE.Exp inEqn;
    input DAE.VariableArray inVar;
    output list<Integer> lIndx;
  protected
    Integer indx,iterVar;
    list<DAE.ComponentRef> crefs;
  algorithm
    lIndx:={};
    crefs:={};
    crefs:=treeSearch(inEqn,crefs);
    for c in crefs loop
      (indx,_):=BackendVariable.getVariableByCref(c,inVar);
      if not listMember(indx,lIndx) and indx>0 then
        lIndx:=addIndx2list(indx::lIndx);
      end if;
    end for;
  end getList;

  function treeSearch
    input DAE.Exp inEqn;
    input list<DAE.ComponentRef> inListCrefs;
    output list<DAE.ComponentRef> outListCrefs;
  algorithm
    _:=match(inEqn)
      local DAE.Exp exp1,exp2;
            list<DAE.Exp> lExp;
            DAE.ComponentRef cref;
    case DAE.BINARY(exp1,_,exp2)
    algorithm
      outListCrefs:=treeSearch(exp1,inListCrefs);
      outListCrefs:=treeSearch(exp2,outListCrefs);
    then "";
    case DAE.UNARY(_,exp1)
    algorithm
      outListCrefs:=treeSearch(exp1,inListCrefs);
    then "";
    case DAE.CALL(_,lExp)
      algorithm
        exp1:=listGet(lExp,1);
        lExp:=listDelete(lExp,1);
        outListCrefs:=treeSearch(exp1,inListCrefs);
        for e in lExp loop
          outListCrefs:=treeSearch(expr,outListCrefs);
        end for;
    then "";
    case DAE.CREF(cref)
     algorithm
       outListCrefs:=cref::inListCrefs;
    then "";
    else
      algorithm
        outListCrefs:=inListCrefs;
    then "";
    end match;
  end treeSearch;

  function addIndx2list
    input list<Integer> inList;
    output list<Integer> outList;
  protected
    array<Integer> arr;
    Integer val,helpVar,iterVar;
  algorithm
    if listLength(inList)<2 then
      outList:=inList;
    else
      arr:=listArray(inList);
      for i in 2:listLength(inList) loop
        iterVar:=i;
        val:=arr[iterVar];
        while iterVar>1 and arr[iterVar-1]>val loop
          helpVar:=arr[iterVar+0];
          arr[iterVar+0]:=arr[iterVar-1];
          arr[iterVar-1]:=helpVar;
          iterVar:=iterVar-1;
        end while;
        arr[iterVar+0]:=val;
      end for;
      outList:=arrayList(arr);
    end if;
  end addIndx2list;

function setAdjacencyT
  input DAE.AdjacencyMatrix inAdjacencyT;
  input list<Integer> variableList;
  input Integer equationIndex;
  input Integer sizeEquations;
  output DAE.AdjacencyMatrix outAdjacencyT;
protected
  list<Integer> list;
  Integer var;
algorithm
  list:=variableList;
  outAdjacencyT:=inAdjacencyT;
  for i in list loop
    var:=i;
    outAdjacencyT[var]:=equationIndex::inAdjacencyT[var];
  end for;
  end setAdjacencyT;

end BackendDAEUtil;
