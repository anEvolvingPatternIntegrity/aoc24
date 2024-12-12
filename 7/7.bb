#! /usr/bin/env bb

(ns aoc-2024-12-7
  (:require [clojure.string :as str]
            [clojure.math :as math]
            [clojure.math.combinatorics :as combo]))

(defn load-tests [filename]
  (->> filename
       slurp
       str/split-lines
       (map #(str/split % #":\s+"))
       (map #(vec [(read-string (first %))
                   (map read-string (str/split (second %) #"\s"))]))))

(defn cat [b a]
  (->> (math/log10 b) math/floor inc (math/pow 10) int (* a) (+ b)))

(defn value-for-ops-on-nums [ops nums]
  (let [partials (apply map partial [ops (rest nums)])]
    (reduce #(%2 %1) (first nums) partials)))

(defn possible-result-values [ops nums]
  (let [possible-op-combos (combo/selections ops (dec (count nums)))]
    (map value-for-ops-on-nums
         possible-op-combos
         (take (count possible-op-combos) (repeat nums)))))

(defn num-if-match [ops]
  (fn [test]
    (let [[target values] test
          poss (set (possible-result-values ops values))]
      (if (poss target) target 0))))

(defn solve [filename ops]
  (let [tests (load-tests filename)]
    (reduce + (map (num-if-match ops) tests))))

;;(println "[Test] Part 1" (solve "input.test" [+ *]))
;;(println "[Test] Part 2" (solve "input.test" [+ * cat]))
(println "Part 1" (solve "input" [+ *]))
(println "Part 2" (solve "input" [+ * cat]))
