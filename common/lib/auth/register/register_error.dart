enum RegisterError {
  emailAlreadyTaken,
  unknownRegisterError;

  factory RegisterError.fromString(String name) {
    switch (name) {
      case 'emailAlreadyTaken':
        return RegisterError.emailAlreadyTaken;
      case 'unknownRegisterError':
        return RegisterError.unknownRegisterError;
      default:
        throw ArgumentError('Invalid RegisterError: $name');
    }
  }

  @override
  String toString() => switch (this) {
    RegisterError.emailAlreadyTaken => 'emailAlreadyTaken',
    RegisterError.unknownRegisterError => 'unknownRegisterError',
  };
}
