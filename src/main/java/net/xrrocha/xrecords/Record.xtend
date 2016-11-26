package net.xrrocha.xrecords

import java.util.Collections
import java.util.HashMap
import java.util.Map

/**
 *
 * Format-independent representation of a tabular record.
 *
 * A *tabular record* is a collection of named fields each holding a scalar
 * value.
 *
 * A *scalar value* can be:
 *
 * - A [`String`](https://docs.oracle.com/javase/8/docs/api/java/lang/String.html)
   value containing a free-form string or the string
 * representation of a `value type` such as a [`Date`]
 * (https://docs.oracle.com/javase/8/docs/api/java/util/Date.html)
 * or a [`BigDecimal`]
 * (https://docs.oracle.com/javase/8/docs/api/java/math/BigDecimal.html).
 * - A *primitive value* such as numeric type wrappers ([`Integer`]
 * (https://docs.oracle.com/javase/8/docs/api/java/lang/Integer.html),
 * [`Double`](https://docs.oracle.com/javase/8/docs/api/java/lang/Double.html),
 * etc.)
 * or
 * [`Boolean`](https://docs.oracle.com/javase/8/docs/api/java/lang/Boolean.html)
 * values (`true`, `false`)
 *
 * `Record` field values are all "flat": they must be representable as a
 * `String` and cannot nest. Thus, a `Record` cannot contain another `Record`
 * nor can it contain a complex object lacking an appropriate `Parser`.
 *
 * A [`Parser`](field/Parser.html) is an object capable of parsing a `String`
 * to yield a scalar value and formatting a scalar value to yield its `String`
 * representation. Xrecords comes equipped with parsers for `String`, `Integer`,
 * `Double`, `Boolean`, `BigDecimal` and `Date`. You can easily add your own.
 *
 * `Record` has methods to:
 *
 * - List all field names
 * - Get a field value given its name (fails for non-existent name)
 * - Set a field given its name and value
 * - Remove a field given its name (fails for non-existent name)
 *
 * `Record` also provides methods to copy from/to another record as well as
 * utility static methods to convert to/from [`Map`]
 * (https://docs.oracle.com/javase/8/docs/api/java/util/Map.html).
*/
class Record {

  val fields = new HashMap<String, Object>()

  static def fromMap(Map<String, ?extends Object> map) {
    val record = new Record
    map.keySet.forEach [ fieldName |
      record.setField(fieldName, map.get(fieldName))
    ]
    record
  }

  def toMap() {
    Collections.unmodifiableMap(fields)
  }

  def hasField(String name) {
    fields.containsKey(name)
  }

  def void setField(String name, Object value) {
    if(name == null)
      throw new NullPointerException('Record field name cannot be null')
    if(name.trim.length == 0)
      throw new IllegalArgumentException('Record field name cannot be blank')

    fields.put(name, value)
  }

  def getField(String name) {
    if(fields.containsKey(name)) {
      fields.get(name)
    } else {
      throw new IllegalArgumentException('''No such field: «name»''')
    }
  }

  def removeField(String name) {
    if(fields.containsKey(name)) {
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

  override boolean equals(Object other) {
    if(!(other instanceof Record && other != null)) {
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