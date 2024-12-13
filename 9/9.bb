#! /usr/bin/env bb

(ns aoc-2024-12-9
  (:require [clojure.string :as str]))

(defn input [filename]
  (map read-string (str/split (str/trim (slurp filename)) #"")))

(defn ->blocks [input]
  (let [->block (fn [[index size]]
                  (if (even? index)
                    (take size (repeat (/ index 2)))
                    (take size (repeat "."))))
        indexed (map-indexed vector input)]
    (mapcat ->block indexed)))

(defn compact [blocks]
  (let [reversed (filter #(not= % ".") (reverse blocks))]
    (loop [bs blocks
           rs reversed
           acc []
           cnt 0]
      (let [c (first bs)
            r (first rs)]
        ;(println cnt {:bs bs :rs rs :acc acc :c c :r r})
        (if (or (nil? r) (nil? c))
          acc
          (if (= c ".")
            (recur (rest bs) (rest rs) (conj acc r) (inc cnt))
            (recur (rest bs) (butlast rs) (conj acc c) (inc cnt))))))))

(defn checksum [filename]
  (->> (input filename)
       ->blocks
       compact
       (map-indexed vector)
       (map #(apply * %))
       (reduce +)))

;(println "part 1 test checksum: " (checksum "input.test"))
;(println "part 1 checksum: " (checksum "input"))
