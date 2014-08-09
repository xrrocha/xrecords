package xrrocha.xrecords.record.jdbc

import java.sql.ResultSet
import java.util.List
import xrrocha.xrecords.copier.Source
import xrrocha.xrecords.record.Record

class JDBCRecordSource extends JDBCBase implements Source<Record> {
    @Property String sqlText
    
    private ResultSet resultSet
    
    override open() {
        val connection = dataSource.connection
        val statement = connection.createStatement()
        resultSet = statement.executeQuery(sqlText)
    }

    override boolean hasNext() {
        resultSet.next()
    }
    
    override Record next() {
        val metaData = resultSet.metaData
        val columnCount = metaData.columnCount

        val record = new Record
        
        for (i : 0 ..< columnCount) {
            record.setField(metaData.getColumnLabel(i + 1), resultSet.getObject(i + 1))
        }
        
        record
    }
    
    override close(int count) {
        val statement = resultSet.statement
        val connection = statement.connection
        resultSet.close()
        statement.close()
        connection.close()
    }
    
    override validate(List<String> errors) {
        super.validate(errors)
        if (sqlText == null || sqlText.trim.length == 0) {
            errors.add('Missing sql text for JDBC source')
        }
    }
    
    override remove() {
        throw new UnsupportedOperationException('Unimplemented: remove JDBCRecordSource')
    }
}
