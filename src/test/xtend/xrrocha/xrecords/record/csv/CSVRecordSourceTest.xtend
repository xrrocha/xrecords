package xrrocha.xrecords.record.csv

import java.io.Reader
import java.io.StringReader
import java.util.ArrayList
import java.util.Date
import java.util.GregorianCalendar
import org.junit.Test
import xrrocha.xrecords.field.DateParser
import xrrocha.xrecords.field.IndexedField
import xrrocha.xrecords.field.IntegerParser
import xrrocha.xrecords.field.StringParser
import xrrocha.xrecords.record.Record
import xrrocha.xrecords.util.Provider

import static org.junit.Assert.*

class CSVRecordSourceTest {
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
        
        val source = new CSVRecordSource => [
            separator = ','
            headerRecord = true
            quote = '"'
            input = provider
            fields = #[
                new IndexedField<String> => [
                    index = 0
                    name = 'name'
                    format = new StringParser
                ],
                new IndexedField<Date> => [
                    index = 1
                    name = 'birthdate'
                    format = new DateParser('dd/MM/yyyy')
                ],
                new IndexedField<Integer> => [
                    index = 2
                    name = 'count'
                    format = new IntegerParser('#,###')
                ]
            ].cast // FIXME Handle field generic types properly
        ]
        
        source.open()
        val actualRecords = source.fold(new ArrayList<Record>) [ records, record |
            records.add(record)
            records
        ]
        source.close(actualRecords.size)
        
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
    
    def <T> T cast(Object obj) { obj as T }
}