class AppQuery: Decodable {
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

  private enum CodingKeys: String, CodingKey {
    case data
    case errors
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.data = try container.decode(Data.self, forKey: .data)
    self.errors = try container.decodeIfPresent(Errors.self, forKey: .errors)
  }


  struct Data: Decodable {
    let organizations: [Internal_1_Organizations]
    let nestedOrganizations: [[[Internal_2_Nestedorganizations]?]?]
    let outerAndInnerNullableOrganizations: [Internal_3_Outerandinnernullableorganizations?]?
    let outerAndInnerNullableOrganizations2: [Internal_4_Outerandinnernullableorganizations2?]?
    let outerNullableOrganizations: [Internal_5_Outernullableorganizations]?
    let outerNullableOrganizations2: [Internal_6_Outernullableorganizations2]?
    let innerNullableOrganizations: [Internal_7_Innernullableorganizations?]
    let nullableOrganization: Internal_8_Nullableorganization?
    let organization: Internal_9_Organization

    private enum CodingKeys: String, CodingKey {
      case organizations
      case nestedOrganizations
      case outerAndInnerNullableOrganizations
      case outerAndInnerNullableOrganizations2
      case outerNullableOrganizations
      case outerNullableOrganizations2
      case innerNullableOrganizations
      case nullableOrganization
      case organization
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      self.organizations = try container.decode([Internal_1_Organizations].self, forKey: .organizations)
      self.nestedOrganizations = try container.decode([[[Internal_2_Nestedorganizations]?]?].self, forKey: .nestedOrganizations)
      self.outerAndInnerNullableOrganizations = try container.decode([Internal_3_Outerandinnernullableorganizations?]?.self, forKey: .outerAndInnerNullableOrganizations)
      self.outerAndInnerNullableOrganizations2 = try container.decode([Internal_4_Outerandinnernullableorganizations2?]?.self, forKey: .outerAndInnerNullableOrganizations2)
      self.outerNullableOrganizations = try container.decode([Internal_5_Outernullableorganizations]?.self, forKey: .outerNullableOrganizations)
      self.outerNullableOrganizations2 = try container.decode([Internal_6_Outernullableorganizations2]?.self, forKey: .outerNullableOrganizations2)
      self.innerNullableOrganizations = try container.decode([Internal_7_Innernullableorganizations?].self, forKey: .innerNullableOrganizations)
      self.nullableOrganization = try container.decode(Internal_8_Nullableorganization?.self, forKey: .nullableOrganization)
      self.organization = try container.decode(Internal_9_Organization.self, forKey: .organization)
    }
  }

  struct Errors: Decodable {
    init(from decoder: Decoder) throws {
      // TODO
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


struct Internal_1_Organizations: Decodable, FooComponent_Org, BarComponent_Org {
  let int: Int32
  let float: Float
  let boolean: Bool
  let id: String
  let name: String

  private enum CodingKeys: String, CodingKey {
    case int
    case float
    case boolean
    case id
    case name
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
  }
}


struct Internal_2_Nestedorganizations: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_3_Outerandinnernullableorganizations: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_4_Outerandinnernullableorganizations2: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_5_Outernullableorganizations: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_6_Outernullableorganizations2: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_7_Innernullableorganizations: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_8_Nullableorganization: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}


struct Internal_9_Organization: Decodable, AllOrgFields {
  let id: String
  let name: String
  let int: Int32
  let float: Float
  let boolean: Bool

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case int
    case float
    case boolean
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.int = try container.decode(Int32.self, forKey: .int)
    self.float = try container.decode(Float.self, forKey: .float)
    self.boolean = try container.decode(Bool.self, forKey: .boolean)
  }
}
