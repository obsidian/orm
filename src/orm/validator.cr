abstract struct Validator
  macro options(*options)
    record Options, {{ *options }}
    getter options : Options

    def initialize(options)
      @options = Options.new(**options)
    end

    def initialize({{ options.first.var }} : {{ options.first.type }})
      @options = Options.new({{ options.first.var }}: {{ options.first.var }})
    end
  end

  abstract def validate(model, field : Symbol, value) : Bool
end
