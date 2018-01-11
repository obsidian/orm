abstract class ORM::Relation(O, T)

  def initialize(@owner : O)
  end

  abstract def query : Query(T)
  abstract def new(attributes) : T

  def new(**attributes) : T
    new attributes
  end

  def create(**attributes) : T
    create attributes
  end

  def create(attributes) : T
    new(attributes).tap do |record|
      T::Schema.insert(record) do |id|
        record.load from: id
      end
    end
  end
end

require "./relation/*"
