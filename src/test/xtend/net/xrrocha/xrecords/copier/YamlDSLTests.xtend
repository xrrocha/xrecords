package net.xrrocha.xrecords.copier

import java.sql.DriverManager
import java.util.List
import net.xrrocha.xrecords.record.Record
import net.xrrocha.yamltag.DefaultYamlFactory
import org.junit.Test

import static org.junit.Assert.*

class YamlDSLTests {
    @Test
    def void populatesDatabaseFromCSV() {
        val yamlScript = '''
            source: !csvSource
                input: !fixedInput |
                    1,M,1/1/1980,John,,Doe
                    2,F,2/2/1990,Janet,,Doe
                    3,M,3/3/2000,Alexio,,Flako
                fields: [
                    { index: 0,  name: id, format: !integer        },
                    { index: 3,  name: firstName,  format: !string },
                    { index: 5,  name: lastName,   format: !string },
                    { index: 1,  name: gender,     format: !string }
                ]

            matcher: !script [gender == "M"]

            transformer: !script |
                ({ID: id, NAME: (firstName + " " + lastName).toString(), GENDER: gender})

            destination: !databaseDestination
                tableName: PERSON
                fieldNames: [ID, NAME, GENDER]
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
                name        VARCHAR(32) NOT NULL,
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
        assertEquals('John Doe', records.get(0).getField("NAME"))
        assertEquals('M', records.get(0).getField("GENDER"))
        
        assertEquals(3, records.get(1).getField("ID"))
        assertEquals('Alexio Flako', records.get(1).getField("NAME"))
        assertEquals('M', records.get(1).getField("GENDER"))
    }
}