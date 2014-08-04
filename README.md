# XRecords: Tabular Record File Conversion Framework #

```xrecords``` is a [framework](http://en.wikipedia.org/wiki/Software_framework)
for converting tabular data files between a wide variety of formats including
(but not limited to):

- Relational database tables
- Comma-separated values (CSV)
- Delimited
- Fixed-length
- XML
- DBF (Xbase)

```xrecords``` is a [blackbox](http://en.wikipedia.org/wiki/Extensibility#Black-Box_Extensibility)
framework and thus can be instantiated declaratively, without programming.

```xrecords``` file-conversion applications are written using
[YAML](http://en.wikipedia.org/wiki/YAML). Blackbox components can be scripted
in any JVM language supported by
[JSR-223](https://jcp.org/en/jsr/detail?id=223).

The following ```xrecords``` application populates a Postgres table from a
fixed-length file:

```yaml
source: !fixedLengthSource
    input:  !fromFile [people.txt]
    length: 55
    trim:   true
    fixedFields: &fields
        - { name: code,                   offset:  0, length:  3 }
        - { name: fname,                  offset:  3, length: 16 }
        - { name: lname,                  offset: 19, length: 16 }
        - { name: salary,   type: NUMBER, offset: 35, length:  9, formatString: '$###,###.##' }
        - { name: hiredate, type: DATE,   offset: 44, length: 10, formatString: MM/dd/yyyy }

filter: !scriptFilter [salary > 1500]

destination: !jdbcDestination
  batchSize: 16384
  tableName: person
  columnNames: [id, first_name, last_name, salary, hiredate]
  dataSource: !!org.postgresql.ds.PGSimpleDataSource
    user: test
    password: test
    serverName: localhost
    databaseName: hr
```

:

```xrecords``` is written in the [Xtend](http://www.eclipse.org/xtend)
programming language and uses the [SnakeYAML](https://code.google.com/p/snakeyaml/)
YAML library.

