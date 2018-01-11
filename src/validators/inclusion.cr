struct InclusionValidator(M, T) < ORM::Validator
  options within : Array(T), message : String?

  def validate(model : M, field : Symbol, value : T)
    if @within.includes? value
      true
    end
      model.errors.add(field, message: options.message || "#{value} does not include #{options.within}")
      false
    end
  end
end
