package net.xrrocha.xrecords.jdbc

import java.sql.ResultSet
import java.util.List
import net.xrrocha.xrecords.AbstractSource
import net.xrrocha.xrecords.Record
import net.xrrocha.xrecords.Source
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Delegate
import net.xrrocha.xrecords.Stats

class JDBCSource extends JDBCBase implements Source {
    @Accessors String sqlText

    @Delegate Source delegate = new AbstractSource<ResultSet, ResultSet>() {
        override doOpen() {
            val connection = dataSource.connection
            val statement = connection.createStatement()
            statement.executeQuery(sqlText)
        }

        override next(ResultSet resultSet) {
            if(resultSet.next()) resultSet else null
        }

        override def buildRecord(ResultSet resultSet) {
            val metaData = resultSet.metaData
            val columnCount = metaData.columnCount

            val record = new Record

            for (i : 0 ..< columnCount) {
                record.setField(metaData.getColumnLabel(i + 1), resultSet.getObject(i + 1))
            }

            record
        }

        override doClose(ResultSet resultSet, Stats stats) {
            val statement = resultSet.statement
            val connection = statement.connection
            resultSet.close()
            statement.close()
            connection.close()
        }
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
