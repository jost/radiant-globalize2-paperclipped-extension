module Globalize2Paperclipped
  module AssetExtensions
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        class << self
          alias_method :unglobalized_search, :search
          alias_method :search, :globalized_search
          alias_method :unglobalized_count_by_conditions, :count_by_conditions
          alias_method :count_by_conditions, :globalized_count_by_conditions
        end
      end

    end
    
    module ClassMethods
      def scope_locale(locale, &block)
        with_scope(:find => { :joins => "INNER JOIN asset_translations on asset_translations.asset_id = assets.id", :conditions => ['asset_translations.locale = ?', locale] }) do
          yield
        end
      end

      def globalized_count_by_conditions
        type_conditions = @file_types.blank? ? nil : Asset.types_to_conditions(@file_types.dup).join(" OR ")
        join = "inner join asset_translations on asset_translations.asset_id = assets.id"
        @count_by_conditions ||= @conditions.empty? ? Asset.count(:all, :conditions => type_conditions, :joins => join) : Asset.count(:all, :conditions => @conditions, :joins => join)
      end

      def globalized_search(search, filter, page)
        locale_cond_sql = "locale = '#{I18n.locale.to_s}'"
        unless search.blank?

          search_cond_sql = []
          search_cond_sql << 'LOWER(asset_file_name) LIKE (:term)'
          search_cond_sql << 'LOWER(title) LIKE (:term)'
          search_cond_sql << 'LOWER(caption) LIKE (:term)'

          cond_sql = '(' + search_cond_sql.join(" or ") + ') and ' + locale_cond_sql

          @conditions = [cond_sql, {:term => "%#{search.downcase}%"}]
        else
          @conditions = [locale_cond_sql]
        end
        options = { :joins => "INNER JOIN asset_translations on asset_translations.asset_id = assets.id",
                    :conditions => @conditions,
                    :order => 'created_at DESC',
                    :page => page,
                    :per_page => 10 }

        @file_types = filter.blank? ? [] : filter.keys
        if not @file_types.empty?
          options[:total_entries] = count_by_conditions
          Asset.paginate_by_content_types(@file_types, :all, options )
        else
          Asset.paginate(:all, options)
        end
      end
    end 
  end
end
