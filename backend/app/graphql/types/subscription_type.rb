module Types
  class SubscriptionType < BaseObject
    field :cart_updated, subscription: Subscriptions::CartUpdated
  end
end
