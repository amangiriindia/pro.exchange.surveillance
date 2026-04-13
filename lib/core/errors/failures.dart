import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
    : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
    : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
    : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class NoDataFailure extends Failure {
  const NoDataFailure([String message = 'No data available']) : super(message);
}

class UndoRedoFailure extends Failure {
  const UndoRedoFailure(String message) : super(message);
}

class ExportFailure extends Failure {
  const ExportFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred'])
    : super(message);
}
