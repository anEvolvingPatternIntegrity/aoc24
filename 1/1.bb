#! /usr/bin/env bb

(ns aoc-2024-12-1
  (:require [clojure.string :as str]))

(let [lines       (str/split-lines (slurp "./input"))
      line->nums  #(map read-string (str/split % #"\s+"))
      rows        (map line->nums lines)
      [col1 col2] (apply map vector rows)
      freqs       (frequencies col2)]
  (println (reduce + (map #(abs (- %1 %2)) (sort col1) (sort col2))))
  (println (reduce + (map #(* % (get freqs % 0)) col1))))
