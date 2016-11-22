package net.xrrocha.xrecords.jdbc

import java.util.List
import javax.sql.DataSource
import net.xrrocha.xrecords.validation.Validatable
import org.eclipse.xtend.lib.annotations.Accessors

// Add suport for array fields jdbc
abstract class JDBCBase implements Validatable {
  @Accessors DataSource dataSource

  override def validate(List<String> errors) {
    if(dataSource == null) {
      errors.add('Missing data source')
    }
  }
}
