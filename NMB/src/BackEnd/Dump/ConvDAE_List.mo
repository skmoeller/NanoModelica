package ConvDAE_List
"
Desc: These functions convert objects of type DAE_List to objects of type DAE.
"
  import List;
  import DAE;
  import DAE_List;  

function convExp
"
Desc: Converts DAE_List.Exp into DAE.Exp.
"
  input DAE_List.Exp inO;
  output DAE.Exp outO;
algorithm
  outO := match(inO)
    local
      Integer d;
      Real r;
      Boolean b;
      DAE_List.ComponentRef cref;
      DAE_List.Exp exp1, exp2;
      String s;
      DAE_List.UnOp uop;
      DAE_List.BinOp bop;
      list<DAE_List.Exp> listExp;
    case DAE_List.INT(integer=d) then DAE.INT(d);
    case DAE_List.REAL(real=r) then DAE.REAL(r);
    case DAE_List.BOOL(bool=b) then DAE.BOOL(b);
    case DAE_List.CREF(id=cref) then DAE.CREF(convComponentRef(cref));
    case DAE_List.BINARY(exp1=exp1,op=bop,exp2=exp2) 
    then DAE.BINARY(convExp(exp1),convBinOp(bop),convExp(exp2));
    case DAE_List.UNARY(op=uop, exp1=exp1) 
    then DAE.UNARY(convUnOp(uop),convExp(exp1));
    case DAE_List.CALL(id=s, args=listExp) 
    then DAE.CALL(s, List.map(listExp,convExp));
    end match;
end convExp;

function convBinOp
"
Desc: Converts DAE_List.BinOp into DAE.BinOp.
"
  input DAE_List.BinOp inO;
  output DAE.BinOp outO;
algorithm
  outO := match(inO)
    case DAE_List.ADD() then DAE.ADD();
    case DAE_List.SUB() then DAE.SUB();
    case DAE_List.MUL() then DAE.MUL();
    case DAE_List.DIV() then DAE.DIV();
    case DAE_List.POW() then DAE.POW();
  end match;
end convBinOp;

function convUnOp
"
Desc: Converts DAE_List.UnOp into DAE.UnOp.
"
  input DAE_List.UnOp inO;
  output DAE.UnOp outO;
algorithm
  outO := match(inO)
    case DAE_List.NEG() then DAE.NEG();
  end match;
end convUnOp;

function convBackendDAE
"
Desc: Converts DAE_List.BackendDAE into DAE.BackendDAE.
"
  input DAE_List.BackendDAE inDAE;
  output DAE.BackendDAE outDAE;
algorithm
  outDAE := match(inDAE)
    local
      DAE_List.EquationSystem sim;
      DAE_List.EquationSystem init;
      DAE_List.Shared share;
  case DAE_List.BACKENDDAE(
    simulation=sim,
    initialization=init,
    shared=share
  )
  then
  DAE.BACKENDDAE(
    convEquationSystem(sim),
    convEquationSystem(init),
    convShared(share)
  );
  end match;
end convBackendDAE;

function convEquationSystem
"
Desc: Converts DAE_List.EquationSystem into DAE.EquationSystem
"
  input DAE_List.EquationSystem inEqSys;
  output DAE.EquationSystem outEqSys;
  protected
  algorithm
  outEqSys := match(inEqSys)
    local  
      DAE_List.VariableArray var;
      DAE_List.EquationArray equ;
      Option<DAE_List.AdjacencyMatrix> L_oadja;
      Option<DAE.AdjacencyMatrix> oadja;
      Option<DAE_List.AdjacencyMatrix> L_oadjaT;
      Option<DAE.AdjacencyMatrix> oadjaT;
      DAE_List.AdjacencyMatrix adja;
      Option<DAE_List.Matching> L_omat;
      Option<DAE.Matching> omat;
      DAE_List.Matching mat;
      DAE_List.StrongComponents L_strong;
  case DAE_List.EQUATION_SYSTEM(
    variables=var,
    equations=equ,
    adjacency=L_oadja,
    adjacencyTranspose=L_oadjaT,
    matching=L_omat,
    strongComponents=L_strong
  )
  algorithm
    oadja := match(L_oadja)
    case NONE() then NONE();
    case SOME(adja) then SOME(convAdjacencyMatrix(adja));
    end match;
    oadjaT := match(L_oadjaT)
    case NONE() then NONE();
    case SOME(adja) then SOME(convAdjacencyMatrix(adja));
    end match;
    omat := match(L_omat)
    case NONE() then NONE();
    case SOME(mat) then SOME(convMatching(mat));
    end match;   
  then DAE.EQUATION_SYSTEM(
    convVariableArray(var),
    convEquationArray(equ),
    oadja,
    oadjaT,
    omat,
    convStrongComponents(L_strong)
  );  
  end match; 
