# clojure-notes
My notes on how to use clojure
## Useful Links
[Good overview of everything](https://www.braveclojure.com/do-things/)

## Maps

### Retrieving a value from a map
```clojure
(def m {:first "John" :last "Pyeatt :age 54})
(:last m)
=> "Pyeatt"
```
### Merging the contents of two maps together
```clojure
(merge {:firstname "John" :lastname "Pyeatt" :age 54} {:lastname "Smith" :height 74})

=> {:firstname "John", :lastname "Smith", :age 54, :height 74}
```
### Adding values to a map
```clojure
(assoc {:first "John" :last "Smith"} :last "Pyeatt" :age 54 )
=> {:first "John", :last "Pyeatt", :age 54}
```
### Removing values from a map
```clojure
(dissoc {:first "John" :last "Pyeatt" :age 54} :middle :last)
=> {:first "John", :age 54}
```
### Modifying a value in a map with a function
```clojure
(update {:first "John" :age 54} :age inc)
=> {:first "John", :age 55}
```
### Returning a subset of map values
```clojure
(select-keys {:male true :age 24 :name "Steve"} [:male :age])
=> {:male true, :age 24}
```
## Sets

### Does a value exist in a set
```clojure
(contains? #{"john" :male 54 :tall} :male)
=> true
```


## Sequential Data
For sequential data you have lists and vectors.

### map function
The map function applies a function to every value in a collection. Returns a lazy sequence.
```clojure
(defn divide-by-2
  [n]
  (/ n 2))

(map divide-by-2 [8 12 16])
=> (4 6 8)
```
#### Extract a particular map key value from a collection of maps
```clojure
(map :first [{:first "John" :last "Pyeatt"} {:first "Betsey" :last "Davis"}])
=> ("John" "Betsey")```
```
### reduce function
Applies a function to a sequence of values and reduces those values to one value based on the function.
```clojure
(reduce + 0 [4 5 7 9])
=> 25
```

### removing values from a sequence with filter
```clojure
(defn greater-than-10
  [v]
  (< 10 v))

(filter greater-than-10 [4 10 23 43 2])
=> (23 43)
```
or
```clojure
(filter (fn [v] (< 10 v)) [4 10 23 43 2])
=> (23 43)
```
### removing values from a sequence of maps by value with filter
Use this option when you need to vary the filtering value (i.e. you need to define
a function that takes 2 args, then reference it in your (partial) call.
```clojure
(defn find-by-id? [id m]
  (= (:id m) id))
(let [m-list [{:id 1 :name "One"} {:id 2 :name "two"} {:id 3 :name "three"}]]

  (->> m-list (filter (partial find-by-id? 2))))
  
=> => ({:id 2, :name "two"})
```

Here's a more complicated example. This is list of maps. Inside each map is a :kids list with a map 
of the kids names and ages. The code below extracts a list of a each family which has at least 1 kid
under 19.
```clojure
(let [m [{:family "pyeatt" 
          :kids [{:name "SAM" :age 20 :pets ["cat"]}
                 {:name "Gwen" :age 18 :pets ["rabbit" "fish"]}]}
         {:family "gerlach"
          :kids [{:name "Gina" :age 32} {:name "Billy" :age 27 :pets ["cat"]}]}
         {:family "kerkman" 
          :kids [{:name "emma" :age 14 :pets ["dog"]}]}]]
  (->> m 
       (filter (fn [{:keys [kids]}]
                 (some #(> 19 (:age %)) kids)))))
                 
;; returns
({:family "pyeatt", :kids [{:name "SAM", :age 20, :pets ["cat"]} {:name "Gwen", :age 18, :pets ["rabbit" "fish"]}]}
 {:family "kerkman", :kids [{:name "emma", :age 14, :pets ["dog"]}]})
```
Now with the same original value `m` nest one more deep and get the list of families who have cats.

```clojure
  (->> m 
       (filter (fn [{:keys [kids]}]
                 (some #(some (fn [x]
                                (= x "cat" )) (:pets %)) kids)))))
```
returns
```
({:family "pyeatt", :kids [{:name "SAM", :age 20, :pets ["cat"]} {:name "Gwen", :age 18, :pets ["rabbit" "fish"]}]}
 {:family "gerlach", :kids [{:name "Gina", :age 32} {:name "Billy", :age 27, :pets ["cat"]}]})
```

### Lists
Lists are implemented as linked lists. For this reason it is easiest to add new elements to the beginning
of the list. When you use `conj` it will add new elements to the front of a list.

#### flatten a list
```clojure
(let [big-list [{:name "john" :age 55}
                {:name "Betsey" :age 53}
                [{:name "Sam" :age 20} {:name "Gwen" :age 18}]]]
  (flatten big-list ))
```
Results in this
```clojure
({:name "john", :age 55} {:name "Betsey", :age 53} {:name "Sam", :age 20} {:name "Gwen", :age 18})
```
#### intersection of two lists
```clojure
(let [a [1 3 5 7 9]
      c [3 7 8]]
  (filter (set a) c))
=> (3 7)
```

### Vectors
Vectors are like arrays. You use them when you want to add to the end of a vector, again using `conj`. Or when you need
to get the nth element.
```clojure
(get [4 5 6 7] 2)
=> 6
```

#### group-by
```clojure
(let [src [["aa:aa:bb:aa:aa:00" "Room 100"]
           ["aa:aa:bb:aa:aa:01" "Room 101"]
           ["aa:aa:bb:aa:aa:02" "Room 102"]
           ["aa:aa:bb:aa:aa:03" "Room 103"]
           ["aa:aa:bb:aa:aa:04" "Room 104"]
           ["aa:aa:bb:aa:aa:05" "Room 102"]
           ["aa:aa:bb:aa:aa:01" "Room 106"]]]
  (group-by first src))
```
results in
```clojure
{"aa:aa:bb:aa:aa:00" [["aa:aa:bb:aa:aa:00" "Room 100"]],
 "aa:aa:bb:aa:aa:01" [["aa:aa:bb:aa:aa:01" "Room 101"] ["aa:aa:bb:aa:aa:01" "Room 106"]],
 "aa:aa:bb:aa:aa:02" [["aa:aa:bb:aa:aa:02" "Room 102"]],
 "aa:aa:bb:aa:aa:03" [["aa:aa:bb:aa:aa:03" "Room 103"]],
 "aa:aa:bb:aa:aa:04" [["aa:aa:bb:aa:aa:04" "Room 104"]],
 "aa:aa:bb:aa:aa:05" [["aa:aa:bb:aa:aa:05" "Room 102"]]}

```
### Lists of Maps
#### Conditionally accumumulating data from a list of maps into a list
Sometimes you have a list of maps and you want to conditionlly extract maps from the list which have
certain criteria. For example let's say I have this list of maps:
```clojure
[{:name "Fred" :id 2} {:name "Steve" :id 12} {:name "Bill" :id 43}]
```
And I want to get the values for :name whose id is greater than 10
```clojure
(remove nil? (for [d dat]
    (when (< 10 (:id d)) (:name d))))
```
result
```clojure
("Steve" "Bill")
```
#### mapcat
Let's say you have a list of maps and you want to return a subset of the list based on some criteria and
modify the list on output. The combination of (remove) (mapcat) and (for) may be an answer.

```clojure
(let [src [{:first "John" :last "Pyeatt" :hobbies ["golf", "running"]}
           {:first "Betsey" :last "Davis" :hobbies ["sewing" "biking" "golf"]}
           {:first "Sam" :last "Pyeatt" :hobbies ["snowboarding" "swimming"]}]]
      (remove nil?
              (mapcat (fn [person]
                        (for [hobby (:hobbies person)]
                          (when (= "golf" hobby)
                            {:name (str (:first person) (:last person)) :sport "golf"}))) src)))
```
So working from the inside out.
1. the (when) checks to see if the person likes golf. If so it creates the output map with :name and :sport as the keywords
1. the (for) loop checks all of the hobbies
1. The (fn) defines a function that, given a person map either returns nil or the map with :name and :sport
1. The (mapcat) calls the (fn) function for each of the elements of src.
1. The (remove) calls nil? and removes an elements returned by (fn) which are nil

The result from the above call would be
```clojure
({:name "JohnPyeatt", :sport "golf"} {:name "BetseyDavis", :sport "golf"})
```

### Queues
LIFO implementation.
```clojure
(def new-orders clojure.lang.PersistentQueue/EMPTY)
(defn add-order [orders order]
   (conj orders order))
(defn cook-order [orders]
   (cook (peek orders))
   (pop orders))
```

### Misc functions

#### concat - concatonates multiple collections and returns a new lazy sequence
```clojure
(concat [4 5 6] [9 8 7])
=> (4 5 6 9 8 7)
```
#### first - returns the first element of a list or vector
```clojure
(first [4 5 6])
=> 4
```
#### rest - returns all but the first element of a list or vector
Even if you specify a vector for input, the result will be a list.
```clojure
(rest [4 5 6])
=> (5 6)
```
