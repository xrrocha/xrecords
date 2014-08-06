package xrrocha.xrecords.record.jdbc

import java.util.List

class JDBCUtils {
    static def String buildPreparedInsert(String tableName, List<String> fieldNames) {
        '''
            INSERT INTO "«tableName»"(«fieldNames.map['''"«it»"'''].join(', ')»)
            VALUES(«(0 ..< fieldNames.size).map['?'].join(', ')»)
        '''
    }
}