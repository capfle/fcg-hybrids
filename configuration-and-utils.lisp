;; Copyright 2019-present
;;           Sony Computer Science Laboratories Paris
;;           Remi van Trijp (http://www.remivantrijp.eu)

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

(in-package :nlp-tools)

(setf *penelope-host* "http://spacy.fcg-net.org/")

;; The FCG-hybrids uses functions from the NLP-tools package as much as possible.
;; For English, however, a combination of SpaCy and the Berkeley Neural Parser
;; is used, so we can ask for both a dependency- and constituent analysis.

(defun run-english-parser (sentence &key (model "en"))
  "Call the penelope server to get the dependency labels all words in a sentence."
  (unless (stringp sentence)
    (error "The function <run-english-parser> expects a string as input"))
  (send-request "/beng"
                (encode-json-to-string `((:sentence . ,(remove-multiple-spaces sentence))
                                         (:model . ,model)))))

(defun convert-ica-string-to-ica-list (string)
  "Converts a string representing a constituent analysis into a list representation."
  (loop for pair in '((":" "\\:")
                      ("." "\\.")
                      ("," "\\,")
                      ("''" "PARENTH")
                      ("``" "PARENTH")
                      ("\"" "PARENTH"))
        do (setf string (string-replace string (first pair) (second pair))))
  (read-from-string string))

(export '(get-english-sentence-analysis))

(defun get-english-sentence-analysis (sentence &key (model "en")) ;; To do: allow sentence ID.
  "Get a dependency and immediate constituent analysis for an English sentence."
  (let* ((analysis (run-english-parser (format nil "~a" sentence) :model model))
         (dependency-tree (rest (assoc :tree (first (rest (assoc :beng analysis))))))
         (constituent-tree (convert-ica-string-to-ica-list (second (assoc :ica (second (first analysis)))))))
    (values dependency-tree constituent-tree)))

(in-package :fcg)

;;; Helper functions.
;;; -------------------------------------------------------------------------------------
(defun calculate-boundaries-and-form-constraints (base-transient-structure
                                                  unit-tree
                                                  &optional (cxn-inventory *fcg-constructions*))
  "Update the boundaries feature of the ROOT unit of a transient structure, and adds form constraints to the ROOT."
  (let* ((strings (fcg-extract-selected-form-constraints base-transient-structure '(string)))
         ;; Remi 26/04/2021
         ;; Temporary cip-node is necessary to be able to reuse the normal fcg processing functions.
         ;; Would be better to rewrite the update-list-of-boundaries function.
         (temp-node (make-instance 'cip-node
                                   :construction-inventory cxn-inventory
                                   :car (make-cxn-application-result
                                         :resulting-cfs 
                                         (make-instance 'coupled-feature-structure
                                                        :left-pole (append
                                                                    (left-pole-structure
                                                                     base-transient-structure)
                                                                    unit-tree)))))
         (old-boundaries (fcg-get-boundaries base-transient-structure))
         (new-boundaries (update-list-of-boundaries old-boundaries temp-node))
         (new-form-constraints (infer-all-constraints-from-boundaries
                                new-boundaries
                                (get-updating-references cxn-inventory)
                                (fcg-get-transient-unit-structure temp-node))))
    `(root
      (boundaries ,new-boundaries)
      (form ,(append strings new-form-constraints)))))
