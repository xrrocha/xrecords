package net.xrrocha.xrecords.fixed

import java.io.Writer
import java.util.Arrays
import java.util.List
import net.xrrocha.xrecords.AbstractDestination
import net.xrrocha.xrecords.Destination
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

@Data class WriterBuffer {
  Writer out
  char[] buffer

  def write() {
    out.write(buffer)
    Arrays.fill(buffer, ' ')
  }

  def close() {
    out.close()
  }
}

class FixedDestination extends FixedBase implements Destination {
  @Accessors Provider<Writer> output

  @Delegate Destination delegate = new AbstractDestination<WriterBuffer> {
    override doOpen() {
      val buffer = newCharArrayOfSize(length)
      Arrays.fill(buffer, ' ')
      new WriterBuffer(output.provide, buffer)
    }

    override doPut(WriterBuffer writer, Record record) {
      fields.forEach [ field |
        val fieldValue = record.getField(field.name)
        field.put(fieldValue, writer.buffer)
      ]
      writer.write()
    }

    override doClose(WriterBuffer writer) {
      writer.close()
    }
  }

  override validate(List<String> errors) {
    super.validate(errors)
    if(output == null) {
      errors.add('Missing output provider')
    }
  }
}