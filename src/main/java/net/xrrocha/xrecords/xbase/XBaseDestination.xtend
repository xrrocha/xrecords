package net.xrrocha.xrecords.xbase

import com.linuxense.javadbf.DBFField
import com.linuxense.javadbf.DBFWriter
import java.io.OutputStream
import java.util.List
import net.xrrocha.xrecords.AbstractDestination
import net.xrrocha.xrecords.Destination
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtend.lib.annotations.Data

// This XBase impl only supports double
// TODO Add file support to XBaseDestination
class XBaseDestination extends XBase implements Destination {
    @Accessors Provider<OutputStream> output
    @Accessors DBFField[] dbfFields

    @Data static class DBFWriterState {
        protected val OutputStream os
        protected val DBFWriter writer
        
        def addRecord(Object[] fieldValues) {
            writer.addRecord(fieldValues)
        }
        
        def close() {
            writer.write(os)
            os.flush()
            os.close()
        }
    }

    @Delegate Destination delegate = new AbstractDestination<DBFWriterState>() {
        override doOpen() {
            val os = output.provide
            val writer = new DBFWriter => [
                fields = dbfFields
            ]
            
            new DBFWriterState(os, writer)
        }

        override doPut(DBFWriterState writer, Record record) {
            val Object[] fieldValues = newArrayOfSize(dbfFields.length)

            for (i : 0 ..< dbfFields.length) {
                val fieldName = dbfFields.get(i).name
                if (record.hasField(fieldName)) {
                    fieldValues.set(i, record.getField(fieldName))
                }
            }

            writer.addRecord(fieldValues)
        }

        override doClose(DBFWriterState writer, Stats stats) {
            writer.close()
        }
    }

    override validate(List<String> errors) {
        if (output == null) {
            errors.add('Missing output provider for XBase record destination')
        }
    }
}
