import SwiftState

typealias TBStateMachine = StateMachine<TBStateMachineStates, TBStateMachineEvents>

enum TBStateMachineEvents: EventType {
    case startStop, timerFired, skipRest, skipWork
}

enum TBStateMachineStates: StateType {
    case idle, work, rest
}
