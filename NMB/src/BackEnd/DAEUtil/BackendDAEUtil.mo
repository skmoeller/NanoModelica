package BackendDAEUtil
"
Brief:
contains all functions related to manipulate BackendDAE.
"
public
import DAE;

protected
import BackendEquation;
import BackendVariable;
import AvlSetInt;

/*
 *
 * public functions section
 *
 */
public

/******************************************************************
 stuff to calculate Adjacency matrix
******************************************************************/
function adjacencyMatrix
  "Funktion bestimmt zeilenweise die Adjazenzmatrix, wobei diese von Oben
   nach Unten aufgebaut wird.
   Außerdem wird gleichzeitig die transponierte Adjazenzmatrix aufgebaut."
  input DAE.VariableArray inVariables; /*Variablen Array*/
  input DAE.EquationArray inEquations; /*Gleichungen Array*/
  output DAE.AdjacencyMatrix outAdjacencyMatrix; /*Adjazenzmatrix*/
  output DAE.AdjacencyMatrix outAdjacencyMatrixT; /*Transponierte Adjazenzmatrix*/
protected
  Integer sizeEquations; /*Variabeln fuer Anzahl Gleichungen */
  Integer iterVar;/*Variable fuer die Iteration*/
algorithm
  sizeEquations:=inEquations.size;
  /*Initialisierung der Matrizen*/
  outAdjacencyMatrix:=arrayCreate(sizeEquations,{});
  outAdjacencyMatrixT:=arrayCreate(sizeEquations,{});
  for i in sizeEquations:-1:1 loop
    iterVar:=i;
    /*Setze Zeile von Adjazenzmatrix*/
    outAdjacencyMatrix[iterVar]:=setAdjacency(inVariables,inEquations.equations[iterVar]);
    /*Mit Zeile aus Adjazenzmatrix wird stueckweise die transponierte Matrix dazu aufgebaut*/
    outAdjacencyMatrixT:=setAdjacencyT(outAdjacencyMatrixT,outAdjacencyMatrix[iterVar],iterVar);
  end for;
end adjacencyMatrix;

/*
 *
 * protected functions section
 *
 */
