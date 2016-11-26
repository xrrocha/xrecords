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

  /**
   * The underlying `Map` containing field names and values.
  */
  val fields = new HashMap<String, Object>()

  /**
   * Populate a new `Record` from a `Map`. Null keys are silently ignored
   *
   * @param map The `String`-to-`Object` source map
  */
  static def fromMap(Map<String, ?extends Object> map) {
    val record = new Record
    map.keySet.
      filter[ key | key != null ].
      forEach [ key | record.setField(key, map.get(key)) ]
    record
  }

  /*
   * Return an immutable wrapper of the underlying `Map`
  */
  def toMap() {
    Collections.unmodifiableMap(fields)
  }

  /*
   * Determine whether this `Record` contains a value with the given `name`.
   * @param name The field name whose occurence is to be ascertained
  */
  def hasField(String name) {
    fields.containsKey(name)
  }

  /**
   * Set the field associated with `name` to the given `value`.
   * @param name The field name
   * @param value The field value
   * @throws `NullPointerExxception` if the `name` is null or blank
  */
  def void setField(String name, Object value) {
    if(name == null)
      throw new NullPointerException('Record field name cannot be null')
    if(name.trim.length == 0)
      throw new IllegalArgumentException('Record field name cannot be blank')

    fields.put(name, value)
  }
/**
 * Return the `value` associated with the given `name`.
 *
 * `Name` must exist already in this `Record`.
 *
 * @param name T%he name of the field to retrie3ve
 *
 * @throws IllegalArgumentException if the field `name` is not alreqady present
*/
  def getField(String name) {
    if(fields.containsKey(name)) {
      fields.get(name)
    } else {
      throw new IllegalArgumentException('''No such field: «name»''')
    }
  }

  /*
   * Removes a field given its `name`.
   *
   * @param name The name of the field to be removed
   *
   * @throws IllegalArgumentException if the given `name` does not occur in this
   * `Record`
  */
  def removeField(String name) {
    if(fields.containsKey(name)) {
      fields.remove(name)
    } else {
      throw new IllegalArgumentException('''No such field: «name»''')
    }
  }

  /*
   * Remove all fields in this `Record` at once.
  */
  def clear() {
    fields.clear()
  }

  /*
   * Return all field names in this `Record` (in no particular order).
  */
  def fieldNames() {
    fields.keySet
  }

  /*
   * Copy all fields in this `Record` onto the `other` one, possibly overwriting
   * equally named fields as well as adding new ones.
   *
   * @param other The other `Record` to put fields onto
   *
  */
  def copyTo(Record other) {
    fields.keySet.forEach[other.setField(it, getField(it))]
  }

  /*
   * Copy all fields in the other `Record` onto this `Record`, possibly
   * overwriting equally named fields as well as adding new ones.
   *
   * @param other The other `Record` to draw fields from
   *
  */
  def copyFrom(Record other) {
    other.copyTo(this)
  }

  /*
   * Compare this `Record` with another one field-by-field
   *
   * @param other The other `Record` to compare against.
  */
  override boolean equals(Object other) {
    if(!(other instanceof Record && other != null)) {
      false
    } else {
      (other as Record).fields.equals(fields)
    }
  }

  /*
   * Project hashCode() of underlying map
  */
  override int hashCode() {
    fields.hashCode()
  }


  /*
   * Project toString() of underlying map
  */
  override toString() {
    fields.toString
  }
}