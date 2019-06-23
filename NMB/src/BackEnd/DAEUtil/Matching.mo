package Matching
" file:        Matching.mo
  package:     Matching
  description: Matching contains functions for matching algorithms"

import DAE;
import Array;
import List;

function PerfectMatching
"Die Funktion reserviert Speicher fuer die Datenstrukturen des Matchings
und ruft die entsprechenden Unterfunktionen auf.
Ausserdem wird geprueft ob das Matching funktioniert hat. Die Funktion gibt einen
Fehler zurück falls es kein 'perfektes Matching' gibt."
  input  DAE.AdjacencyMatrix m; /*Adjazenz MAtrix fuer System*/
  output DAE.Matching matching; /*Struktur fuer Matching (var->eq & eq -> var); 'global' verfuegbar*/
protected
  array<Integer> assign;/*Array fuer einen Durchlauf des Matchings*/
  Integer sizeEquations,eqnIdx; /*Anzahl Gleichungen, Index aktuelle Gleichung*/
  array<Boolean> vMark; /*Array fuer Markierungen der Variablen ('global')*/
  array<Boolean> eMark; /*Array fuer Markierungen der Gleichungen ('global')*/
  Boolean success; /*Variable die Anzeigt, ob Matching erfolgreich war*/
algorithm
  /*Variabeln und Array's initialisieren*/
  sizeEquations:=arrayLength(m);
  matching:=DAE.MATCHING(arrayCreate(sizeEquations,0),arrayCreate(sizeEquations,0));
  vMark:=arrayCreate(sizeEquations,false);
  eMark:=arrayCreate(sizeEquations,false);
  assign:=arrayCreate(sizeEquations,0);
  /*Schleife ruft jede Gleichung auf und sucht entsprechende Variable mit Funktion 'patchFound'*/
  for i in 1:sizeEquations loop
    eqnIdx:=i;
    (vMark,eMark,assign,success):=pathFound(eqnIdx,sizeEquations,vMark,eMark,matching.variableAssign,m);
    matching.variableAssign:=assign; /*Aktuelles Ergbnis in 'globale' Variable kopieren*/
    /*Falls kein Matching gefunden, wird Fehler ausgeben*/
    if not success then
      print("singulaer");
    end if;
  end for;
  /*Pruefe zusätzlich ob alle Gleichungen betrachtet wurden*/
  if listMember(false,arrayList(eMark)) then
      print("Not all Equation touched");
  end if;
  /*Bilde 'transponiertes Matching', d.h var->eq*/
  matching.equationAssign:=createEquationAssign(matching.variableAssign,sizeEquations);
end PerfectMatching;

function pathFound
  "Funktion sucht Pfad in Bipartiten Graphen der jeweils eine Gleichung mit einer Variablen verbindet.
  Ggf wird Pfad auch innerhalb der Funktion neu gesetzt."
  input Integer equationIdx; /*Aktueller Gleichungs Index*/
  input Integer sizeEquations; /*Anzahl der Gleichungen*/
  input array<Boolean> inVariableMark; /*Array mit bereits markierten Variablen*/
  input array<Boolean> inEquationMark; /*Array mit bereits markierten Gleichungen*/
  input array<Integer> inVariableAssign; /*Aktuelles Matching*/
  input DAE.AdjacencyMatrix adjacency; /*Adjazenz Matrix*/
  output array<Boolean> outVariableMark; /*Gibt aktualisierte markierte Variablen zurueck*/
  output array<Boolean> outEquationMark; /*Gibt aktualisierte markierte Gleichungen zurueck*/
  output array<Integer> outVariableAssign; /*Neues Matching*/
  output Boolean success;
protected
  Boolean zeroAssign; /*Gibt es Variable die noch nicht im Matching ist*/
  Integer variableIdx; /*Index der aktuellen Variabeln*/
  list<Integer> otherVariables; /*Liste mit Variabeln die fuer aktuellen Durchlauf unmarkiert sind*/
  array<Boolean> helpVariableMark;/*Zwischenspeicher fuer bereits markierte Variablen*/
  array<Integer> helpVariableAssign; /*Zwischenspeicher fuer Matching*/
