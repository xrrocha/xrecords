package net.xrrocha.xrecords.csv

import java.io.Reader
import java.io.StringReader
import java.util.ArrayList
import java.util.Date
import java.util.GregorianCalendar
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.field.DateParser
import net.xrrocha.xrecords.field.IndexedField
import net.xrrocha.xrecords.field.IntegerParser
import net.xrrocha.xrecords.field.StringParser
import net.xrrocha.xrecords.util.Provider
import org.junit.Test

import static org.junit.Assert.*

import static extension net.xrrocha.xrecords.util.Extensions.cast

class CSVRecordSourceTest {
    @Test
    def void validatesAll() {
        val destination = new CSVSource => [
            separator = '\u0000'
        ]
        val errors = newLinkedList
        destination.validate(errors)
        assertTrue(errors.size == 3) // separator, provider, fields
    }

    @Test
    def void readsCsvRecords() {
        val csvRecords = '''
            "name","birthdate","count"
            "Alex","24/11/1999","1,234"
            "Diego","16/1/1982","4,321"
            "Ivan","14/11/1988","5,432"
        '''
        
        val provider = new Provider<Reader> {
            override provide() {
                new StringReader(csvRecords)
            }
        }
        
        val source = new CSVSource => [
            separator = ','
            headerRecord = true
            quote = '"'
            input = provider
            fields = #[
                new IndexedField<String> => [
                    index = 0
                    name = 'name'
                    parser = new StringParser
                ],
                new IndexedField<Date> => [
                    index = 1
                    name = 'birthdate'
                    parser = new DateParser('dd/MM/yyyy')
                ],
                new IndexedField<Integer> => [
                    index = 2
                    name = 'count'
                    parser = new IntegerParser('#,###')
                ]
            ].cast
        ]
        
        source.open()
        val actualRecords = source.fold(new ArrayList<Record>) [ records, record |
            records.add(record)
            records
        ]
        source.close(new Stats(actualRecords.size, actualRecords.size))
        
        val expectedRecords = #[
            new Record => [
                setField('name', 'Alex')
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
        
        assertEquals(expectedRecords, actualRecords)
    }
}