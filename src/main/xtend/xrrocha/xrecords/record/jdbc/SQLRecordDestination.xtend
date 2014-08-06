package xrrocha.xrecords.record.jdbc

import java.io.OutputStream
import java.io.OutputStreamWriter
import java.io.PrintWriter
import java.util.List
import xrrocha.xrecords.copier.Destination
import xrrocha.xrecords.copier.Lifecycle
import xrrocha.xrecords.field.FormattedField
import xrrocha.xrecords.record.Record
import xrrocha.xrecords.util.Provider

class SQLRecordDestination implements Destination<Record>, Lifecycle {
    @Property String tableName
    @Property List<FormattedField<Object>> fields
    
    @Property Provider<OutputStream> output
    
    private var PrintWriter out
    override open() {
        out = new PrintWriter(new OutputStreamWriter(output.provide()), true)
    }
    
    override put(Record record, int index) {
        val fieldValues = fields.map [ field |
            val objectValue = record.getField(field.name)
            
            if (objectValue == null) {
                "NULL"
            }
            else {
                if (objectValue instanceof Number) {
                    objectValue.toString
                } else if(objectValue instanceof String) {
                    enclose(escape(objectValue as String))
                } else {
                    enclose(field.toString(objectValue))
                }
            }
        ]
        
        val sqlText = '''
            INSERT INTO "«tableName»"(«fields.map['''"«name»"'''].join(', ')»)
            VALUES(«fieldValues.map[it].join(', ')»);'''
        
        out.println(sqlText)
    }
    
    override close(int count) {
        out.close()
    }
    
    def enclose(String string) {
        "'" + string + "'"
    }
    
    def escape(String string) {
        string.replace("'", "''")
    }
}