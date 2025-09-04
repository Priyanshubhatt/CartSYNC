module Types
  class QueryType < BaseObject
    field :cart_queries, Queries::CartQueries, null: false, resolver_method: :cart_queries

    def cart_queries
      Queries::CartQueries
    end
  end
end
