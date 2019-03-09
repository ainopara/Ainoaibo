
/// Edit an immutable struct and create a new struct.
///
/// - Sources:
/// [Let's Talk About Let](https://www.youtube.com/watch?v=jzdOkQFekbg)
///
/// - Examples:
/// ```swift
/// let rect = mutate(view.bounds) { (value: inout CGRect) in
///     value.origin.y += 20.0
///     value.size.height -= 20.0
/// }
/// ```
public func mutate<T>(_ value: T, change: (inout T) -> Void) -> T {
    var copy = value
    change(&copy)
    return copy
}
