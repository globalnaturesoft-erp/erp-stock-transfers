Erp::Ability.class_eval do
  def stock_transfers_ability(user)
    
    can :printable, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_active? or transfer.is_delivered?
    end
    
    can :creatable, Erp::StockTransfers::Transfer do |transfer|
      if Erp::Core.available?("ortho_k")
        user.get_permission(:inventory, :stock_transfers, :transfers, :create) == 'yes'
      else
        true
      end
    end
    
    can :updatable, Erp::StockTransfers::Transfer do |transfer|
      (transfer.is_draft? or transfer.is_active? or transfer.is_delivered?) and
      if Erp::Core.available?("ortho_k")
        user.get_permission(:inventory, :stock_transfers, :transfers, :update) == 'yes'
      else
        true
      end
    end
    
    can :activatable, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft?
    end
    
    can :deliverable, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft? or transfer.is_active?
    end
    
    can :cancelable, Erp::StockTransfers::Transfer do |transfer|
      (transfer.is_draft? or transfer.is_active? or transfer.is_delivered?) and
      if Erp::Core.available?("ortho_k")
        user.get_permission(:inventory, :stock_transfers, :transfers, :delete) == 'yes'
      else
        true
      end
    end
    
  end
end