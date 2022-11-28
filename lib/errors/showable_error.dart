/// Showable error.
class ShowableError {
  /// Creates a new instance of [ShowableError].
  const ShowableError(this.message, this.error);

  /// Error message.
  final String message;

  /// Error.
  final dynamic error;

  @override
  String toString() => message;
}
