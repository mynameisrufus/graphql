defmodule GraphQL.Type.Introspection do

  alias GraphQL.Schema
  alias GraphQL.Type.ObjectType
  alias GraphQL.Type.List
  alias GraphQL.Type.NonNull
  alias GraphQL.Type.String
  alias GraphQL.Type.Boolean

  def schema do
    %ObjectType{
      name: "__Schema",
      description:
        """
        A GraphQL Schema defines the capabilities of a GraphQL server. It
        exposes all available types and directives on the server, as well as
        the entry points for query, mutation, and subscription operations.
        """,
      fields: quote do %{
        types: %{
          description: "A list of all types supported by this server.",
          #type: %NonNull{of_type: %List{of_type: %NonNull{of_type: type}}},
          type: %String{},
          resolve: fn(schema, x, y) ->
            IO.inspect "In Resolve"
            GraphQL.Schema.reduce_types(schema.query)
          end
          # resolve(schema) {
          #   var typeMap = schema.getTypeMap();
          #   return Object.keys(typeMap).map(key => typeMap[key]);
          # }
        },
        queryType: %{
          description: "The type that query operations will be rooted at.",
          type: %NonNull{of_type: GraphQL.Type.Introspection.type},
          resolve: nil #fn(%{query: query}, _, _) -> query end
        },
        mutationType: %{
          description: "If this server supports mutation, the type that mutation operations will be rooted at.",
          type: GraphQL.Type.Introspection.type,
          resolve: nil #fn(%{mutation: mutation}, _, _) -> mutation end
        },
        subscriptionType: %{
          description: "If this server support subscription, the type that subscription operations will be rooted at.",
          type: GraphQL.Type.Introspection.type,
          resolve: nil #fn(%{subscription: subscription}, _, _) -> subscription end
        },
        directives: %{
          description: "A list of all directives supported by this server.",
          type: %NonNull{of_type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.directive}}},
          resolve: nil #schema => schema.getDirectives(),
        }
      } end
    }
  end

  def directive do
    %ObjectType{
      name: "__Directive",
      description:
        """
        A Directive provides a way to describe alternate runtime execution and
        type validation behavior in a GraphQL document.

        In some cases, you need to provide options to alter GraphQL’s
        execution behavior in ways field arguments will not suffice, such as
        conditionally including or skipping a field. Directives provide this by
        describing additional information to the executor
        """,
      fields: %{
        name: %{type: %NonNull{of_type: %String{}}},
        description: %{type: %String{}},
        args: %{
          type: %NonNull{of_type: %List{of_type: %NonNull{of_type: input_value}}},
          resolve: nil #directive => directive.args || []
        },
        onOperation: %{type: %NonNull{of_type: %Boolean{}}},
        onFragment: %{type: %NonNull{of_type: %Boolean{}}},
        onField: %{type: %NonNull{of_type: %Boolean{}}},
      }
    }
  end

  def type do
    %ObjectType{
      name: "__Type",
      description:
        """
        The fundamental unit of any GraphQL Schema is the type. There are
        many kinds of types in GraphQL as represented by the `__TypeKind` enum.

        Depending on the kind of a type, certain fields describe
        information about that type. Scalar types provide no information
        beyond a name and description, while Enum types provide their values.
        Object and Interface types provide the fields they describe. Abstract
        types, Union and Interface, provide the Object types possible
        at runtime. List and NonNull types compose other types.
        """,
      fields: quote do %{
        kind: %{
          type: %NonNull{of_type: "TypeKind"} # type_kind
          # resolve(type) {
          #   if (type instanceof GraphQLScalarType) {
          #     return TypeKind.SCALAR;
          #   } else if (type instanceof GraphQLObjectType) {
          #     return TypeKind.OBJECT;
          #   } else if (type instanceof GraphQLInterfaceType) {
          #     return TypeKind.INTERFACE;
          #   } else if (type instanceof GraphQLUnionType) {
          #     return TypeKind.UNION;
          #   } else if (type instanceof GraphQLEnumType) {
          #     return TypeKind.ENUM;
          #   } else if (type instanceof GraphQLInputObjectType) {
          #     return TypeKind.INPUT_OBJECT;
          #   } else if (type instanceof GraphQLList) {
          #     return TypeKind.LIST;
          #   } else if (type instanceof GraphQLNonNull) {
          #     return TypeKind.NON_NULL;
          #   }
          #   throw new Error('Unknown kind of type: ' + type);
          # }
        },
        name: %{type: %String{}},
        description: %{type: %String{}},
        fields: %{
          type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.field}},
          args: %{includeDeprecated: %{type: %Boolean{}, defaultValue: false}}
          # resolve(type, { includeDeprecated }) {
          #   if (type instanceof GraphQLObjectType ||
          #       type instanceof GraphQLInterfaceType) {
          #     var fieldMap = type.getFields();
          #     var fields =
          #       Object.keys(fieldMap).map(fieldName => fieldMap[fieldName]);
          #     if (!includeDeprecated) {
          #       fields = fields.filter(field => !field.deprecationReason);
          #     }
          #     return fields;
          #   }
          #   return null;
          # }
        },
        interfaces: %{
          type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.type}}
          # resolve(type) {
          #   if (type instanceof GraphQLObjectType) {
          #     return type.getInterfaces();
          #   }
          # }
        },
        possibleTypes: %{
          type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.type}}
          # resolve(type) {
          #   if (type instanceof GraphQLInterfaceType ||
          #       type instanceof GraphQLUnionType) {
          #     return type.getPossibleTypes();
          #   }
          # }
        },
        enumValues: %{
          type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.enum_value}},
          args: %{includeDeprecated: %{type: %Boolean{}, defaultValue: false}}
          # resolve(type, { includeDeprecated }) {
          #   if (type instanceof GraphQLEnumType) {
          #     var values = type.getValues();
          #     if (!includeDeprecated) {
          #       values = values.filter(value => !value.deprecationReason);
          #     }
          #     return values;
          #   }
          # }
        },
        inputFields: %{
          type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.input_value}}
          # resolve(type) {
          #   if (type instanceof GraphQLInputObjectType) {
          #     var fieldMap = type.getFields();
          #     return Object.keys(fieldMap).map(fieldName => fieldMap[fieldName]);
          #   }
          # }
        },
        ofType: %{type: GraphQL.Type.Introspection.type}
      } end
    }
  end

  def field do
    %ObjectType{
      name: "__Field",
      description:
        """
        Object and Interface types are described by a list of Fields, each of
        which has a name, potentially a list of arguments, and a return type.
        """,
      fields: %{
        name: %{type: %NonNull{of_type: %String{}}},
        description: %{type: %String{}},
        args: %{
          type: %NonNull{of_type: %List{of_type: %NonNull{of_type: GraphQL.Type.Introspection.input_value}}}
          # resolve: field => field.args || []
        },
        type: %{type: %NonNull{of_type: GraphQL.Type.Introspection.type}},
        isDeprecated: %{
          type: %NonNull{of_type: %Boolean{}}
          # resolve: field => !isNullish(field.deprecationReason),
        },
        deprecationReason: %{type: %String{}}
      }
    }
  end

  def input_value do
    %ObjectType{
      name: "__InputValue",
      description:
        """
        Arguments provided to Fields or Directives and the input fields of an
        InputObject are represented as Input Values which describe their type
        and optionally a default value.
        """,
      fields: %{
        name: %{type: %NonNull{of_type: %String{}}},
        description: %{type: %String{}},
        type: %{type: %NonNull{of_type: GraphQL.Type.Introspection.type}},
        defaultValue: %{
          type: %String{},
          description: "A GraphQL-formatted string representing the default value for this input value."
          # resolve: inputVal => isNullish(inputVal.defaultValue) ?
          #   null :
          #   print(astFromValue(inputVal.defaultValue, inputVal))
        }
      }
    }
  end

  def enum_value do
    %ObjectType{
      name: "__EnumValue",
      description:
        """
        One possible value for a given Enum. Enum values are unique values, not
        a placeholder for a string or numeric value. However an Enum value is
        returned in a JSON response as a string.
        """,
      fields: %{
        name: %{type: %NonNull{of_type: %String{}}},
        description: %{type: %String{}},
        isDeprecated: %{
          type: %NonNull{of_type: %Boolean{}}
          # resolve: enumValue => !isNullish(enumValue.deprecationReason),
        },
        deprecationReason: %{type: %String{}}
      }
    }
  end

  def query do
    """
    query IntrospectionQuery {
      __schema {
        queryType { name }
        mutationType { name }
        subscriptionType { name }
        types {
          ...FullType
        }
        directives {
          name
          description
          args {
            ...InputValue
          }
          onOperation
          onFragment
          onField
        }
      }
    }

    fragment FullType on __Type {
      kind
      name
      description
      fields(includeDeprecated: true) {
        name
        description
        args {
          ...InputValue
        }
        type {
          ...TypeRef
        }
        isDeprecated
        deprecationReason
      }
      inputFields {
        ...InputValue
      }
      interfaces {
        ...TypeRef
      }
      enumValues(includeDeprecated: true) {
        name
        description
        isDeprecated
        deprecationReason
      }
      possibleTypes {
        ...TypeRef
      }
    }

    fragment InputValue on __InputValue {
      name
      description
      type { ...TypeRef }
      defaultValue
    }

    fragment TypeRef on __Type {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
          }
        }
      }
    }
    """
  end

  defmodule MetaField do
    def typename do
      %{
        name: "__typename",
        type: %NonNull{of_type: %String{}},
        description: "The name of the current Object type at runtime.",
        args: [],
        resolve: fn(_, _, %{parent_type: %{name: name}}) -> name end
      }
    end

    def schema do
      %{
        name: "__schema",
        type: %NonNull{of_type: GraphQL.Type.Introspection.schema},
        description: "Access the current type schema of this server.",
        args: [],
        resolve: fn(_, _, args) -> args.schema end
      }
    end
  end

end
