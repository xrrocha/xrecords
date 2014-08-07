package xrrocha.xrecords.record

import java.sql.DriverManager
import java.util.List
import org.junit.Test
import static org.junit.Assert.*
import xrrocha.xrecords.copier.Copier
import net.xrrocha.yamltag.DefaultYamlFactory

class YamlDSLTests {
    @Test
    def void populatesDatabaseFromCSV() {
        val yamlScript = '''
            source: !csvSource
                separator: ','
                quote: '"'
                headerRecord: false
                input: !fixedInput |
                    1,"M","John",,"Doe"
                    2,"F","Janet",,"Doe"
                fields:
                    - index: 0
                      name: ID
                      format: !integer
                    - index: 2
                      name: FIRST_NAME
                      format: !string
                    - index: 4
                      name: LAST_NAME
                      format: !string
                    - index: 1
                      name: GENDER
                      format: !string
            #matcher:
            #transformer:
            destination: !databaseDestination
                tableName: PERSON
                fieldNames: [ID, FIRST_NAME, LAST_NAME, GENDER]
                batchSize: 1
                commitOnBatch: true
                dataSource: !basicDataSource
                    driverClassName: org.hsqldb.jdbc.JDBCDataSource
                    url: jdbc:hsqldb:mem:shutdown
                    username: sa
                    password:
        '''
        
        val yaml = new DefaultYamlFactory().newYaml
        val copier = yaml.loadAs(yamlScript, Copier)

        val userName = 'sa'
        val userPassword = ''
        val jdbcUrl = 'jdbc:hsqldb:mem:shutdown'
        val driverClass = 'org.hsqldb.jdbcDriver'
        Class.forName(driverClass)
        val connection = DriverManager.getConnection(jdbcUrl, userName, userPassword)
        val createStatement = connection.createStatement()
        createStatement.execute('''
            CREATE MEMORY TABLE person (
                id          INTEGER     NOT NULL PRIMARY KEY,
                first_name  VARCHAR(16) NOT NULL,
                middle_name VARCHAR(16),
                last_name   VARCHAR(16) NOT NULL,
                gender      CHAR(1)     NOT NULL
                    CHECK (gender IN ('F', 'M'))
            )
        ''')
        createStatement.close()
       
        copier.copy()
        
        val selectStatement = connection.createStatement()
        val resultSet = selectStatement.executeQuery('SELECT * FROM person ORDER BY id')
        val List<Record> records = newArrayList()
        while (resultSet.next) {
            val record = new Record
            for (i: 0 ..< resultSet.metaData.columnCount) {
                record.setField(resultSet.metaData.getColumnName(i + 1), resultSet.getObject(i + 1))
            }
            records.add(record)
        }

        val dropStatement = connection.createStatement()
        dropStatement.execute('DROP TABLE person')
        dropStatement.close()
        
        connection.close()
        
        assertEquals(2, records.size)
        
        assertEquals(1, records.get(0).getField("ID"))
        assertEquals('John', records.get(0).getField("FIRST_NAME"))
        assertEquals('Doe', records.get(0).getField("LAST_NAME"))
        assertEquals('M', records.get(0).getField("GENDER"))
        
        assertEquals(2, records.get(1).getField("ID"))
        assertEquals('Janet', records.get(1).getField("FIRST_NAME"))
        assertEquals('Doe', records.get(1).getField("LAST_NAME"))
        assertEquals('F', records.get(1).getField("GENDER"))
    }
}