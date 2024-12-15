#! /usr/bin/env bb

(ns aoc-2024-12-10
  (:require [clojure.string :as str]))

(defn load-grid [filename]
  (->> filename
       slurp
       str/split-lines
       (map #(vec (map read-string (str/split % #""))))
       vec))

(def g (load-grid "example.4"))

(defn ->neighbors [[row col]]
  (list [row (dec col)] [row (inc col)]
        [(inc row) col] [(dec row) col]))

(defn matches? [g n]
  (fn [pos]
    (let [got (get-in g pos)]
      (= n got))))

(defn neighbors-w-val [g pos n]
  (println "nwv " pos n)
  (let [neighbors (->neighbors pos)]
    (filter (matches? g n) neighbors)))

(defn reachable-from [g pos-set num]
  (loop [ps pos-set
         n num
         acc {}
         cnt 0]
    (println "acc " acc)
    (if (> cnt 100)
      acc
      (let [neighbors (set (mapcat #(neighbors-w-val g % n) ps))]
        (if neighbors
          (recur neighbors (inc num) (assoc acc n neighbors) (inc cnt))
          acc
          )
        )
      )

    ))
