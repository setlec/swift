// RUN: %target-swift-frontend %use_no_opaque_pointers %s -emit-ir -g -o - | %FileCheck %s
// RUN: %target-swift-frontend %s -emit-ir -g -o -
public class ClosureMaker {
    var a : Int

    init (a : Int) { self.a = a }

    public func getClosure() -> (() -> Int) {
        return { [weak self] () -> Int in
          if let _self = self {
                return _self.a
            } else {
                return 0
            }
        }
    }
}

// CHECK: define {{.*}} @"$s4main12ClosureMakerC03getB0SiycyFSiycfU_"
// CHECK: call void @llvm.dbg.declare(metadata %swift.weak** %{{.*}} !DIExpression(DW_OP_deref)),
