import Foundation
import FoundationNetworking

class HttpJsonApiClient {
  func post(url urlString: String, json: [String: String]) -> Any {
    let url = URL(string: urlString)!
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
    let sem = DispatchSemaphore.init(value: 0)
    var result: Any? = nil
    let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
      defer { sem.signal() }

      if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        result = json
      }
    }

    task.resume()
    sem.wait()

    return result!
  }
}

func renderFoo(org: FooComponent_Org) {
  print(org)
}

func renderBar(org: BarComponent_Org) {
  print(org)
}

let client = HttpJsonApiClient()
if let result = client.post(
    url: "http://localhost:4000/graphql",
    json: [
      "query": AppQuery.operationDefinition
    ]
  ) as? [String: Any] {
  let result = AppQuery(json: result)
  print(result.data as Any)
  print(result.errors as Any)
  if let data = result.data {
    for org in data.organizations {
      renderFoo(org: org)
      renderBar(org: org)
    }
  }
}
