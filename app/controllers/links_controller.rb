require 'open-uri'
require 'uri'
require 'pismo'

class LinksController < ApplicationController

  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user, only: :destroy

  def create

    
    @link = current_user.links.build(params[:link]) if check_url

    if @link!= nil && @link.save

    current_user.link_with_user!(@link)
      flash[:success] = "Link submitted"
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def destroy
    
    current_user.unlink_with_user!(@link)

    redirect_to root_url unless @link.users.exists? current_user
  end

  private
    def correct_user
      @link = current_user.links.find_by_id(params[:id])
      redirect_to root_url if @link.nil?
    end
   
    def check_url
	given =params[:link][:url_link]
	given = "http://" + given if /https?:\/\/[\S]+/.match(given) == nil
	begin       	
		page =  open(given).base_uri.to_s
		doc = Pismo::Document.new(page)
		link_title = doc.title
		ur = URI(page)
		host = ur.host
		page.slice! ur.fragment if ur.fragment != nil
		page.slice! ur.query if ur.query != nil
		page.slice! "http://"
		page.slice! "https://"
		page.slice! "www."
		params[:link][:url_link] = page
		params[:link][:url_heading] = link_title
		true
	rescue
	       	flash[:error] = "Invalid url"
		false
	end
   end   
end
