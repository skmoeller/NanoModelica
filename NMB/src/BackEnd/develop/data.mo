package Data
"
  Testdaten für das Projekt.
"
  import DAE_List;
   
  function getModel
  "
    Liefert die Eingabedaten für die Berechnung des Matching.
  "
    output DAE_List.AdjacencyMatrix data1;
  algorithm
    data1 := {{2},{4,3},{4,3},{5,3},{6,5},{7,5},{4,2,1},{8,1}};
  end getModel;  
end Data;
