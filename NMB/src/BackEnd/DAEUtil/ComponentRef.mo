package ComponentRef
"
Contains all functions related to the datatype DAE.ComponentRef.
"
public 
import DAE;

protected 
import BackendEquation;
import BackendVariable;
  
/* 
 *
 * public functions section 
 *
 */
public

function compareCREF
"
Compares two crefs by building a string for each of them and compares these strings. The result is true, if they are identical.
"
  input DAE.ComponentRef Cref1;
  input DAE.ComponentRef Cref2;
  output Boolean b;
protected
    String s1, s2;
algorithm
    s1 := ComponentRefToStr(Cref1);
    s2 := ComponentRefToStr(Cref2);
  if(s1 == s2)
    then 
      b:= true;
  else  
     b:= false;
  end if;	  
end compareCREF;

function compareCrefNoStr
"
Compares two crefs by comparing the names of each part. The result is true, if they are identical.
"
  input DAE.ComponentRef Cref1;
  input DAE.ComponentRef Cref2;
  output Boolean b;
algorithm
  b := match (Cref1,Cref2)
       local 
	     String s1, s2;
         DAE.ComponentRef c1, c2;
	   case(DAE.COMPONENT_REF(name = s1, qualName = SOME(c1)), 
	        DAE.COMPONENT_REF(name = s2, qualName = SOME(c2))) guard(s1 == s2)
	     then compareCrefNoStr(c1,c2);
	   case(DAE.COMPONENT_REF(name = s1, qualName = NONE()), 
	        DAE.COMPONENT_REF(name = s2, qualName = NONE())) guard(s1 == s2)
         then true;
	   else then false;
  end match;	   
end compareCrefNoStr;

function ComponentRefToStr1
"
Build the full name of a cref as string calling ComponentRefToString.
Needed as for templates with only one argument.
"
    input DAE.ComponentRef inCref;
    output String outString;
  algorithm
  outString := match(inCref)
    local
	  DAE.ComponentRef qualName;
	  String name;
    case(DAE.COMPONENT_REF(name=name, qualName=SOME(qualName)))
    equation
      name = name + ".";
      then ComponentRefToStr(qualName, name);
    case(DAE.COMPONENT_REF(name=name, qualName=NONE()))
      then name;
    end match;
end ComponentRefToStr1;
  
function ComponentRefToStr
"
Build the full name of a cref as string.
"
    input DAE.ComponentRef inCref;
    input String inString = "";
    output String outString;
  algorithm
  outString := match(inCref)
    local
	  DAE.ComponentRef qualName;
	  String name;
    case(DAE.COMPONENT_REF(name=name, qualName=SOME(qualName)))
    equation
      name = inString + name + ".";
      then ComponentRefToStr(qualName, name);
    case(DAE.COMPONENT_REF(name=name, qualName=NONE()))
      then inString + name;
    end match;
end ComponentRefToStr;

function hashComponentRefMod  
"
Description: Hash the ComponentRef to a positiv Integer in the range of [0,mod-1] 
"
  input DAE.ComponentRef cr;
  input Integer mod;
  output Integer res;
protected
  Integer h;
algorithm
   // hash might overflow => force positive
   assert(1 < mod,"ERROR: mod value < 2");
   h := intAbs(hashComponentRef(cr));
   res := intMod(h,mod);
end hashComponentRefMod;

function hashComponentRef 
  input DAE.ComponentRef cr;
  output Integer hash;
protected
 String id;
algorithm
  id := ComponentRefToStr(cr);
  hash := stringHashDjb2(id);
end hashComponentRef;

public function printComponentRefListStr
"
Description: Create { ComponentRef(..), ComponentRef(..),..,ComponentRef(..) } 
from a list of ComponentRefs
"
  input list<DAE.ComponentRef> crs;
  output String res;
algorithm
  res := "{" + List.dump(crs, DumpDAE.dumpComponentRef) + "}";
end printComponentRefListStr;


/* 
 *
 * protected functions section 
 *
 */
 
function stringHashDjb2
  input String str;
  output Integer hash;
external "builtin";
end stringHashDjb2;
protected  

  
end ComponentRef;