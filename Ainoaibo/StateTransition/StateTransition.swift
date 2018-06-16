open class StateTransitionBehavior<ViewModel: AnyObject, State, Action> {
    public weak var viewModel: ViewModel?

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public init() {}

    open func preTransition(action: Action, from: State, to: State) {}
    open func postTransition(action: Action, from: State, to: State) {}
}
