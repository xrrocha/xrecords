package net.xrrocha.xrecords.util

import java.util.HashMap
import java.util.List
import java.util.Map

class Extensions {
    def static <K, V> Map<K, List<V>> groupBy(Iterable<? extends V> iterable, (V) => K extract) {
        val map = new HashMap<K, List<V>>
        iterable.forEach [
            val index = extract.apply(it)
            if (map.containsKey(index)) {
                map.get(index).add(it)
            } else {
                map.put(index, newArrayList(it))
            }
        ]
        map
    }
    
    def static <T> T cast(Object obj) { obj as T }
}