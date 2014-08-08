# XRecords: Tabular Record File Conversion Framework #

```xrecords``` is a small [framework](http://en.wikipedia.org/wiki/Software_framework)
for converting a wide variety of tabular data file formats including (but not
limited to):

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
delimited file:

```yaml
source: !delimitedSource
    input:  !fromFile [people.txt]
    delimiter: '\t'
    fields: &fields
        - { name: id }
        - { name: first_name }
        - { name: last_name, type: STRING } # STRING is the default type
        - { name: salary,   type: NUMBER, format: '$###,###.##' }
        - { name: hiredate, type: DATE, format: MM/dd/yyyy }

filter: !condition [salary > 75000]

destination: !databaseDestination
  tableName: person
  columns: *fields
  dataSource: !!org.postgresql.ds.PGSimpleDataSource
    user: test
    password: test
    serverName: localhost
    databaseName: hr
```

```xrecords``` is written in the [Xtend](http://www.eclipse.org/xtend)
programming language and uses the [SnakeYAML](https://code.google.com/p/snakeyaml/)
YAML library.

