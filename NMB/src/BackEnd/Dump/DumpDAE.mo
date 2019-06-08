package DumpDAE
"
Desc: Contains all functions to print the complete ImportDAE and BackendDAE structure as constructor calls. The output will be a string of nested constructors. Arrays have to be printed as lists in the form {...}. Other list constructors like list(..) will not work.
"
import DAE;
import List;

public

function dumpAdjacencyMatrix
"
Desc: Dump DAE.AdjacencyMatrix as {{..},{..},..,{..}}
"
  input DAE.AdjacencyMatrix inAdjMat;
  output String s;
protected
  Integer dim;
algorithm 
  dim := arrayLength(inAdjMat);
  s := "{";
  for i in 1:dim-1 loop
    s := s + "{" + List.dump(inAdjMat[i],intString) + "},";
  end for;
  if(0 < dim) then
    s := s + "{" + List.dump(inAdjMat[dim],intString) + "}";
  end if;
  s := s + "}";
end dumpAdjacencyMatrix;

function dumpBackendDAE
"
Desc: Dump DAE.BackendDAE as DAE_List.BACKENDDAE(...)
"
  input DAE.BackendDAE inDae;
  output String s = "";
  protected
  algorithm
    s := "DAE_List.BACKENDDAE("
      + dumpEquationSystem(inDae.simulation) + "," 
      + dumpEquationSystem(inDae.initialization) + ","
      + dumpShared(inDae.shared);
    s := s + ")";
end dumpBackendDAE;
  
function dumpEquationSystem
"
Desc: Dump DAE.EquationSystem as DAE_List.EQUATION_SYSTEM(...)
"
  input DAE.EquationSystem inEquSystem;
  output String s = "";
  protected
    String s1;
  algorithm
    s := "DAE_List.EQUATION_SYSTEM("
      + dumpVariableArray(inEquSystem.variables) + "," 
      + dumpEquationArray(inEquSystem.equations) + ",";
    s1 := match(inEquSystem.adjacency)
      local
        DAE.AdjacencyMatrix lm;
      case(SOME(lm)) then "SOME(" + dumpAdjacencyMatrix(lm) + ")";
      case NONE() then "NONE()";
    end match;
    s := s + s1 + ",";
    s1 := match(inEquSystem.adjacencyTranspose)
      local
        DAE.AdjacencyMatrix lm;
      case(SOME(lm)) then "SOME(" + dumpAdjacencyMatrix(lm) + ")";
      case NONE() then "NONE()";
    end match;
    s := s + s1 + ",";
    s1 := match(inEquSystem.matching)
      local
        DAE.Matching lm;
      case(SOME(lm)) then "SOME(" + dumpMatching(lm) + ")";
      case NONE() then "NONE()";
    end match;
    s := s + s1 + ","; 
    s := s + dumpStrongComponents(inEquSystem.strongComponents);      
    s := s + ")"; 
end dumpEquationSystem;  

function dumpShared
"
Desc: Dump DAE.Shared as DAE_List.SHARED(...)
"
  input DAE.Shared inShared;
  output String s = "";
  protected
  algorithm
    s := "DAE_List.SHARED("
      + dumpVariableArray(inShared.parameterVariables) + "," 
      + dumpVariableArray(inShared.stateVariables) + ","
      + dumpVariableArray(inShared.aliasVariables) + ","
      + dumpEquationSystem(inShared.removedEqns);
    s := s + ")"; 
end dumpShared;  


function dumpComponentRef
"
Desc: Dump DAE.ComponentRef as DAE_List.COMPONENT_REF(...)
"
  input DAE.ComponentRef cref;
  output String s;
  protected
    String s1;
  algorithm
  s :="DAE_List.COMPONENT_REF(";
  s := s + "\"" + cref.name + "\",";
  s1 := match(cref.qualName)
      local DAE.ComponentRef lcref;
    case SOME(lcref) then "SOME(" + dumpComponentRef(lcref) + ")";
    case NONE() then "NONE()";
    end match;
  s := s + s1 + ")";
end dumpComponentRef; 

function dumpCrefIndex
"
Desc: Dump DAE.CrefIndex as DAE_List.CREF_INDEX(...)
"
  input DAE.CrefIndex inCrefIdx;
  output String s = "";
  algorithm
    s := "DAE_List.CREF_INDEX("
      + dumpComponentRef(inCrefIdx.cref) + ","
      + String(inCrefIdx.index) + ")";
end dumpCrefIndex;
 
