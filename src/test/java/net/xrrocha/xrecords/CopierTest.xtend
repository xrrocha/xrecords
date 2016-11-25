package net.xrrocha.xrecords

import org.junit.Test

import static org.junit.Assert.*
import static org.mockito.Matchers.*
import static org.mockito.Mockito.*

public class CopierInteractionTest {
  //@Test
  def void opensAndClosesLifecycleComponents() {
    val Source sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(false)

    val filterMock = mock(Filter)

    val transformerMock = mock(Transformer)

    val destinationMock = mock(Destination)

    new Copier => [
      val copier = new Copier => [
        source = sourceMock
        filter = filterMock
        transformer = transformerMock
        destination = destinationMock
      ]
      copier.copy()

      val inOrder = inOrder(sourceMock, destinationMock)
      inOrder.verify(sourceMock).open()
      inOrder.verify(destinationMock).open()
      inOrder.verify(sourceMock).hasNext
      inOrder.verify(destinationMock).close()
      inOrder.verify(sourceMock).close()

      verify(filterMock, never).matches(any)
      verify(transformerMock, never).transform(any)
    ]
  }

  @Test
  def void matchComesBeforeTransform() {
    val Source sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(true, false)
    val recordOne = new Record => [ setField('one', 1) ]
    val recordTwo = new Record => [ setField('two', 2) ]
    when(sourceMock.next).thenReturn(recordOne)

    val filterMock = mock(Filter)
    when(filterMock.matches(recordOne)).thenReturn(true)

    val transformerMock = mock(Transformer)
    when(transformerMock.transform(recordOne)).thenReturn(recordTwo)

    val destinationMock = mock(Destination)

    val copier = new Copier => [
      source = sourceMock
      filter = filterMock
      transformer = transformerMock
      destination = destinationMock
    ]
    copier.copy()

    val inOrder = inOrder(filterMock, transformerMock, destinationMock)
    inOrder.verify(filterMock).matches(recordOne)
    inOrder.verify(transformerMock).transform(recordOne)
    inOrder.verify(destinationMock).put(recordTwo)
  }

  //@Test
  def void honorsNoStopOnError() {
    val sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(true, true, false)
    val recordOne = new Record => [ setField('one', 1) ]
    val recordTwo = new Record => [ setField('two', 2) ]
    when(sourceMock.next).thenReturn(recordOne, recordTwo)

    val destinationMock = mock(Destination)
    doThrow(new RuntimeException).when(destinationMock).put(recordOne)

    val copier = new Copier => [
      source = sourceMock
      destination = destinationMock
    ]
    copier.copy()
    verify(destinationMock).put(recordOne)
    verify(destinationMock).put(recordTwo)
  }

  @Test
  def void appliesFilterWhenSupplied() {
    val sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(true, true, false)
    val recordOne = new Record => [ setField('one', 1) ]
    val recordTwo = new Record => [ setField('one', 1) ]
    when(sourceMock.next).thenReturn(recordOne, recordTwo)

    val filterMock = mock(Filter)
    when(filterMock.matches(recordOne)).thenReturn(false)
    when(filterMock.matches(recordTwo)).thenReturn(true)

    val destinationMock = mock(Destination)

    val copier = new Copier => [
      source = sourceMock
      filter = filterMock
      destination = destinationMock
    ]
    copier.copy()

    val inOrder = inOrder(sourceMock, filterMock, destinationMock)
    inOrder.verify(sourceMock).hasNext
    inOrder.verify(filterMock).matches(recordOne)
    inOrder.verify(sourceMock).hasNext
    inOrder.verify(filterMock).matches(recordTwo)
    inOrder.verify(destinationMock).put(recordTwo)
    inOrder.verify(sourceMock).hasNext
  }

  @Test
  def void appliesTransformerWhenSupplied() {
    val sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(true, false)
    val recordOne = new Record => [ setField('one', 1) ]
    when(sourceMock.next).thenReturn(recordOne)

    val transformerMock = mock(Transformer)
    val recordTwo = new Record => [ setField('two', 2) ]
    when(transformerMock.transform(recordOne)).thenReturn(recordTwo)

    val destinationMock = mock(Destination)

    val copier = new Copier => [
      source = sourceMock
      transformer = transformerMock
      destination = destinationMock
    ]
    copier.copy()

    val inOrder = inOrder(sourceMock, transformerMock, destinationMock)
    inOrder.verify(sourceMock).hasNext
    inOrder.verify(transformerMock).transform(recordOne)
    inOrder.verify(destinationMock).put(recordTwo)
    inOrder.verify(sourceMock).hasNext
  }

  @Test
  def void copiesAllElements() {
    val sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(true, true, false)
    val recordOne = new Record => [ setField('one', 1) ]
    val recordTwo = new Record => [ setField('two', 2) ]
    when(sourceMock.next).thenReturn(recordOne, recordTwo)

    val destinationMock = mock(Destination)

    val copier = new Copier => [
      source = sourceMock
      destination = destinationMock
    ]
    copier.copy()

    verify(sourceMock,times(3)).hasNext
    val inOrder = inOrder(destinationMock)
    inOrder.verify(destinationMock).put(recordOne)
    inOrder.verify(destinationMock).put(recordTwo)
  }

  //@Test
  def void closesOpenSourceOnDestinationOpenError() {
    val sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(false)

    val filterMock = mock(Filter)

    val transformerMock = mock(Transformer)

    val destinationMock = mock(Destination)

    doThrow(new RuntimeException).when(destinationMock).open()

    val copier = new Copier => [
      source = sourceMock
      filter = filterMock
      transformer = transformerMock
      destination = destinationMock
    ]

    try {
      copier.copy()
      fail('copy() should have failed')
    } catch(RuntimeException e) {
      val order = inOrder(sourceMock, filterMock, transformerMock, destinationMock)
      order.verify(sourceMock).open()
      order.verify(destinationMock).open()

      order.verify(sourceMock).close()

      verify(destinationMock, never).close()
    }
  }

  //@Test
  def void ignoresErrorsOnClosing() {
    val sourceMock = mock(Source)
    when(sourceMock.hasNext).thenReturn(false)
    doThrow(new RuntimeException).when(sourceMock).close()

    val destinationMock = mock(Destination)
    doThrow(new RuntimeException).when(destinationMock).close()

    val copier = new Copier => [
      source = sourceMock
      destination = destinationMock
    ]

    try {
      copier.copy()
      fail('copy() should have failed')
    } catch(Exception e) {
    }

    val order = inOrder(destinationMock, sourceMock)
    order.verify(sourceMock).open()
    order.verify(destinationMock).open()

    order.verify(destinationMock).close()
    order.verify(sourceMock).close()
  }
}
