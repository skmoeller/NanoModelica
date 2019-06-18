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
  for i in inEquations.size:-1:1 loop
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
    _:=match(crefs)
    local list<DAE.ComponentRef> lc;
          DAE.ComponentRef c;
      case c::lc
      algorithm
        (indx,_):=BackendVariable.getVariableByCref(c,inVar);
        if not listMember(indx,lIndx) then
         /* lIndx:=addIndx2list(indx::lIndx,indx);*/
        end if;
      then "";
      else then "";
    end match;
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
        _:=match(lExp)
          local DAE.Exp expr;
                list<DAE.Exp> lexpr;
        case expr::lexpr
          algorithm
            outListCrefs:=treeSearch(expr,inListCrefs);
          then "";
      end match;
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
    input list<Integer> inLIndx;
    input Integer indx;
    output list<Integer> outLIndx;
  protected
    list<Integer> list;
    array<Integer>array=listArray(inLIndx);
    Integer val,helpVar,iterVar;
  algorithm
    list:=inLIndx;
    if listLength(inLIndx)<2 then
      outLIndx:=inLIndx;
    else
      for i in 2:listLength(inLIndx) loop
        iterVar:=i;
        val:=listGet(list,iterVar);
        while iterVar>1 and listGet(list,iterVar-1)>val loop
          helpVar:=listGet(list,(iterVar+0));
          array[(iterVar+0)]:=listGet(list,(iterVar-1));
          array[iterVar-1]:=helpVar;
          iterVar:=iterVar-1;
        end while;
        array[(iterVar+0)]:=val;
        outLIndx:=arrayList(array);
      end for;
    end if;
  end addIndx2list;

function setAdjacencyT
  input DAE.AdjacencyMatrix inAdjacencyT;
  input list<Integer> variableList;
  input Integer equationIndex;
  input Integer sizeEquations;
  output DAE.AdjacencyMatrix outAdjacencyT;
algorithm
  outAdjacencyT:=arrayCreate(sizeEquations,{});
  _:=match(variableList)
    local Integer var;
          list<Integer>rList;
    case var::rList
      algorithm
        outAdjacencyT[var]:=equationIndex::inAdjacencyT[var];
    then "";
    else then "";
    end match;
  end setAdjacencyT;

end BackendDAEUtil;
