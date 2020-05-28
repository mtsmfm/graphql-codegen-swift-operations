import Foundation
import FoundationNetworking

struct Film {
  let title: String
}

struct Query {
  let allFilms: Array<Film>
}

extension Film {
  init?(json: [String: Any]) {
    guard let title = json["title"] as? String else {
      return nil
    }

    self.title = title
  }
}

extension Query {
  init?(json: [String: Any]) {
    var allFilms: Array<Film> = []
    guard let allFilmsJSON = json["allFilms"] as? [[String: Any]] else {
      return nil
    }

    for filmJSON in allFilmsJSON {
      guard let film = Film(json: filmJSON) else {
        return nil
      }

      allFilms.append(film)
    }

    self.allFilms = allFilms
  }
}

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

let client = HttpJsonApiClient()
if (
  let data = client.post(
    url: "https://swapi.graph.cool/graphql",
    json: [
      "query": "{ allFilms { title } }"
    ]
  )["data"] as? [String: Any]
let result = Query(json: data)
print(result)
