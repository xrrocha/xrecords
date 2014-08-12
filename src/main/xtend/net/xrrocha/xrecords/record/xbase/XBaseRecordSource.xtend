package net.xrrocha.xrecords.record.xbase

import com.linuxense.javadbf.DBFReader
import java.io.InputStream
import java.util.List
import net.xrrocha.xrecords.copier.Source
import net.xrrocha.xrecords.record.Record
import net.xrrocha.xrecords.util.Provider

// Test XBaseRecordSource
class XBaseRecordSource extends XBase implements Source<Record> {
    @Property Provider<InputStream> input
    
    private var InputStream is
    private var DBFReader reader
    private Object[] fields
    
    override open() {
        is = input.provide
        reader = new DBFReader(is)
    }
    
    override hasNext() {
        fields = reader.nextRecord()
        fields != null
    }
    
    override next() {
        val record = new Record
        
        for (i: 0 ..< fields.length) {
            val fieldName = reader.getField(i).name
            record.setField(fieldName, fields.get(i))
        }
        
        record
    }
    
    override close(int count) {
        is.close()      
    }
    
    override validate(List<String> errors) {
        if (input == null) {
            errors.add('Missing input provider for XBase record source')
        }
    }
    
    override remove() {
        throw new UnsupportedOperationException('XBaseRecordSource.remove: unimplemented')
    }
}