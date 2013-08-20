require 'active_support/inflector'

module BSNS

	@@config = {}

	def has_many model, opts = {}
		field = opts[:as] || model.to_s.downcase.pluralize
		with  = opts[:with] || nil
		model = model.to_s.singularize
		class_eval do 
			define_method field do
				fields = instance_variable_get "@#{field}"
				collection_from_array fields, model, with
			end
		end
	end

	def self.configure opts
		@@config = opts
	end

	def self.get_config key
		@@config[key.to_sym]
	end

	class Base

		extend BSNS

		attr_accessor :load_path

		def initialize data={}
			set_defaults
			data.each do |k,v|
				accessor = "#{k}="
				if respond_to? accessor
					self.send accessor, v
				else
					instance_variable_set "@#{k}", v
				end
			end
		end

		def self.class
			self
		end

		def self.root_path
			BSNS.get_config(:content_path).gsub(/\/$/, '')+'/'
		end

		def self.relative_path
			self.class.name.to_s.downcase.pluralize
		end

		def set_defaults
		end

		def self.load file
			data = {}
			data['load_path'] = file
			data = YAML.load_file root_path +
			                      relative_path.gsub(/\/$/, '')+'/'+
			                      file.to_s+'.yml'
			self.new data
		end

		def collection_from_array arr, model, extra_key = nil
			# Return an array of all the references for a thing.
			arr.map do |d| 
				if d.instance_of? Hash
					# Normalize {:id => :linking_value} to [:id, :linking_value]
					id    = d.keys[0]
					value = d[id]
					d     = [id, value]
				end
				id  = d.instance_of?(Array) ? d[0] : d
				obj = model.to_s.capitalize.constantize.load id
				obj.define_linking_field extra_key, d[1] if extra_key
				obj
			end
		end

		def define_linking_field field, value
			self.class.module_eval { attr_accessor field.to_sym }
			self.send "#{field}=", value
		end

	end

end