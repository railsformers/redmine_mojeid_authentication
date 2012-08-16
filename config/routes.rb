ActionController::Routing::Routes.draw do |map|
  map.xrds "/xrds.xml", :controller => :consumer, :action => :xrds
  map.consumer "/consumer", :controller => :consumer, :action => :start, :conditions => { :method => :post }
  map.consumer "/consumer", :controller => :consumer, :action => :xrds_source, :conditions => { :method => :get }
  map.consumer_completed "/consumer/completed", :controller => :consumer, :action => :completed
  map.consumer_unlink "/consumer/unlink", :controller => :consumer, :action => :unlink, :conditions => { :method => :post }
end
