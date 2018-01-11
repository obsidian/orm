abstract struct ORM::Schema
  macro adapter(name)
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
    relation({{ relation }}, HasMany) do

    end
  end

  macro has_one(relation, *, through = nil, source = nil, validate = nil, autosave = nil, extend = nil, foreign_key = nil, primary_key = nil, dependent = nil)
    {% source = relation.var %}
    {% source = relation.var %}

    @{{ relation.var }} : {{ relation.type }}?

    def {{ relation.var }} : {{ relation.type }}
      @{{ relation.var }} ||= {% if through %}
        {{ through.var }}.{{ source }}
      {% else %}
        {{ relation.type }}::Schema.first({{ primary_key.id }}: {{ foreign_key.id }})
      {% end %}
    end
  end

  macro has_and_belongs_to_many(relation, *, join_table = nil, primary_key = nil, foreign_key = nil, association_primary_key = nil, association_foreign_key = nil, validate = nil, autosave = nil)
    relation({{ relation }}, HasAndBelongsToMany) do
      {{ relation.type }}::Schema
        .joins({{ join_table }}, on: "{{ join_table }}.{{ foreign_key }} = #{ TABLE }.{{ primary_key }}")
        .joins({{ join_table }}, on: "{{ join_table }}.{{ foreign_key }} = #{ {{ relation.type }}::Schema::TABLE }.{{ primary_key }}")
    end
  end

  macro belongs_to(relation, *, foreign_key = nil, primary_key = nil, dependent = nil, validate = nil, autosave = nil, validate = nil, touch = nil, inverse_of = nil, optional = nil, required = nil, default = nil)
    @{{ relation.var }} : {{ relation.type }}?

    def {{ relation.var }} : {{ relation.type }}
      @{{ relation.var }} ||= {{ relation.type }}::Schema.first({{ foreign_key.id }}: {{ primary_key.id }})
    end
  end

  private macro relation(relation)
    {% class_name = {{ relation.var }}{{ relation.var.stringify.camelcase.id }}Relation %}

    class {{ class_name }} < ::ORM::Relation::{{ relation.var }}({{ relation.type }})
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
