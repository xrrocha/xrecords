package net.xrrocha.xrecords

import org.junit.Test

import static org.junit.Assert.*
import static org.mockito.Matchers.*
import static org.mockito.Mockito.*
import static net.xrrocha.xrecords.Stats.ZERO_STATS

public class CopierInteractionTest {
    @Test
    def void opensAndClosesLifecycleComponents() {
        val Source sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(false)
        
        val filterMock = mock(Filter)
        
        val transformerMock = mock(Transformer)
        
        val destinationMock = mock(Destination)
        
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
        inOrder.verify(destinationMock).close(ZERO_STATS)
        inOrder.verify(sourceMock).close(ZERO_STATS)
        
        verify(filterMock, never).matches(any)
        verify(transformerMock, never).transform(any)
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
    
    @Test
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
            stopOnError = false
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

    @Test
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
        } catch (RuntimeException e) {
            val order = inOrder(sourceMock, filterMock, transformerMock, destinationMock)
            order.verify(sourceMock).open()
            order.verify(destinationMock).open()
            
            order.verify(sourceMock).close(ZERO_STATS)

            verify(destinationMock, never).close(any)
        }
    }

    @Test
    def void ignoresErrorsOnClosing() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(false)
        doThrow(new RuntimeException).when(sourceMock).close(ZERO_STATS)
        
        val destinationMock = mock(Destination)
        doThrow(new RuntimeException).when(destinationMock).close(ZERO_STATS)

        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed')
        } catch (Exception e) {}
        
        val order = inOrder(destinationMock, sourceMock)
        order.verify(sourceMock).open()
        order.verify(destinationMock).open()
        
        order.verify(destinationMock).close(ZERO_STATS)
        order.verify(sourceMock).close(ZERO_STATS)
    }
}

public class CopierListenerTest {
    @Test
    def void reportsOpeningAndClosing() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(false)
        
        val destinationMock = mock(Destination)
        
        val listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = listenerMock
        ]
        copier.copy()

        val inOrder = inOrder(listenerMock)
        inOrder.verify(listenerMock).onSourceOpen(sourceMock)
        inOrder.verify(listenerMock).onDestinationOpen(destinationMock)
        inOrder.verify(listenerMock).onDestinationClose(destinationMock, ZERO_STATS)
        inOrder.verify(listenerMock).onSourceClose(sourceMock, ZERO_STATS)
    }    
    
    @Test
    def void reportsOnNext() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onNext(sourceMock, recordOne, 0)
    }
    
    @Test
    def void omitsOnFilterIfNoFilter() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock, never).onFilter(any, any, anyBoolean, anyInt)
    }
    
    @Test
    def void omitsOnFilterIfNullFilter() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            filter = Filter.nullFilter
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock, never).onFilter(any, any, anyBoolean, anyInt)
    }
    
    @Test
    def void reportsOnFilterIfFilter() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val filterMock = mock(Filter)
        when(filterMock.matches(recordOne)).thenReturn(true)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            filter = filterMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onFilter(any, any, anyBoolean, anyInt)
    }
    
    @Test
    def void omitsTransformIfNoTransformer() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock, never).onTransform(any, any, any, anyInt)
    }
    
    @Test
    def void omitsTransformIfNullTransformer() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            transformer = Transformer.nullTransformer
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock, never).onTransform(any, any, any, anyInt)
    }
    
    @Test
    def void reportsTransformIfTransformer() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        val recordTwo = new Record => [ setField('two', 2) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val transformerMock = mock(Transformer)
        when(transformerMock.transform(recordOne)).thenReturn(recordTwo)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onTransform(transformerMock, recordOne, recordTwo, 0)
    }
    
    @Test
    def void reportsPut() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onPut(destinationMock, recordOne, 0)
    }

    @Test
    def void reportsOpeningErrors() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(false)
        
        val destinationMock = mock(Destination)
        doThrow(new RuntimeException).when(destinationMock).open()
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed!')
        } catch (RuntimeException e) {
            val inOrder = inOrder(listenerMock)
            inOrder.verify(listenerMock).onSourceOpen(sourceMock)
            inOrder.verify(listenerMock).onDestinationOpenError(destinationMock, e)
            inOrder.verify(listenerMock).onSourceClose(sourceMock, ZERO_STATS)
            verify(listenerMock, never).onDestinationClose(any, any)
        }
    }    

    @Test
    def void reportsClosingErrors() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(false)
        
        val destinationMock = mock(Destination)
        val exception = new RuntimeException
        doThrow(exception).when(destinationMock).close(ZERO_STATS)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        try {
            copier.copy()
            fail('copy() should have failed')            
        } catch (Exception e) {}
        
        val inOrder = inOrder(listenerMock)
        inOrder.verify(listenerMock).onSourceOpen(sourceMock)
        inOrder.verify(listenerMock).onDestinationCloseError(destinationMock, ZERO_STATS, exception)
        inOrder.verify(listenerMock).onSourceClose(sourceMock, ZERO_STATS)
    }    
    
    @Test
    def void reportsOnHasNextError() {
        val sourceMock = mock(Source)
        val exception = new RuntimeException
        when(sourceMock.hasNext).thenThrow(exception)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            stopOnError = true
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed!')
        } catch (RuntimeException e) {}

        verify(listenerMock).onHasNextError(sourceMock, 0, exception)
        verify(listenerMock).onStop(exception, 0)
    }
    
    @Test
    def void reportsOnNextError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true)
        val exception = new RuntimeException
        when(sourceMock.next).thenThrow(exception)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            stopOnError = true
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed!')
        } catch (RuntimeException e) {}
        
        verify(listenerMock).onNextError(sourceMock, 0, exception)
        verify(listenerMock).onStop(exception, 0)
    }
    
    @Test
    def void reportsOnFilterError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val filterMock = mock(Filter)
        when(filterMock.matches(recordOne)).thenThrow(new RuntimeException)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            filter = filterMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed!')
        } catch (RuntimeException e) {
            verify(listenerMock).onFilterError(filterMock, recordOne, 0, e)
        }
    }
    
    @Test
    def void reportsOnTransformError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)
        
        val transformerMock = mock(Transformer)
        when(transformerMock.transform(recordOne)).thenThrow(new RuntimeException)
        
        val destinationMock = mock(Destination)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed!')
        } catch (RuntimeException e) {
            verify(listenerMock).onTransformError(transformerMock, recordOne, 0, e)
        }
    }
    
    @Test
    def void reportsPutError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        val recordOne = new Record => [ setField('one', 1) ]
        when(sourceMock.next).thenReturn(recordOne)

        val destinationMock = mock(Destination)
        doThrow(new RuntimeException).when(destinationMock).put(recordOne)
        
        val CopierListener listenerMock = mock(CopierListener)
        
        val copier = new Copier => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener, listenerMock])
        ]
        
        try {
            copier.copy()
            fail('copy() should have failed!')
        } catch (Exception e) {
           verify(listenerMock).onPutError(destinationMock, recordOne, 0, e)
        }
    }
}
