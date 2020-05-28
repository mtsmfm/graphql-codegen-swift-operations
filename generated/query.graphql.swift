// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AppQueryQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query AppQuery {
      allFilms {
        __typename
        title
      }
    }
    """

  public let operationName: String = "AppQuery"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("allFilms", type: .nonNull(.list(.nonNull(.object(AllFilm.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(allFilms: [AllFilm]) {
      self.init(unsafeResultMap: ["__typename": "Query", "allFilms": allFilms.map { (value: AllFilm) -> ResultMap in value.resultMap }])
    }

    public var allFilms: [AllFilm] {
      get {
        return (resultMap["allFilms"] as! [ResultMap]).map { (value: ResultMap) -> AllFilm in AllFilm(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: AllFilm) -> ResultMap in value.resultMap }, forKey: "allFilms")
      }
    }

    public struct AllFilm: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Film"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(title: String) {
        self.init(unsafeResultMap: ["__typename": "Film", "title": title])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The title of this film
      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }
    }
  }
}
