package Main
"
  Beispiel für den Arbeitsablauf bei der Modulentwicklung.
"
  import DAE;
  import DAE_List;
  import DumpDAE; 
  import ConvDAE_List;
  import Data;
  import BackendDAEUtil;
  
  function main
      output String msg1 = "";
  protected
    DAE_List.VariableArray tempData1;
    DAE_List.EquationArray tempData2;
    DAE.VariableArray data1;
    DAE.EquationArray data2;
    DAE.AdjacencyMatrix result1;
    DAE.AdjacencyMatrix result2;
    String msg = "";
    Integer i;
  algorithm
  
  // Daten laden und konvertieren.
    (tempData1, tempData2) := Data.getModel();
    data1 := ConvDAE_List.convVariableArray(tempData1);
    data2 := ConvDAE_List.convEquationArray(tempData2);
    
  // Programmieren Sie die Funktion BackendDAEUtil.adjacencyMatrix(...).  
    (result1, result2) := BackendDAEUtil.adjacencyMatrix(data1, data2);
    
  // Diese Zeichenkette wird mit einer erwarteten verglichen. Stimmen sie
  // überein, so haben Sie die Funktion vermutlich richtig implementiert.
  // Erzeugen Sie zusätzlich eigene Beispiele, um Ihre Funktion zu testen!
    msg1 := DumpDAE.dumpAdjacencyMatrix(result1) + "\n";
    msg1 := msg1 + DumpDAE.dumpAdjacencyMatrix(result2);
    
  // Ergebnisse anzeigen (einfache Kontrollausgabe) 
    i := 1;
    for r in result1 loop
      msg := msg + "Eqn " + String(i) + " : ";
      i := i + 1;
      for c in r loop
        msg := msg + String(c) + " ";
      end for;
      msg := msg + "\n";
    end for;
    msg := msg +"\n";

    i := 1;
    for r in result2 loop
      msg := msg + "Var " + String(i) + " : ";
      i := i + 1;
      for c in r loop
        msg := msg + String(c) + " ";
      end for;
      msg := msg + "\n";
    end for;
    msg := msg +"\n";
    
    print(msg);
  end main;    
     
end Main;
