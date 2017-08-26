Erp::Ability.class_eval do
  def orders_ability(user)
    
    can :activate, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft? or transfer.is_deleted?
    end
    
    can :delivery, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft? or transfer.is_active?
    end
    
    can :delete, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft? or transfer.is_active? or transfer.is_delivered?
    end
    
    can :update, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft? or transfer.is_active? or transfer.is_delivered?
    end
    
    can :export_file, Erp::StockTransfers::Transfer do |transfer|
      transfer.is_draft? or transfer.is_active? or transfer.is_delivered?
    end
  end
end