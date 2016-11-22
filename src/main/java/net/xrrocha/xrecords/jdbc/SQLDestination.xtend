package net.xrrocha.xrecords.jdbc

import java.io.OutputStream
import java.io.OutputStreamWriter
import java.io.PrintWriter
import java.util.List
import net.xrrocha.xrecords.AbstractDestination
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.field.FormattedField
import net.xrrocha.xrecords.util.Provider
import net.xrrocha.xrecords.validation.Validatable
import org.eclipse.xtend.lib.annotations.Accessors

class SQLDestination extends AbstractDestination<PrintWriter> implements Validatable {
  @Accessors String tableName
  @Accessors List<FormattedField<Object>> fields

  @Accessors String prolog
  @Accessors String epilog

  @Accessors Provider<OutputStream> output

  override doOpen() {
    val out = new PrintWriter(new OutputStreamWriter(output.provide()), true)
    if(prolog != null) {
      out.println(prolog)
    }
    out
  }

  override doPut(PrintWriter out, Record record) {
    val fieldValues = fields.map [ field |
      val objectValue = record.getField(field.name)
      if(objectValue == null) {
        'NULL'
      } else {
        if(objectValue instanceof Number) {
          objectValue.toString
        } else if(objectValue instanceof String) {
          enclose(escape(objectValue))
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

  override doClose(PrintWriter out, Stats stats) {
    if(epilog != null) {
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
    if(tableName == null || tableName.trim.length == 0) {
      errors.add('Missing table name')
    }

    if(output == null) {
      errors.add('Missing output')
    }

    if(fields == null) {
      errors.add('Missing fields')
    } else {
      for(i : 0 ..< fields.size) {
        if(fields.get(i) == null) {
          errors.add('''Missing field «i»''')
        } else {
          fields.get(i).validate(errors)
        }
      }
    }
  }
}
