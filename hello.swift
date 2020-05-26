import Foundation
import FoundationNetworking

let session = URLSession.shared
let url = URL(string: "https://swapi.graph.cool/graphql")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
let json = [
  "query": "{ allFilms { title } }"
]
let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
let sem = DispatchSemaphore.init(value: 0)

let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
  defer { sem.signal() }

  if let data = data, let dataString = String(data: data, encoding: .utf8) {
    print(dataString)
  }
}

task.resume()
sem.wait()