end convEquationSystem;  

function convShared
"
Desc: Converts DAE_List.Shared into DAE.Shared(...)
"
  input DAE_List.Shared inShared;
  output DAE.Shared outShared;
  protected
  algorithm
  outShared := match(inShared)
    local  
      DAE_List.VariableArray param;
      DAE_List.VariableArray state; 
      DAE_List.VariableArray alias;
      DAE_List.EquationSystem removedEqns;
  case DAE_List.SHARED(
    parameterVariables=param,
    stateVariables=state,      
    aliasVariables=alias,
    removedEqns=removedEqns
  )
  then DAE.SHARED(
    convVariableArray(param),
    convVariableArray(state),
    convVariableArray(alias),
    convEquationSystem(removedEqns)
  );
  end match;  
end convShared; 

function convAdjacencyMatrix
"
Desc: Converts DAE_List.AdjacencyMatrix into DAE.AdjacencyMatrix.
"
  input DAE_List.AdjacencyMatrix inO;
  output DAE.AdjacencyMatrix outO;
algorithm
  outO := listArray(inO);
end convAdjacencyMatrix;

function convMatching
"
Desc: Converts DAE_List.Matching into DAE.Matching.
"
  input DAE_List.Matching inO;
  output DAE.Matching outO;
algorithm
  outO := match(inO)
    local
      list<Integer> lint1, lint2;
  case DAE_List.MATCHING(variableAssign=lint1,equationAssign=lint2)
  then DAE.MATCHING(listArray(lint1),listArray(lint2));
  end match;
end convMatching;

function convStrongComponents
"
Desc: Converts DAE_List.StrongComponents into DAE.StrongComponents.
"
  input DAE_List.StrongComponents inO;
  output DAE.StrongComponents outO;
algorithm
  outO := List.map(inO,convStrongComponent);
end convStrongComponents;

function convStrongComponent
"
Desc: Converts DAE_List.StrongComponent into DAE.StrongComponent.
"
  input DAE_List.StrongComponent inO;
  output DAE.StrongComponent outO;
algorithm
  outO := match(inO)
    local
      Integer int1, int2;
      list<Integer> lint1, lint2;
      Option<DAE_List.Exp> ole1, ole2;
      Option<DAE.Exp> oe1, oe2;
      DAE_List.Exp e1, e2;
      list<DAE_List.Exp> lexp1;
      list<list<DAE_List.Exp>> lexp2;
      list<DAE.Exp> ldexp1;
      list<list<DAE.Exp>> ldexp2;      
  case DAE_List.SINGLE_EQUATION(equationIndex=int1,variableIndex=int2, residual=ole1,derivative=ole2)
  algorithm
    oe1 := match ole1
    case SOME(e1) then SOME(convExp(e1));
    else NONE();
    end match;
    oe2 := match ole2
    case SOME(e2) then SOME(convExp(e2));
    else NONE();
    end match;    
  then DAE.SINGLE_EQUATION(int1, int2, oe1, oe2);
  case DAE_List.ALGEBRAIC_LOOP(equationIndices=lint1,variableIndices=lint2, residuals=lexp1, jacobian=lexp2)
  algorithm
    ldexp2 := {};
    ldexp1 := List.map(lexp1,convExp);
    for le in lexp2 loop
      ldexp2 := List.map(le,convExp)::ldexp2;
    end for;
    ldexp2 := listReverse(ldexp2);
  then DAE.ALGEBRAIC_LOOP(lint1,lint2,ldexp1,ldexp2);
  end match;
