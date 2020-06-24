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

const getWrappingType = (type: GraphQLOutputType) => {
  const typeStack = [];
  let t = type;

  while (true) {
    if (isNonNullType(t)) {
      if (isListType(t.ofType)) {
        t = t.ofType.ofType;
        typeStack.push({ nonNull: true, list: true });
      } else {
        typeStack.push({ nonNull: true, list: false });
        break;
      }
    } else if (isListType(t)) {
      t = t.ofType;
      typeStack.push({ nonNull: false, list: true });
    } else {
      typeStack.push({ nonNull: false, list: false });
      break;
    }
  }

  return typeStack;
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
    const typeName = getNamedType(type).name;
    let swiftType: string;
    let swiftElementType: string;
    let swiftPrimitive = false;

    if (selectionSetId) {
      const selectionSet = selectionSets.find(s => s.id === selectionSetId)!

      swiftElementType = toSwiftStructName(selectionSet);
    } else {
      if (!scalarMap[typeName]) {
        throw `Swift type for ${typeName} is not defined`;
      }

      swiftElementType = scalarMap[typeName]!;
      swiftPrimitive = true;
    }

    swiftType = getWrappingType(type).reduceRight((str, { list, nonNull }) => {
      str = list ? `[${str}]` : str;
      str = nonNull ? str : `${str}?`;
      return str;
    }, swiftElementType);

    return { name, swiftType, swiftElementType, swiftPrimitive, type }
  });
}

const printStruct = (structName: string, protocols: string[], properties: ReturnType<typeof toSwiftProperties>) => {
  return `
struct ${structName}: ${["Decodable", ...protocols].join(", ")} {
${indentMultiline(properties.map(({ name, swiftType }) => `let ${name}: ${swiftType}`).join("\n"), 1)}

  private enum CodingKeys: String, CodingKey {
${indentMultiline(properties.map(({ name }) => `case ${name}`).join("\n"), 2)}
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

${indentMultiline(properties.map(({ name, swiftType }) => `self.${name} = try container.decode(${swiftType}.self, forKey: .${name})`).join("\n"), 2)}
  }
}`
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
    Int: "Int32",
    Float: "Float",
    Boolean: "Bool"
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
class ${op.name}: Decodable {
  let data: Data?;
  let errors: Errors?;
  public static let operationDefinition: String =
    """
${indentMultiline(op.definition, 2)}
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

${indentMultiline(printStruct('Data', [], properties), 1)}

  struct Errors: Decodable {
    init(from decoder: Decoder) throws {
      // TODO
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
${indentMultiline(properties.map(({ name, swiftType }) => `var ${name}: ${swiftType} { get }`).join("\n"), 1)}
}
    `.trim();
  }).join("\n\n");

  result += "\n\n";

  result += selectionSets.map(selectionSet => {
    const { selections } = selectionSet;
    const properties = toSwiftProperties(selections, fragments, scalarMap, selectionSets);
    const structName = toSwiftStructName(selectionSet);
    const fragmentNames = (selections.filter(s => s.kind === 'FragmentSpread') as FragmentSpreadNode[]).map(s => s.name.value);

    return printStruct(structName, fragmentNames, properties);
  }).join("\n\n");

  result += "\n";

  return result;
};
