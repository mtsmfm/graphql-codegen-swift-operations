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
      nestedOrganizations {
        ...AllOrgFields
      }
      outerAndInnerNullableOrganizations {
        ...AllOrgFields
      }
      outerAndInnerNullableOrganizations2 {
        ...AllOrgFields
      }
      outerNullableOrganizations {
        ...AllOrgFields
      }
      outerNullableOrganizations2 {
        ...AllOrgFields
      }
      innerNullableOrganizations {
        ...AllOrgFields
      }
      nullableOrganization(id: "a") {
        ...AllOrgFields
      }
      organization(id: "a") {
        ...AllOrgFields
      }
    }

    fragment FooComponent_Org on Organization {
      id
    }

    fragment BarComponent_Org on Organization {
      name
    }

    fragment AllOrgFields on Organization {
      id
      name
      int
      float
      boolean
    }
    """

  init(json: [String: Any]) {
    self.data = Data(json: json["data"] as Any)
    self.errors = Errors(json: json["errors"] as Any)
  }

  struct Data {
    let organizations: [Internal_1_Organizations]
    let nestedOrganizations: [[[Internal_2_Nestedorganizations]?]?]
    let outerAndInnerNullableOrganizations: [Internal_3_Outerandinnernullableorganizations?]?
    let outerAndInnerNullableOrganizations2: [Internal_4_Outerandinnernullableorganizations2?]?
    let outerNullableOrganizations: [Internal_5_Outernullableorganizations]?
    let outerNullableOrganizations2: [Internal_6_Outernullableorganizations2]?
    let innerNullableOrganizations: [Internal_7_Innernullableorganizations?]
    let nullableOrganization: Internal_8_Nullableorganization?
    let organization: Internal_9_Organization

    init?(json: Any?) {
      guard let json = json as? [String: Any] else {
        return nil
      }

      self.organizations = (json["organizations"] as! [Any]).map { json in
        Internal_1_Organizations(json: json)!
      }
      self.nestedOrganizations = (json["nestedOrganizations"] as! [Any]).map { json in
        (json as? [Any])?.map { json in
          (json as? [Any])?.map { json in
            Internal_2_Nestedorganizations(json: json)!
          }
        }
      }
      self.outerAndInnerNullableOrganizations = (json["outerAndInnerNullableOrganizations"] as? [Any])?.map { json in
        Internal_3_Outerandinnernullableorganizations(json: json)
      }
      self.outerAndInnerNullableOrganizations2 = (json["outerAndInnerNullableOrganizations2"] as? [Any])?.map { json in
        Internal_4_Outerandinnernullableorganizations2(json: json)
      }
      self.outerNullableOrganizations = (json["outerNullableOrganizations"] as? [Any])?.map { json in
        Internal_5_Outernullableorganizations(json: json)!
      }
      self.outerNullableOrganizations2 = (json["outerNullableOrganizations2"] as? [Any])?.map { json in
        Internal_6_Outernullableorganizations2(json: json)!
      }
      self.innerNullableOrganizations = (json["innerNullableOrganizations"] as! [Any]).map { json in
        Internal_7_Innernullableorganizations(json: json)
      }
      self.nullableOrganization = Internal_8_Nullableorganization(json: json["nullableOrganization"])
      self.organization = Internal_9_Organization(json: json["organization"])!
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

protocol AllOrgFields {
  var id: String { get }
  var name: String { get }
  var int: Int32 { get }
  var float: Float { get }
  var boolean: Bool { get }
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

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
    self.id = json["id"] as! String
    self.name = json["name"] as! String
  }
}

struct Internal_2_Nestedorganizations {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_3_Outerandinnernullableorganizations {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_4_Outerandinnernullableorganizations2 {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_5_Outernullableorganizations {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_6_Outernullableorganizations2 {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_7_Innernullableorganizations {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_8_Nullableorganization {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}

struct Internal_9_Organization {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  init?(json: Any?) {
    guard let json = json as? [String: Any] else {
      return nil
    }

    self.id = json["id"] as! String
    self.name = json["name"] as! String
    self.int = json["int"] as! Int32
    self.float = json["float"] as! Float
    self.boolean = json["boolean"] as! Bool
  }
}
