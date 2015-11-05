package net.xrrocha.xrecords.xbase

import com.linuxense.javadbf.DBFReader
import java.io.InputStream
import java.util.List
import net.xrrocha.xrecords.AbstractSource
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Source
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

@Data class XBaseSourceState {
    InputStream is
    DBFReader reader
    
    def nextRecord() { reader.nextRecord() }
    def fieldName(int i) { reader.getField(i).name }
    def close() { is.close() }
}

// Test XBaseRecordSource
class XBaseSource extends XBase implements Source {
    @Accessors Provider<InputStream> input
    
    @Delegate Source delegate = new AbstractSource<XBaseSourceState, Object[]>() {
        override doOpen() {
            val is = input.provide
            new XBaseSourceState(is, new DBFReader(is))
        }
        
        override next(XBaseSourceState reader) {
            reader.nextRecord()
        }
        
        override buildRecord(Object[] fields) {
            val record = new Record
            
            for (i: 0 ..< fields.length) {
                val fieldName = state.fieldName(i)
                // TODO Add trimming option to XBaseSource
                val fieldValue = {
                    val value = fields.get(i)
                    if (value instanceof String) value.toString.trim
                    else value
                }
                record.setField(fieldName, fieldValue)
            }
            
            record
        }
        
        override doClose(XBaseSourceState reader, Stats stats) {
            reader.close()
        }
    }
    
    override validate(List<String> errors) {
        if (input == null) {
            errors.add('Missing input provider for XBase record source')
        }
    }
}