class AppQuery {
  let data: Data?;
  let errors: Errors?;
  public static let operationDefinition: String =
    """
    query AppQuery {
      organizations {
        int
        float
        boolean
        ...FooComponent_Org
        ...BarComponent_Org
      }
    }

    fragment FooComponent_Org on Organization {
      id
    }

    fragment BarComponent_Org on Organization {
      name
    }
    """

  init(json: [String: Any]) {
    self.data = Data(json: json["data"] as Any)
    self.errors = Errors(json: json["errors"] as Any)
  }

  struct Data {
    let organizations: [Internal_1_Organizations]

    init?(json: Any) {
      guard let data = json as? [String: Any] else {
        return nil
      }

      self.organizations = (data["organizations"] as! [[String: Any]]).map { Internal_1_Organizations(json: $0)! }
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

protocol FooComponent_Org {
  var id: String { get }
}

protocol BarComponent_Org {
  var name: String { get }
}

struct Internal_1_Organizations: FooComponent_Org, BarComponent_Org {
  let int: Int32
  let float: Float
  let boolean: Bool
  let id: String
  let name: String

  init?(json: Any) {
    guard let data = json as? [String: Any] else {
      return nil
    }

    self.int = data["int"] as! Int32
    self.float = data["float"] as! Float
    self.boolean = data["boolean"] as! Bool
    self.id = data["id"] as! String
    self.name = data["name"] as! String
  }
}
