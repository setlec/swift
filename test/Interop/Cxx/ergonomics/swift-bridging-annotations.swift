// RUN: rm -rf %t
// RUN: split-file %s %t

// RUN: %target-swift-frontend %t/SwiftMod.swift -module-name SwiftMod -emit-module -o %t/SwiftMod.swiftmodule -I %t -enable-experimental-cxx-interop -Xcc -DFIRSTPASS

// RUN: %target-swift-ide-test -print-module -module-to-print=SwiftMod -module-to-print=CxxModule -I %t -I %t/Inputs -I %swift_src_root/lib/ClangImporter -source-filename=x -enable-experimental-cxx-interop | %FileCheck %s

// RUN: %target-swift-ide-test -print-module -module-to-print=SwiftMod -module-to-print=CxxModule -I %t -I %t/Inputs -I %swift_src_root/lib/ClangImporter -source-filename=x -enable-experimental-cxx-interop -Xcc -DINCMOD | %FileCheck %s

//--- SwiftMod.swift

public protocol Proto {
}

//--- Inputs/module.modulemap
module CxxModule {
    header "header.h"
    requires cplusplus
}

//--- Inputs/header.h

// Note: in actuality, this will be included
// as <swift/bridging>, but in this test we include
// it directly.
#ifndef INCMOD
#include "bridging"
#else
#pragma clang module import SwiftBridging
#endif

class SELF_CONTAINED SelfContained {
public:
    int *pointer;

    SelfContained();

    const int *returnsIndependent() const RETURNS_INDEPENDENT_VALUE;
};

class SHARED_REFERENCE(retainSharedObject, releaseSharedObject)
SharedObject {
public:
    static SharedObject *create();
};

void retainSharedObject(SharedObject *);
void releaseSharedObject(SharedObject *);

class IMMORTAL_REFERENCE LoggerSingleton {
public:
    LoggerSingleton(const LoggerSingleton &) = delete;
    static LoggerSingleton *getInstance();
};

class UNSAFE_REFERENCE UnsafeNonCopyable {
public:
    UnsafeNonCopyable(UnsafeNonCopyable &) = delete;
};

UnsafeNonCopyable *returnsPointerToUnsafeReference();
void takesPointerToUnsafeNonCopyable(UnsafeNonCopyable *);

class CONFORMS_TO_PROTOCOL(SwiftMod.Proto) ConformsTo {
public:
};


// CHECK: struct SelfContained {

// CHECK:   func returnsIndependent() -> UnsafePointer<Int32>!

// CHECK: class SharedObject {
// CHECK:   class func create() -> SharedObject!
// CHECK: func retainSharedObject(_: SharedObject!)
// CHECK: func releaseSharedObject(_: SharedObject!)

// CHECK: class LoggerSingleton {
// CHECK:   class func getInstance() -> LoggerSingleton!
// CHECK: }

// CHECK: class UnsafeNonCopyable {
// CHECK: }
// CHECK: func returnsPointerToUnsafeReference() -> UnsafeNonCopyable!
// CHECK: func takesPointerToUnsafeNonCopyable(_: UnsafeNonCopyable!)

// CHECK: struct ConformsTo : Proto {

