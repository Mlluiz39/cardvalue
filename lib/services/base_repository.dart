abstract class BaseRepository<T> {
  Future<T> getById(String id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(String id);
}
