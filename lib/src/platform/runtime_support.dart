import 'runtime_support_stub.dart'
    if (dart.library.io) 'runtime_support_native.dart'
    if (dart.library.js_interop) 'runtime_support_web.dart'
    as impl;

bool get isWebRuntime => impl.isWebRuntime;
bool get isDesktopRuntime => impl.isDesktopRuntime;
bool get isMobileRuntime => impl.isMobileRuntime;

Future<void> configurePlatformServices() => impl.configurePlatformServices();

void setupPlatformWindow() => impl.setupPlatformWindow();
