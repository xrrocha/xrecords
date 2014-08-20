package net.xrrocha.xrecords.record.fixed

import java.io.Writer
import java.util.List
import net.xrrocha.xrecords.copier.Destination
import net.xrrocha.xrecords.record.Record
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors

// TODO Test FixedRecordDestination
class FixedRecordDestination extends FixedBase implements Destination<Record> {
    @Accessors Provider<Writer> output
    
    private char[] buffer
    private var Writer out
    
    override open() {
        if (buffer == null) {
            buffer = newCharArrayOfSize(length)
        }
        out = output.provide
    }
    
    override put(Record record, int index) {
        fields.forEach [ field |
            val fieldValue = record.getField(field.name)
            field.put(fieldValue, buffer)
        ]
        out.write(buffer)
    }
    
    override close(int count) {
        out.close()        
    }
    
    override validate(List<String> errors) {
        super.validate(errors)
        if (output == null) {
            errors.add('Missing input provider')
        }
    }
}