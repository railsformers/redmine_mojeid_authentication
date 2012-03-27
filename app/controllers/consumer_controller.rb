class ConsumerController < AccountController
  unloadable

  def xrds
    respond_to do |format|
      format.xml { render :inline => xrds_response(consumer_completed_url) }
    end
  end

  def start
    unless params[:assoc_request]
      logout_user
    end
    mojeid = MojeID.new
    mojeid.return_to = consumer_completed_url
    mojeid.realm = root_url
    begin
      mojeid.fetch_request(consumer)
    rescue MojeID::DiscoveryFailure => f
      flash[:error] = "Discovery Failure: #{f.message}"
      redirect_to root_path and return
    end

    mojeid.add_attributes([
      [MojeID::AVAILABLE_ATTRIBUTES[1], nil, true],
      [MojeID::AVAILABLE_ATTRIBUTES[2], nil, true]
    ])

    redirect_to mojeid.redirect_url
  end

  def completed
    mojeid = MojeID.new
    @response = mojeid.fetch_response(consumer, params, request, url_for)
    if mojeid.response_status == :success
      if User.current.logged?
        actual_mojeid = User.current.mojeid_identity_url
        User.current.mojeid_identity_url = @response.endpoint.claimed_id.split('#')[0]
        if User.current.valid?
          User.current.firstname = mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[1]].first if mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[1]].any?
          User.current.lastname = mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[2]].first if mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[2]].any?
          User.current.save
        else
          User.current.mojeid_identity_url = actual_mojeid
          flash[:error] = t("mojeid_already_used")
        end
        redirect_to "/my/account"
        return
      elsif user = User.find_by_mojeid_identity_url(@response.endpoint.claimed_id.split('#')[0])
        user.firstname = mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[1]].first if mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[1]].any?
        user.lastname = mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[2]].first if mojeid.data[MojeID::AVAILABLE_ATTRIBUTES[2]].any?
        user.save
        self.logged_user = user
        call_hook(:controller_account_success_authentication_after, { :user => user })
        redirect_to root_path and return
      else
        flash[:error] = t("mojeid_unassociated")
      end
    else
      flash[:error] = t("mojeid_error")
    end
    redirect_to signin_path
  end

  private

  def consumer
    @consumer ||= MojeID.get_consumer(session, MojeID.get_openid_store("tmp"))
  end
end
