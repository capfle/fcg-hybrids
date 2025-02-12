;; Copyright Sony Computer Science Laboratories Paris
;; Authors: Remi van Trijp (http://www.remivantrijp.eu)
;;          Martina Galletti martina.galletti@sony.com
;;          Ines Blin ines.blin@sony.com

;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at

;;     http://www.apache.org/licenses/LICENSE-2.0

;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
;;=========================================================================

(in-package :fcg)

(defvar *italian-fcg-categories* nil "FCG-categories for Italian grammars.")

(setf *italian-fcg-categories*
      '(;; Nominal:
        (noun ()
              (referent ?ref)
              (agreement ((person ?person)
                          (gender ?gender)
                          (number ?number)))
              (syn-cat ((lex-class noun)
                        (definite ?def))))
        (proper-noun (noun)
                     (syn-cat ((lex-class proper-noun)
                               (definite +))))))
