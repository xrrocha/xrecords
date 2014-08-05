package xrrocha.xrecords.record.jdbc

import java.sql.Connection
import java.sql.DriverManager
import org.apache.commons.dbcp.BasicDataSource
import org.junit.AfterClass
import org.junit.BeforeClass
import org.junit.Test
import xrrocha.xrecords.record.Record

import static org.junit.Assert.*

@Data
class Person {
    int id
    String firstName
    String middleName
    String lastName
    String gender
    
    def toRecord() {
        val record = new Record
        record.setField("ID", id)
        record.setField("FIRST_NAME", firstName)
        record.setField("MIDDLE_NAME", middleName)
        record.setField("LAST_NAME", lastName)
        record.setField("GENDER", gender)
        record
    }
}

class JDBCRecordSourceTest {
    static var Connection connection
    static val jdbcUrl = 'jdbc:hsqldb:mem:shutdown'
    
    @BeforeClass
    static def void createDatabase() {
        Class.forName("org.hsqldb.jdbcDriver")
        connection = DriverManager.getConnection(jdbcUrl, 'sa', '')
        
        val statement = connection.createStatement()
        statement.execute('''
            CREATE MEMORY TABLE person (
                id          INTEGER     NOT NULL PRIMARY KEY,
                first_name  VARCHAR(16) NOT NULL,
                middle_name VARCHAR(16) NOT NULL,
                last_name   VARCHAR(16) NOT NULL,
                gender      CHAR(1)     NOT NULL
                    CHECK (gender IN ('F', 'M'))
            )
        ''')
        statement.close()
    }
    
    @Test
    def void retrievesAllRecords() {
        val people = #[
            new Person(1, 'John', 'Alexander', 'Doe', 'M'),
            new Person(2, 'Janet', 'Ellen', 'Doe', 'F'),
            new Person(3, 'Diego', 'Ivan', 'Stein', 'M')
        ]
        
        val statement = connection.prepareStatement('INSERT INTO person VALUES(?, ?, ?, ?, ?)')
        people.forEach[person |
            statement.clearParameters()
            statement.setInt(1, person.id)
            statement.setString(2, person.firstName)
            statement.setString(3, person.middleName)
            statement.setString(4, person.lastName)
            statement.setString(5, person.gender)
            statement.addBatch()
        ]
        statement.executeBatch()
        statement.close()
        
        val source = new JDBCRecordSource => [
            sqlText = 'SELECT * FROM person ORDER BY id'
            dataSource = new BasicDataSource => [
                driverClassName = 'org.hsqldb.jdbc.JDBCDataSource'
                url = jdbcUrl
                username = 'sa'
                password = ''
            ]
        ]
        
        source.open()
        val records = IteratorExtensions.toList(source.map[it])
        source.close()

        val expectedRecords = people.map[toRecord]
        
        assertEquals(expectedRecords, records)
    }
    
    @AfterClass
    static def void closeDatabase() {
        connection.close()
    }
}