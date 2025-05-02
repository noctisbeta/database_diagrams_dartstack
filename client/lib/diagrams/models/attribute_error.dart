import 'package:meta/meta.dart';

@immutable
final class AttributeError {
  const AttributeError({
    required this.order,
    required this.nameError,
    required this.typeError,
  });

  const AttributeError.empty()
    : order = null,
      nameError = null,
      typeError = null;

  final int? order;
  final String? nameError;
  final String? typeError;

  AttributeError copyWith({
    int? Function()? orderFn,
    String? Function()? nameErrorFn,
    String? Function()? typeErrorFn,
  }) => AttributeError(
    order: orderFn != null ? orderFn() : order,
    nameError: nameErrorFn != null ? nameErrorFn() : nameError,
    typeError: typeErrorFn != null ? typeErrorFn() : typeError,
  );
}
