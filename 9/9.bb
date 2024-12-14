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

(defn reversed-non-empty [blocks]
  (filter #(not= % ".") (reverse blocks)))

(defn compact [blocks]
  (let [reversed (reversed-non-empty blocks)]
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
;
(def rnebs (reversed-non-empty (->blocks (input "input.test"))))
(println rnebs)
(def rnebs-pbi (partition-by identity rnebs))
(def compblockstr (str/join (->blocks (input "input.test"))))

(defn swap-blocks [all-blocks-str block]
  (let [block-size (count block)
        block-str (str/join block)
        dot-str (str/join (take block-size (repeat ".")))
        match-regex (re-pattern (str "[\\.]{" block-size "}.*" block-str))
        block-replace-regex (re-pattern block-str)
        dot-replace-regex (re-pattern (str/join (take block-size (repeat "\\."))))
        ]
    (println {:bs block-size :block block-str :mr match-regex :brr block-replace-regex
              :drr dot-replace-regex})
    (if (re-find match-regex all-blocks-str)
      (-> all-blocks-str
          (str/replace-first block-replace-regex dot-str)
          (str/replace-first dot-replace-regex block-str)
          )
      all-blocks-str
      )
    )
  )

(-> compblockstr (swap-blocks '(9 9)) (swap-blocks '(8 8 8 8)) (swap-blocks '(7 7 7)))
