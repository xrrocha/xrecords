package net.xrrocha.xrecords.field

import java.util.GregorianCalendar
import net.xrrocha.xrecords.Record
import org.junit.Test

import static org.junit.Assert.*

class FieldTest {
}

class FormattedFieldTest {

  @Test
  def void parsesWithFormat() {
    val field = new FormattedField<Integer> => [
      parser = new IntegerParser('###,###')
    ]
    assertEquals(12345, field.fromString('12,345'))
    assertEquals('12,345', field.toString(12345))
  }

  @Test
  def void formatsNonNullValueFromRecord() {
    val date = new GregorianCalendar(1955, 3, 18).time
    val field = new FormattedField => [
      name = 'date'
      parser = new DateParser('yyy/MM/dd')
    ]
    val record = new Record => [
      setField('date', date)
    ]
    assertEquals('1955/04/18', field.formatValueFrom(record))
  }

  @Test
  def void formatsNullValueFromRecord() {
    val field = new FormattedField => [
      name = 'string'
      parser = new StringParser
    ]
    val record = new Record => [
      setField('string', null)
    ]
    assertEquals('', field.formatValueFrom(record))
  }
}

class IndexedFieldTest {

  @Test
  def void extractsFieldByIndex() {
    val field = new IndexedField<Integer> => [
      index = 2
      parser = new IntegerParser('###,###')
    ]
    val values = #['Spongebob', '1/1/1980', '1,234']
    assertEquals(1234, field.getValueFrom(values))
  }
}

class FixedFieldTest {

  @Test
  def void getsValueProperly() {
    val field = new FixedField<Integer> => [
      parser = new IntegerParser('###,###')
      offset = 4
      length = 6
    ]
    val string = '    12,345 '
    val array = string.toCharArray

    assertEquals(12345, field.get(array))
  }

  @Test
  def void putsValueProperly() {
    val field = new FixedField<Integer> => [
      parser = new IntegerParser('###,###')
      offset = 4
      length = 6
    ]
    val string = '    12,345 '
    val array = string.toCharArray

    field.put(54321, array)
    assertEquals('    54,321 ', new String(array))
  }

  @Test
  def void rejectsTooLongParsedString() {
    val field = new FixedField<Integer> => [
      parser = new IntegerParser('###,###')
      offset = 4
      length = 6
    ]
    val string = '    12,345 '
    val array = string.toCharArray

    try {
      field.put(7654321, array)
      fail('Accepted too long formatted value')
    } catch(IllegalArgumentException iae) {
    }
  }
}