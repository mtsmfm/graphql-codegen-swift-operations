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
    let allFilms: [Internal_1_Allfilms]

    init?(json: Any) {
      guard let data = json as? [String: Any] else {
        return nil
      }

      self.allFilms = (data["allFilms"] as! [[String: Any]]).map { Internal_1_Allfilms(json: $0)! }
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

protocol FooComponent_Film {
  var title: String { get }
}

protocol BarComponent_Film {
  var director: String? { get }
}

struct Internal_1_Allfilms: FooComponent_Film, BarComponent_Film {
  let title: String
  let director: String?

  init?(json: Any) {
    guard let data = json as? [String: Any] else {
      return nil
    }

    self.title = data["title"] as! String
    self.director = data["director"] as? String
  }
}
