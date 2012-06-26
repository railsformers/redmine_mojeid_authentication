module MojeIDAuthentication
  class ViewHooks < Redmine::Hook::ViewListener
    def view_account_login_bottom(context={})
      context[:controller].send(:render_to_string, {
        :partial => "hooks/view_account_login_bottom",
        :locals => context
      })
    end

    def view_my_account(context={})
      context[:controller].send(:render_to_string, {
        :partial => "hooks/view_my_account",
        :locals => context
      })
    end

    def view_users_form(context={})
      context[:controller].send(:render_to_string, {
        :partial => "hooks/view_users_form",
        :locals => context
      })
    end

    def view_layouts_base_html_head(context={})
      css = stylesheet_link_tag 'mojeid_authentication.css', :plugin => 'redmine_mojeid_authentication'
      css + xrds_meta_tag(context[:request])
    end
  end
end
