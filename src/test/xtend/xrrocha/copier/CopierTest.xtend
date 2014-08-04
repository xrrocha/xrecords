package xrrocha.copier

import org.junit.Test

import static org.junit.Assert.*

import static org.mockito.Mockito.*

public class CopierInteractionTest {
    private val lifecycleMockSettings = withSettings().extraInterfaces(Lifecycle)
    
    @Test
    def opensAndClosesLifecycleComponents() {
        val sourceMock = mock(Source, lifecycleMockSettings)
        when(sourceMock.hasNext).thenReturn(false)
        
        val filterMock = mock(Filter, lifecycleMockSettings)
        
        val transformerMock = mock(Transformer, lifecycleMockSettings)
        
        val destinationMock = mock(Destination, lifecycleMockSettings)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            transformer = transformerMock
            destination = destinationMock
        ]
        copier.copy()

        val inOrder = inOrder(sourceMock, filterMock, transformerMock, destinationMock)
        inOrder.verify(sourceMock as Lifecycle).open()
        inOrder.verify(filterMock as Lifecycle).open()
        inOrder.verify(transformerMock as Lifecycle).open()
        inOrder.verify(destinationMock as Lifecycle).open()
        inOrder.verify(sourceMock).hasNext
        inOrder.verify(sourceMock as Lifecycle).close()
        inOrder.verify(filterMock as Lifecycle).close()
        inOrder.verify(transformerMock as Lifecycle).close()
        inOrder.verify(destinationMock as Lifecycle).close()
    }
    
    @Test
    def honorsNoStopOnError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, true, false)
        when(sourceMock.next).thenReturn("one", "two")
        
        val destinationMock = mock(Destination)
        doThrow(new RuntimeException).when(destinationMock).put("one")
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            stopOnError = false
        ]
        copier.copy()
        verify(destinationMock).put("one")
        verify(destinationMock).put("two")
    }

    @Test
    def void appliesFilterWhenSupplied() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, true, false)
        when(sourceMock.next).thenReturn("one", "two")
        
        val filterMock = mock(Filter)
        when(filterMock.matches("one")).thenReturn(false)
        when(filterMock.matches("two")).thenReturn(true)
        
        val destinationMock = mock(Destination)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            destination = destinationMock
        ]
        copier.copy()

        val inOrder = inOrder(sourceMock, filterMock, destinationMock)
        inOrder.verify(sourceMock).hasNext
        inOrder.verify(filterMock).matches("one")
        inOrder.verify(sourceMock).hasNext
        inOrder.verify(filterMock).matches("two")
        inOrder.verify(destinationMock).put("two")
        inOrder.verify(sourceMock).hasNext
    }

    @Test
    def void appliesTransformerWhenSupplied() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val transformerMock = mock(Transformer, lifecycleMockSettings)
        when(transformerMock.transform("one")).thenReturn("1")
        
        val destinationMock = mock(Destination)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
        ]
        copier.copy()

        val inOrder = inOrder(sourceMock, transformerMock, destinationMock)
        inOrder.verify(sourceMock).hasNext
        inOrder.verify(transformerMock).transform("one")
        inOrder.verify(destinationMock).put("1")
        inOrder.verify(sourceMock).hasNext
    }

    @Test
    def void copiesAllElements() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, true, false)
        when(sourceMock.next).thenReturn("one", "two")
        
        val destinationMock = mock(Destination)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
        ]
        copier.copy()

        verify(sourceMock,times(3)).hasNext
        val inOrder = inOrder(destinationMock)
        inOrder.verify(destinationMock).put("one")
        inOrder.verify(destinationMock).put("two")
    }

    @Test
    def closesOpenComponentsOnOpenError() {
        val sourceMock = mock(Source, lifecycleMockSettings)
        when(sourceMock.hasNext).thenReturn(false)
        
        val filterMock = mock(Filter, lifecycleMockSettings)
        
        val transformerMock = mock(Transformer, lifecycleMockSettings)
        
        val destinationMock = mock(Destination, lifecycleMockSettings)

        doThrow(new RuntimeException).when(destinationMock as Lifecycle).open()

        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            transformer = transformerMock
            destination = destinationMock
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed")
        } catch (RuntimeException e) {
            val order = inOrder(sourceMock, filterMock, transformerMock, destinationMock)
            order.verify(sourceMock as Lifecycle).open()
            order.verify(filterMock as Lifecycle).open()
            order.verify(transformerMock as Lifecycle).open()
            order.verify(destinationMock as Lifecycle).open()
            
            order.verify(sourceMock as Lifecycle).close()
            order.verify(filterMock as Lifecycle).close()
            order.verify(transformerMock as Lifecycle).close()

            verify(destinationMock as Lifecycle, never).close()
        }
    }

    @Test
    def ignoresErrorsOnClosingComponents() {
        val sourceMock = mock(Source, lifecycleMockSettings)
        when(sourceMock.hasNext).thenReturn(false)
        doThrow(new RuntimeException).when(sourceMock as Lifecycle).close()
        
        val filterMock = mock(Filter, lifecycleMockSettings)
        doThrow(new RuntimeException).when(filterMock as Lifecycle).close()
        
        val transformerMock = mock(Transformer, lifecycleMockSettings)
        doThrow(new RuntimeException).when(transformerMock as Lifecycle).close()
        
        val destinationMock = mock(Destination, lifecycleMockSettings)
        doThrow(new RuntimeException).when(destinationMock as Lifecycle).close()

        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            transformer = transformerMock
            destination = destinationMock
        ]
        copier.copy()
        
        val order = inOrder(sourceMock, filterMock, transformerMock, destinationMock)
        order.verify(sourceMock as Lifecycle).open()
        order.verify(filterMock as Lifecycle).open()
        order.verify(transformerMock as Lifecycle).open()
        order.verify(destinationMock as Lifecycle).open()
        
        order.verify(sourceMock as Lifecycle).close()
        order.verify(filterMock as Lifecycle).close()
        order.verify(transformerMock as Lifecycle).close()
        order.verify(destinationMock as Lifecycle).close()
    }
}

