import Combine
import Foundation

/*
 1. Publishers:
 - defines how values and errors arte produced
 - value type
 - allows registration of a `Subscriber`
 
 
 [Publisher]        [Subscriber]
 
 Subscriber is attached to Publisher:
            <===    subscribe(Subscriber)
 
 Publisher sends a Subscription:
            ===>    receive(subscription:)
 
 Subscriber requests N values
            <===    request(_ : Demand)
 
 Publisher sends N values or less
            ===>    receive(: Input)
            ===>    receive(: Input)
 
 Publisher sends completion (or error)
            ===>    receive(completion:)
 
 
 2. Operators:
 - adopts `Publisher`
 - describe a behavior for changing values
 - subscribes to a Publisher (upstream)
 - sends result to a Subscriber (downstream)
 - value type
 */


/*
 Using an Published and Subscriber
 */

struct BasicsSample {
    
    class Wizard {
        var grade: Int = 0
    }
    
    static func imperativeSample() {
        let merlin = Wizard()
        merlin.grade = 5
        
        let graduationPublisher = NotificationCenter.Publisher(center: .default, name: Notification.Name(rawValue: "graduated"), object: merlin)
        
        let gradeSubscriber = Subscribers.Assign(object: merlin, keyPath: \.grade)
        
        let converter = Publishers.Map(upstream: graduationPublisher) { note in
            return note.userInfo?["NewGrade"] as? Int ?? 0
        }
        
        converter.subscribe(gradeSubscriber)
    }
    
    static func fluentSample() {
        let merlin = Wizard()
        merlin.grade = 5
        
        let cancellable = NotificationCenter.default.publisher(for: Notification.Name(rawValue: "graduated"), object: merlin)
            .map { note in
                return note.userInfo?["NewGrade"] as? Int ?? 0
            }
            .assign(to: \.grade, on: merlin)
    }
    
    static func enrichedSample() {
        let merlin = Wizard()
        merlin.grade = 5
        
        let cancellable = NotificationCenter.default.publisher(for: Notification.Name(rawValue: "graduated"), object: merlin)
            .compactMap { note in
                return note.userInfo?["NewGrade"] as? Int
            }
            .filter { $0 >= 5 }
            .prefix(3)
            .assign(to: \.grade, on: merlin)
        
    }
}


/*
 Combining operators
 
 1. Zip
 - convenrts seveal inputs int a single tuple
 - A "when/and" operation
 - requires input from all proceed
 
 [Publisher] ===>
 
 [Publisher] ===> [Zip] ===> [Subscriber]
 
 [Publisher] ===>
 
 
 2. Combine Latest
 - converts sevaral inputs into a single value
 - A "when/or" operator
 - requires input from any to proceed
 - stores last value
 
 [Publisher] ===>
 
 [Publisher] ===> [CombineLatest] ===> [Subscriber]
 
 [Publisher] ===>
 
 */

class CombiningOperatorsSample {
    class ContinueButton {
        var isEnabled: Bool = false
    }
    
    static func zipSample() {
        let continueButton = ContinueButton()
        
        let organizing = CurrentValueSubject<Bool, Never>(false)
        let decomposing = CurrentValueSubject<Bool, Never>(false)
        let arranging = CurrentValueSubject<Bool, Never>(false)
        
        Publishers.Zip3(organizing, decomposing, arranging)
            .map { $0 && $1 && $2 }
            .assign(to: \.isEnabled, on: continueButton)
    }
    
    static func combineLatestSample() {
        let continueButton = ContinueButton()
        
        let read = CurrentValueSubject<Bool, Never>(false)
        let practiced = CurrentValueSubject<Bool, Never>(false)
        let approved = CurrentValueSubject<Bool, Never>(false)
        
        Publishers.CombineLatest3(read, practiced, approved)
            .map { $0 && $1 && $2 }
            .assign(to: \.isEnabled, on: continueButton)
    }
}
