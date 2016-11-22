package net.xrrocha.xrecords.fixed

import java.util.List
import org.junit.Test

import static org.junit.Assert.*

class FixedBaseTest {
  @Test
  def void validatesProperly() {
    val fixedBase = new FixedBase() {} => [
      length = 0
      fields = null
    ]

    val List<String> errors = newLinkedList
    fixedBase.validate(errors)

    assertEquals(errors.size, 2)
    assertTrue(errors.get(0).contains('Invalid fixed record length'))
    assertTrue(errors.get(1).contains('Missing fields'))
  }
}