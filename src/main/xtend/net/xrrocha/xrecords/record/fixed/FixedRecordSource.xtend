package net.xrrocha.xrecords.record.fixed

import java.io.IOException
import java.io.Reader
import java.util.List
import net.xrrocha.xrecords.copier.Source
import net.xrrocha.xrecords.record.Record
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors

// Test FixedRecordSource
class FixedRecordSource extends FixedBase implements Source<Record> {
    @Accessors Provider<Reader> input
    
    private var Reader in
    private char[] buffer
    
    override open() {
        if (buffer == null) {
            buffer = newCharArrayOfSize(length)
        }
        in = input.provide
    }
    
    override hasNext() {
        val count = in.read(buffer)
        if (count > 0 && count != length) {
            throw new IOException('''Premature end of file. Expected «length» chars, got «count»''')
        }
        count == length
    }
    
    override next() {
        val record = new Record

        fields.forEach [ field |
            val fieldString = new String(buffer, field.offset, field.length)
            val fieldValue = field.fromString(fieldString)
            record.setField(field.name, fieldValue)         
        ]

        record
    }
    
    override close(int count) {
        in.close()        
    }
    
    override validate(List<String> errors) {
        super.validate(errors)
        if (input == null) {
            errors.add('Missing input provider')
        }
    }
    
    override remove() {
        throw new UnsupportedOperationException('FixedRecordSource.remove: unimplemented')
    }
}