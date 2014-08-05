package xrrocha.xrecords.record.jdbc

import java.sql.ResultSet
import java.util.Iterator
import xrrocha.xrecords.record.Record

class JDBCRecordSource extends JDBCBase implements Iterator<Record> {
    @Property String sqlText
    
    private ResultSet resultSet
    
    override open() {
        val connection = dataSource.getConnection()
        val statement = connection.createStatement()
        resultSet = statement.executeQuery(sqlText)
    }

    override boolean hasNext() {
        resultSet.next()
    }
    
    override Record next() {
        val metaData = resultSet.getMetaData()
        val columnCount = metaData.getColumnCount()

        val record = new Record
        
        for (i : 0 ..< columnCount) {
            record.setField(metaData.getColumnLabel(i + 1), resultSet.getObject(i + 1))
        }
        
        record
    }
    
    override close() {
        val statement = resultSet.getStatement()
        val connection = statement.getConnection()
        resultSet.close()
        statement.close()
        connection.close()
    }
    
    override remove() {
        throw new UnsupportedOperationException("Unimplemented: remove JDBCRecordSource")
    }
}
