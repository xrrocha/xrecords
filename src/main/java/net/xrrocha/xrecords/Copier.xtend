package net.xrrocha.xrecords

import java.util.Iterator
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * A `Lifecycle` class provides methods for `open`ing and `close`ing it.
 *
 * This interface is extended by `Source` and `Destination` so that their
 * interal resources (files, database connections, network connections, etc.)
 * are created prior to `Record` copying and disposed of afterwards.
*/
interface Lifecycle {

  /*
   * Open this component's underlying resources prior to start copying records.
  */
  def void open()

  /*
   * Close this component's underlying resources after record copying
   * completion.
  */
  def void close()
}

/*
 * Iterator yielding `Record`s from some external origin. `Source` extends
 * `Lifecycle` to be given the oportunity of opening and closing `Record`
 * resources
*/
interface Source extends Iterator<Record>, Lifecycle {
}

/*
 * `Record` selector that determines whether a given `Record` should be sent
 * to the `Copier`s destination or not.
*/
interface Filter {
  /**
   * Determine whether the given `Record` should or should not be sent to
   * this `Filter`'s parent `Copier`. This is an optional copying component.
   *
   * @param record The record to be examined for inclusion eligibility.
  */
  def boolean matches(Record record)
}

/*
 * Transformation to be applied to each `Record` prior to its being sent to the
 * parent `Copier`'s destination. This is an optional copying component.
*/
interface Transformer {
  /**
   * Transform the incoming `Record` returning the new, possbily modified
   * replacement `Record`.
   *
   * @param record The `Record` to be transformed.
  */
  def Record transform(Record record)
}

interface Destination extends Lifecycle {
  def void put(Record record)
}

/**
 * The workhorse of the `Record` copying framework, a `Copier` is configured
 * with:
 *
 * - A record `Source` yielding zero or more  `Record`s
 * - An optional `Filter` selecting which `Record`s to include in copying
 * - An optional `Transformer`modyfying incoming `Record`s prior to their
 * consumption
 * - A `Destination` where selected `Record`s are sent for consumption
*/
@Accessors
class Copier {

  /**
   * This copier's' `Record` source.
  */
  Source source

  /**
   * This copier's `Filter` or the identify filter is not specified.
  */
  Filter filter = [ record | true ]

  /**
   * This copier's `Transformer` or the identity function if not specified.
  */
  Transformer transformer = [ record | record ]

  /**
   * This copier's `Record` destination.
  */
  Destination destination

  /*
   * Copy incoming records to the configured destination possibly excluding
   * and/or transforming some of them.
   *
  */
  final def copy() {
    // Start by opening both source and destination
    #[source, destination].forEach[open]

    try {
      source. // Pull each record from source
      filter[filter.matches(it)]. // Verify record is eligible for consumption
      map[transformer.transform(it)]. // Modify record prior to consumption
      forEach[destination.put(it)] // Put each record into destination
    } finally {
      // Make sure source and destination are closed, even in the face of errors
      #[source, destination].forEach[close]
    }
  }
}

