package net.xrrocha.xrecords.test

import java.util.List
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.util.FieldRenamingTransformer
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

  @Test
  def void validatesRenames() {
    val transformer = new FieldRenamingTransformer => [
      renames = null
    ]
    val List<String> errors = newLinkedList
    transformer.validate(errors)
    assertEquals(1, errors.size)
    assertTrue(errors.get(0).contains('Missing renames'))
  }
}