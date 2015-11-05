package net.xrrocha.xrecords.field

import java.math.BigDecimal
import java.util.GregorianCalendar
import org.junit.Test

import static org.junit.Assert.*

public class ParserTest {
    @Test
    def void parsesBoolean() {
        val parser = new BooleanParser
        val trueValues = #['true', 'yes', 'on']
        val falseValues = #['false', 'no', 'off']

        assertTrue(trueValues.forall[parser.parse(it)])    
        assertTrue(trueValues.forall[parser.parse(it.toUpperCase)])    

        assertTrue(falseValues.forall[!parser.parse(it)])    
        assertTrue(falseValues.forall[!parser.parse(it.toUpperCase)])    

        assertEquals('true', parser.format(true))    
        assertEquals('false', parser.format(false))    
    }
    
    @Test
    def void parsesProvidedBoolean() {
        val parser = new BooleanParser => [
            trueRepresentation = 'oui'
            falseRepresentation = 'non'
            representations = #{
                'sí' -> true,
                'no' -> false,
                'sim' -> true,
                'não' -> false,
                'non' -> false,
                'yes' -> true
            }
        ]
        val trueValues = #['sí', 'sim', 'yes']
        val falseValues = #['no', 'não', 'non']

        assertTrue(trueValues.forall[parser.parse(it)])    
        assertTrue(trueValues.forall[parser.parse(it.toUpperCase)])    

        assertTrue(falseValues.forall[!parser.parse(it)])    
        assertTrue(falseValues.forall[!parser.parse(it.toUpperCase)])    

        assertEquals('oui', parser.format(true))    
        assertEquals('non', parser.format(false))    
    }
    
    @Test
    def void rejectsInvalidBooleans() {
        val parser = new BooleanParser
        val values = #['nothing', null]
        values.forEach[
            try {
                parser.parse(it)
                fail('parse() should have failed')
            } catch (IllegalArgumentException e) {}
        ]
    }
    
    @Test
    def void parsesDefaultInteger() {
        val parser = new IntegerParser
        assertEquals(123, parser.parse('0123'))
        assertEquals('123', parser.format(123))
    }
    @Test
    def void parsesFormattedInteger() {
        val parser = new IntegerParser('###,###')
        assertEquals(123456, parser.parse('123,456'))
        assertEquals('123,456', parser.format(123456))
    }
    @Test
    def void parsesIntegerWithMultiplier() {
        val parser = new IntegerParser('###,###', 100)
        assertEquals(1234, parser.parse('123,456'))
        assertEquals('12,345,600', parser.format(123456))
    }

    @Test
    def void parsesDefaultDouble() {
        val parser = new DoubleParser
        assertEquals(123d, parser.parse('0123'), 0d)
        assertEquals('123', parser.format(123d))
    }
    @Test
    def void parsesFormattedDouble() {
        val parser = new DoubleParser('###,###')
        assertEquals(123456d, parser.parse('123,456'), 0d)
        assertEquals('123,456', parser.format(123456d))
    }
    @Test
    def void parsesDoubleWithMultiplier() {
        val parser = new DoubleParser('######', 100)
        assertEquals(1234.56d, parser.parse('123456'), 0d)
        assertEquals('12345600', parser.format(123456d))
    }

    @Test
    def void parsesDefaultBigDecimal() {
        val parser = new BigDecimalParser
        assertEquals(new BigDecimal('123.45'), parser.parse('0123.45'))
        assertEquals('123.45', parser.format(new BigDecimal('123.45')))
    }
    @Test
    def void parsesFormattedBigDecimal() {
        val parser = new BigDecimalParser('###,###.##')
        assertEquals(new BigDecimal('123456.78'), parser.parse('123,456.78'))
        assertEquals('123,456.78', parser.format(new BigDecimal('123456.78')))
    }
    @Test
    def void parsesBigDecimalWithMultiplier() {
        val parser = new BigDecimalParser('######', 100)
        assertEquals(new BigDecimal('1234.56'), parser.parse('123456'))
        assertEquals('12345600', parser.format(new BigDecimal('123456')))
    }

    @Test
    def void parsesDefaultDate() {
        val parser = new DateParser
        val date = new GregorianCalendar(2014, 7, 6).time

        assertEquals(date, parser.parse('6/8/2014'))
        assertEquals('06/08/2014', parser.format(date))
    }
    @Test
    def void parsesFormattedDate() {
        val parser = new DateParser('yyyy/MM/dd')
        val date = new GregorianCalendar(2014, 7, 6).time

        assertEquals(date, parser.parse('2014/8/6'))
        assertEquals('2014/08/06', parser.format(date))
    }

    @Test
    def void parsesDefaultString() {
        val parser = new StringParser
        assertEquals('someString', parser.parse('someString'))
        assertEquals('someString', parser.format('someString'))
    }
    @Test
    def void parsesFormattedString() {
        val parser = new StringParser('uselessFormat')
        assertEquals('someString', parser.parse('someString'))
        assertEquals('someString', parser.format('someString'))
    }
}
