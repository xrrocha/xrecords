package net.xrrocha.xrecords.xbase

import com.linuxense.javadbf.DBFField
import com.linuxense.javadbf.DBFReader
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.OutputStream
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Stats
import net.xrrocha.xrecords.util.Provider
import org.junit.Test

import static net.xrrocha.xrecords.xbase.XBase.*
import static org.junit.Assert.*

class TestXBaseDestination {
  @Test
  def void writesRecordsProperly() {
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
    val destination = new XBaseDestination => [
      output = new Provider<OutputStream> {
        override provide() { baos }
      }
      dbfFields = #[
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

    destination.open()
    records.forEach[destination.put(it)]
    destination.close(new Stats(records.size, records.size))

    val dbfReader = new DBFReader(new ByteArrayInputStream(baos.toByteArray))
    val fieldNames = #['id', 'name', 'gender']
    assertEquals(fieldNames.size, dbfReader.fieldCount)
    records.forEach [ record |
      val fieldValues = dbfReader.nextRecord()
      assertNotNull(fieldValues)
      assertEquals(3, fieldValues.length)
      (0 ..< fieldNames.size).forEach[ i |
        assertEquals(record.getField(fieldNames.get(i)).toString, fieldValues.get(i).toString.trim)
      ]
    ]
    assertNull(dbfReader.nextRecord())
  }
}