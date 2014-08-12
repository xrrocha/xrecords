package net.xrrocha.xrecords.record.xbase

import com.linuxense.javadbf.DBFField
import com.linuxense.javadbf.DBFWriter
import java.io.OutputStream
import java.util.List
import net.xrrocha.xrecords.copier.Destination
import net.xrrocha.xrecords.field.Field
import net.xrrocha.xrecords.record.Record
import net.xrrocha.xrecords.util.Provider

// TODO Test XBaseRecordDestination
class XBaseRecordDestination extends XBase implements Destination<Record> {
    @Property Provider<OutputStream> output
    @Property List<Field> fields;
    
    private var OutputStream os
    private var DBFWriter writer
    private var DBFField[] dbfFields
    
    override open() {
        if (dbfFields == null) {
            dbfFields = newArrayOfSize(fields.size)
            for (i: 0 ..< fields.size) {
                val dbfField = new DBFField => [
                    name = fields.get(i).name
                    // TODO Add data type to dbf field
                ]
                dbfFields.set(i, dbfField)
            }
        }
        os = output.provide
        writer = new DBFWriter()
        writer.setFields(dbfFields)
        
    }
    
    override put(Record record, int index) {
        val Object[] fieldValues = newArrayOfSize(fields.size)
        for (i: 0 ..< fields.size) {
            fieldValues.set(i, record.getField(fields.get(i).name))
        }
        writer.addRecord(fieldValues)
        writer.write(os)
    }
    
    override close(int count) {
        os.flush()
        os.close()      
    }
    
    override validate(List<String> errors) {
        if (output == null) {
            errors.add('Missing output provider for XBase record destination')
        }
    }
}