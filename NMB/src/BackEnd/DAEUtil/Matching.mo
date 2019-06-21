package Matching
" file:        Matching.mo
  package:     Matching
  description: Matching contains functions for matching algorithms"

import DAE;
import Array;
import List;

function PerfectMatching "
  This function fails if there is no perfect matching for the given system."
  input  DAE.AdjacencyMatrix m;
  output DAE.Matching matching;
protected
  array<Integer> assign;
  Integer sizeEquations,eqnIdx;
  array<Boolean> vMark;
  array<Boolean> eMark;
  Boolean success;
algorithm
  sizeEquations:=arrayLength(m);
  matching:=DAE.MATCHING(arrayCreate(sizeEquations,0),arrayCreate(sizeEquations,0));
  vMark:=arrayCreate(sizeEquations,false);
  eMark:=arrayCreate(sizeEquations,false);
  assign:=arrayCreate(sizeEquations,0);
  for i in 1:sizeEquations loop
    eqnIdx:=i;
    (vMark,eMark,assign,success):=pathFound(eqnIdx,sizeEquations,vMark,eMark,matching.variableAssign,m);
    matching.variableAssign:=assign;
    if not success then
      print("singulaer");
    end if;
  end for;
  if listMember(false,arrayList(eMark)) then
      print("Not all Equation touched");
  end if;
  matching.equationAssign:=createEquationAssign(matching.variableAssign,sizeEquations);
end PerfectMatching;

function pathFound
  input Integer equationIdx;
  input Integer sizeEquations;
  input array<Boolean> inVariableMark;
  input array<Boolean> inEquationMark;
  input array<Integer> inVariableAssign;
  input DAE.AdjacencyMatrix adjacency;
  output array<Boolean> outVariableMark;
  output array<Boolean> outEquationMark;
  output array<Integer> outVariableAssign;
  output Boolean success;
protected
  Boolean zeroAssign;
  Integer variableIdx;
  list<Integer> otherVariables;
  array<Boolean> helpVariableMark;
  array<Integer> helpVariableAssign;
algorithm
  outVariableMark:=inVariableMark;
  outEquationMark:=inEquationMark;
  outVariableAssign:=inVariableAssign;
  outEquationMark[equationIdx]:=true;/*what should this do?????*/
  (variableIdx,zeroAssign):=zeroVariableAssign(equationIdx,adjacency,outVariableAssign);
  if zeroAssign then
    success:=true;
    outVariableAssign[variableIdx]:=equationIdx;
  else
    success:=false;
    otherVariables:=findOtherVariables(equationIdx,adjacency,outVariableMark);
    for j in otherVariables loop
      variableIdx:=j;
      outVariableMark[variableIdx]:=true;
      (helpVariableMark,_,helpVariableAssign,success):=pathFound(outVariableAssign[variableIdx],sizeEquations,outVariableMark,outEquationMark,outVariableAssign,adjacency);
      if success then
        outVariableMark:=helpVariableMark;
        outVariableMark:=helpVariableMark;
        outVariableAssign:=helpVariableAssign;
        outVariableAssign[variableIdx]:=equationIdx;
        break;
      end if;
    end for;
  end if;
end pathFound;

function zeroVariableAssign
  input Integer eqnIdx;
  input DAE.AdjacencyMatrix adjacency;
  input array<Integer> assign;
  output Integer variableIndex;
  output Boolean success=false;
algorithm
  for i in adjacency[eqnIdx] loop
    variableIndex:=i;
    if assign[variableIndex]==0 then
      success:=true;
      break;
    end if;
  end for;
end zeroVariableAssign;

function findOtherVariables
  input Integer eqnIdx;
  input DAE.AdjacencyMatrix adjacency;
  input array<Boolean> vMark;
  output list<Integer> outListVariableIndex;
protected
  Integer iterVar;
algorithm
  outListVariableIndex:={};
  for i in adjacency[eqnIdx] loop
    iterVar:=i;
    if not vMark[iterVar] then
      outListVariableIndex:=iterVar::outListVariableIndex;
    end if;
  end for;
end findOtherVariables;

function createEquationAssign
  input array<Integer> vAssign;
  input Integer lenghtArray;
  output array<Integer> equationAssign;
protected
  Integer iterVar;
algorithm
equationAssign:=arrayCreate(lenghtArray,0);
  for i in 1:lenghtArray loop
    iterVar:=i;
  equationAssign[vAssign[iterVar]]:=iterVar;
  end for;
end createEquationAssign;

end Matching;
