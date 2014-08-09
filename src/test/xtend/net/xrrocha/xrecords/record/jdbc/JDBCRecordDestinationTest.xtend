package net.xrrocha.xrecords.record.jdbc

import java.sql.Connection
import java.sql.PreparedStatement
import java.util.List
import javax.sql.DataSource
import org.junit.Test
import net.xrrocha.xrecords.record.Record

import static org.junit.Assert.*
import static org.mockito.Matchers.*
import static org.mockito.Mockito.*
import static net.xrrocha.xrecords.record.jdbc.Person.*

class JDBCRecordDestinationTest extends JDBCRecordTest {
    @Test
    def void validatesAll() {
        val destination = new JDBCRecordDestination => [
            dataSource = null
            tableName = null
            fieldNames = null
            batchSize = 0
        ]
        val errors = newLinkedList
        destination.validate(errors)
        assertTrue(errors.size == 4)
    }

    @Test
    def void populatesTable() {
       val records = newArrayList(
           Record.fromMap(#{
               ID -> 1,
               FIRST_NAME -> 'John',
               MIDDLE_NAME -> null,
               LAST_NAME -> 'Doe',
               GENDER -> 'M'
           }),
           Record.fromMap(#{
               ID -> 2,
               FIRST_NAME -> 'Janet',
               MIDDLE_NAME -> null,
               LAST_NAME -> 'Doe',
               GENDER -> 'F'
           })
       )
       
       val destination = createDestination(createDataSource(), 1, false)

       val count = runDestination(destination, records)
       
       assertEquals(records.size, count)
       val statement = connection.createStatement()
       val resultSet = statement.executeQuery('SELECT * FROM person ORDER BY id')
       records.forEach [ record |
           assertTrue(resultSet.next)
           record.fieldNames.forEach [ fieldName |
               assertEquals(record.getField(fieldName), resultSet.getObject(fieldName))
           ]
       ]
       assertFalse(resultSet.next)
    }
    
    @Test
    def void commitsOnBatchAndExecutesBatchOnClose() {
        val dataSource = mock(DataSource)
        val connection = mock(Connection)
        val statement = mock(PreparedStatement)
        
        when(dataSource.connection).thenReturn(connection)
        when(connection.prepareStatement(anyString)).thenReturn(statement)
        when(statement.connection).thenReturn(connection)
        
        val destination = createDestination(dataSource, 2, true)
 
        val records = newArrayList(
           Record.fromMap(#{
               ID -> 1,
               FIRST_NAME -> 'John',
               MIDDLE_NAME -> null,
               LAST_NAME -> 'Doe',
               GENDER -> 'M'
           }),
           Record.fromMap(#{
               ID -> 2,
               FIRST_NAME -> 'Janet',
               MIDDLE_NAME -> null,
               LAST_NAME -> 'Doe',
               GENDER -> 'F'
           }),
           Record.fromMap(#{
               ID -> 3,
               FIRST_NAME -> 'Sponge',
               MIDDLE_NAME -> null,
               LAST_NAME -> 'Bob',
               GENDER -> 'M'
           })
       )

       runDestination(destination, records)
       
       verify(statement, times(2)).executeBatch()
       verify(connection, times(2)).commit()
    }
    
    def createDestination(DataSource theDataSource, int theBatchSize, boolean theCommitOnBatch) {
        new JDBCRecordDestination => [
           tableName = 'PERSON'
           fieldNames = #[ID, FIRST_NAME, MIDDLE_NAME, LAST_NAME, GENDER]
           batchSize = theBatchSize
           commitOnBatch = theCommitOnBatch
           dataSource = theDataSource
        ]
    }
    
    def runDestination(JDBCRecordDestination destination, List<Record> records) {
       destination.open()
       val count = records.fold(0)[ index, record |
           destination.put(record, index)
           index + 1
       ]
       destination.close(count)
       count
    }

    @Test
    def void buildsInsertSql() {
        val expectedInsertSql =
            '''
                INSERT INTO "tableName"("field1", "field2", "field3")
                VALUES(?, ?, ?)
            '''
               
        val tableName = 'tableName'
        val fieldNames = #['field1', 'field2', 'field3']
        val actualInsertSql = JDBCRecordDestination.buildPreparedInsert(tableName, fieldNames)

        assertEquals(expectedInsertSql, actualInsertSql)
    }
}