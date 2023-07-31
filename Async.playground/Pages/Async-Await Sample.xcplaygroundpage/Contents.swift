import _Concurrency
import Foundation
import PlaygroundSupport

func sampleFunc() async {
    print("sampleFunc")
    try? await Task.sleep(nanoseconds: 1_000_000_000)
}

Task {
    await sampleFunc()
    print("done")
    PlaygroundPage.current.finishExecution()
}

PlaygroundPage.current.needsIndefiniteExecution = true