end convStrongComponent;

function convVariableArray
"
Desc: Converts DAE_List.VariableArray into DAE.VariableArray.
"
  input DAE_List.VariableArray inO;
  output DAE.VariableArray outO;
algorithm
  outO := match(inO)
    local
      Integer int1;
      list<DAE_List.Variable> lvar;
      list<list<DAE_List.CrefIndex>> lcref;
  case DAE_List.VARIABLE_ARRAY(size=int1,variables=lvar,variableIndices=lcref)
  then DAE.VARIABLE_ARRAY(
    int1,
    listArray(List.map(lvar,convVariable)),
    listArray(List.mapList(lcref,convCrefIndex))
  );
  end match;
end convVariableArray;

function convCrefIndex
"
Desc: Converts DAE_List.CrefIndex into DAE.CrefIndex.
"
  input DAE_List.CrefIndex inO;
  output DAE.CrefIndex outO;
algorithm
  outO := match(inO)
    local
      DAE_List.ComponentRef cref;
      Integer index;
    case DAE_List.CREF_INDEX(cref=cref, index=index) 
    then DAE.CREF_INDEX(convComponentRef(cref), index);
  end match;
end convCrefIndex;

function convEquationArray
"
Desc: Converts DAE_List.EquationArray into DAE.EquationArray.
"
  input DAE_List.EquationArray inO;
  output DAE.EquationArray outO;
algorithm
  outO := match(inO)
    local
      Integer int1;
      list<DAE_List.Equation> lequ;
  case DAE_List.EQUATION_ARRAY(size=int1,equations=lequ)
  then DAE.EQUATION_ARRAY(int1,listArray(List.map(lequ,convEquation)));
  end match;
end convEquationArray;  
  
function convEquation
"
Desc: Converts DAE_List.Equation into DAE.Equation.
"
  input DAE_List.Equation inO;
  output DAE.Equation outO;
algorithm
  outO := match(inO)
    local
      DAE_List.Exp lhs;
      DAE_List.Exp rhs;    
    case DAE_List.EQUATION(lhs=lhs, rhs=rhs)
    then DAE.EQUATION(convExp(lhs), convExp(rhs));
  end match;
end convEquation; 

function convVariable
"
Desc: Converts DAE_List.Variable into DAE.Variable.
"
  input DAE_List.Variable inO;
  output DAE.Variable outO;
algorithm
  outO := match(inO)
    local
      DAE_List.ComponentRef name;
      DAE_List.Type tp;
      DAE_List.Kind kind;
      DAE_List.Direction dir;
      Option<DAE_List.Exp> L_oexp;
      Option<DAE.Exp> oexp;
      DAE_List.Exp exp;
      Option<DAE_List.VarAttributes> L_oatt;
      Option<DAE.VarAttributes> oatt;
      DAE_List.VarAttributes att;
      String s;
  case DAE_List.VARIABLE(name=name,tp=tp,kind=kind,direction=dir,bindExp=L_oexp,attributes=L_oatt,comment=s)
  algorithm
    oexp := match(L_oexp)
    case NONE() then NONE();
    case SOME(exp) then SOME(convExp(exp));
    end match;
    oatt := match(L_oatt)
    case NONE() then NONE();
    case SOME(att) then SOME(convVarAttributes(att));
    end match;
  then DAE.VARIABLE(
    convComponentRef(name),
    convType(tp),
    convKind(kind),
    convDirection(dir),
    oexp,
    oatt,
    s);
  end match;
end convVariable; 

