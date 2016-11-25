package net.xrrocha.xrecords.xbase

import com.linuxense.javadbf.DBFField
import com.linuxense.javadbf.DBFWriter
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.InputStream
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.util.Provider
import org.junit.Test

import static net.xrrocha.xrecords.xbase.XBase.*
import static org.junit.Assert.*

class TestXBaseSource {
  @Test
  def void readsRecordsProperly() {
    val records = #[
      new Record => [
        setField('id', 1d)
        setField('name', 'Neo')
        setField('gender', 'M')
      ],
      new Record => [
        setField('id', 2d)
        setField('name', 'Trinity')
        setField('gender', 'F')
      ]
    ]

    val baos = new ByteArrayOutputStream
    val dbfWriter = new DBFWriter => [
      fields = #[
        new DBFField => [
          name = 'id'
          dataType = NUMERIC
          fieldLength = 4
        ],
        new DBFField => [
          name = 'name'
          dataType = CHARACTER
          fieldLength = 32
        ],
        new DBFField => [
          name = 'gender'
          dataType = CHARACTER
          fieldLength = 1
        ]
      ]
    ]

    val fieldNames = #['id', 'name', 'gender']
    records.forEach [ record |
      val fieldValues = newArrayOfSize(fieldNames.size)
      (0 ..< fieldNames.size).forEach [ i |
        fieldValues.set(i, record.getField(fieldNames.get(i)))
      ]
      dbfWriter.addRecord(fieldValues)
    ]
    dbfWriter.write(baos)
    baos.flush()
    baos.close()

    val source = new XBaseSource => [
      input = new Provider<InputStream> {
        override provide() { new ByteArrayInputStream(baos.toByteArray) }
      }
    ]
    source.open()
    records.forEach [ record |
      assertTrue(source.hasNext)
      val sourceRecord = source.next
      assertEquals(record, sourceRecord)
    ]
    assertFalse(source.hasNext)
    source.close()
  }
}