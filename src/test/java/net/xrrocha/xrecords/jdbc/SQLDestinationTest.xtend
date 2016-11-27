package net.xrrocha.xrecords.jdbc

import java.io.ByteArrayOutputStream
import java.io.OutputStream
import java.util.Date
import java.util.GregorianCalendar
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.field.DateParser
import net.xrrocha.xrecords.field.FormattedField
import net.xrrocha.xrecords.field.IntegerParser
import net.xrrocha.xrecords.field.StringParser
import net.xrrocha.xrecords.util.Provider
import org.junit.Test

import static org.junit.Assert.*

class SQLDestinationTest {

  @Test
  def void generatesInsertStatements() {
    val records = #[
      new Record => [
        setField('name', 'Alex')
        setField('count', 2)
        setField('birthdate', date(1999, 10, 24))
      ],
      new Record => [
        setField('name', 'Diego')
        setField('count', 3)
        setField('birthdate', date(1982, 0, 16))
      ]
    ]

    val provider = new Provider<OutputStream> {
      val baos = new ByteArrayOutputStream
      override provide() { baos }
    }

    val destination = new SQLDestination => [
      tableName = 'person'
      output = provider
      fields = #[
        new FormattedField<String> => [
          name = 'name'
          parser = new StringParser
        ],
        new FormattedField<Integer> => [
          name = 'count'
          parser = new IntegerParser
        ],
        new FormattedField<Date> => [
          name = 'birthdate'
          parser = new DateParser('dd-MMM-yyy')
        ]
      ].map[it as Object].map[it as FormattedField<Object>] // uff!
    ]

    destination.open()
    records.fold(0) [ index, record |
      destination.put(record)
      index + 1
    ]
    destination.close()

    val expectedString = '''
            INSERT INTO "person"("name", "count", "birthdate")
            VALUES('Alex', 2, '24-Nov-1999');
            INSERT INTO "person"("name", "count", "birthdate")
            VALUES('Diego', 3, '16-Jan-1982');
        '''

    val actualString = provider.baos.toString

    assertEquals(expectedString, actualString)
  }

  @Test
  def void outputsPrologAndEpilog() {
    val outputProlog = '''
            SET ECHO ON
            SET FEED ON
            SET AUTOCOMMIT ON
            SPOOL load.log
        '''
    val outputEpilog = '''
            SPOOL OFF
        '''
    val provider = new Provider<OutputStream> {
      val baos = new ByteArrayOutputStream
      override provide() { baos }
    }

    val destination = new SQLDestination => [
      tableName = 'person'
      output = provider
      prolog = outputProlog
      epilog = outputEpilog
      fields = #[
        new FormattedField<String> => [
          name = 'name'
          parser = new StringParser
        ],
        new FormattedField<Integer> => [
          name = 'count'
          parser = new IntegerParser
        ],
        new FormattedField<Date> => [
          name = 'birthdate'
          parser = new DateParser('dd-MMM-yyy')
        ]
      ].map[it as Object].map[it as FormattedField<Object>] // uff!
    ]

    destination.open()
    destination.close()

    val expectedString = normalize(outputProlog + outputEpilog)

    val actualString = normalize(provider.baos.toString)

    assertEquals(expectedString, actualString)
  }

  def normalize(String string) {
    string.replaceAll('\\s+', ' ').trim
  }

  def date(int year, int month, int day) {
    new GregorianCalendar(year, month, day).time
  }
}