function convComponentRef
"
Desc: Converts DAE_List.ComponentRef into DAE.ComponentRef.
"
  input DAE_List.ComponentRef inO;
  output DAE.ComponentRef outO;
algorithm
  outO := match(inO)
    local
      String s;
      Option<DAE_List.ComponentRef> L_ocref;
      Option<DAE.ComponentRef> ocref;
      DAE_List.ComponentRef cref;
  case DAE_List.COMPONENT_REF(name=s,qualName=L_ocref)
  algorithm
    ocref := match(L_ocref)
    case NONE() then NONE();
    case SOME(cref) then SOME(convComponentRef(cref));
    end match;
  then DAE.COMPONENT_REF(s,ocref);
  end match;
end convComponentRef; 

function convVarAttributes
"
Desc: Converts DAE_List.VarAttributes into DAE.VarAttributes.
"
  input DAE_List.VarAttributes inO;
  output DAE.VarAttributes outO;
algorithm
  outO := match(inO)
  local
      DAE_List.Exp exp1;
      Boolean b;
      Option<DAE_List.Exp> L_omi;
      Option<DAE.Exp> omi;
      Option<DAE_List.Exp> L_oma;
      Option<DAE.Exp> oma;
      Option<DAE_List.Exp> L_onom;
      Option<DAE.Exp> onom;
      Option<DAE_List.Exp> L_oun;
      Option<DAE.Exp> oun;
      DAE_List.Exp exp2;
  case DAE_List.VAR_ATTRIBUTES(start=exp1,fixed=b,min=L_omi,max=L_oma,nominal=L_onom,unit=L_oun)
  algorithm
    omi := match(L_omi)
      case NONE() then NONE();
      case SOME(exp2) then SOME(convExp(exp2));
    end match;
    oma := match(L_oma)
      case NONE() then NONE();
      case SOME(exp2) then SOME(convExp(exp2));
    end match;
    onom := match(L_onom)
      case NONE() then NONE();
      case SOME(exp2) then SOME(convExp(exp2));
    end match;
    oun := match(L_oun)
      case NONE() then NONE();
      case SOME(exp2) then SOME(convExp(exp2));
    end match;
  then DAE.VAR_ATTRIBUTES(convExp(exp1), b, omi, oma, onom, oun);
  end match;
end convVarAttributes; 

function convType
"
Desc: Converts DAE_List.Type into DAE.Type.
"
  input DAE_List.Type inO;
  output DAE.Type outO;
algorithm
  outO := match(inO)
    case DAE_List.T_REAL() then DAE.T_REAL();
    case DAE_List.T_INTEGER() then DAE.T_INTEGER();
    case DAE_List.T_BOOL() then DAE.T_BOOL();
    case DAE_List.T_STRING() then DAE.T_STRING();
  end match;
end convType;   

function convKind
"
Desc: Converts DAE_List.Kind into DAE.Kind.
"
  input DAE_List.Kind inO;
  output DAE.Kind outO;
algorithm
  outO := match(inO)
    case DAE_List.K_VARIABLE() then DAE.K_VARIABLE();
    case DAE_List.K_STATE() then DAE.K_STATE();
    case DAE_List.K_DER_STATE() then DAE.K_DER_STATE();
    case DAE_List.K_PARAMETER() then DAE.K_PARAMETER();
    case DAE_List.K_CONSTANT() then DAE.K_CONSTANT();
    case DAE_List.K_DUMMY_STATE() then DAE.K_DUMMY_STATE();
    case DAE_List.K_DUMMY_DER() then DAE.K_DUMMY_DER();
  end match;
end convKind;

function convDirection
"
Desc: Converts DAE_List.Direction into DAE.Direction.
"
  input DAE_List.Direction inO;
  output DAE.Direction outO;
algorithm
  outO := match(inO)
    case DAE_List.INPUT() then DAE.INPUT();
    case DAE_List.OUTPUT() then DAE.OUTPUT();
    case DAE_List.NODIR() then DAE.NODIR();
  end match;
end convDirection;

end ConvDAE_List;