ClearAll[expect]
ClearAll[totalRight]
ClearAll[totalWrong]
ClearAll[totalTests];
SetAttributes[ expect, HoldAllComplete ];
totalRight = totalWrong = totalTests = 0;
expect[expected_, actual_] := (* <~~~ Here's the API *)
   Module[{evalActualOnce = actual,
           evalExpectedOnce = expected},
      totalTests += 1;
      Print[ {"Test[" <> ToString[totalTests] <> "]:=\n",
              HoldForm[actual],
              "\nexpected", HoldForm[expected],
              "\neval'd expected", evalExpectedOnce,
              "\neval'd actual  ", evalActualOnce,
              "\nright?",   evalExpectedOnce === evalActualOnce} ];
      Print[ "" ]; (* newline *)
      If[ evalExpectedOnce === evalActualOnce,
          totalRight += 1,
          totalWrong += 1 ];
      {"total right", totalRight, "total wrong", totalWrong}];
ClearAll[eqv]
ClearAll[leibniz]
leibniz[ eqv[x_, y_], e_, z_ ] :=
        ((* Print[{"leibniz", "x", x, "y", y, "e", e,
                "conclusion", eqv[e /. {z -> x}, e /. {z -> y}]}]; *)
         eqv[e /. {z -> x}, e /. {z -> y}])
ClearAll[leibnizE]
leibnizE[ premise:eqv[ x_, y_ ], e_, z_ ] :=
        Module[{conclusion = leibniz[premise, e, z]},
               Print[{"leibnizE:","x", x, "y", y}];
               Print["  E(z)     : " <> ToString[e]];
               Print["  E[z := X]: " <> ToString[conclusion[[1]]]];
               Print["=   <X = Y>: " <> ToString[premise]];
               Print["  E[z := Y]: " <> ToString[conclusion[[2]]]];
               conclusion[[2]]]
ClearAll[transitivity]
transitivity[ and [ eqv[x_, y_], eqv[y_, z_] ] ] := eqv[x, z]
ClearAll[substitution]
substitution[e_, v_:List, f_:List] := e /. MapThread [ Rule, {v, f} ]
ClearAll[associativity]
associativity[eqv[ eqv[p_, q_], r_ ]] := eqv[ p, eqv[q, r] ]
associativity[eqv[ p_, eqv[q_, r_] ]] := eqv[ eqv[p, q], r ]
ClearAll[symmetryOfEqv]
symmetryOfEqv[eqv[p_, q_]] := eqv[q, p]
ClearAll[identity]
identity[eqv[q_, q_]] := eqv[true, eqv[q, q]]
ClearAll[fump]
SetAttributes[fump, HoldAllComplete]
fump[e_] := (
    Print[ToString[Unevaluated[e]] <> " ~~>\n" <> ToString[e]];
    e)
dump[annotation_, e_] := (
    Print[annotation <> " ~~> ", e];
    e)

expect[ eqv[eqv[p, q, q], p]
,
Module[{proposition = eqv[p, eqv[p, q, q]]}, (* the prop. I want to prove *)
  proposition                          // fump                  //
  symmetryOfEqv[#1]&                   // dump["symmetryOfEqv", #1]& //
  leibnizE[#1, eqv[p, z], z]&          //
  leibnizE[proposition, eqv[p, z], z]& //
  symmetryOfEqv[#1]&                   // dump["symmetryOfEqv", #1]&
]]
