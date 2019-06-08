package Array
"
Brief:
This package contains all functions that operate on the Array type. test
"

import MetaModelica.Dangerous.{arrayGetNoBoundsChecking, arrayUpdateNoBoundsChecking, arrayCreateNoInit};

/* 
 *
 * public functions section 
 *
 */
function expand<T>
  "Increases the number of elements of an array with inN. Each new element is
   assigned the value inFill."
  input Integer inN;
  input array<T> inArray;
  input T inFill;
  output array<T> outArray;
protected
  Integer len;
algorithm
  if inN < 1 then
    outArray := inArray;
  else
    len := arrayLength(inArray);
    outArray := arrayCreateNoInit(len + inN, inFill);
    copy(inArray, outArray);
    setRange(len + 1, len + inN, outArray, inFill);
  end if;
end expand;

function expandOnDemand<T>
  "Resizes an array with the given factor if the array is smaller than the
   requested size."
  input Integer inNewSize "The number of elements that should fit in the array.";
  input array<T> inArray "The array to resize.";
  input Real inExpansionFactor "The factor to resize the array with.";
  input T inFillValue "The value to fill the new part of the array.";
  output array<T> outArray "The resulting array.";
protected
  Integer new_size, len = arrayLength(inArray);
algorithm
  if inNewSize <= len then
    outArray := inArray;
  else
    new_size := realInt(intReal(len) * inExpansionFactor);
    outArray := arrayCreateNoInit(new_size, inFillValue);
    copy(inArray, outArray);
    setRange(len + 1, new_size, outArray, inFillValue);
  end if;
end expandOnDemand;

function copy<T>
  "Copies all values from inArraySrc to inArrayDest. Fails if inArraySrc is
   larger than inArrayDest.

   NOTE: There's also a builtin arrayCopy operator that should be used if the
         purpose is only to duplicate an array."
  input array<T> inArraySrc;
  input array<T> inArrayDest;
  output array<T> outArray = inArrayDest;
algorithm
  if arrayLength(inArraySrc) > arrayLength(inArrayDest) then
    fail();
  end if;

  for i in 1:arrayLength(inArraySrc) loop
    arrayUpdateNoBoundsChecking(outArray, i, arrayGetNoBoundsChecking(inArraySrc, i));
  end for;
end copy;

function setRange<T>
  "Sets the elements in positions inStart to inEnd to inValue."
  input Integer inStart;
  input Integer inEnd;
  input array<T> inArray;
  input T inValue;
  output array<T> outArray = inArray;
algorithm
  if inStart > arrayLength(inArray) then
    fail();
  end if;

  for i in inStart:inEnd loop
    arrayUpdate(inArray, i, inValue);
  end for;
end setRange;

function fold<T, FoldT>
  "Takes an array, a function, and a start value. The function is applied to
   each array element, and the start value is passed to the function and
   updated."
  input array<T> inArray;
  input FoldFunc inFoldFunc;
  input FoldT inStartValue;
  output FoldT outResult = inStartValue;

  partial function FoldFunc
    input T inElement;
    input FoldT inFoldArg;
    output FoldT outFoldArg;
  end FoldFunc;
algorithm
  for e in inArray loop
    outResult := inFoldFunc(e, outResult);
  end for;
end fold;

/* 
 *
 * protected functions section 
 *
 */

end Array;