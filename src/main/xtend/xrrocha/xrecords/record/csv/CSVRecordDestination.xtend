package xrrocha.xrecords.record.csv

import au.com.bytecode.opencsv.CSVWriter
import java.io.Writer
import java.util.List
import xrrocha.xrecords.copier.Destination
import xrrocha.xrecords.copier.Lifecycle
import xrrocha.xrecords.field.FormattedField
import xrrocha.xrecords.record.Record
import xrrocha.xrecords.util.Provider

class CSVRecordDestination extends CSVBase implements Destination<Record>, Lifecycle {
    @Property Provider<Writer> output
    @Property List<FormattedField<Object>> fields

    private var CSVWriter writer
    
    override open() {
        writer = new CSVWriter(output.provide, separator, quote)
        
         if (headerRecord) {
             val String[] headers = newArrayOfSize(fields.size)
             for (i: 0 ..< fields.size) {
                 headers.set(i, fields.get(i).name)
             }
             writer.writeNext(headers);
         }
    }
    
    override put(Record record, int index) {
        val String[] recordValues = newArrayOfSize(fields.size)
        
        for (i: 0 ..< fields.size) {
            recordValues.set(i, fields.get(i).formatValueFrom(record))
        }

        writer.writeNext(recordValues)
    }
    
    override close(int count) {
        writer.close()
    }
}