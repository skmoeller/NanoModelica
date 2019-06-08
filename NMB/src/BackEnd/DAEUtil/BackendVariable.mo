package BackendVariable
"
Brief:
contains all functions related to the
DAE.VariableArray and the DAE.Variable type.
"
public
import DAE;
import List;  
import Array;

protected
import DumpDAE;
import ComponentRef;
/* 
 *
 * public functions section 
 *
 */
public

function variableListToArray 
  input list<DAE.Variable> inVarList;
  output DAE.VariableArray outVarsArray;
protected
  DAE.VariableArray VarArr;
  array<list<DAE.CrefIndex>> indices;
  Integer buckets;
algorithm
  VarArr       := emptyVariableArray(listLength(inVarList));
  outVarsArray := List.fold(inVarList, addNewVar, VarArr); 
end variableListToArray;

function addVar
  "Adds a variable to the set, or updates it if it already exists."
  input DAE.Variable inVar;
  input DAE.VariableArray inVariables;
  output DAE.VariableArray outVariables = inVariables;
protected
  Integer hash_idx, arr_idx;
  list<DAE.CrefIndex> indices;
algorithm
  hash_idx := ComponentRef.hashComponentRefMod(inVar.name, arrayLength(inVariables.variableIndices)) + 1;
  indices := arrayGet(inVariables.variableIndices, hash_idx);

  try
    DAE.CREF_INDEX(index=arr_idx) := List.getMemberOnTrue(inVar.name, indices, crefIndexEqualComponentRef);
    outVariables.variables := vararrayUpdate(outVariables.size,inVariables.variables, arr_idx, inVar);
  else
    outVariables.variables := vararrayAdd(outVariables.size, outVariables.variables, inVar);
    arrayUpdate(outVariables.variableIndices, hash_idx, (DAE.CREF_INDEX(inVar.name, outVariables.size + 1)::indices));
    outVariables.size := outVariables.size + 1;
  end try;
end addVar;

public function addNewVar
  "Add a new variable to the set, without checking if it already exists."
  input DAE.Variable inVar;
  input DAE.VariableArray inVariables;
  output DAE.VariableArray outVariables;
protected
  array<list<DAE.CrefIndex>> hash_vec;
  array<DAE.Variable> varr;
  Integer bsize, num_vars, idx;
  list<DAE.CrefIndex> indices;
algorithm
  DAE.VARIABLE_ARRAY(size = num_vars, variables = varr, variableIndices = hash_vec) := inVariables;
  bsize := arrayLength(hash_vec);
  idx := ComponentRef.hashComponentRefMod(inVar.name, bsize) + 1;
  varr := vararrayAdd(num_vars, varr, inVar);
  indices := hash_vec[idx];
  arrayUpdate(hash_vec, idx, (DAE.CREF_INDEX(inVar.name, num_vars + 1)::indices));
  outVariables := DAE.VARIABLE_ARRAY(num_vars + 1, varr, hash_vec);
end addNewVar;

function emptyVariable
"
  Generate a variable with some default values.
" 
  output DAE.Variable outVar;
algorithm
  // nessecary to allocate some memory, otherwise from time to time 
  // operations will result in segmentation fault
  outVar := DAE.VARIABLE(DAE.COMPONENT_REF("",NONE()),DAE.T_REAL(),DAE.K_PARAMETER(),DAE.NODIR(),NONE(),NONE(),"");
end emptyVariable;

function emptyVariableArray
  "Creates a new empty VariableArray structure."
  input Integer inSize;
  output DAE.VariableArray outVarArr;
protected
  array<list<DAE.CrefIndex>> indices;
  Integer buckets, arr_size;
  array<DAE.Variable> arr;
algorithm
  arr_size := max(inSize, 257);
  buckets := realInt(intReal(arr_size) * 1.4);
  indices := arrayCreate(buckets, {});
  arr := arrayCreate(arr_size, emptyVariable());
  outVarArr := DAE.VARIABLE_ARRAY(0, arr, indices);
end emptyVariableArray;

function isVariableKindVariable
  input DAE.Variable inVar;
  output Boolean result;
algorithm
  result := isKindVariable(inVar.kind);
end isVariableKindVariable;

function getVariableByCref
"
 Brief:
       return array index and variable or fail if variable is not in array.
"
  input DAE.ComponentRef inCref;
  input DAE.VariableArray inVarr;
  output Integer index;
  output DAE.Variable outVar;
algorithm 
try
  index := getVariableIndexByCREF(inCref, inVarr);
  outVar := inVarr.variables[index];
else 
  index := -1;
