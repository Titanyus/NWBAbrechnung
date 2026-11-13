class CustomersController < PlantScopedController
  before_action :load_customer, only: [ :show, :edit, :update ]

  def index
    scope = @plant.customer_memberships.includes(:customer).joins(:customer)
    if params[:q].present?
      query = "%#{Customer.sanitize_sql_like(params[:q].to_s.first(200))}%"
      scope = scope.where("customers.first_name ILIKE :q OR customers.last_name ILIKE :q OR customers.company_name ILIKE :q OR customer_memberships.customer_number ILIKE :q", q: query)
    end
    scope = scope.where(active: params[:state] == "active") if %w[active inactive].include?(params[:state])
    @memberships = page(scope.order("customers.company_name", "customers.last_name", "customers.first_name", "customer_memberships.id"))
  end

  def show
    @contracts = @membership.supply_contracts.includes(:connection).order(starts_on: :desc)
  end

  def new
    @customer = Customer.new
    @membership = @plant.customer_memberships.new
    @can_edit_customer = true
    @available_customers = available_customers
  end

  def create
    @customer = @plant.operator.customers.new(customer_params)
    @membership = @plant.customer_memberships.new(membership_params.merge(customer: @customer))
    Customer.transaction do
      @customer.save!
      @membership.save!
      MasterData::Change.audit!(@membership, user: current_user)
    end
    redirect_to plant_customer_path(@plant, @customer), status: :see_other, notice: "Kunde wurde angelegt."
  rescue ActiveRecord::RecordInvalid => error
    @customer.errors.add(:base, error.record.errors.full_messages.join("; ")) unless error.record == @customer
    @can_edit_customer = true
    @available_customers = available_customers
    render :new, status: :unprocessable_entity
  end

  def link
    customer = visible_customers.find(params[:customer_id])
    customer.with_lock do
      membership = @plant.customer_memberships.create!(customer: customer)
      MasterData::Change.audit!(membership, user: current_user)
    end
    redirect_to plant_customer_path(@plant, customer), status: :see_other, notice: "Vorhandener Kunde wurde dieser Anlage zugeordnet."
  rescue ActiveRecord::RecordInvalid
    redirect_to plant_customers_path(@plant), status: :see_other, alert: "Die Kundenzuordnung konnte nicht gespeichert werden."
  end

  def edit
  end

  def update
    @customer.with_lock do
      @can_edit_customer = editable_customer?
      if customer_params.present? && !@can_edit_customer
        head :forbidden
        return
      end
      @customer.update!(customer_params) if customer_params.present?
      MasterData::Change.audit!(@customer, user: current_user, plant: @plant) if @customer.saved_changes?
      @membership.update!(membership_params)
      MasterData::Change.audit!(@membership, user: current_user)
    end
    redirect_to plant_customer_path(@plant, @customer), status: :see_other, notice: "Kunde wurde gespeichert."
  rescue ActiveRecord::RecordInvalid => error
    @customer.errors.add(:base, error.record.errors.full_messages.join("; ")) unless error.record == @customer
    render :edit, status: :unprocessable_entity
  end

  private

  def available_customers
    scope = visible_customers.where.not(id: @plant.customers.select(:id))
    if params[:q].present?
      query = "%#{Customer.sanitize_sql_like(params[:q].to_s.first(200))}%"
      scope = scope.where("first_name ILIKE :q OR last_name ILIKE :q OR company_name ILIKE :q", q: query)
    end
    scope.order(:last_name, :company_name, :id).limit(100)
  end

  def visible_customers
    Customer.where(id: CustomerMembership.where(plant_id: current_user.plants.select(:id)).select(:customer_id))
  end

  def editable_customer?
    !@customer.customer_memberships.where.not(plant_id: current_user.plants.select(:id)).exists?
  end

  def load_customer
    @membership = @plant.customer_memberships.includes(:customer).find_by!(customer_id: params[:id])
    @customer = @membership.customer
    @can_edit_customer = editable_customer?
  end

  def customer_params
    params.fetch(:customer, ActionController::Parameters.new).permit(:first_name, :last_name, :company_name, :address, :phone, :email, :notes)
  end

  def membership_params
    params.fetch(:customer_membership, ActionController::Parameters.new).permit(:customer_number, :payment_method, :direct_debit_agreement, :active)
  end
end
