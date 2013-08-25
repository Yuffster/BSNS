require 'active_support/inflector'

module BSNS

	@@config = {}

	def has_many model, opts = {}
		field = opts[:as] || model.to_s.downcase.pluralize
		with  = opts[:with] || nil
		embed = opts[:embedded] || false
		model = model.to_s.singularize
		class_eval do 
			define_method field do
				collection_from_array instance_variable_get("@#{field}"), model, opts
			end
		end
	end

	def has_one model, opts = {}
		model = model.to_s
		field = opts[:as] || model.downcase
		class_eval do
			define_method field do
				klass = model.capitalize.constantize
				data  = instance_variable_get "@#{field}"
				if opts[:embedded]
					obj = klass.new data
				else
					if data.type_of? Hash
						obj = klass.load data[0]
					end
				end
			end
		end
	end

	def acts_as_collection
		set_v :single_file, true
	end

	def self.configure opts
		@@config = opts
	end

	def self.get_config key
		@@config[key.to_sym]
	end

	class Base

		extend BSNS

		def initialize data={}
			get_defaults.each do |k,v|
				data[k] ||= v
			end
			data.each do |k,v|
				accessor = "#{k}="
				if respond_to? accessor
					self.send accessor, v
				else
					instance_variable_set "@#{k}", v
				end
			end
		end

		def get_defaults
			data = get_v :defaults
			unless data
				data = self.class.load_or_nil "_defaults"
				set_v :defaults, data
			end
			data || {}
		end

		def get_v k
			self.class.get_v k
		end

		def set_v k, v
			self.class.set_v k, v
		end

		def self.get_v k
			begin
				return class_variable_get "@@#{k}"
			rescue
				return nil
			end
		end

		def self.set_v k, v
			class_variable_set "@@#{k}", v
		end

		def self.class
			self
		end

		def self.root_path
			path = BSNS.get_config(:content_path) || 'content'
			path.gsub(/\/$/, '')+'/'
		end

		def self.relative_path
			get_v(:relative_path) || self.class.name.to_s.downcase.pluralize
		end

		def self.content_path p
			set_v :relative_path, p
		end

		def self.load_data file
			return load_from_collection file if get_v :single_file
			data = {}
			data['load_path'] = file
			path = (root_path+relative_path.gsub(/\/$/, '')+'/')+file.to_s+'.yml'
			throw "File not found: #{path}" unless File.exists? path
			YAML.load_file path
		end

		def self.load file
			data = load_data file
			self.new data
		end

		def self.load_or_nil file
			begin
				load_data file
			rescue
				return nil
			end
		end

		def self.load_from_collection f
			unless get_v :data
				data = YAML.load_file (root_path + relative_path + '.yml')
				set_v :data, data
			end
			get_v(:data)[f.to_s]
		end

		# Return an array of all the references for a thing.
		def collection_from_array arr, model, opts
			arr.map { |d| obj_from_dataset d, model, opts }
		end

		def obj_from_dataset d, model, opts={}
			extra_key = opts[:with]
			if d.instance_of?(Hash) && !opts[:embedded]
				# Normalize {:id => :linking_value} to [:id, :linking_value]
				id    = d.keys[0]
				value = d[id]
				d     = [id, value]
			end
			klass = obj = model.to_s.capitalize.constantize
			if opts[:embedded]
				obj = klass.new d
			else
				id  = d.instance_of?(Array) ? d[0] : d
				obj = klass.load id
			end
			obj.define_linking_field extra_key, d[1] if extra_key
			obj
		end

		def define_linking_field field, value
			self.class.module_eval { attr_accessor field.to_sym }
			self.send "#{field}=", value
		end

	end

end