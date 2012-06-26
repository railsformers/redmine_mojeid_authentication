ActionController::Routing::Routes.draw do |map|
  map.xrds "/xrds.xml", :controller => :consumer, :action => :xrds
  map.consumer "/consumer", :controller => :consumer, :action => :start, :method => :post
  map.consumer_completed "/consumer/completed", :controller => :consumer, :action => :completed
  map.consumer_unlink "/consumer/unlink", :controller => :consumer, :action => :unlink, :method => :post
end
