package net.xrrocha.xrecords.fixed

import java.io.IOException
import java.io.Reader
import java.util.List
import net.xrrocha.xrecords.AbstractSource
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Source
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.util.Provider
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Delegate

@Data class ReaderBuffer {
  Reader in
  char[] buffer

  def read() { in.read(buffer) }
  def close() { in.close() }
}

// Test FixedRecordSource
class FixedSource extends FixedBase implements Source {
  @Accessors Provider<Reader> input

  @Delegate Source delegate = new AbstractSource<ReaderBuffer, char[]>() {
    override doOpen() {
      new ReaderBuffer(input.provide, newCharArrayOfSize(length))
    }

    override next(ReaderBuffer reader) {
      val count = reader.read()

      switch count {
        case count <= 0: null
        case length: reader.buffer
        default:
          throw new IOException('''Premature end of file. Expected «length» chars, got «count»''')
      }
    }

    override Record buildRecord(char[] buffer) {
      val record = new Record

      fields.forEach [ field |
        val fieldString = new String(buffer, field.offset, field.length)
        val fieldValue = field.fromString(fieldString.trim)
        record.setField(field.name, fieldValue)
      ]

      record
    }

    override doClose(ReaderBuffer reader, Stats stats) {
      reader.close()
    }
  }

  override validate(List<String> errors) {
    super.validate(errors)
    if(input == null) {
      errors.add('Missing input provider')
    }
  }
}