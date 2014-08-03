package xrrocha.copier

import org.junit.Test
import static org.mockito.Mockito.*

public class CopierLifecycleTest {
    @Test
    def opensAndClosesBothSourceAndDestination() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(false)
        
        val destinationMock = mock(Destination)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
        ]
        copier.copy()

        val inOrder = inOrder(sourceMock, destinationMock)
        inOrder.verify(sourceMock).open()
        inOrder.verify(destinationMock).open()
        verify(sourceMock).hasNext
        inOrder.verify(sourceMock).close()
        inOrder.verify(destinationMock).close()
    }

    @Test
    def appliesTransformerWhenSupplied() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, false)
        when(sourceMock.next).thenReturn("one")
        
        val transformerMock = mock(Transformer, withSettings().extraInterfaces(CopierComponent))
        when(transformerMock.transform("one")).thenReturn("1")
        
        val destinationMock = mock(Destination)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
        ]
        copier.copy()

        val inOrder = inOrder(sourceMock, transformerMock, destinationMock)
        inOrder.verify(sourceMock).open()
        inOrder.verify(transformerMock as CopierComponent).open()
        inOrder.verify(destinationMock).open()
        inOrder.verify(sourceMock).hasNext
        inOrder.verify(transformerMock).transform("one")
        inOrder.verify(destinationMock).put("1")
        inOrder.verify(sourceMock).hasNext
        inOrder.verify(sourceMock).close()
        inOrder.verify(transformerMock as CopierComponent).close()
        inOrder.verify(destinationMock).close()
    }

    @Test
    def closesSourceOnDestinationOpenError() {
        val sourceMock = mock(Source)

        val destinationMock = mock(Destination)
        doThrow(new RuntimeException()).when(destinationMock).open()

        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
        ]
        
        try {
            copier.copy()
        } catch (RuntimeException e) {
            val order = inOrder(sourceMock, destinationMock)
            order.verify(sourceMock).open()
            order.verify(destinationMock).open()
            order.verify(sourceMock).close()
            
            verify(destinationMock, never).close()
        }
    }

    @Test
    def closesSourceOnTransformerOpenError() {
        val sourceMock = mock(Source)
        
        val transformerMock = mock(Transformer, withSettings().extraInterfaces(CopierComponent))
        doThrow(new RuntimeException()).when(transformerMock as CopierComponent).open()

        val destinationMock = mock(Destination)

        val copier = new Copier<Object> => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
        ]
        
        try {
            copier.copy()
        } catch (RuntimeException e) {
            val inOrder = inOrder(sourceMock, transformerMock, destinationMock)
            inOrder.verify(sourceMock).open()
            inOrder.verify(transformerMock as CopierComponent).open()
            inOrder.verify(sourceMock).close()

            verify(transformerMock as CopierComponent, never).close()
            verify(destinationMock, never).open()
        }
    }

    @Test
    def closesSourceAndTransformerOnDestinationOpenError() {
        val sourceMock = mock(Source)
        
        val transformerMock = mock(Transformer, withSettings().extraInterfaces(CopierComponent))

        val destinationMock = mock(Destination)
        doThrow(new RuntimeException()).when(destinationMock).open()

        val copier = new Copier<Object> => [
            source = sourceMock
            transformer = transformerMock
            destination = destinationMock
        ]
        
        try {
            copier.copy()
        } catch (RuntimeException e) {
            val inOrder = inOrder(sourceMock, transformerMock, destinationMock)
            inOrder.verify(sourceMock).open()
            inOrder.verify(transformerMock as CopierComponent).open()
            inOrder.verify(destinationMock).open()
            inOrder.verify(sourceMock).close()
            inOrder.verify(transformerMock as CopierComponent).close()

            verify(destinationMock, never).close()
        }
    }

    @Test def void getsAllElementsFromSource() {
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
        verify(sourceMock, times(2)).next
    }

    @Test def putsAllElementsInDestination() {
        val sourceMock = mock(Source)
        when(sourceMock.hasNext).thenReturn(true, true, false)
        when(sourceMock.next).thenReturn("one", "two")
        
        val destinationMock = mock(Destination)
        
        val copier = new Copier<Object> => [
            source = sourceMock
            destination = destinationMock
        ]
        copier.copy()
        
        val inOrder = inOrder(destinationMock)
        inOrder.verify(destinationMock).put("one")
        inOrder.verify(destinationMock).put("two")
    }
}
