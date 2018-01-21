abstract struct ORM::Schema
  @@adapter : ORM::Adapter

  # :no-doc:
  module RelationshipQueries
  end

  macro inherited
    # :no-doc:
    module RelationshipQueries
      extend {{ @type.superclass }}::RelationshipQueries
    end
  end

  macro adapter(name)
    @@adapter = {{ name }}
  end

  macro primary_key(field, *)
    field {{ field }}
    @@primary_key = {{ field.var }}
  end

  macro field(field, *)
    property field
    alias field.stringify.camelcase.id = field.type
  end

  macro has_many(relation, *, through = nil, source = nil, validate = nil, autosave = nil, extend = nil, foreign_key = nil, primary_key = nil, dependent = nil)
    def Relationships.{{ relation.var }}
      { kind: through: {{ through }}, source: {{ source }}, validate: {{ validate }}, autosave: {{ autosave }}, extend: {{ extend }}, foreign_key: {{ foreign_key }}, primary_key: {{ primary_key }}, dependent: {{ dependent }} }
    end

    {% source = source || relation.var %}
    {% primary_key = primary_key || "@@primary_key".id %}

    relation({{ relation }}, HasMany, extend: {{ extend }}) do

    end
  end

  macro has_one(relation, *, through = nil, source = nil, validate = nil, autosave = nil, foreign_key = nil, primary_key = nil, dependent = nil)
    {% primary_key = primary_key || "@@primary_key".id %}
    {% foreign_key = foreign_key || "#{@type.name.underscore}_id".id %}
    {% source = source || relation.var %}

    def RelationshipQueries.{{ relation.var }} : Query
      {% if through %}
        {{ through.var }}.{{ source }}
      {% else %}
        {{ relation.type }}::Schema.where({{ foreign_key.id }}: {{ primary_key.id }}).limit(1)
      {% end %}
    end

    @{{ relation.var }} : {{ relation.type }}?

    def {{ relation.var }} : {{ relation.type }}
      @{{ relation.var }} ||= Relationships.{{ relation.var }}.first
    end
  end

  macro has_and_belongs_to_many(relation, *, join_table = nil, primary_key = nil, foreign_key = nil, association_primary_key = nil, association_foreign_key = nil, validate = nil, autosave = nil, extend = nil)
    {% primary_key = primary_key || "@@primary_key".id %}

    relation({{ relation }}, HasAndBelongsToMany, extend: {{ extend }}) do
      {{ relation.type }}::Schema
        .joins({{ join_table }}, on: "{{ join_table }}.{{ foreign_key }} = #{ TABLE }.{{ primary_key }}")
        .joins({{ join_table }}, on: "{{ join_table }}.{{ foreign_key }} = #{ {{ relation.type }}::Schema::TABLE }.{{ primary_key }}")
    end
  end

  macro belongs_to(relation, *, foreign_key = nil, primary_key = nil, dependent = nil, validate = nil, autosave = nil, validate = nil, touch = nil, inverse_of = nil, optional = nil, required = nil, default = nil)
    {% primary_key = primary_key || "#{relation.type.name}.@@primary_key".id %}
    {% foreign_key = foreign_key || "#{relation.type.name.underscore}_id".id %}

    @{{ relation.var }} : {{ relation.type }}?

    def {{ relation.var }} : {{ relation.type }}
      @{{ relation.var }} ||= {{ relation.type }}::Schema.first({{ primary_key.id }}: {{ foreign_key.id }})
    end
  end

  private macro relation(relation, kind, *, extend)
    {% class_name = {{ kind }}{{ relation.var.stringify.camelcase.id }}Relation %}

    class {{ class_name }} < ::ORM::Relation::{{ kind }}({{ relation.type }})
      {% if extend %}
        include {{ extend }}
      {% end %}

      def query
        {{ yield }}
      end
    end

    @{{ relation.var }} : {{ class_name }}?

    def {{ relation.var }}
      @{{ relation.var }} ||= {{ class_name }}.new(self)
    end
  end
end