protected

  function setAdjacency
    "Funktion ruft Routine auf um an Liste fuer entsprechende Gleichung zu kommen"
    input DAE.VariableArray inVar; /*Variablen Array*/
    input DAE.Equation inEqn; /*Gleichungen als 'Expressions'*/
    output list<Integer> outList; /*Liste mit Indizes von vorkommenden Variablen*/
  algorithm
    outList:=getList(DAE.BINARY(inEqn.lhs,DAE.SUB(),inEqn.rhs),inVar); /*Schreibe Gleichung als (lhs-rhs)=0 -> Ein Expression!*/
  end setAdjacency;

  function getList
    "Funktion durchsucht zunaechst den 'Expression-Baum' und gibt alle gefundenen 'crefs'
    zurueck. Dann folgt Zuweisung von Indizes an entsprechende 'crefs'. Paarweise verschiedene
    werden anschliessend in Ausgabeliste geschrieben."
    input DAE.Exp inEqn; /*Gleichungen als 'Expressions'*/
    input DAE.VariableArray inVar; /*Variablen Array*/
    output list<Integer> lIndx; /*Liste mit Indizes von vorkommenden VAriablen*/
  protected
    Integer indx,iterVar; /*indx: Index Variable; iterVar: Iterationsvariable fuer Schleife */
    list<DAE.ComponentRef> crefs; /*Liste von 'crefs'*/
  algorithm
    /*Initialisierung der Listen*/
    lIndx:={};
    crefs:={};
    /*Aufruf Funktion fuer Suchen der 'crefs'*/
    crefs:=treeSearch(inEqn,crefs);
    for c in crefs loop
      /*Mit interner Funktion wird Index ueber Hash-Wert bestimmt*/
      (indx,_):=BackendVariable.getVariableByCref(c,inVar); /*TODO: VARIABLEN DER FORM der.u2 etc. werden in UNIX nicht erkannt*/
      /*Falls Index noch nicht in Liste und entsprechender 'cref' 'Variable', wird er hinzugefuegt*/
      if (not listMember(indx,lIndx)) and indx>0 then
        /*Rufe Funktion zum Hinzufuegen auf*/
        lIndx:=addIndx2list(indx::lIndx);
      end if;
    end for;
  end getList;

  function treeSearch
    "Funktion fuehrt eine rekursive Durchsuchung des Baumes durch. Es werden alle Zweige bis zu Blaettern
    abgelaufen. An allen anderen Knoten wird Liste von 'crefs' entsprechend aktuallisiert."
    input DAE.Exp inEqn; /*Expression welcher nach 'crefs abgesucht wird'*/
    input list<DAE.ComponentRef> inListCrefs; /*Liste mit bereits gefundenen 'crefs'*/
    output list<DAE.ComponentRef> outListCrefs; /*Liste mit eventuell neuem 'cref'*/
  algorithm
    _:=match(inEqn)
      local DAE.Exp exp1,exp2; /*Locale VAriablen die 'Expression' aufnehmen*/
            list<DAE.Exp> lExp; /*Liste von 'Expressions'; fuer 3.Fall*/
            DAE.ComponentRef cref; /*Gesuchter 'cref'*/
    /*1.Fall: Zwei Ausdruecke mit Rechenoperation: Laufe zunaechst 'linken' Zweig, aktuallisiere Liste, dann 'rechter Zweig'*/
    case DAE.BINARY(exp1,_,exp2)
    algorithm
      outListCrefs:=treeSearch(exp1,inListCrefs);
      outListCrefs:=treeSearch(exp2,outListCrefs);
    then "";
    /*2.Fall: Ausdruck mit negativem Vorzeichen; Durchsuche Zweig mit dem 'Expression'*/
    case DAE.UNARY(_,exp1)
    algorithm
      outListCrefs:=treeSearch(exp1,inListCrefs);
    then "";
    /*3.Fall: Funktionsaufruf. Iteriere ueber die Liste mit den 'Expressions' und pruefe diese einzeln*/
    case DAE.CALL(_,lExp)
      algorithm
        /*1. Element wird herausgeloest->damit Liste entsprechend aktuallisiert werden kann.*/
        exp1:=listGet(lExp,1);
        lExp:=listDelete(lExp,1);
        outListCrefs:=treeSearch(exp1,inListCrefs);
        /*Iteration ueber Liste->Suche nach 'crefs' in den einzelnen 'Expressions'*/
        for e in lExp loop
          outListCrefs:=treeSearch(e,outListCrefs);
        end for;
    then "";
    /*4. Fall 'cref' gefunden! Fuege diesen zu Liste hinzu*/
    case DAE.CREF(cref)
     algorithm
       outListCrefs:=cref::inListCrefs;
    then "";
    /*Sonstige Faelle: Falls Blatt Integer,Real,... ist-> Liste nicht veraendern!*/
    else
      algorithm
        outListCrefs:=inListCrefs;
    then "";
    end match;
  end treeSearch;

  function addIndx2list
    "Funktion fuegt Element aufsteigend mittels Insertion-Sort in bereits sortierte Liste ein"
    input list<Integer> inList; /*Uebergebene Liste mit neuem Index als 1. Element*/
    output list<Integer> outList;/*Liste mit neuem Index an entsprechender Stelle*/
  protected
    array<Integer> arr;/*Hilfsarry um ueber Elemente zu iterieren*/
    Integer val,helpVar,iterVar; /*Variablen fuer Insertion-Sort*/
  algorithm
    if listLength(inList)<2 then
      outList:=inList;
    else
      arr:=listArray(inList);
      for i in 2:listLength(inList) loop
        iterVar:=i;
        val:=arr[iterVar];
        while iterVar>1 and arr[iterVar-1]>val loop
          helpVar:=arr[iterVar+0];
          arr[iterVar+0]:=arr[iterVar-1];
          arr[iterVar-1]:=helpVar;
          iterVar:=iterVar-1;
        end while;
        arr[iterVar+0]:=val;
      end for;
      outList:=arrayList(arr);
    end if;
  end addIndx2list;

function setAdjacencyT
  "Funktion setzt einige Elemente der transponierten Adjazenzmatrix.
  Jede Zeile, welche in der Eingabe Liste vorkommt, erhaelt entsrechenden Gleichungsindex."
  input DAE.AdjacencyMatrix inAdjacencyT;/*Alte transponierte Adjazenzmatrix*/
  input list<Integer> variableList; /*Liste von Variabeln die in Gleichung mit Index 'equationIndex' vorkommen*/
  input Integer equationIndex; /*Aktuell betrachtet Gleichung*/
  output DAE.AdjacencyMatrix outAdjacencyT; /*Aktuallisierte Adjazenzmatrix*/
protected
  Integer var; /*Iterationvariable*/
algorithm
  outAdjacencyT:=inAdjacencyT;
  for i in variableList loop
    var:=i;
    outAdjacencyT[var]:=equationIndex::inAdjacencyT[var];
  end for;
  end setAdjacencyT;

end BackendDAEUtil;
