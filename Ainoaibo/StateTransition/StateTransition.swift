open class StateTransitionBehavior<State> {
    public enum TransitionRuleResult {
        case allow
        case reject
        case notApplicable
    }

    public init() {}

    open func checkTransition(from: State, to: State) -> TransitionRuleResult { return .notApplicable }
    open func preTransition(from: State, to: State) {}
    open func postTransition(from: State, to: State) {}
}
