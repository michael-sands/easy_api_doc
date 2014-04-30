require 'cgi'
require 'base64'
require 'oauth'

module EasyApiDoc
  class DocumentationController < EasyApiDoc::ApplicationController
    before_filter :defaults

    def api_base
      @api_version = EasyApiDoc::ApiVersion.find(params[:api])
    end

    def namespace
      if @namespace == nil
        flash[:error] = "No namespace found"
        redirect_to root_path
        return
      end
      @resources = @namespace.resources
    end

    def resource
      @resource = @namespace.resources.find {|r| r.name == params[:resource] }
      unless @resource
        flash[:error] = "No resource found #{params[:resource]}"
        redirect_to root_path
        return
      end
      @actions = @resource.actions
    end

    def api_action
      @resource = @namespace.resources.find {|r| r.name == params[:resource] }
      unless @resource
        flash[:error] = "No resource #{params[:resource]} found"
        redirect_to root_path
        return
      end
      @action = @resource.actions.find {|a| a.name == params[:api_action] }
      unless @resource
        flash[:error] = "No action #{params[:api_action]} found"
        redirect_to root_path
        return
      end
      create_auth_params if @action.authentication
    end

    private

    def defaults
      @api_version = EasyApiDoc::ApiVersion.find(params[:api])
      @namespace = @api_version.namespaces.find {|ns| ns.name == params[:namespace] }
      @meta = EasyApiDoc::ApiVersion.config['meta']
      @app_title = @meta['app_title'] if @meta
    end

    def create_auth_params
      create_oauth_1_0_auth_params if @action.authentication['type'].downcase == "oauth"
    end

    def create_oauth_1_0_auth_params
      @action.authentication['oauth_token'] = @oauth_access_token
    end

    # def execute_action
    #   @api_version = EasyApiDoc::ApiVersion.find(params[:api])
    #   @namespace = @api_version.namespaces.find {|ns| ns.name == params[:namespace] }
    #   @resource = @namespace.resources.find {|r| r.name == params[:resource] }
    #   @action = @resource.actions.find {|a| a.name == params[:api_action] }
    #   params[:payload].delete(:authenticity_token)

    #   res = @action.run(params[:payload], params[:remote_method], params[:format])
    #   render params[:format].to_sym => res, :status => 200 #res[:status]
    # end

  end
end
