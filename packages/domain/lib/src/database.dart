/// The interface for accessing the database.
abstract class Database {
  const Database._();

  /// Opens the database. Must be called before accessing any repositories.
  Future<void> open();

  /// Closes the database.
  Future<void> close();
}
