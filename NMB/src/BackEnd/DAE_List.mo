package DAE_List
"
Desc: This package is a copy of the package DAE, except all arrays are replaced by lists.
A model will be dumped as constructor call with many nested  constructor calls inside. Each object of the model has to be dumped as constructor call. Arrays unfortunately don't have a constructor. So they will be dumped as lists. Therefor a datatype with lists instead of arrays is needed. After constructing an object by these calls it has to be converted into the corresponding datatype from the DAE package.
"
  uniontype Exp "expressions"
    record INT "integer literals"
      Integer integer;
    end INT;

    record REAL "literal reals"
      Real real;
    end REAL;

    record BOOL "literal booleans"
      Boolean bool;
    end BOOL;

    record CREF "identifiers"
      ComponentRef id;
    end CREF;

    record BINARY "binary expressions"
      Exp exp1;
      BinOp op;
      Exp exp2;
    end BINARY;

    record UNARY "unary expresions"
      UnOp op;
      Exp exp1;
    end UNARY;

    record CALL "function calls"
      String id;  // "function name"
      list<Exp> args; // "function arguments"
    end CALL;
  end Exp;

  uniontype BinOp "binary operators"
    record ADD "addition" end ADD;
    record SUB "substraction" end SUB;
    record MUL "multiplication" end MUL;
    record DIV "division" end DIV;
    record POW "power" end POW;
  end BinOp;

  uniontype UnOp "unary operators"
    record NEG "negation operator" end NEG;
  end UnOp;

  uniontype ImportDAE
    record IMPORT_DAE
      list<Variable> variables;
      list<Equation> equations;
      list<Equation> initialEquations;
      list<Equation> bindingEquations;
    end IMPORT_DAE;
  end ImportDAE;
  
  uniontype BackendDAE "represents the whole model"
    record BACKENDDAE
      EquationSystem simulation;
      EquationSystem initialization;
      Shared shared; 
    end BACKENDDAE;
  end BackendDAE;
  
  uniontype EquationSystem
    record EQUATION_SYSTEM
      VariableArray variables;
      EquationArray equations;
      Option<AdjacencyMatrix> adjacency;
      Option<AdjacencyMatrix> adjacencyTranspose;
      Option<Matching> matching;
      StrongComponents strongComponents;
    end EQUATION_SYSTEM;
  end EquationSystem;
  
  uniontype Shared
    record SHARED
      VariableArray parameterVariables;
      VariableArray stateVariables;
      VariableArray aliasVariables;
      EquationSystem removedEqns;
    end SHARED;
  end Shared;
  
  type AdjacencyMatrix = list<list<Integer>>; // array<list<..>>

  uniontype Matching
    record MATCHING
      list<Integer> variableAssign "variableAssign[varindx]=eqnindx"; // array
      list<Integer> equationAssign "equationAssign[eqnindx]=varindx"; // array
    end MATCHING;
  end Matching;

  type StrongComponents = list<StrongComponent>;

  uniontype StrongComponent
    record SINGLE_EQUATION
      Integer equationIndex;
      Integer variableIndex;
      Option<Exp> residual;
      Option<Exp> derivative;
    end SINGLE_EQUATION;

    record ALGEBRAIC_LOOP
      list<Integer> equationIndices;
      list<Integer> variableIndices;
      list<Exp> residuals;
      list<list<Exp>> jacobian;
    end ALGEBRAIC_LOOP;
  end StrongComponent;

  uniontype VariableArray
    record VARIABLE_ARRAY
      Integer size;
      list<Variable> variables;        // array
      list<list<CrefIndex>> variableIndices; // array
    end VARIABLE_ARRAY;
  end VariableArray;

  uniontype CrefIndex "Component Reference Index"
    record CREF_INDEX
      ComponentRef cref;
      Integer index;
    end CREF_INDEX;
  end CrefIndex;

  uniontype EquationArray
    record EQUATION_ARRAY
      Integer size;
      list<Equation> equations; // array
    end EQUATION_ARRAY;
  end EquationArray;

  uniontype Equation
    record EQUATION
      Exp lhs;
      Exp rhs;
    end EQUATION;
  end Equation;

  uniontype Variable
    record VARIABLE
      ComponentRef name;
      Type tp;
      Kind kind;
      Direction direction;
      Option<Exp> bindExp;
      Option<VarAttributes> attributes;
      String comment;
    end VARIABLE;
  end Variable;

  uniontype ComponentRef
    record COMPONENT_REF
      String name;
      Option<ComponentRef> qualName;
    end COMPONENT_REF;
  end ComponentRef;
  
  uniontype VarAttributes 	// e.g. start="288.15" fixed="false" min="0.0"  max="273.9"  nominal="500"  unit="K" displayUnit="degC"
    record VAR_ATTRIBUTES
      Exp start;
      Boolean fixed;
      Option<Exp> min;
      Option<Exp> max;
      Option<Exp> nominal;
      Option<Exp> unit;
    end VAR_ATTRIBUTES;
  end VarAttributes;

  uniontype Type
    record T_REAL
    end T_REAL;
    record T_INTEGER
    end T_INTEGER;
    record T_BOOL
    end T_BOOL;
    record T_STRING
    end T_STRING;// fehlt const?
  end Type;

  uniontype Kind
    record K_VARIABLE 	// <VariableCategory>algebraic</VariableCategory>
    end K_VARIABLE;
    record K_STATE  	// <VariableCategory>state</VariableCategory>
    end K_STATE;
    record K_DER_STATE 	// <VariableCategory>derivative</VariableCategory>
    end K_DER_STATE;
    record K_PARAMETER 	// <VariableCategory>independentParameter</VariableCategory>
    end K_PARAMETER;
    record K_CONSTANT  // <VariableCategory>constant</VariableCategory>
    end K_CONSTANT;
    record K_DUMMY_STATE  	// <VariableCategory>algebraic</VariableCategory>
    end K_DUMMY_STATE;
    record K_DUMMY_DER 	// <VariableCategory>algebraic</VariableCategory>
    end K_DUMMY_DER;     
  end Kind;
  
  uniontype Direction
    record INPUT end INPUT;
    record OUTPUT end OUTPUT;
    record NODIR end NODIR;
  end Direction; 
end DAE_List;
