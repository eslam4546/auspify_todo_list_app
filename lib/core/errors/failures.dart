import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A local database error occurred.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid task input data.']);
}