function dumpDirection
"
Desc: Dump DAE.Direction as DAE_List.INPUT()
or as DAE_List.OUTPUT()
or as DAE_List.NODIR()
"
  input DAE.Direction dir;
  output String s;
  protected
  algorithm
  s := match(dir)
  case (DAE.INPUT()) then "DAE_List.INPUT()";
  case (DAE.OUTPUT()) then "DAE_List.OUTPUT()";
  case (DAE.NODIR()) then "DAE_List.NODIR()";
  end match;
end dumpDirection;

function dumpEquation
"
Desc: Dump DAE.Equation as DAE_List.EQUATION(...)
"
  input DAE.Equation equ;
  output String str;
  algorithm
  str := "DAE_List.EQUATION(" + dumpExp(equ.lhs) + "," + dumpExp(equ.rhs) + ")";
end dumpEquation;

function dumpEquationArray
"
Desc: DAE.EquationArray as DAE_List.EQUATION_ARRAY(...)
"
  input DAE.EquationArray inEqnArr;
  output String s = "";
  protected
    Integer dim;  // Arraydimension
  algorithm
    dim := inEqnArr.size;
    s := "DAE_List.EQUATION_ARRAY(";
    s := s + String(inEqnArr.size) + ",";    
    s := s + "{";  
    for i in 1:dim-1 loop
      s := s + dumpEquation(inEqnArr.equations[i]) + ",";
    end for;
    if(0 < dim) then
      s := s + dumpEquation(inEqnArr.equations[dim]);       
    end if;
    s := s + "})";
end dumpEquationArray;

function dumpExp
"
Desc: Dump DAE.Exp as DAE_List.INT(...)
or as DAE_List.REAL(...)
or as DAE_List.BOOL(...)
or as DAE_List.CREF(...)
or as DAE_List.BINARY(...)
or as DAE_List.UNARY(...)
or as DAE_List.CALL(...)
"
  input DAE.Exp inExp;
  output String result;
algorithm
  result := match(inExp)
    local
      String s1, s2="", sop="";
      Integer i;
      Real r;
      Boolean b;
      DAE.Exp exp1, exp2;
      list<DAE.Exp> expList;
      DAE.BinOp bop;
      DAE.UnOp uop;
      DAE.ComponentRef c1;

	  case(DAE.CALL(id=s1, args=expList))
	  //then "DAE_List.CALL(\"" + s1 + "\",{" + dumpExpList(expList) + "})";
    then "DAE_List.CALL(\"" + s1 + "\",{" + List.dump(expList,dumpExp) + "})";

    case(DAE.INT(integer=i))
    then "DAE_List.INT(" + intString(i) + ")";

    case(DAE.REAL(real=r))
    then "DAE_List.REAL(" + realString(r) + ")";

    case(DAE.BOOL(bool=b))
    then "DAE_List.BOOL(" + boolString(b) + ")";

    case(DAE.CREF(id=c1))
    then "DAE_List.CREF(" + dumpComponentRef(c1) + ")";

    case (DAE.BINARY(exp1=exp1, op=bop, exp2=exp2))
      equation
        s1 = dumpExp(exp1);
        s2 = dumpExp(exp2);
        sop = dumpBinOp(bop);
      then "DAE_List.BINARY(" + s1 + "," + sop + "," + s2 + ")"; 

    case (DAE.UNARY(uop, exp1))
      equation
        s1 = dumpExp(exp1);
        sop = dumpUnOp(uop);
    then "DAE_List.UNARY(" + sop + "," + s1 + ")";	  

    else equation
      print("Something else failed\n");
    then fail();
  end match;
end dumpExp;

function dumpBinOp
"
Desc: Dump DAE.BinOp as DAE_List.BinOp(...)
"
  input DAE.BinOp inBinOp;
  output String s;
  algorithm    
    s := match(inBinOp)
    case(DAE.SUB())	then "DAE_List.SUB()";
    case(DAE.ADD())	then "DAE_List.ADD()";
    case(DAE.MUL())	then "DAE_List.MUL()";
    case(DAE.DIV())	then "DAE_List.DIV()";
    case(DAE.POW())	then "DAE_List.POW()";
    else fail();
    end match;
end dumpBinOp;  
     
function dumpUnOp
"
Desc: Dump DAE.UnOp as DAE_List.UnOp(...)
"
  input DAE.UnOp inUnOp;
  output String s;
  algorithm    
    s := match(inUnOp)
    case(DAE.NEG())	then "DAE_List.NEG()";
    else fail();
    end match;
end dumpUnOp;
       
