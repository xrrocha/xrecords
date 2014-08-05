package xrrocha.xrecords.record

import java.util.HashMap

class Record {
    val fields = new HashMap<String, Object>()
    
    def void setField(String name, Object value) {
        if (name == null)
            throw new NullPointerException('Record field name cannot be null')
        if (name.trim.length == 0)
            throw new IllegalArgumentException('Record field name cannot be blank')
        if (value == null)
            throw new NullPointerException('Record value cannot be null. Remove field instead')
        
        fields.put(name, value)
    }
    
    def getField(String name) {
        if (fields.containsKey(name)) {
            fields.get(name)
        } else {
            throw new IllegalArgumentException('''No such field: «name»''')
        }
    }
    
    def removeField(String name) {
        if (fields.containsKey(name)) {
            fields.remove(name)
        } else {
            throw new IllegalArgumentException('''No such field: «name»''')
        }
    }
    
    def clear() {
        fields.clear()
    }
    
    def fieldNames() {
        fields.keySet
    }
    
    def copyTo(Record other) {
        fields.keySet.forEach[other.setField(it, getField(it))]
    }
    
    def copyFrom(Record other) {
        other.copyTo(this)
    }
    
    // TODO Test Record.equals, hashCode & toString
    override boolean equals(Object other) {
        if (!(other instanceof Record && other != null)) {
            false
        } else {
            (other as Record).fields.equals(fields)
        }
    }
    
    override int hashCode() {
        fields.hashCode()
    }
    
    override toString() {
        fields.toString
    }
}