export 'bible_local_datasource_interface.dart';
export 'bible_local_datasource_web.dart'
    if (dart.library.io) 'bible_local_datasource_native.dart';
