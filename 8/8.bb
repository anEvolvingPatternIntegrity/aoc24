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

;; TODO antinodes for pt 1: just return the list with no % mult
(defn antinodes [times [rowa cola] [rowb colb]]
  (let [rowdiffa (- rowa rowb)
        coldiffa (- cola colb)
        rowdiffb (- rowb rowa)
        coldiffb (- colb cola)]
    (mapcat #(list [(+ rowa (* % rowdiffa)) (+ cola (* % coldiffa))]
                [(+ rowb (* % rowdiffb)) (+ colb (* % coldiffb))]) (range (inc times)))))

(defn in-bounds? [maxrow maxcol]
  (fn [ [row col] ]
    (and (>= row 0) (<= row maxrow)
         (>= col 0) (<= col maxcol))))

(defn mkindex [grid]
  (let [maxrow (dec (count grid))
        maxcol (dec (count (get grid 0)))
        cells (for [row (range maxrow) col (range maxcol)] [row col])]
    (reduce (add-to-grid-index grid) {} cells)))

(defn ->antinodes [index maxrow maxcol]
  (fn [m k]
    (let [ib? (in-bounds? maxrow maxcol)
          pairs (combo/combinations (get index k) 2)
          antinodes (mapcat #(apply antinodes (* 10 (max maxrow maxcol)) %) pairs)]
      (assoc m k (filter ib? antinodes)))))

(defn grid-and-antinodes [filename]
  (let [grid (load-grid filename)
        rows (count grid)
        cols (count (get grid 0))
        cells (for [row (range rows) col (range cols)] [row col])
        index (reduce (add-to-grid-index grid) {} cells)
        as-by-v (reduce (->antinodes index (dec rows) (dec cols)) {} (keys index))
]
    {:rows rows :cols cols :cells cells :index index :grid grid
     :antinodes as-by-v}
    ))

(defn uniq-antinode-count [filename]
  (let [{:keys [grid antinodes]} (grid-and-antinodes filename)]
    (count (set (mapcat conj (vals antinodes))))))

(defn solve [filename]
  (let [grid (load-grid filename)
        maxrow (dec (count grid))
        maxcol (dec (count (get grid 0)))
        cells (for [row (range maxrow) col (range maxcol)] [row col])
        index (reduce (add-to-grid-index grid) {} cells)
        pairs (mapcat #(combo/combinations % 2) (vals index))
        ans  (mapcat #(apply antinodes %) pairs)
        ans' (set (filter (in-bounds? maxrow maxcol) ans))]
    (println {:maxrow maxrow :maxcol maxcol})
    (println pairs)
    (println ans)
    (println ans')
    (count ans')))


;;(println "[Test] Part 1" (solve "input.test"))
;;(println "[Test2] Part 1" (solve "input.test.2"))
(defn write-json [infile n]
  (let [g-n-as (grid-and-antinodes infile)]
    (spit (str infile (if n (str "." n) "") ".json") (json/encode g-n-as)))
  )

;;(write-json "input.test" 2)
;;(write-json "input.test.2" 2)
;;(write-json "input" 2)

;;(println "[Test] Part 2" (solve "input.test" [+ * cat]))
;;(println "Part 1" (solve "input"))
;;(println "Part 2" (solve "input" [+ * cat]))
