import Foundation
import FoundationNetworking

protocol FooComponent_Film {
  var title: String { get }
}

protocol BarComponent_Film {
  var director: String { get }
}

class AppQuery {
  let data: Data?;
  let errors: Errors?;

  public static let operationDefinition: String =
    """
      query AppQuery {
        allFilms {
          ...FooComponent_Film
          ...BarComponent_Film
        }
      }

      fragment FooComponent_Film on Film {
        title
      }

      fragment BarComponent_Film on Film {
        director
      }
    """

  init(json: [String: Any]) {
    self.data = Data(json: json["data"] as Any)
    self.errors = Errors(json: json["errors"] as Any)
  }

  struct Data {
    let allFilms: [Internal_AllFilmsElement]

    init?(json: Any) {
      guard let data = json as? [String: Any] else {
        return nil
      }

      self.allFilms = (data["allFilms"] as! [[String: Any]]).map { Internal_AllFilmsElement(json: $0)! }
    }
  }

  struct Internal_AllFilmsElement: FooComponent_Film, BarComponent_Film {
    let title: String
    let director: String

    init?(json: Any) {
      guard let json = json as? [String: Any] else {
        return nil
      }

      self.title = json["title"] as! String
      self.director = json["director"] as! String
    }
  }

  struct Errors {
    let json: Any

    init?(json: Any) {
      guard let errors = json as? [String: Any] else {
        return nil
      }

      self.json = errors
    }
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

func renderFoo(film: FooComponent_Film) {
  print(film)
}

func renderBar(film: BarComponent_Film) {
  print(film)
}

let client = HttpJsonApiClient()
if let result = client.post(
    url: "https://swapi.graph.cool/graphql",
    json: [
      "query": AppQuery.operationDefinition
    ]
  ) as? [String: Any] {
  let result = AppQuery(json: result)
  print(result.data as Any)
  print(result.errors as Any)
  if let data = result.data {
    for film in data.allFilms {
      renderFoo(film: film)
      renderBar(film: film)
    }
  }
}
