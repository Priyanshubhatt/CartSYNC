class CartSyncSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::SubscriptionType)

  # Use the new interpreter for better performance
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Enable batch loading
  use GraphQL::Batch

  # Configure subscriptions
  use GraphQL::Subscriptions::ActionCableSubscriptions
end
