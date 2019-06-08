package Main
"
  Beispiel für den Arbeitsablauf bei der Modulentwicklung.
"
  import DAE;
  import DAE_List;
  import DumpDAE; 
  import ConvDAE_List;
  import Data;
  import Matching;
  
  function main
      output String msg1 = "";
  protected
    DAE_List.AdjacencyMatrix tempData1;
    DAE.AdjacencyMatrix data1;
    array<Integer> a1, a2;
    DAE.Matching matching;
    String msg = "";
    Integer i;
  algorithm
  // Daten laden und konvertieren.
    tempData1 := Data.getModel();
    data1 := ConvDAE_List.convAdjacencyMatrix(tempData1);
    
  // Programmieren Sie die Funktion Matching.PerfectMatching(...).  
    matching := Matching.PerfectMatching(data1);

  // Diese Zeichenkette wird mit einer erwarteten verglichen. Stimmen sie
  // überein, so haben Sie die Funktion vermutlich richtig implementiert.
  // Erzeugen Sie zusätzlich eigene Beispiele, um Ihre Funktion zu testen!    
    msg1 := DumpDAE.dumpMatching(matching);    
  
  // Ergebnisse anzeigen (einfache Kontrollausgabe)    
    DAE.MATCHING(variableAssign = a1, equationAssign = a2) := matching;
    i := 1;
    for idx in a1 loop
      msg := msg + "var["+ String(i) +"] solved by equ " + String(idx) + "\n";
      i := i+1;
    end for;
    msg := msg + "\n";
    i := 1;
    for idx in a2 loop
      msg := msg + "eqn["+ String(i) +"] solves var " + String(idx) + "\n";
      i := i+1;
    end for;      
    print(msg);
  end main;    
     
end Main;
