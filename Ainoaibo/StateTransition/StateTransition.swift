
public enum StateTransitionRuleResult {
    case allow
    case reject
    case notApplicable
}

open class StateTransitionBehavior<ViewModel: AnyObject, State, Action> {
    public weak var viewModel: ViewModel?

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public init() {}

    open func checkTransition(action: Action, from: State, to: State) -> StateTransitionRuleResult { return .notApplicable }
    open func preTransition(action: Action, from: State, to: State) {}
    open func postTransition(action: Action, from: State, to: State) {}
}
