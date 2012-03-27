ActionController::Routing::Routes.draw do |map|
  map.xrds "/xrds.xml", :controller => :consumer, :action => :xrds
  map.consumer "/consumer", :controller => :consumer, :action => :start, :method => :post
  map.consumer_completed "/consumer/completed", :controller => :consumer, :action => :completed
end
