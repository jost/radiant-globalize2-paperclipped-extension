# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class Globalize2PaperclippedExtension < Radiant::Extension
  version "0.1"
  description "Translate Paperclipped Assets using Radiant Globalize2 Extension."
  url "http://blog.aissac.ro/radiant/globalize2paperclipped-extension/"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :globalize2_paperclipped
  #   end
  # end
  
  def activate
    throw "Globalize2 Extension must be loaded before Globalize2Paperclipped" unless defined?(Globalize2Extension)
    throw "Paperclipped Extension must be loaded before Globalize2Paperclipped" unless defined?(PaperclippedExtension)
    
    PaperclippedExtension.admin.asset.index.add :top, 'admin/shared/change_locale_admin'
    PaperclippedExtension.admin.asset.edit.add :main, 'admin/shared/change_asset_locale', :before => 'edit_form'  
    
    PaperclippedExtension.admin.asset.index.add :thead, 'admin/shared/globalize_th'
    PaperclippedExtension.admin.asset.index.add :tbody, 'admin/shared/globalize_asset_td'
    
    Asset.send(:translates, *[:title, :caption])
    
    Asset.send(:include, Globalize2Paperclipped::AssetExtensions)
    Page.send(:include, Globalize2Paperclipped::Globalize2PaperclippedTags)
    Page.send(:include, Globalize2Paperclipped::PageExtensions)
    
  end
  
  def deactivate
  end
  
end
