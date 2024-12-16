#! /usr/bin/env bb

(ns aoc-2024-12-11
  (:require [clojure.string :as str]
            [clojure.math :as math]))

(defn even-digits? [n]
  (->> n math/log10 int odd?))

(defn to-int [s]
  (int (parse-long s)))

(defn cleave [n]
  (let [s (str n)
        pivot (/ (count s) 2)
        parts (map str/join (split-at pivot s))]
    ;(println "s " s "pivot " pivot "parts " parts)
    (map to-int parts)))

(defn num-> [n]
  (cond
    (zero? n) 1
    (even-digits? n) (cleave n)
    :else (* 2024 n)))

(defn blink [ns]
  (flatten (map num-> ns)))

(defn do-blinks [ns times]
  (loop [ns ns
         n 0]
    (if (>= n times)
      ns
      (recur (blink ns) (inc n)))))

(defn num-after-blinks [ns times]
  (count (do-blinks ns times)))

(defn solve [filename times]
  (let [ns (map read-string (str/split (slurp filename) #"\s"))]
    (num-after-blinks ns times)))

(solve "input" 75)
