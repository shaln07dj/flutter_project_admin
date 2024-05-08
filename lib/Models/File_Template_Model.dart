import 'dart:typed_data';

class File_Template_Model {
  final String name;
  final String mime;
  final int byteSize;
  final Uint8List? bytes;
  final String? url;
  final String? filePath;
  final file;

  File_Template_Model({
    required this.name,
    required this.mime,
    required this.byteSize,
    this.bytes,
    this.url,
    this.filePath,
    this.file,
  });

  String get size {
    final kb = byteSize / 1024;
    final mb = kb / 1024;

    return mb > 1
        ? '${mb.toStringAsFixed(2)} MB'
        : '${kb.toStringAsFixed(2)} KB';
  }
}
