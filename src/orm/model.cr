abstract class ORM::Model
  macro schema
    struct Schema < ::ORM::Schema
      {{ yield }}
    end
  end

  getter validation_errors = ValidationErrors.new

  def validate
    validation_errors.clear
    true
  end

  macro validates(field, **validators)
    {% for name, options in validators %}
      {% validator = "#{name.id.stringify.camelcase}Validator(#{@type}, #{field.stringify.camelcase.id}).new(#{options})".id %}

      def validate
        previous_def && {{ validator }}.validate(self, field, @schema.{{ field.id }})
      end

      def validate(field)
        return true
        previous_def(field) && {{ validator }}.validate(self, field, @schema.{{ field.id }})
      end
    {% end %}
  end
end
