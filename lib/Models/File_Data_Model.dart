class File_Data_Model {
  final String name;
  final String mime;
  final int byteSize;
  final String? url;

  File_Data_Model({
    required this.name,
    required this.mime,
    required this.byteSize,
    this.url,
  });

  String get size {
    final kb = byteSize / 1024;
    final mb = kb / 1024;

    return mb > 1
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
  }
}
