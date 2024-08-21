extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> updateAndReturn(K key, V value) {
    final newMap = Map.of(this);
    newMap[key] = value;
    return newMap;
  }
}