package xrrocha.xrecords.record.jdbc

import java.io.OutputStream
import java.io.OutputStreamWriter
import java.io.PrintWriter
import java.util.List
import xrrocha.xrecords.copier.Destination
import xrrocha.xrecords.field.FormattedField
import xrrocha.xrecords.record.Record
import xrrocha.xrecords.util.Provider
import xrrocha.xrecords.validation.Validatable

class SQLRecordDestination implements Destination<Record>, Validatable {
    @Property String tableName
    @Property List<FormattedField<Object>> fields
    
    @Property String prolog
    @Property String epilog
    
    @Property Provider<OutputStream> output
    
    private var PrintWriter out
    
    override open() {
        out = new PrintWriter(new OutputStreamWriter(output.provide()), true)
        if (prolog != null) {
            out.println(prolog)
        }
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
         if (epilog != null) {
            out.println(epilog)
        }
        out.close()
    }
    
    def enclose(String string) {
        "'" + string + "'"
    }
    
    def escape(String string) {
        string.replace("'", "''")
    }

    override validate(List<String> errors) {
        if (tableName == null || tableName.trim.length == 0) {
            errors.add('Missing table name')
        }

        if (output == null) {
            errors.add('Missing output')
        }

        if (fields == null) {
            errors.add('Missing fields')
        } else {
            for (i: 0..< fields.size) {
                if (fields.get(i) == null) {
                    errors.add('''Missing field «i»''')
                } else {
                    fields.get(i).validate(errors)
                }
            }
        }
    }
}