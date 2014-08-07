package xrrocha.xrecords.record.csv

import java.util.Date
import java.util.GregorianCalendar
import org.junit.Test
import xrrocha.xrecords.field.DateParser
import xrrocha.xrecords.field.FormattedField
import xrrocha.xrecords.field.IntegerParser
import xrrocha.xrecords.field.StringParser
import xrrocha.xrecords.io.StringWriterProvider
import xrrocha.xrecords.record.Record

import static org.junit.Assert.assertEquals

class CSVRecordDestinationTest {
    // TODO Test quoting
    // TODO Test header
    
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
            ].map[it as Object].map[it as FormattedField<Object>] // uff!
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