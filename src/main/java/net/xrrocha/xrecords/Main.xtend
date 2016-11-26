package net.xrrocha.xrecords

import java.io.File
import java.io.FileReader
import net.xrrocha.yamltag.DefaultYamlFactory

/**
 *
 * Command-line application used to bu8ild and execute a record `Copier` from
 * a Yaml configuration.
 *
 * The first and only command line argument expected by `Main` is the
 * filename of the Yaml configuration used to instantiate a [`Copier`](Copier
 * .html). A `Copier` has:
 *
 * - A [`Source`](Source.html) emiting [`Record`](Record.html)s
 * - An optional [`Filter`](Filter.html) used to selectively skip `Record`s
 * - An optional [`Transformer`](Transformer.html) used to enrich the incoming
 * `Record` and
 * - A [`Destination`](Destination.html) to consume incoming `Record`s
 *
 * The following is an example of the Yaml configuration used to dump
 * comma-separated records onto a relational table:
 *
 * ```yaml
 *#
 *# copier configuration to dump comma-separated records onto a relational
 *# database table.
 *#
 *
 *source: !csvSource # comma-separated source
 *    input: !fixedInput | # inline example data (rather than taken from a file)
 *        1,M,1/1/1980,John,,Doe
 *        2,F,2/2/1990,Janet,,Doe
 *        3,M,3/3/2000,Alexio,,Flako
 *    fields: [ # reordered field definitions, each with data type parser
 *        { index: 0,  name: id,        parser: !integer },
 *        { index: 3,  name: firstName, parser: !string  },
 *        { index: 5,  name: lastName,  parser: !string  },
 *        { index: 1,  name: gender,    parser: !string  }
 *    ]
 *
 *filter: !script [gender == "M"] # selection predicate in javascript (nashorn)
 *
 *transformer: !script | # javascript expression returning augmented record
 *  ({ID: id, NAME: (firstName + " " + lastName).toString(), GENDER: gender})
 *
 *destination: !databaseDestination # jdbc destination: insert records in table
 *    tableName: PERSON
 *    fieldNames: [NAME, GENDER]
 *    dataSource: !!org.hsqldb.jdbc.JDBCDataSource
 *      url: jdbc:hsqldb:file:hsqldb/example;hsqldb;shutdown=true
 *      user: sa
 * ```
 */
class Main {

  /**
    *`main` method that reads a Yaml file containing the instantiation of a
    *`Copier`.
    *
    * @param args The command-line arguments. The first element must point to
    * a Yaml file containing a `Copier` configuration
   */
  def static void main(String... args) {

    if(args.length < 1) {
      System.err.println('Usage: Main <script.yaml>')
      System.exit(1)
    }

    val file = new File(args.get(0))
    if(!(file.exists && file.canRead)) {
      System.err.println('''Can't open file: «file.absolutePath»''')
      System.exit(1)
    }

    val reader = new FileReader(file)

    // Use yamltag to enable xrecord framework class Yaml tag aliases
    val yamlFactory = new DefaultYamlFactory
    val yaml = yamlFactory.newYaml

    // Yaml loads a ready-made Copier
    val copier = yaml.loadAs(reader, Copier)

    // Copy in accordance to given configuration
    copier.copy()
  }

}