function dumpImportDAE
"
Desc: Dump DAE.ImportDAE as DAE_List.IMPORT_DAE(...)
"
  input DAE.ImportDAE inImpDae;
  output String s;
  algorithm  
  s := "DAE_List.IMPORT_DAE({" 
  + List.dump(inImpDae.variables,dumpVariable) + "}" 
  + ",{" + List.dump(inImpDae.equations,dumpEquation) + "}" 
  + ",{" + List.dump(inImpDae.initialEquations,dumpEquation) + "}" 
  + ",{" + List.dump(inImpDae.bindingEquations,dumpEquation) + "}" 
  + ")";
end dumpImportDAE;

function dumpKind
"
Desc: Dump DAE.Kind() as DAE_List.K_VARIABLE()
or as DAE_List.K_STATE()
or as DAE_List.K_DER_STATE()
or as DAE_List.K_PARAMETER()
or as DAE_List.K_CONSTANT()
"
  input DAE.Kind kind;
  output String s;
  protected
  algorithm
  s := match(kind)
  case (DAE.K_VARIABLE()) then "DAE_List.K_VARIABLE()";
  case (DAE.K_STATE()) then "DAE_List.K_STATE()";
  case (DAE.K_DER_STATE()) then "DAE_List.K_DER_STATE()";
  case (DAE.K_PARAMETER()) then "DAE_List.K_PARAMETER()";
  case (DAE.K_CONSTANT()) then "DAE_List.K_CONSTANT()";
  case (DAE.K_DUMMY_STATE()) then "DAE_List.K_DUMMY_STATE()";
  case (DAE.K_DUMMY_DER()) then "DAE_List.K_DUMMY_DER()";
  end match;
end dumpKind;

function dumpMatching
"
Desc: Dump DAE.Matching as DAE_List.MATCHING(...)
"
  input DAE.Matching inMatch;
  output String s = "";
  protected
    Integer dim;
  algorithm
    dim := arrayLength(inMatch.variableAssign);
    s := "DAE_List.MATCHING(";
    s := s + "{";  
    for i in 1:dim-1 loop
      s := s + String(inMatch.variableAssign[i]) + ",";
    end for;
    if(0 < dim) then
      s := s + String(inMatch.variableAssign[dim]);
    end if;
    s := s + "},";
    
    dim := arrayLength(inMatch.equationAssign);
    s := s + "{";  
    for i in 1:dim-1 loop
      s := s + String(inMatch.equationAssign[i]) + ",";
    end for;
    if(0 < dim) then
      s := s + String(inMatch.equationAssign[dim]);
    end if;   
    s := s + "})";
end dumpMatching;

function dumpStrongComponent
"
Desc: Dump DAE.StrongComponent as DAE_List.SINGLE_EQUATION(...)
or as DAE_List.EQUATION_SYSTEM(...)
"
  input DAE.StrongComponent inStrComp;
  output String s = "";
protected
  String s1;
algorithm
  s1 := match(inStrComp)
    local 
      String s2 = "";
      String s3 = "";
      Integer i1, i2;
      list<Integer> Li1, Li2;
      Option<DAE.Exp> oe1, oe2;
      DAE.Exp e1, e2;
      list<DAE.Exp> lexp1;
      list<list<DAE.Exp>> lexp2;      
    case(DAE.SINGLE_EQUATION(equationIndex=i1,variableIndex=i2,residual=oe1, derivative=oe2))
    algorithm
      s2 := match(oe1)
      case SOME(e1) then dumpExp(e1);
      else "NONE()";
      end match;
      s3 := match(oe2)
      case SOME(e2) then dumpExp(e2);
      else "NONE()";
      end match;
    then "DAE_List.SINGLE_EQUATION(" + String(i1) + "," + String(i2) + ", " + s2 + ", " + s3 + ")";
    case(DAE.ALGEBRAIC_LOOP(equationIndices=Li1,variableIndices=Li2, residuals=lexp1, jacobian=lexp2))
    algorithm
      s2 := "";
      for le in lexp2 loop
        s2 := s2 + "{" + List.dump(le,dumpExp) + "},";
      end for;
      // remove last comma from string s2
      s2 := substring(s2,1,stringLength(s2)-1);
    then "DAE_List.ALGEBRAIC_LOOP({" + List.dump(Li1,intString) + "},{" 
          + List.dump(Li2,intString) + "}, {" + List.dump(lexp1,dumpExp) + "},{" + s2 + "})";
  end match;
  s := s + s1;
end dumpStrongComponent;

function dumpStrongComponents
"
Desc: Dump DAE.StrongComponents as {...}
"
  input DAE.StrongComponents inStrComps;
  output String s = "";
  algorithm
  s := "{"
    + List.dump(inStrComps,dumpStrongComponent) + "}";
end dumpStrongComponents;

