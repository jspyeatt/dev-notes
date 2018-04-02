# clojure-notes
My notes on how to use clojure

## Maps

### Retrieving a value from a map
```
(def m {:first "John" :last "Pyeatt :age 54})
(:last m)
=> "Pyeatt"
```
### Merging the contents of two maps together
```
(merge {:firstname "John" :lastname "Pyeatt" :age 54} {:lastname "Smith" :height 74})

=> {:firstname "John", :lastname "Smith", :age 54, :height 74}
```
### Adding values to a map
```
(assoc {:first "John" :last "Smith"} :last "Pyeatt" :age 54 )
=> {:first "John", :last "Pyeatt", :age 54}
```
### Removing values from a map
```
(dissoc {:first "John" :last "Pyeatt" :age 54} :middle :last)
=> {:first "John", :age 54}
```
### Modifying a value in a map with a function
```
(update {:first "John" :age 54} :age inc)
=> {:first "John", :age 55}
```
### Returning a subset of map values
```
(select-keys {:male true :age 24 :name "Steve"} [:male :age])
=> {:male true, :age 24}
```
## Sets

### Does a value exist in a set
```
(contains? #{"john" :male 54 :tall} :male)
=> true
```


## Sequential Data
For sequential data you have lists and vectors.

### map function
The map function applies a function to every value in a collection. Returns a lazy sequence.
```
(defn divide-by-2
  [n]
  (/ n 2))

(map divide-by-2 [8 12 16])
=> (4 6 8)
```
#### Extract a particular map key value from a collection of maps
```
(map :first [{:first "John" :last "Pyeatt"} {:first "Betsey" :last "Davis"}])
=> ("John" "Betsey")```
```
### reduce function
Applies a function to a sequence of values and reduces those values to one value based on the function.
```
(reduce + 0 [4 5 7 9])
=> 25
```

### removing values from a sequence with filter
```
(defn greater-than-10
  [v]
  (< 10 v))

(filter greater-than-10 [4 10 23 43 2])
=> (23 43)
```
or
```
(filter (fn [v] (< 10 v)) [4 10 23 43 2])
=> (23 43)
```
### removing values from a sequence of maps by value with filter
Use this option when you need to vary the filtering value (i.e. you need to define
a function that takes 2 args, then reference it in your (partial) call.
```
(defn find-by-id? [id m]
  (= (:id m) id))
(let [m-list [{:id 1 :name "One"} {:id 2 :name "two"} {:id 3 :name "three"}]]

  (->> m-list (filter (partial find-by-id? 2))))
  
=> => ({:id 2, :name "two"})
```

### Lists
Lists are implemented as linked lists. For this reason it is easiest to add new elements to the beginning
of the list. When you use `conj` it will add new elements to the front of a list.

### Vectors
Vectors are like arrays. You use them when you want to add to the end of a vector, again using `conj`. Or when you need
to get the nth element.
```
(get [4 5 6 7] 2)
=> 6
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
### Queues
LIFO implementation.
```
(def new-orders clojure.lang.PersistentQueue/EMPTY)
(defn add-order [orders order]
   (conj orders order))
(defn cook-order [orders]
   (cook (peek orders))
   (pop orders))
```

### Misc functions

#### concat - concatonates multiple collections and returns a new lazy sequence
```
(concat [4 5 6] [9 8 7])
=> (4 5 6 9 8 7)
```
#### first - returns the first element of a list or vector
```
(first [4 5 6])
=> 4
```
#### rest - returns all but the first element of a list or vector
Even if you specify a vector for input, the result will be a list.
```
(rest [4 5 6])
=> (5 6)
```
