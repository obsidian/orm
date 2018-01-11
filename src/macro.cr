macro model(name)
  {% if name.is_a? Path %}
    {% class_name = name %}
    {% parent_class = ORM::Model %}
  {% elsif name.is_a?(Call) && name.receiver && name.name = "<" && name.args.size == 1 %}
    {% if name.args[0].ancestors.include?(ORM::Model) %}
      {% parent_class = name.args[0] %}
      {% class_name = name.receiver %}
    {% else %}
      raise "Must inherit from an ORM::Model"
    {% end %}
  {% else %}
    raise "invalid syntax, use `model Name do ...`"
  {% end %}

  @schema = {{ class_name }}.new
  forward_missing_to @schema

  class {{ class_name }} < {{ parent_class }}
    {{ yield }}
  end
end
