#! /usr/bin/env bb

(ns aoc-2024-12-10
  (:require [clojure.string :as str]))

(defn load-grid [filename]
  (->> filename
       slurp
       str/split-lines
       (map #(vec (map read-string (str/split % #""))))
       vec))

(defn ->neighbors [[row col]]
  (list [row (dec col)] [row (inc col)]
        [(inc row) col] [(dec row) col]))

(defn matches? [g n]
  (fn [pos]
    (let [got (get-in g pos)]
      (= n got))))

(defn neighbors-w-val [g pos n]
  (let [neighbors (->neighbors pos)]
    (filter (matches? g n) neighbors)))

(defn reachable-from [g pos]
  (loop [ps #{pos}
         n 1
         acc {}]
    (let [neighbors (set (mapcat #(neighbors-w-val g % n) ps))]
      (if (empty? neighbors)
        acc
        (recur neighbors (inc n) (assoc acc n neighbors))))))

(defn score-trailhead [g]
  (fn [pos]
    (count (get (reachable-from g pos) 9))))

(defn sum-scores [filename]
  (let [grid (load-grid filename)
        rows (count grid)
        cols (count (get grid 0))
        cells (for [row (range rows) col (range cols)] [row col])
        trailheads (filter #(zero? (get-in grid %)) cells)
        scorer (score-trailhead grid)]
    (reduce + (map scorer trailheads))))

(sum-scores "input")
