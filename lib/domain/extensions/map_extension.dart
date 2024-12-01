extension MapExtension<K, T> on Map<K, T> {
  Map<K, T> updateAndReturn(K key, Function(T) update) {
    final newMap = Map<K, T>.from(this);
    newMap[key] = update(newMap[key] as T);
    return newMap;
  }
}