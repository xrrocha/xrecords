package xrrocha.xrecords.record.jdbc

import org.junit.Test
import xrrocha.xrecords.record.Record

import static org.junit.Assert.*

class JDBCRecordDestinationTest extends JDBCRecordTest {
    @Test
    def void populatesTable() {
       val records = newArrayList(
           Record.fromMap(#{
               'ID' -> 1,
               'FIRST_NAME' -> 'John',
               'MIDDLE_NAME' -> null,
               'LAST_NAME' -> 'Doe',
               'GENDER' -> 'M'
           }),
           Record.fromMap(#{
               'ID' -> 2,
               'FIRST_NAME' -> 'Janet',
               'MIDDLE_NAME' -> null,
               'LAST_NAME' -> 'Doe',
               'GENDER' -> 'F'
           })
       )
       
       val destination = new JDBCRecordDestination => [
           tableName = 'PERSON'
           fieldNames = #['ID', 'FIRST_NAME', 'MIDDLE_NAME', 'LAST_NAME', 'GENDER']
           batchSize = 1
           commitOnBatch = false
           dataSource = createDataSource()
       ]
       
       destination.open()
       val count = records.fold(0)[ index, record |
           destination.put(record, index)
           index + 1
       ]
       destination.close(count)
       
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
    
    // commitOnBatch
    
    // executeBatch on close
}