package net.xrrocha.xrecords.field

import java.util.GregorianCalendar
import net.xrrocha.xrecords.Record
import org.junit.Test

import static org.junit.Assert.*

class FieldTest {
    @Test
    def void validatesName() {
        val field = new Field
        val errors = newLinkedList
        field.validate(errors)
        assertTrue(errors.size == 1 && errors.get(0).toLowerCase.contains('missing'))
    }
    
    @Test
    def void validatesNameUniqueness() {
        val fields = #[
            new Field => [ name = 'someField' ],
            new Field => [ name = 'someOtherField' ],
            new Field => [ name = 'someField' ]
        ]
        val errors = newLinkedList
        Field.validateFields(fields, errors)
        assertTrue(errors.size == 1 && errors.get(0).toLowerCase.contains('duplicate'))
    }
    
    @Test
    def void validatesEachField() {
        val fields = #[
            new Field,
            new Field => [ name = 'someName' ],
            new Field
        ]
        val errors = newLinkedList
        Field.validateFields(fields, errors)
        assertTrue(errors.size == 3)
        assertTrue(errors.get(0).toLowerCase.contains('duplicate'))
        assertTrue(errors.get(1).toLowerCase.contains('missing'))
        assertTrue(errors.get(2).toLowerCase.contains('missing'))
    }
}

class FormattedFieldTest {
    @Test
    def void validatesFormat() {
        val field = new FormattedField => [
            name = 'someName'
        ]
        val errors = newLinkedList
        field.validate(errors)
        assertTrue(errors.size == 1 && errors.get(0).toLowerCase.contains('missing'))
    }
    
    @Test
    def void parsesWithFormat() {
        val field = new FormattedField<Integer> => [
            format = new IntegerParser('###,###')
        ]
        assertEquals(12345, field.fromString('12,345'))
        assertEquals('12,345', field.toString(12345))
    }
    
    @Test
    def void formatsNonNullValueFromRecord() {
        val date = new GregorianCalendar(1955, 3, 18).time
        val field = new FormattedField => [
            name = 'date'
            format = new DateParser('yyy/MM/dd')
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
            format = new StringParser
        ]
        val record = new Record => [
            setField('string', null)
        ]
        assertEquals('', field.formatValueFrom(record))
    }
}

class IndexedFieldTest {
    @Test
    def void validatesIndex() {
        val field = new IndexedField => [
            name = 'someName'
            format = new StringParser
            index = -123
        ]
        val errors = newLinkedList
        field.validate(errors)
        assertTrue(errors.size == 1 && errors.get(0).toLowerCase.contains('negative'))
    }
    
    @Test
    def void extractsFieldByIndex() {
        val field = new IndexedField<Integer> => [
            index = 2
            format = new IntegerParser('###,###')
        ]
        val values = #['Spongebob', '1/1/1980', '1,234']
        assertEquals(1234, field.getValueFrom(values))
    }
}

class FixedFieldTest {
    @Test
    def void validatesOffsetAndLength() {
        val field = new FixedField => [
            name = 'someName'
            format = new StringParser
            offset = -123
            length = 0
        ]
        val errors = newLinkedList
        field.validate(errors)
        assertTrue(errors.size == 2 &&
            errors.get(0).toLowerCase.contains('negative') &&
            errors.get(1).toLowerCase.contains('zero')
        )
    }

    @Test
    def void getsValueProperly() {
        val field = new FixedField<Integer> => [
            format = new IntegerParser('###,###')
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
            format = new IntegerParser('###,###')
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
            format = new IntegerParser('###,###')
            offset = 4
            length = 6
        ]
        val string = '    12,345 '
        val array = string.toCharArray
        
        try {
            field.put(7654321, array)
            fail('Accepted too long formatted value')
        } catch (IllegalArgumentException iae) {}
    }
}