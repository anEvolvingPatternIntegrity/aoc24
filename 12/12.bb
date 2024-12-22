#! /usr/bin/env bb

(ns aoc-2024-12-12
  (:require [clojure.string :as str]
            [clojure.set :a set]))

(defn load-grid [filename]
  (->> filename
       slurp
       str/split-lines
       (map #(vec (str/split % #"")))
       vec))

(def grid (load-grid "example.1"))


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

(defn ->region [grid pos vs]
  (loop [to-check #{pos}
         region #{pos}
         visited (clojure.set/union vs #{pos})
         cnt 0]
    (let [val (get-in grid pos)
          neighbors (set (remove visited (mapcat #(neighbors-w-val grid % val) to-check)))]
      (println "Val: " val " Neighbors:" neighbors " Region: " region " Visited: " visited " cnt: " cnt)
      (if (or (> cnt 10) (empty? neighbors))
        {:region region
         ;:entry pos
         :visited visited}
        (recur neighbors (clojure.set/union region neighbors) (clojure.set/union visited neighbors) (inc cnt))))))

(defn add-region [grid]
  (fn [m pos]
    (let [{:keys [region visited]} (->region grid pos (:visited m))

          ]
      (if (pos? (count region))
        (-> m
            (assoc-in [regions pos] region)
            (update :visited clojure.set/union visited))
        m))))

(defn regions [grid]
  (let [cells (for [row (range (count grid)) col (range (count (get grid 0)))] [row col])
        regions (reduce (add-region grid) {} cells)
        ]
    (println regions)
    )
  )
