package net.xrrocha.xrecords.fixed

import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.field.DoubleParser
import net.xrrocha.xrecords.field.FixedField
import net.xrrocha.xrecords.field.IntegerParser
import net.xrrocha.xrecords.field.StringParser
import net.xrrocha.xrecords.io.StringWriterProvider
import org.junit.Test

import static net.xrrocha.xrecords.util.Extensions.*
import static org.junit.Assert.*

class FixedDestinationTest {
  @Test
  def void buildsProperOutput() {
    val destination = new FixedDestination => [
      length = 37
      fields = cast(#[
        new FixedField => [
          name = 'code'
          parser = new IntegerParser('000')
          offset = 0
          length = 3
        ],
        new FixedField => [
          name = 'desc'
          parser = new StringParser
          offset = 3
          length = 24
        ],
        new FixedField => [
          name = 'qty'
          parser = new IntegerParser('0000')
          offset = 27
          length = 4
        ],
        new FixedField => [
          name = 'price'
          parser = new DoubleParser('000000', 100)
          offset = 31
          length = 6
        ]
      ])
      output = new StringWriterProvider
    ]

    val records = #[
      new Record => [
        setField('code', 123)
        setField('desc', 'Bolts x 10')
        setField('qty', 12)
        setField('price', 2.45)
      ],
      new Record => [
        setField('code', 234)
        setField('desc', 'Eau de Perrier')
        setField('qty', 2000)
        setField('price', 0.75)
      ],
      new Record => [
        setField('code', 345)
        setField('desc', 'Acqua Pellegrino')
        setField('qty', 520)
        setField('price', 0.55)
      ],
      new Record => [
        setField('code', 456)
        setField('desc', 'Caturro Coffee')
        setField('qty', 32)
        setField('price', 150.24)
      ]
    ]

    destination.open()
    records.forEach[destination.put(it)]
    destination.close()

    val expectedRecords = '''
            123Bolts x 10              0012000245
            234Eau de Perrier          2000000075
            345Acqua Pellegrino        0520000055
            456Caturro Coffee          0032015024
        '''.toString.replaceAll('\\r?\\n', '')

    assertEquals(expectedRecords, destination.output.toString)
  }
}