end try;  
end getVariableByCref;

function isKindVariable
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_VARIABLE()) then true;
  else false;
  end match;
end isKindVariable;

function isVariableKindState
  input DAE.Variable inVar;
  output Boolean result;
algorithm
  result := isKindState(inVar.kind);
end isVariableKindState;

function isKindState
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_STATE()) then true;
  else false;
  end match;
end isKindState;

function isVariableKindDerState
  input DAE.Variable inVar;
  output Boolean result;
algorithm
  result := isKindDerState(inVar.kind);
end isVariableKindDerState;

function isKindDerState
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_DER_STATE()) then true;
  else false;
  end match;
end isKindDerState;

function isVariableKindParameter
  input DAE.Variable inVar;
  output Boolean result;
algorithm
  result := isKindParameter(inVar.kind);
end isVariableKindParameter;

function isKindParameter
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_PARAMETER()) then true;
  else false;
  end match;
end isKindParameter;

function isVariableKindConstant
  input DAE.Variable inVar;
  output Boolean result;
algorithm
  result := isKindConstant(inVar.kind);
end isVariableKindConstant;

function isKindConstant
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_CONSTANT()) then true;
  else false;
  end match;
end isKindConstant;

function isKindDummyState
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_DUMMY_STATE()) then true;
  else false;
  end match;
end isKindDummyState;

function isKindDummyDer
  input DAE.Kind inKind;
  output Boolean result;
algorithm
  result := match(inKind)
  case(DAE.K_DUMMY_DER()) then true;
  else false;
  end match;
end isKindDummyDer;


function setVariableBinding
  input output DAE.Variable var;
  input DAE.Exp inExp;
algorithm
  var.bindExp := SOME(inExp);
end setVariableBinding;


/* 
 *
 * protected functions section 
 *
 */
//protected
function separateVariablesByKind
  input list<DAE.Variable>  inVarList;
  input list<DAE.Variable>  inVariables = {};
  input list<DAE.Variable>  inParameterVariables = {};
  input list<DAE.Variable>  inStateVariables = {};
  output list<DAE.Variable> outVariables;
  output list<DAE.Variable> outParameterVariables;
  output list<DAE.Variable> outStateVariables;
algorithm
  _:= match(inVarList)
    local
      DAE.Variable head;
      DAE.Kind kind;
      list<DAE.Variable> rest, addList;
      constant Boolean debug = false;
    case({})
      algorithm
        outVariables          := listReverse(inVariables);
        outParameterVariables := listReverse(inParameterVariables); 
        outStateVariables     := listReverse(inStateVariables);
      then ();
      
    case((head as DAE.VARIABLE(kind=kind))::rest)
      guard(isKindVariable(kind) or isKindDerState(kind) or isKindDummyDer(kind) or isKindDummyState(kind))
      equation
        if debug then print("Var: " + DumpDAE.dumpVariable(head) + "\n"); end if;
          addList = head :: inVariables;
          (outVariables, outParameterVariables, outStateVariables) =
          separateVariablesByKind(rest, addList, inParameterVariables, inStateVariables);
      then ();

    case((head as DAE.VARIABLE(kind=kind))::rest)
      guard( isKindParameter(kind) or isKindConstant(kind))
      equation
        if debug then print("Param: " + DumpDAE.dumpVariable(head) + "\n"); end if;
          addList = head :: inParameterVariables;
          (outVariables, outParameterVariables, outStateVariables) =
          separateVariablesByKind(rest, inVariables, addList, inStateVariables);
      then ();

    case((head as DAE.VARIABLE(kind=DAE.K_STATE()))::rest)
      equation
        if debug then print("State: " + DumpDAE.dumpVariable(head) + "\n"); end if;
          addList = head :: inStateVariables;
          (outVariables, outParameterVariables, outStateVariables) =
          separateVariablesByKind(rest, inVariables, inParameterVariables, addList);
      then ();
    else fail();
    end match;
end separateVariablesByKind;

function addBindingExpToParameter
"
Adds the binding expressions to the corresponding parameter. If a parameter got 
a binding expression, it is removed from the temporary list.
"
  input  list<DAE.Equation> inBindingEqs;
  input  list<DAE.Variable> inParameterList;
  output list<DAE.Variable> outParameterList = {};
  protected
    list<DAE.Variable> restParaml;
    DAE.Variable v;	
algorithm
  restParaml := inParameterList;
  for eq in inBindingEqs loop
    (v, restParaml) := helpAddBindingtoVar(eq, restParaml);
    outParameterList := v::outParameterList;
  end for;
  outParameterList := listAppend(restParaml,outParameterList);
