package net.xrrocha.xrecords.validation

import java.util.List

interface Validatable {
  def void validate(List<String> errors)
}

enum ValidationState {
  NEW, FAILED, OK
}

class Validator {
  private val (List<String>) => void validation

  private var validationState = ValidationState.NEW

  new((List<String>) => void validation) {
    this.validation = validation
  }

  def void validate() {
    val List<String> errors = newArrayList()

    try {
      validation.apply(errors)
    } catch(Exception e) {
      errors.add('''Unexpected failure during validation: «e»''')
    }

    if(errors.size > 0) {
      validationState = ValidationState.FAILED
      throw new ValidationException(errors)
    }

    validationState = ValidationState.OK
  }

  def state() { validationState }
}

class ValidationException extends RuntimeException {
  private val List<String> errors

  new(List<String> errors) {
    super('''«errors.size» validation error«if(errors.size > 1) 's' else ''»: «'\n\t- ' + errors.join('\n\t- ')»''')
    this.errors = errors
  }

  def getErrors() { errors }
}
