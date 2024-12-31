import "dart:io";
import "dart:ffi";
import "package:ffi/ffi.dart";
import "package:win32/win32.dart";

const win8Version = 0x0602;

bool isWindows8OrGreater() => IsWindowsVersionOrGreater(
  HIBYTE(win8Version),
  LOBYTE(win8Version),
  0,
) == 1;

typedef NativeGetPackageName = Uint32 Function(Pointer<Uint32>, Pointer<Utf16>);
typedef DartGetPackageName = int Function(Pointer<Uint32>, Pointer<Utf16>);

extension on DynamicLibrary {
  int getCurrentPackageName(Pointer<Uint32> length, Pointer<Utf16> buffer) =>
    lookupFunction<NativeGetPackageName, DartGetPackageName>('GetCurrentPackageFullName')(length, buffer);
}

bool checkPackageIdentity() => using((arena) {
  if (!Platform.isWindows) return false;
  if (!isWindows8OrGreater()) return false;
  final lib = DynamicLibrary.open('kernel32.dll');
  final length = arena<Uint32>();
  final error = lib.getCurrentPackageName(length, nullptr);
  final result = error != WIN32_ERROR.APPMODEL_ERROR_NO_PACKAGE;
  lib.close();
  return result;
});
