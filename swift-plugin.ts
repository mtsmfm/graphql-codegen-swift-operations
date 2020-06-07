import {
  isListType, print, TypeInfo, visitWithTypeInfo, visit, concatAST, getNamedType,
  FragmentDefinitionNode, OperationDefinitionNode, FragmentSpreadNode,
  InlineFragmentNode, isNonNullType, GraphQLOutputType
} from 'graphql';
import { PluginFunction } from '@graphql-codegen/plugin-helpers';

type Selection = FragmentSpreadNode | InlineFragmentNode | Property

interface SelectionSetData {
  id: number;
  name: string
  type: GraphQLOutputType
  selections: Selection[]
}

interface OperationData {
  name: string
  definition: string
  selections: Selection[]
}

interface FragmentData {
  name: string
  selections: Selection[]
}

interface Property {
  name: string
  type: GraphQLOutputType
  selectionSetId: SelectionSetData['id'] | undefined
  kind?: undefined;
}

interface ScalarMap {
  [name: string]: string | undefined
}

const capitalize = (str: string) => {
  return `${str.slice(0, 1).toUpperCase()}${str.slice(1).toLowerCase()}`
}

const toSwiftStructName = ({ id, name }: Pick<SelectionSetData, 'id' | 'name'>) => {
  return `Internal_${id}_${capitalize(name)}`;
}

const indentMultiline = (lines: string, indent: number) => {
  return lines.split("\n").map(l => l.length === 0 ? "" : Array.from({ length: indent }).map(() => "  ").join("") + l).join("\n");
}

const toSwiftProperties = (selections: Selection[], fragments: FragmentData[], scalarMap: ScalarMap, selectionSets: SelectionSetData[]) => {
  return selections.reduce((ary, selection) => {
    switch (selection.kind) {
      case "FragmentSpread":
        const f = fragments.find(f => f.name === selection.name.value)!
        return [...ary, ...(f.selections.filter(s => !s.kind) as Property[])]
      case "InlineFragment":
        throw "TODO: InlineFragment"
      case undefined:
        return [...ary, selection]
    }
  }, [] as Property[]).map(({ type, name, selectionSetId }) => {
    const ofType = (isListType(type) || isNonNullType(type)) && type.ofType;
    const isList = isListType(type) || isListType(ofType);
    const isNonNull = isNonNullType(type) || isNonNullType(ofType);
    const typeName = getNamedType(type).name;

    let swiftType: string;
    let swiftPrimitive = false;

    if (selectionSetId) {
      const selectionSet = selectionSets.find(s => s.id === selectionSetId)!
      swiftType = toSwiftStructName(selectionSet);
    } else {
      if (!scalarMap[typeName]) {
        throw `Swift type for ${typeName} is not defined`;
      }

      swiftType = scalarMap[typeName]!;
      swiftPrimitive = true;
    }

    return { name, swiftType, swiftPrimitive, isList, isNonNull }
  });
}

