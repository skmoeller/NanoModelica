package Matching
" file:        Matching.mo
  package:     Matching
  description: Matching contains functions for matching algorithms"

import DAE;

function PerfectMatching "
  This function fails if there is no perfect matching for the given system."
  input  DAE.AdjacencyMatrix m;
  output DAE.Matching matching;
end PerfectMatching;

end Matching;