public class CopierListenerTest {
    private val lifecycleMockSettings = withSettings().extraInterfaces(Lifecycle)

    @Test
    def reportsOpeningAndClosing() {
        val sourceMock = mock(Source, lifecycleMockSettings)
        when(sourceMock.hasNext).thenReturn(false)
        
        val filterMock = mock(Filter, lifecycleMockSettings)
        
        val transformerMock = mock(Transformer, lifecycleMockSettings)
        
        val destinationMock = mock(Destination, lifecycleMockSettings)
        
        val listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            transformer = transformerMock
            destination = destinationMock
            listener = listenerMock
        ]
        copier.copy()

        val inOrder = inOrder(listenerMock)
        inOrder.verify(listenerMock).onOpen(sourceMock as Lifecycle)
        inOrder.verify(listenerMock).onOpen(filterMock as Lifecycle)
        inOrder.verify(listenerMock).onOpen(transformerMock as Lifecycle)
        inOrder.verify(listenerMock).onOpen(destinationMock as Lifecycle)
        inOrder.verify(listenerMock).onCloseComponent(sourceMock as Lifecycle, 0)
        inOrder.verify(listenerMock).onCloseComponent(filterMock as Lifecycle, 0)
        inOrder.verify(listenerMock).onCloseComponent(transformerMock as Lifecycle, 0)
        inOrder.verify(listenerMock).onCloseComponent(destinationMock as Lifecycle, 0)
        inOrder.verify(listenerMock).onClose(0)
    }    
    
    @Test
    def reportsOnNext() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onNext("one", 0)
    }
    
    @Test
    def omitsOnFilterIfNoFilter() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock, never).onFilter(any, anyBoolean, anyInt)
    }
    
    @Test
    def reportsOnFilterIfFilter() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val filterMock = mock(Filter)
        when(filterMock.matches("one")).thenReturn(true)
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onFilter("one", true, 0)
    }
    
    @Test
    def omitsTransformIfNoTransformer() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock, never).onTransform(any, any, anyInt)
    }
    
    @Test
    def reportsTransformIfTransformer() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val transformerMock = mock(Transformer)
        when(transformerMock.transform("one")).thenReturn("1")
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onTransform("one", "1", 0)
    }
    
    @Test
    def reportsPut() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
    
        verify(listenerMock).onPut("one", 0)
    }

    @Test
    def reportsOpeningErrors() {
        val sourceMock = mock(Source, lifecycleMockSettings)
        when(sourceMock.hasNext).thenReturn(false)
        
        val destinationMock = mock(Destination, lifecycleMockSettings)
        doThrow(new RuntimeException).when(destinationMock as Lifecycle).open()
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed!")
        } catch (RuntimeException e) {
            val inOrder = inOrder(listenerMock)
            inOrder.verify(listenerMock).onOpen(sourceMock as Lifecycle)
            inOrder.verify(listenerMock).onCloseComponent(sourceMock as Lifecycle, 0)
            inOrder.verify(listenerMock).onOpenError(destinationMock as Lifecycle, e)
            verify(listenerMock, never).onClose(anyInt)
        }
    }    

    @Test
    def reportsClosingErrors() {
        val sourceMock = mock(Source, lifecycleMockSettings)
        when(sourceMock.hasNext).thenReturn(false)
        
        val destinationMock = mock(Destination, lifecycleMockSettings)
        val exception = new RuntimeException
        doThrow(exception).when(destinationMock as Lifecycle).close()
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        copier.copy()
        
        val inOrder = inOrder(listenerMock)
        inOrder.verify(listenerMock).onCloseComponent(sourceMock as Lifecycle, 0)
        inOrder.verify(listenerMock).onCloseComponentError(destinationMock as Lifecycle, 0, exception)
        inOrder.verify(listenerMock).onClose(0)
    }    
    
    @Test
    def reportsOnHasNextError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenThrow(new RuntimeException)
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            stopOnError = true
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed!")
        } catch (RuntimeException e) {
            verify(listenerMock).onNextError(0, e)
            verify(listenerMock).onStop(0)
        }
    }
    
    @Test
    def reportsOnNextError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true)
        when(sourceMock.next).thenThrow(new RuntimeException)
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            stopOnError = true
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed!")
        } catch (RuntimeException e) {
            verify(listenerMock).onNextError(0, e)
            verify(listenerMock).onStop(0)
        }
    }
    
    @Test
    def reportsOnFilterError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val filterMock = mock(Filter)
        when(filterMock.matches("one")).thenThrow(new RuntimeException)
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            filter = filterMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed!")
        } catch (RuntimeException e) {
            verify(listenerMock).onFilterError("one", 0, e)
        }
    }
    
    @Test
    def reportsOnTransformError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val transformerMock = mock(Transformer)
        when(transformerMock.transform("one")).thenThrow(new RuntimeException)
        
        val destinationMock = mock(Destination)
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed!")
        } catch (RuntimeException e) {
            verify(listenerMock).onTransformError("one", 0, e)
        }
    }
    
    @Test
    def reportsPutError() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")

        val destinationMock = mock(Destination)
        doThrow(new RuntimeException).when(destinationMock).put("one")
        
        val CopierListener<Object> listenerMock = mock(CopierListener)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
            listener = new MultiCopierListener(#[new LoggingCopierListener<Object>, listenerMock])
        ]
        
        try {
            copier.copy()
            fail("copy() should have failed!")
        } catch (Exception e) {
           verify(listenerMock).onPutError("one", 0, e)
        }
    }
}
