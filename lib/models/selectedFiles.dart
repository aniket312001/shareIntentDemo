import 'fileTypeEnum.dart';

class SelectedFile {
  final String name;
  String path;
  final FileType2 type;

  SelectedFile({
    required this.name,
    required this.path,
    required this.type,
  });
}
