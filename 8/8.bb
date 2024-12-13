#! /usr/bin/env bb

(ns aoc-2024-12-8
  (:require [clojure.string :as str]
            [clojure.math.combinatorics :as combo]
            [cheshire.core :as json]))

(defn load-grid [filename]
  (->> filename
       slurp
       str/split-lines
       (map #(str/split % #""))
       vec))

(defn add-to-grid-index [grid]
  (fn [idx pos]
    (let [value (get-in grid pos)]
      (if (not= value ".")
        (assoc idx value ((fnil conj #{}) (get idx value) pos))
        idx))))

(defn in-bounds? [maxrow maxcol]
  (fn [ [row col] ]
    (and (>= row 0) (<= row maxrow)
         (>= col 0) (<= col maxcol))))

(defn antinodes-for-pair [mults [rowa cola] [rowb colb]]
  (mapcat #(list [(+ rowa (* % (- rowa rowb))) (+ cola (* % (- cola colb)))]
                 [(+ rowb (* % (- rowb rowa))) (+ colb (* % (- colb cola)))])
          mults))

(defn ->antinodes [part index maxrow maxcol]
  (fn [m k]
    (let [ib? (in-bounds? maxrow maxcol)
          pairs (combo/combinations (get index k) 2)
          antinode-mults ({:part1 (range 1 2)
                           :part2 (range (inc (max maxrow maxcol))) } part)
          antinodes (mapcat #(apply antinodes-for-pair antinode-mults %) pairs)]
      (assoc m k (filter ib? antinodes)))))

(defn grid-and-antinodes [part filename]
  (let [grid (load-grid filename)
        rows (count grid)
        cols (count (get grid 0))
        cells (for [row (range rows) col (range cols)] [row col])
        index (reduce (add-to-grid-index grid) {} cells)
        as-by-v (reduce (->antinodes part index (dec rows) (dec cols))
                        {} (keys index))]
    {:antinodes as-by-v
     :rows rows :cols cols
     :cells cells :index index :grid grid}))

(defn uniq-antinode-count [part filename]
  (let [{:keys [antinodes]} (grid-and-antinodes part filename)]
    (count (set (mapcat conj (vals antinodes))))))

(println "\n[TEST] Part 1" (uniq-antinode-count :part1 "input.test"))
(println "[TEST] Part 2" (uniq-antinode-count :part2 "input.test"))
(println "Part 1" (uniq-antinode-count :part1 "input"))
(println "Part 2" (uniq-antinode-count :part2 "input"))

;;(defn write-json [infile n]
;;  (let [g-n-as (grid-and-antinodes infile)]
;;    (spit (str infile (if n (str "." n) "") ".json") (json/encode g-n-as))))

;;(println "[Test] Part 1" (solve "input.test"))
;;(println "[Test2] Part 1" (solve "input.test.2"))
