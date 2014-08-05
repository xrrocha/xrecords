package xrrocha.xrecords.record.jdbc

import java.sql.PreparedStatement
import java.sql.ResultSetMetaData
import java.sql.SQLException
import java.util.List
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import xrrocha.xrecords.copier.Destination
import xrrocha.xrecords.record.Record

class JDBCRecordDestination extends JDBCBase implements Destination<Record> {
    @Property String tableName
    @Property List<String> fieldNames
    
    @Property int batchSize = 1
    @Property boolean commitOnBatch = true
    
    private var int rowCount
    private var String sqlText
    private var PreparedStatement statement
    private var ResultSetMetaData metaData
    
    private static Logger logger = LoggerFactory.getLogger(JDBCRecordDestination)
    
    override open() {
        rowCount = 0

        if (sqlText == null) {
            sqlText = buildInsertSql(tableName, fieldNames)
        }
        
        val connection = dataSource.getConnection()
        statement = connection.prepareStatement(sqlText)
        metaData = statement.getMetaData()
    }

    // TODO Consider Destination.put(E element, int count)
    override put(Record record) {
        try {
            for (i: 0 ..< fieldNames.length) {
                val fieldValue = record.getField(fieldNames.get(i))
                
                if (fieldValue != null) {
                    statement.setObject(i + 1, fieldValue)
                } else {
                    if (metaData != null) {
                        statement.setNull(i + 1, metaData.getColumnType(i + 1))
                    } else {
                        statement.setObject(i + 1, null)
                    }
                }
            }

            statement.addBatch()
            
            rowCount = rowCount + 1
            if (rowCount % batchSize == 0) {
                if (logger.debugEnabled)
                    logger.debug('''Batch execution point reached: «rowCount»''')
                statement.executeBatch()
                if (commitOnBatch) {
                    statement.getConnection().commit()
                }
            }
        } catch (SQLException e) {
            val exception = e?.getNextException ?: e
            logger.warn('''Error inserting batch: «exception.getMessage»''', exception)
        }
    }

    override close() {
        statement.executeBatch()
        val connection = statement.getConnection()
        connection.commit()
        statement.close()
        connection.close()
    }
    
    static def String buildInsertSql(String tableName, List<String> fieldNames) {
        '''
            INSERT INTO "«tableName»"(«fieldNames.map['''"«it»"'''].join(', ')»)
            VALUES(«(0 ..< fieldNames.size).map['?'].join(', ')»)
        '''
    }
}