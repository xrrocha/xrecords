package xrrocha.xrecords.record.jdbc

import javax.sql.DataSource
import xrrocha.xrecords.copier.Lifecycle

abstract class JDBCBase implements Lifecycle {
    @Property DataSource dataSource
}
