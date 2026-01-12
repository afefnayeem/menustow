//
//  Helpers.swift
//  menustow
//
//  Adapted from stonerl/Ice (my-build) by @stonerl.

// MARK: - With Mutable Copy

/// Invokes the given closure with a mutable copy of the given value.
@discardableResult
func withMutableCopy<Value: Copyable, E: Error>(
    of value: Value,
    _ body: (inout Value) throws(E) -> Void
) throws(E) -> Value {
    var mutable = copy value
    try body(&mutable)
    return mutable
}
