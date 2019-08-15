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
    /*Testfall 1: Genauso viele Gleichung wie Variablen*/
    //data1 := {{2},{4,3},{4,3},{5,3},{6,5},{7,5},{4,2,1},{8,1}};
    /*Testfall 2: Mehr Variabelen als Gleichungen*/
    //data1 := {{2,9},{4,3},{4,3},{5,3},{6,5},{7,5},{4,2,1},{8,1}};
    /*Testfall 3: Weniger Variablen als Gleichungen*/
    //data1 := {{2},{4,3},{4,3},{5,3},{6,5},{7,5},{4,2,1},{1}};
    /*Testfall 4: Gleichung von mehreren Variablen abhaenig -> keine Eindeutige Zuordnung*/
    //data1 := {{2},{4,3},{4,3},{5,3},{6,5},{7,5},{4,2},{8,1}};
    /*Testfall 5: Kein Matching moeglich*/
    //data1 := {{1,2,3},{3},{3}};
    /*Testfall 6: Matching ist moeglich, Testfall 1 aus Adjazenz Matrix*/
    //data1 := {{5},{6},{2},{3},{4,5},{1,2,3,4},{1,7}};
    /*Testfall 7: Matching ist moeglich, Testfall 3 aus Adjazenz Matrix*/
    data1 := {{1},{2}};
  end getModel;
end Data;
