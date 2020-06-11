import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HttpJsonApiClient {
  func post(url urlString: String, json: [String: String]) -> Result<[String: Any]?, Error> {
    let url = URL(string: urlString)!
    let session = URLSession.shared
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
    let sem = DispatchSemaphore.init(value: 0)
    var result: Result<[String: Any]?, Error>!
    let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
      defer { sem.signal() }

      result = Result {
        if let error = error {
            throw error
        }
        return try data.flatMap{ try JSONSerialization.jsonObject(with: $0) as? [String: Any] }
      }
    }

    task.resume()
    sem.wait()

    return result
  }
}

func renderFoo(org: FooComponent_Org) {
  print(org)
}

func renderBar(org: BarComponent_Org) {
  print(org)
}

let client = HttpJsonApiClient()
if case .success(let result?) = client.post(
    url: "http://localhost:4000/graphql",
    json: [
      "query": AppQuery.operationDefinition
    ]
  ) {
  let result = AppQuery(json: result)
  print(result.data as Any)
  print(result.errors as Any)
  if let data = result.data {
    for org in data.organizations {
      renderFoo(org: org)
      renderBar(org: org)
    }
    for org in data.nestedOrganizations {
      print(org as Any)
    }
  }
}
