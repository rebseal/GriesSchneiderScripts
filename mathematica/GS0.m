(* ****************************************************************************

   MISSION STATEMENT

   The mission of mathDragon is two-fold (1) transcribe Gries & Schneider,
   teaching simple logic as a foundation for not just discrete mathematics, but
   all mathematics, plus teaching conditional term-rewriting and to beginners
   along the way, (2) recapitulate TLA, the Temporal Logic of Actions, in a
   programming environment as much like Mathematica as we can make it, but
   open-sourced for flexibility, extensibility, and innovation. TLA, we believe,
   is a critical resource for high-assurance designs, especially in the emerging
   disciplines of robotics and AI.

   The distinguishing feature of Mathematica from other proof assistants,
   theorem provers, and implementations of TLA is that it is also a
   general-purpose symbolic and numerical programming language, and a very good
   one. We want to expose a programming language in the style of Mathematica as
   a text-to-text library that can be embedded in any kind of programming tool
   or environment, even just a raw terminal, but certainly including emacs; IDEs
   like Eclipse, IntelliJ, and Visual Studio Code; cloud apps; and web apps. No
   other proof assistant, theorem prover, or implementation of TLA to our
   knowledge embodies the combination of (1) full integration with
   general-purpose programming, (2) open source, and (3) basis on a text-to-text
   core library.
     __  __      _   _                   _   _
    |  \/  |__ _| |_| |_  ___ _ __  __ _| |_(_)__ __ _
    | |\/| / _` |  _| ' \/ -_) '  \/ _` |  _| / _/ _` |
    |_|  |_\__,_|\__|_||_\___|_|_|_\__,_|\__|_\__\__,_|
    __   __          _
    \ \ / /__ _ _ __(_)___ _ _
     \ V / -_) '_(_-< / _ \ ' \
      \_/\___|_| /__/_\___/_||_|

   This file is a baseline for comparing other versions tailored for mathics and
   for SymJa. It is a backport from mathics to Mathematica. Almost all the rest
   of the commentary in here is specific to mathics because that's where I
   started. Diff this file with the mathics version to see the changes we needed
   to make.

   DIFFERENCES AMONGST MATHEMATICA, MATHICS, AND SYMJA

   Why are there differences between Mathematica and its clones, mathics and
   SymJa? One reason is that Mathematica has subtle behaviors that are difficult
   to emulate exactly. Some of those behaviors are probably accidental, rather
   than by design, but it's difficult to be sure because Mathematica is at least
   35 years old and the original history of features and fixes may be lost. One
   of my recent stackexchange question exposed an "open question" in the pattern
   matcher, according to a Wolfram insider. That means no one knows off the
   top-of-the-head exactly how it works for my edge cases. I also learned that
   there have been bugs in versions of Mathematica as late as 10.1 concerning
   the pattern-matching edge cases I mentioned. I have been using Mathematica
   every day for 35 years, and I am still learning things about the pattern
   matcher. I certainly did while pursuing differences amongst Mathematica,
   mathics, and SymJa. Either I'm just thick, or the pattern-matcher is subtle,
   or both. Evidence for subtlety is that "open questions" and bugs persist this
   far into the game.

   However, that is not a criticism of Mathematica nor its pattern matcher! It
   is is clearly one of the most advanced programming tools in the world.
   Subjectively, it is gloriously expressive and joyfully fun to use. The fact
   that it continues to teach me things could equally be counted as "richness,"
   "power," and "depth" as "subtlety."

   DIFFERENCE 1 --- REDEFINE SYMBOLS AFTER SETTING ATTRIBUTES

   In Mathematica, but not in mathics, to get the behaviors we want, we must
   repeat all definitions that refer to a symbol like "eqv" after changing the
   attributes. The order of (1) setting attributes on symbols and (2) making
   definitions about those symbols matters. That fact is a deep subtlety of
   Mathematica. Some users have exploited it in their applications, and there is
   a history of breaking changes and bugs in the pattern matcher around this
   effect.

   See the following for more

   https://mathematica.stackexchange.com/questions/71463/orderless-pattern-matching

   DIFFERENCE 2 --- MULTIPLE ALLOWED REWRITES

   Many replacement rules have multiple correct answers when applied to symbols
   with Flat, OneIdentity, and Orderless attributes. Mathematica and mathics
   sometimes differ in the default answer that "ReplaceAll" gives. To get all
   the correct answers, use "ReplaceList." To get the desired answer, pick it
   out of the resulting list using [[part]] notation. For example:

     In Mathematica, the preferred rewrite for not[eqv[q,p]]/.notRule is
     eqv[not[eqv[q]],p]]] because Mathematica rewrites

     eqv[p,q]/.{eqv[p_,q_]:>{p,q}} ~~> {eqv[p],eqv[q]}.

     There is at least one more, allowed rewrite, however, revealed by

     ReplaceList[eqv[p,q], {eqv[p_,q_] :> {p,q}}] ~~> {{eqv[p],eqv[q]}, {p,q}}

   ****************************************************************************
    __  __      _   _    _        __   __          _
   |  \/  |__ _| |_| |_ (_)__ ___ \ \ / /__ _ _ __(_)___ _ _
   | |\/| / _` |  _| ' \| / _(_-<  \ V / -_) '_(_-< / _ \ ' \
   |_|  |_\__,_|\__|_||_|_\__/__/   \_/\___|_| /__/_\___/_||_|

    Please see

    https://github.com/rebcabin/Mathics/blob/master/mathics/packages/

    for the most up-to-date version. Changes will be committed there from now
    on.

    When mathics itself is updated, you must reinstall it:

        python setup.py install

    You can run unit tests as follows:

        python setup.py test

   ****************************************************************************

    ___              _       __   __          _
   / __|_  _ _ __ _ | |__ _  \ \ / /__ _ _ __(_)___ _ _
   \__ \ || | '  \ || / _` |  \ V / -_) '_(_-< / _ \ ' \
   |___/\_, |_|_|_\__/\__,_|   \_/\___|_| /__/_\___/_||_|
        |__/

   TODO

   ****************************************************************************
     ___     _          __       ___     _             _    _
    / __|_ _(_)___ ___ / _|___  / __| __| |_  _ _  ___(_)__| |___ _ _
   | (_ | '_| / -_|_-< > _|_ _| \__ \/ _| ' \| ' \/ -_) / _` / -_) '_|
    \___|_| |_\___/__/ \_____|  |___/\__|_||_|_||_\___|_\__,_\___|_|


    This is an extended transcription of Gries & Schnedier, "A Logical Approach
    to Discrete Math," into mathics (https://goo.gl/wSm1wt), a free clone of
    Mathematica (https://goo.gl/0uvLZ), written in Python. I got mathics to run
    on Python 3.5 and not on Python 3.6.

    @Book{gries1993a,
     author = {Gries, David},
     title = {A Logical Approach to Discrete Math},
     publisher = {Springer New York},
     year = {1993},
     address = {New York, NY},
     isbn = {978-1-4757-3837-7}}

    Why are we doing this? Gries & Schnedier is a great example of a formal
    method. Formal methods means "machine-checked proofs." Formal Methods help
    you write better software. They can help you avoid billion-dollar mistakes,
    like crashing the Mars Climate Observer because the units of measure
    "newton" and "pound-force" were not checked by machine. Like losing customer
    data in a cloud database because of an unanticipated edge-case thirty-five
    steps into a leader-election protocol.

    Fall in love with formal methods, please! They're related to static
    type-checking (that's a little formal method in your compiler, proving
    little theorems about types in your code), and great things like
    Clojure.spec (https://goo.gl/sttnFC). I think a lot of people know those are
    good, but there are lots of other, lesser-known formal methods like
    Statecharts (https://statecharts.github.io/) and TLA+
    (https://goo.gl/dx32Mw). Statecharts allowed me to formally prove that an
    embedded controller for a robot had no bugs. TLA+ saved Amazon's Dynamo DB a
    catastrophic failure (https://goo.gl/pTpZYT). Many mistakes have been found
    in published algorithms and protocols at the foundational layer of the
    internet and cloud computing when those protocols were subjected to formal
    methods (no citation).

 *************************************************************************** *)

ClearAll[expect, totalRight, totalWrong, totalTests];
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
      {"total right", totalRight, "total wrong", totalWrong}
      ];
