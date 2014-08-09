package net.xrrocha.xrecords.record.jdbc

import java.sql.Connection
import java.sql.DriverManager
import org.apache.commons.dbcp.BasicDataSource
import org.junit.After
import org.junit.AfterClass
import org.junit.Before
import org.junit.BeforeClass
import net.xrrocha.xrecords.record.Record

@Data
class Person {
    int id
    String firstName
    String middleName
    String lastName
    String gender

    public static val ID = 'ID'
    public static val FIRST_NAME = 'FIRST_NAME'
    public static val MIDDLE_NAME = 'MIDDLE_NAME'
    public static val LAST_NAME = 'LAST_NAME'
    public static val GENDER = 'GENDER'

    
    def toRecord() {
        val record = new Record
        record.setField('ID', id)
        record.setField('FIRST_NAME', firstName)
        record.setField('MIDDLE_NAME', middleName)
        record.setField('LAST_NAME', lastName)
        record.setField('GENDER', gender)
        record
    }
}

class JDBCRecordTest {
    protected static var Connection connection
    static val jdbcUrl = 'jdbc:hsqldb:mem:shutdown'
    
    static val userName = 'sa'
    static val userPassword = ''
    static val driverClass = 'org.hsqldb.jdbcDriver'
    static val dataSourceClass = 'org.hsqldb.jdbc.JDBCDataSource'
    
    @BeforeClass
    static def void openDatabase() {
        Class.forName(driverClass)
        connection = DriverManager.getConnection(jdbcUrl, userName, userPassword)
    }
    
    @AfterClass
    static def void closeDatabase() {
        connection.close()
    }
    
    @Before
    def void createTable() {
        val statement = connection.createStatement()
        statement.execute('''
            CREATE MEMORY TABLE person (
                id          INTEGER     NOT NULL PRIMARY KEY,
                first_name  VARCHAR(16) NOT NULL,
                middle_name VARCHAR(16),
                last_name   VARCHAR(16) NOT NULL,
                gender      CHAR(1)     NOT NULL
                    CHECK (gender IN ('F', 'M'))
            )
        ''')
        statement.close()
    }
    
    @After
    def void dropTable() {
        val statement = connection.createStatement()
        statement.execute('DROP TABLE person')
        statement.close()
    }
    
    static def createDataSource() {
        new BasicDataSource => [
               driverClassName = dataSourceClass
               url = jdbcUrl
               username = userName
               password = userPassword
        ]
    }
}