algorithm
  /*initialisieren der Variabeln*/
  outVariableMark:=inVariableMark;
  outEquationMark:=inEquationMark;
  outVariableAssign:=inVariableAssign;
  outEquationMark[equationIdx]:=true;/*what should this do?????*/
  /*Aufruf Funktion, welche nach Variablen sucht die noch nicht im Matching fuer die aktuelle Gleichung
  enthalten sind. Gibt 'true' bei Erfolg zurueck. Ausserdem wird der entsprechende Variabeln Index zurueckgegeben.
  */
  (variableIdx,zeroAssign):=zeroVariableAssign(equationIdx,adjacency,outVariableAssign);
  if zeroAssign then
    success:=true;
    outVariableAssign[variableIdx]:=equationIdx; /*Fuege gefundenes Paar in Matching ein*/
    /*Alle moeglichen Variablen sind bereits im Matching eingebungen*/
  else
    success:=false;
    /*Suche alle Variablen 'otherVariables' von Gleichung 'equationIdx' mit vMark(equationIdx) = false*/
    otherVariables:=findOtherVariables(equationIdx,adjacency,outVariableMark);
    for j in otherVariables loop
      variableIdx:=j;
      outVariableMark[variableIdx]:=true;
      /*Pruefe von eq ausgehend, andere Moeglichkeiten fuer ein Matching und setze das Matching ggf. neu */
      (helpVariableMark,_,helpVariableAssign,success):=pathFound(outVariableAssign[variableIdx],sizeEquations,outVariableMark,outEquationMark,outVariableAssign,adjacency);
      if success then
        /*Wenn erfolgreich, dann wird das Matching aktualisiert und die aktuelle Gleichung erhaelt entsprechende Variabel*/
        outVariableMark:=helpVariableMark;
        outVariableMark:=helpVariableMark;
        outVariableAssign:=helpVariableAssign;
        outVariableAssign[variableIdx]:=equationIdx;
        break; /*Abbruch bei Erfolg*/
      end if;
    end for;
  end if;
end pathFound;

function zeroVariableAssign
  "Funktion sucht nach Variablen die fuer die aktuelle Gleichung noch nicht in Matching eingebaut wurden."
  input Integer eqnIdx; /*Aktueller Gleichungsindex*/
  input DAE.AdjacencyMatrix adjacency; /*Adjazenz Matrix*/
  input array<Integer> assign; /*Aktuelles Matching*/
  output Integer variableIndex; /*Index der noch ungematchen Variabel*/
  output Boolean success=false; /*Gibt true zurueck wenn es entsprechende Variable gibt*/
algorithm
  /*Durchlaufe Adjazenz Matrix um entsprechende Variabeln zu finden und pruefe ob diese schon gematcht sind*/
  for i in adjacency[eqnIdx] loop
    variableIndex:=i;
    if assign[variableIndex]==0 then
      success:=true;
      /*Bricht bei Erfolg ab*/
      break;
    end if;
  end for;
end zeroVariableAssign;

function findOtherVariables
  "Funktion sucht alle Variablen von Gleichung 'equationIdx' mit vMark(equationIdx) = false
  und speichert sie in Liste 'outListVariableIndex'."
  input Integer eqnIdx; /*Index aktuelle Gleichung*/
  input DAE.AdjacencyMatrix adjacency; /*Adjazenz Matrix*/
  input array<Boolean> vMark; /*Array mit bereits markierten Variablen*/
  output list<Integer> outListVariableIndex; /*Liste die Indizes der gefundenen Variablen enthält*/
protected
  Integer iterVar; /*Variable fuer Iteration*/
algorithm
  /*Initialisieren der Ausgabe Liste*/
  outListVariableIndex:={};
  /*Suche die entsprechenden Variablen die noch genutzt werden koennen*/
  for i in adjacency[eqnIdx] loop
    iterVar:=i;
    if not vMark[iterVar] then
      outListVariableIndex:=iterVar::outListVariableIndex;
    end if;
  end for;
end findOtherVariables;

function createEquationAssign
  "Funktion bildet aus dem Matching eq->var das 'transponierte' Matching var->eq."
  input array<Integer> vAssign; /*Matching der Form var->eq*/
  input Integer lenghtArray; /*Anzahl der Variablen*/
  output array<Integer> equationAssign; /*Matching der Form eq->var*/
protected
  Integer iterVar; /*Iteratonsvariabel*/
algorithm
  /*Initialisieren des Ausgabe Array's*/
equationAssign:=arrayCreate(lenghtArray,0);
  for i in 1:lenghtArray loop
    iterVar:=i;
  equationAssign[vAssign[iterVar]]:=iterVar; /*vAssign[iterVar]:Index von Gleichung von var_{iterVar}*/
  end for;
end createEquationAssign;

end Matching;
