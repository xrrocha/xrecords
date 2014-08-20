package net.xrrocha.xrecords.record.csv

import au.com.bytecode.opencsv.CSVWriter
import java.io.Writer
import java.util.List
import net.xrrocha.xrecords.copier.Destination
import net.xrrocha.xrecords.field.Field
import net.xrrocha.xrecords.field.FormattedField
import net.xrrocha.xrecords.record.Record
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors

class CSVRecordDestination extends CSVBase implements Destination<Record> {
    @Accessors Provider<Writer> output
    @Accessors List<FormattedField<?extends Object>> fields

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

    override validate(List<String> errors) {
        super.validate(errors)
        if (output == null) {
            errors.add('Missing output')
        }
        Field.validateFields(fields, errors)
    }
}