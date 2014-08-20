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

Check the [blog entry](http://blog.xrrocha.net/2014/08/building-object-oriented-frameworks.html)
for an discussion of the framework design. 

```xrecords``` is a [blackbox](http://en.wikipedia.org/wiki/Extensibility#Black-Box_Extensibility)
framework and thus can be instantiated declaratively, without programming.

File-conversion applications are written using
[YAML](http://en.wikipedia.org/wiki/YAML). Blackbox components can be scripted
in any JVM language supported by
[JSR-223](https://jcp.org/en/jsr/detail?id=223).

The following ```xrecords``` application populates a Postgres table from a
delimited file:

```yaml
source: !csvSource
    input: !inputLocation [data/form4269.csv]
    fields: &fields [
        { name: tariff, format: !integer },
        { name: desc,   format: !string  },
        { name: qty,    format: !integer  },
        { name: price,  format: !double ['#,###.##']  },
        { name: origin, format: !string  },
        { name: eta, format: !date [dd/MM/yyyy]  }
    ]

filter: !scriptFilter [tariff != 0]

destination: !databaseDestination
    tableName:  form4269
    columns: *fields
    dataSource: !!org.postgresql.ds.PGSimpleDataSource
        user: load
        password: load123
        serverName: forms.customs.feudalia.gov
        databaseName: forms
```

```xrecords``` is written in the [Xtend](http://www.eclipse.org/xtend)
programming language and uses the [SnakeYAML](https://code.google.com/p/snakeyaml/)
YAML library.

