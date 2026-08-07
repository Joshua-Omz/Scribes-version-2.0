import 'share_unsupported.dart'
    if (dart.library.ffi) 'share_native.dart'
    if (dart.library.html) 'share_web.dart';

final shareService = getShareService();
