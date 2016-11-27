package net.xrrocha.xrecords.test

import net.xrrocha.xrecords.Record
import org.junit.Test

import static org.junit.Assert.*

class FieldRenamingTransformerTest {
  @Test
  def void renamesFieldsWithPreserve() {
    val transformer = new FieldRenamingTransformer => [
      preserveOthers = true
      renames = # {
        'one' -> 'uno',
        'two' -> 'dos'
      }
    ]

    val inputRecord = new Record => [
      setField('one', 1)
      setField('two', 2)
      setField('three', 3)
    ]

    val outputRecord = transformer.transform(inputRecord)
    assertEquals(# {'uno', 'dos', 'three'}, outputRecord.fieldNames)
  }

  @Test
  def void renamesFieldsWithoutPreserve() {
    val transformer = new FieldRenamingTransformer => [
      preserveOthers = false
      renames = # {
        'one' -> 'uno',
        'two' -> 'dos'
      }
    ]

    val inputRecord = new Record => [
      setField('one', 1)
      setField('two', 2)
      setField('three', 3)
    ]

    val outputRecord = transformer.transform(inputRecord)
    assertEquals(# {'uno', 'dos'}, outputRecord.fieldNames)
  }
}