end addBindingExpToParameter;

function helpAddBindingtoVar
"
Looks for the parameter which corresponds to the binding equation. Usualy it is
the first parameter in the list. But if not, the rest of the list is examined.
"
  input DAE.Equation inEqn;
  input list<DAE.Variable> inVarl;
  output DAE.Variable outVar;
  output list<DAE.Variable> outVarl = {};
protected
  DAE.Variable var;
  list<DAE.Variable> varlRest;
  DAE.ComponentRef cref;
algorithm
  outVar := emptyVariable();
  cref := expComponentRef(inEqn.lhs);
  // each bindingEquation has a lhs Variable 
  (outVar, outVarl) := match inVarl
  local
    DAE.Variable v;
  case var::varlRest guard(ComponentRef.compareCrefNoStr(var.name,cref))
  algorithm
    var := setVariableBinding(var, inEqn.rhs);
  then (var, varlRest);
  case var::varlRest
  algorithm
    (v, varlRest) := helpAddBindingtoVar(inEqn, varlRest);
  then (v, var::varlRest);
  else
  algorithm
    print("fail: BackendVariable.helpAddBindingtoVar \n");
  then fail();
  end match;
end helpAddBindingtoVar;

function expComponentRef
  input DAE.Exp inExp;
  output DAE.ComponentRef outCref;
algorithm
  outCref := match(inExp)
    local
	  DAE.ComponentRef id;
    case(DAE.CREF(id = id))
	  then id;
	else 
	  fail();
	end match;
end expComponentRef;

function crefIndexEqualComponentRef
  input DAE.ComponentRef Cref;
  input DAE.CrefIndex CrefIdx;
  output Boolean b;
algorithm 
  b := ComponentRef.compareCrefNoStr(CrefIdx.cref,Cref);
end crefIndexEqualComponentRef;

function hashVariableList
"
Brief: Create a HashVektor ComponentRef => Index.
       If several CREF's return the same hash_index, the new IndexCref get added to the list in
	   inHashVektor[hash_index].
"  
  input array<list<DAE.CrefIndex>>  inHashVektor;
  input list<DAE.Variable>          inVarList;
  output array<list<DAE.CrefIndex>> outHashVektor;  
protected
  DAE.Variable var;
  list<DAE.CrefIndex> indices;
  Integer bsize, hash_index, arr_size, idx = 1;
algorithm 
  bsize := arrayLength(inHashVektor);
  outHashVektor := inHashVektor;
  
  for var in inVarList loop
    hash_index := ComponentRef.hashComponentRefMod(var.name, bsize) + 1;
	  indices := inHashVektor[hash_index];
	  arrayUpdate(outHashVektor, hash_index, (DAE.CREF_INDEX(var.name, idx)::indices));
	  idx:= idx + 1;
  end for;
end hashVariableList;

function getVariableIndexByCREF
input DAE.ComponentRef cr;
input DAE.VariableArray arr;
output Integer index = 0;
protected 
  DAE.CrefIndex cindex;
  array<list<DAE.CrefIndex>>  hashVektor;
  list<DAE.CrefIndex> indices;
  Integer buckets, hash_index;
algorithm  
  hashVektor := arr.variableIndices;
  buckets    := arrayLength(hashVektor);
  hash_index := ComponentRef.hashComponentRefMod(cr, buckets) + 1;
  indices := hashVektor[hash_index];
  for cindex in indices loop
    if(ComponentRef.compareCrefNoStr(cindex.cref,cr))
	  then index := cindex.index;
	end if;
  end for;
  if(index == 0)
  then fail();
  end if;
end getVariableIndexByCREF;

/* =======================================================
 *
 *  Section for functions that deals with VariablesArray
 *
 * =======================================================
 */
 
 protected function vararrayAdd
" Adds a variable last to the array<DAE.Variable>, increasing array size
  if no space left by factor 1.4"
  input Integer num_elems;
  input output array<DAE.Variable> Variables;
  input DAE.Variable inVar;
algorithm
  Variables := Array.expandOnDemand(num_elems + 1, Variables, 1.4, emptyVariable());
  arrayUpdate(Variables, num_elems + 1, inVar);
end vararrayAdd;

function vararrayUpdate
  "Sets the n:th variable in the array."
  input Integer num_elems;
  input output array<DAE.Variable> Variables;
  input Integer inIndex;
  input DAE.Variable inVar;
algorithm
  true := inIndex <= num_elems;
  arrayUpdate(Variables, inIndex, inVar);
end vararrayUpdate;


end BackendVariable;