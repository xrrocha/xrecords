package net.xrrocha.xrecords.record.csv

import java.util.Date
import java.util.GregorianCalendar
import org.junit.Test
import net.xrrocha.xrecords.field.DateParser
import net.xrrocha.xrecords.field.FormattedField
import net.xrrocha.xrecords.field.IntegerParser
import net.xrrocha.xrecords.field.StringParser
import net.xrrocha.xrecords.io.StringWriterProvider
import net.xrrocha.xrecords.record.Record
import static org.junit.Assert.*

import static org.junit.Assert.assertEquals
import static extension net.xrrocha.xrecords.util.Extensions.cast

class CSVRecordDestinationTest {
    @Test
    def void validatesAll() {
        val destination = new CSVRecordDestination => [
            separator = '\u0000'
            quote = '\u0000'
        ]
        val errors = newLinkedList
        destination.validate(errors)
        assertTrue(errors.size == 4) // separator, quote, provider, fields
    }
    
    @Test
    def void prependsFieldNames() {
        val destination = new CSVRecordDestination => [
            separator = ','
            headerRecord = true
            output = new StringWriterProvider
            fields = #[
                new FormattedField<String> => [
                    name = 'name'
                    format = new StringParser
                ],
                new FormattedField<Date> => [
                    name = 'birthdate'
                    format = new DateParser('dd/MM/yyyy')
                ],
                new FormattedField<Integer> => [
                    name = 'count'
                    format = new IntegerParser('#,###')
                ]
            ].cast
        ]
        
        destination.open()
        
        val expectedHeader = destination.fields.map[name].join(',').trim
        val actualHeader = destination.output.toString.trim
        
        assertEquals(expectedHeader, actualHeader)
    }
    
    @Test
    def void omitsFieldNames() {
        val destination = new CSVRecordDestination => [
            headerRecord = false
            output = new StringWriterProvider
            fields = #[
                new FormattedField<String> => [
                    name = 'name'
                    format = new StringParser
                ],
                new FormattedField<Date> => [
                    name = 'birthdate'
                    format = new DateParser('dd/MM/yyyy')
                ],
                new FormattedField<Integer> => [
                    name = 'count'
                    format = new IntegerParser('#,###')
                ]
            ].cast
        ]
        
        destination.open()
        
        assertEquals(0, destination.output.toString.length)
    }
    
    @Test
    def void createsCsvRecords() {
        val records = #[
            new Record => [
                setField('name', '"Alex"')
                setField('birthdate', new GregorianCalendar(1999, 10, 24).time)
                setField('count', 1234)
            ],
            new Record => [
                setField('name', 'Diego')
                setField('birthdate', new GregorianCalendar(1982, 0, 16).time)
                setField('count', 4321)
            ],
            new Record => [
                setField('name', 'Ivan')
                setField('birthdate', new GregorianCalendar(1988, 10, 14).time)
                setField('count', 5432)
            ]
        ]
        
        val destination = new CSVRecordDestination => [
            separator = ','
            headerRecord = true
            quote = '"'
            output = new StringWriterProvider
            fields = #[
                new FormattedField<String> => [
                    name = 'name'
                    format = new StringParser
                ],
                new FormattedField<Date> => [
                    name = 'birthdate'
                    format = new DateParser('dd/MM/yyyy')
                ],
                new FormattedField<Integer> => [
                    name = 'count'
                    format = new IntegerParser('#,###')
                ]
            ].cast
        ]
        
        destination.open()
        val count = records.fold(0) [ index, record |
            destination.put(record, index)
            index + 1
        ]
        destination.close(count)
        
        val expectedOutput = '''
            "name","birthdate","count"
            """Alex""","24/11/1999","1,234"
            "Diego","16/01/1982","4,321"
            "Ivan","14/11/1988","5,432"
        '''
        assertEquals(expectedOutput, destination.output.toString)
    }
}