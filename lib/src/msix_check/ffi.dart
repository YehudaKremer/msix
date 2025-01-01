import "dart:io";
import "dart:ffi";
import "package:ffi/ffi.dart";
import "package:win32/win32.dart";

bool isWindows8OrGreater() => IsWindows8OrGreater() == 1;

bool checkPackageIdentity() => using((arena) {
  if (!Platform.isWindows) return false;
  if (!isWindows8OrGreater()) return false;
  final length = arena<Uint32>();
  final error = GetCurrentPackageFullName(length, nullptr);
  return error != WIN32_ERROR.APPMODEL_ERROR_NO_PACKAGE;
});
