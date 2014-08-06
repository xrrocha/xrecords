package xrrocha.xrecords.field

import org.junit.Test
import static org.junit.Assert.*

class FormattedFieldTest {
    @Test
    def void parsesWithFormat() {
        val field = new FormattedField<Integer> => [
            format = new IntegerParser('###,###')
        ]
        assertEquals(12345, field.fromString('12,345'))
        assertEquals('12,345', field.toString(12345))
    }
}

class IndexedFieldTest {
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