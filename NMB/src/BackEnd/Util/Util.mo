package Util

public function getOption<T>
  "Returns an option value if SOME, otherwise fails"
  input Option<T> inOption;
  output T outValue;
algorithm
  _ := match inOption
  case SOME(outValue)
  then "";
  else
  algorithm
    print("fail: Util.getOption() \n");
  then fail();
  end match;
end getOption;

end Util;