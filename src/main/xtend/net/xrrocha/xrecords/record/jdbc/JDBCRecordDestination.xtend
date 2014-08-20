package net.xrrocha.xrecords.record.jdbc

import java.sql.PreparedStatement
import java.sql.ResultSetMetaData
import java.sql.SQLException
import java.util.List
import net.xrrocha.xrecords.copier.Destination
import net.xrrocha.xrecords.record.Record
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.Logger
import org.slf4j.LoggerFactory

// TODO Allow for field names to be set from first record
class JDBCRecordDestination extends JDBCBase implements Destination<Record> {
    @Accessors String tableName
    @Accessors List<String> fieldNames
    
    @Accessors int batchSize = 1
    @Accessors boolean commitOnBatch = false
    
    private var String sqlText
    private var PreparedStatement statement
    private var ResultSetMetaData metaData
    
    private static Logger logger = LoggerFactory.getLogger(JDBCRecordDestination)
    
    override open() {
        if (sqlText == null) {
            sqlText = buildPreparedInsert(tableName, fieldNames)
        }
        
        val connection = dataSource.connection
        statement = connection.prepareStatement(sqlText)
        metaData = statement.metaData
    }

    override put(Record record, int index) {
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
            
            if ((index + 1) % batchSize == 0) {
                if (batchSize > 1 && logger.debugEnabled)
                    logger.debug('''Batch execution point reached: «index + 1»''')

                statement.executeBatch()

                if (commitOnBatch) {
                    statement.connection.commit()
                }
            }
        } catch (SQLException e) {
            val exception = e?.getNextException ?: e
            logger.warn('''Error inserting batch: «exception.getMessage»''', exception)
            throw e
        }
    }

    override close(int count) {
        if (count % batchSize != 0) {
            statement.executeBatch()
        }
        val connection = statement.connection
        connection.commit()
        statement.close()
        connection.close()
    }
    
    override def validate(List<String> errors) {
        super.validate(errors)
        
        if (tableName == null || tableName.trim.length == 0) {
            errors.add('Missing table name')
        }
        
        if (fieldNames == null) {
            errors.add('Missing field names')
        } else {
            for (i: 0 ..< fieldNames.size) {
                if (fieldNames.get(i) == null || fieldNames.get(i).trim.length == 0) {
                    errors.add('''Missing field name «i»''')
                }
            }
        }
        
        if (batchSize <= 0) {
            errors.add('Batch size cannot be negative or zero')
        }
    }
    
    static def String buildPreparedInsert(String tableName, List<String> fieldNames) {
        '''
            INSERT INTO "«tableName»"(«fieldNames.map['''"«it»"'''].join(', ')»)
            VALUES(«(0 ..< fieldNames.size).map['?'].join(', ')»)
        '''
    }
}