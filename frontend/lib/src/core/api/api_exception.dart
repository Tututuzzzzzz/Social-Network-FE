class ApiException implements Exception {
  final String message;
  final String prefix;

  ApiException([this.message = "", this.prefix = ""]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String message)
    : super(message, 'Error During Communication: ');
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends ApiException {
  UnauthorisedException(String message) : super(message, 'Unauthorised: ');
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 'Forbidden: ');
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 'Not Found: ');
}

class InternalServerErrorException extends ApiException {
  InternalServerErrorException(String message)
    : super(message, 'Internal Server: ');
}

class UnprocessableEntityException extends ApiException {
  UnprocessableEntityException(String message)
    : super(message, 'Unprocessable Content: ');
}

class InvalidInputException extends ApiException {
  InvalidInputException(String message) : super(message, 'Invalid Input: ');
}
