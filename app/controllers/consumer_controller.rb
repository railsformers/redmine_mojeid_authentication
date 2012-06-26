class ConsumerController < AccountController
  unloadable

  FIELD_EMAIL     = 'http://axschema.org/contact/email'
  FIELD_FIRSTNAME = 'http://axschema.org/namePerson/first'
  FIELD_LASTNAME  = 'http://axschema.org/namePerson/last'
  FIELD_STATUS    = 'http://specs.nic.cz/attr/contact/status'

  def xrds
    respond_to do |format|
      format.xml { render :inline => xrds_response(consumer_completed_url) }
    end
  end

  def start
    unless params[:assoc_request]
      logout_user
    end
    mojeid = MojeID.new(:test => true)
    mojeid.return_to = consumer_completed_url
    mojeid.realm = root_url
    begin
      mojeid.fetch_request(consumer)
    rescue MojeID::DiscoveryFailure => f
      flash[:error] = "Discovery Failure: #{f.message}"
      redirect_to root_path and return
    end

    mojeid.add_attributes([
      [FIELD_EMAIL, nil, true],
      [FIELD_FIRSTNAME, nil, true],
      [FIELD_LASTNAME, nil, true],
      [FIELD_STATUS, nil, true]
    ])

    redirect_to mojeid.redirect_url
  end

  def completed
    mojeid = MojeID.new(:test => true)
    @response = mojeid.fetch_response(consumer, params, request, url_for)
    if mojeid.response_status == :success
      if User.current.logged?
        actual_mojeid = User.current.mojeid_identity_url
        User.current.mojeid_identity_url = @response.endpoint.claimed_id.split('#')[0]
        if User.current.valid?
          User.current.firstname = mojeid.data[FIELD_FIRSTNAME].first if mojeid.data[FIELD_FIRSTNAME].any?
          User.current.lastname = mojeid.data[FIELD_LASTNAME].first if mojeid.data[FIELD_LASTNAME].any?
          User.current.mail = mojeid.data[FIELD_EMAIL].first if mojeid.data[FIELD_EMAIL].any?
          User.current.mojeid_status = mojeid.data[FIELD_STATUS].first if mojeid.data[FIELD_STATUS].any?
          User.current.save
        else
          User.current.mojeid_identity_url = actual_mojeid
          flash[:error] = t("mojeid_already_used")
        end
        redirect_to "/my/account" and return
      elsif user = User.find_by_mojeid_identity_url(@response.endpoint.claimed_id.split('#')[0])
        user.firstname = mojeid.data[FIELD_FIRSTNAME].first if mojeid.data[FIELD_FIRSTNAME].any?
        user.lastname = mojeid.data[FIELD_LASTNAME].first if mojeid.data[FIELD_LASTNAME].any?
        user.mail = mojeid.data[FIELD_EMAIL].first if mojeid.data[FIELD_EMAIL].any?
        user.mojeid_status = mojeid.data[FIELD_STATUS].first if mojeid.data[FIELD_STATUS].any?
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
    @data = mojeid.data
    redirect_to signin_path
  end

  def unlink
    User.current.mojeid_identity_url = User.current.mojeid_status = nil
    User.current.save
    redirect_to "/my/account"
  end

  private

  def consumer
    @consumer ||= MojeID.get_consumer(session, MojeID.get_openid_store("/tmp/mojeid-asTg34"))
  end
end
