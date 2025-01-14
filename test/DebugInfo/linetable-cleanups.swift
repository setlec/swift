// RUN: %target-swift-frontend %use_no_opaque_pointers %s -emit-ir -g -o - | %FileCheck %s
// RUN: %target-swift-frontend %s -emit-ir -g -o -

// TODO: check why this is failing on linux
// REQUIRES: OS=macosx

func markUsed<T>(_ t: T) {}

class Person {
    var name = "No Name"
    var age = 0
}

func main() {
    var person = Person()
    var b = [0,1,13]
    for element in b {
        markUsed("element = \(element)")
    }
    markUsed("Done with the for loop")
// CHECK: call {{.*}}void @"$s4main8markUsedyyxlF"
// CHECK: br label
// CHECK: {{[0-9]+}}:
// CHECK: call %Ts16IndexingIteratorVySaySiGG* @"$ss16IndexingIteratorVySaySiGGWOh"(%Ts16IndexingIteratorVySaySiGG* %{{.*}}), !dbg ![[LOOPHEADER_LOC:.*]]
// CHECK: call {{.*}}void @"$s4main8markUsedyyxlF"
// The cleanups should share the line number with the ret stmt.
// CHECK:  call %TSa* @"$sSaySiGWOh"(%TSa* %{{.*}}), !dbg ![[CLEANUPS:.*]]
// CHECK-NEXT:  !dbg ![[CLEANUPS]]
// CHECK-NEXT:  llvm.lifetime.end
// CHECK-NEXT:  load
// CHECK-NEXT:  swift_release
// CHECK-NEXT:  bitcast
// CHECK-NEXT:  llvm.lifetime.end
// CHECK-NEXT:  ret void, !dbg ![[CLEANUPS]]
// CHECK: ![[CLEANUPS]] = !DILocation(line: [[@LINE+1]], column: 1,
}
main()
