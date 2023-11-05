import Foundation

struct PageResult<Data> {
    let data: Data
    let nextOffset: PageOffset
}
