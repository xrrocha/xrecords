package net.xrrocha.xrecords.record.jdbc

import java.util.List
import javax.sql.DataSource
import net.xrrocha.xrecords.validation.Validatable

abstract class JDBCBase implements Validatable {
    @Property DataSource dataSource
    
    override def validate(List<String> errors) {
        if (dataSource == null) {
            errors.add('Missing data source')
        }
    }
}