export const plugin: PluginFunction = async (
  schema,
  documents
) => {
  const typeInfo = new TypeInfo(schema);
  const allAst = concatAST(documents.filter(v => v.document).map(v => v.document!));
  const allFragments = allAst.definitions.filter(d => d.kind === 'FragmentDefinition') as FragmentDefinitionNode[];
  const scalarMap: ScalarMap = {
    ID: "String",
    String: "String",
  }

  const selectionSets: SelectionSetData[] = [];
  const operations: OperationData[] = [];
  const fragments: FragmentData[] = [];

  let currentOperation: OperationDefinitionNode;
  const usingFragments = new Set<FragmentDefinitionNode>();

  const visitor = visitWithTypeInfo(typeInfo, {
    OperationDefinition: {
      enter: (node, _key, _parent, _path, _ancestors) => {
        currentOperation = node;
      },
      leave: (node, _key, _parent, _path, _ancestors) => {
        const name = node.name?.value;
        const definition = [currentOperation, ...usingFragments].map(print).join("\n\n");

        if (!name) {
          throw `${definition} must have operation name`
        }

        usingFragments.clear();

        operations.push({
          name,
          definition,
          selections: node.selectionSet.selections as any
        })
      },
    },
    FragmentDefinition: {
      leave: (node, _key, _parent, _path, _ancestors) => {
        const name = node.name.value;

        fragments.push({
          name,
          selections: node.selectionSet.selections as any
        });
      },
    },
    FragmentSpread: {
      leave: (node, _key, _parent, _path, _ancestors) => {
        const fragment = allFragments.find(f => f.name.value === node.name.value)!
        usingFragments.add(fragment);
      }
    },
    Field: {
      leave: (node, _key, _parent, _path, _ancestors) => {
        const type = typeInfo.getFieldDef().type;
        const name = node.name.value;
        let selectionSetId;

        if (node.selectionSet) {
          selectionSetId = selectionSets.length + 1;

          selectionSets.push({
            id: selectionSetId,
            name,
            type,
            selections: node.selectionSet.selections as any
          });
        }

        return { name, type, selectionSetId } as Property
      },
    }
  });

  visit(allAst, visitor);

  let result = '';
  result += operations.map(op => {
    const properties = toSwiftProperties(op.selections, fragments, scalarMap, selectionSets);

    return `
class ${op.name} {
  let data: Data?;
  let errors: Errors?;
  public static let operationDefinition: String =
    """
${indentMultiline(op.definition, 2)}
    """

  init(json: [String: Any]) {
    self.data = Data(json: json["data"] as Any)
    self.errors = Errors(json: json["errors"] as Any)
  }

  struct Data {
${indentMultiline(properties.map(({ name, swiftType, isList, isNonNull }) => `let ${name}: ${isList ? `[${swiftType}]` : swiftType}${isNonNull ? '' : '?'}`).join("\n"), 2)}

    init?(json: Any) {
      guard let data = json as? [String: Any] else {
        return nil
      }

${indentMultiline(properties.map(({ name, swiftType, swiftPrimitive, isList, isNonNull }) => {
      if (isList) {
        return `self.${name} = (data["${name}"] as! [[String: Any]]).map { ${swiftType}(json: $0)${isNonNull ? '!' : ''} }`;
      } else if (swiftPrimitive) {
        return `self.${name} = data["${name}"] as${isNonNull ? '!' : '?'} ${swiftType}`;
      } else {
        return `self.${name} = ${swiftType}(json: data["${name}"])${isNonNull ? '!' : ''}`;
      }
    }).join("\n"), 3)}
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
    `.trim();
  }).join("\n\n");

  result += "\n\n";

  result += fragments.map(({ name, selections }) => {
    const properties = toSwiftProperties(selections, fragments, scalarMap, selectionSets);

    return `
protocol ${name} {
${indentMultiline(properties.map(({ name, swiftType, isList, isNonNull }) => `var ${name}: ${isList ? `[${swiftType}]` : swiftType}${isNonNull ? '' : '?'} { get }`).join("\n"), 1)}
}
    `.trim();
  }).join("\n\n");

  result += "\n\n";

  result += selectionSets.map(selectionSet => {
    const { selections, id } = selectionSet;
    const properties = toSwiftProperties(selections, fragments, scalarMap, selectionSets);
    const structName = toSwiftStructName(selectionSet);
    const fragmentNames = (selections.filter(s => s.kind === 'FragmentSpread') as FragmentSpreadNode[]).map(s => s.name.value);

    return `
struct ${structName}${fragmentNames.length > 0 ? `: ${fragmentNames.join(", ")}` : ''} {
${indentMultiline(properties.map(({ name, swiftType, isList, isNonNull }) => `let ${name}: ${isList ? `[${swiftType}]` : swiftType}${isNonNull ? '' : '?'}`).join("\n"), 1)}

  init?(json: Any) {
    guard let data = json as? [String: Any] else {
      return nil
    }

${indentMultiline(properties.map(({ name, swiftType, swiftPrimitive, isList, isNonNull }) => {
      if (isList) {
        return `self.${name} = (data["${name}"] as! [[String: Any]]).map { ${swiftType}(json: $0)${isNonNull ? '!' : ''} }`;
      } else if (swiftPrimitive) {
        return `self.${name} = data["${name}"] as${isNonNull ? '!' : '?'} ${swiftType}`;
      } else {
        return `self.${name} = ${swiftType}(json: data["${name}"])`;
      }
    }).join("\n"), 2)}
  }
}
    `.trim();
  }).join("\n\n")

  result += "\n";

  return result;
};
