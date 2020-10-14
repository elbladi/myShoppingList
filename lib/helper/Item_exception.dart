class NewItemException implements Exception {
  String message;

  NewItemException(this.message);

  String getMessage() => this.message;
}