function dumpType
"
Desc: Dump DAE.Type as DAE_List.T_REAL()
or as DAE_List.T_INTEGER()
or as DAE_List.T_BOOL()
or as DAE_List.T_STRING()
"
  input DAE.Type tp;
  output String s;
  protected
  algorithm
  s := match(tp)
  case (DAE.T_REAL()) then "DAE_List.T_REAL()";
  case (DAE.T_INTEGER()) then "DAE_List.T_INTEGER()";
  case (DAE.T_BOOL()) then "DAE_List.T_BOOL()";
  case (DAE.T_STRING()) then "DAE_List.T_STRING()";
  end match;
end dumpType;

function dumpVarAttributes
"
Desc: Dump DAE.VarAttributes as DAE_List.VAR_ATTRIBUTES(...)
"
  input DAE.VarAttributes attr;
  output String s;
  protected
    String s1;
  algorithm
  s :="DAE_List.VAR_ATTRIBUTES(";
  s := s + dumpExp(attr.start);
  if(attr.fixed) then
    s := s + ",true";
  else
    s := s + ",false";
  end if;
  s1 := match(attr.min)
      local DAE.Exp exp;
    case SOME(exp) then "SOME(" + dumpExp(exp) + ")";
    case NONE() then "NONE()";
    end match;
  s := s + "," + s1;
  s1 := match(attr.max)
      local DAE.Exp exp;
    case SOME(exp) then "SOME(" + dumpExp(exp) + ")";
    case NONE() then "NONE()";
    end match;
  s := s + "," + s1;
  s1 := match(attr.nominal)
      local DAE.Exp exp;
    case SOME(exp) then "SOME(" + dumpExp(exp) + ")";
    case NONE() then "NONE()";
    end match;
  s := s + "," + s1;
  s1 := match(attr.unit)
      local DAE.Exp exp;
    case SOME(exp) then "SOME(" + dumpExp(exp) + ")";
    case NONE() then "NONE()";
    end match;
  s := s + "," + s1;  
  s := s + ")";
end dumpVarAttributes;

function dumpVariable
"
Desc: Dump DAE.Variable as DAE_List.VARIABLE(...)
"
  input DAE.Variable var;
  output String str;
  protected
    String s1, s2;
  algorithm
  str := "";
  s2 := "";
  s1 := "DAE_List.VARIABLE(";
  s1 := s1 + dumpComponentRef(var.name) + ",";
  s1 := s1 + dumpType(var.tp) + ",";
  s1 := s1 + dumpKind(var.kind) + ",";
  s1 := s1 + dumpDirection(var.direction) + ",";
  s2 := match(var.bindExp)
  local
    DAE.Exp lexp;
  case(SOME(lexp)) then "SOME(" + dumpExp(lexp) + ")";
  case NONE() then "NONE()";
  end match;
  s1 := s1 + s2 + ",";
  s2 := match(var.attributes)
  local
    DAE.VarAttributes lattr;
  case(SOME(lattr)) then "SOME(" + dumpVarAttributes(lattr) + ")";
  case NONE() then "NONE()";
  end match;
  s1 := s1 + s2 + ",";  
  str := s1 + "\"" + var.comment + "\")";
end dumpVariable;

function dumpVariableArray
"
Desc: Dump DAE.VariableArray as DAE_List.VARIABLE_ARRAY(...)
"
  input DAE.VariableArray inVarArr;
  output String s = "";
  protected
    Integer dim;
  algorithm
  dim := inVarArr.size;
  s := "DAE_List.VARIABLE_ARRAY(";
  s := s + String(inVarArr.size) + ",";
  s := s + "{";  
  // Attention: Don't use "arrayLength" or "for v in inVarArr.variables loop", 
  // because the arrayLength is greater then the size and all unused elements 
  // are not initialized. So any access to such an element will result in a 
  // segmentation fault!
  for i in 1:dim-1 loop
    s := s + dumpVariable(inVarArr.variables[i]) + ",";
  end for;
  if(0 < dim) then
    s := s + dumpVariable(inVarArr.variables[dim]);  
  end if;
  s := s + "},";
 
  dim := arrayLength(inVarArr.variableIndices);
  s := s + "{";  
  for i in 1:dim-1 loop
    //if 0 <> listLength(inVarArr.variableIndices[i]) then
      s := s + "{" + List.dump(inVarArr.variableIndices[i],dumpCrefIndex) + "},";
    //end if;
  end for;
  if(0 < dim) then
    //if 0 <> listLength(inVarArr.variableIndices[dim]) then
      s := s + "{" + List.dump(inVarArr.variableIndices[dim],dumpCrefIndex);
    //end if;
    s := s + "}";
  end if;
  s := s + "})";
end dumpVariableArray;

end DumpDAE;