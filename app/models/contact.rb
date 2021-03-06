class Contact < ActiveRecord::Base
  include Redmine::SafeAttributes

  validates :name, :presence => true

  attr_protected :id

  safe_attributes 'name', 'project_id', 'custom_fields', 'custom_field_values'
  acts_as_customizable
  acts_as_attachable delete_permission: :delete_contacts, view_permission: :view_contacts
  belongs_to :project

  acts_as_event :datetime => :updated_at,
                :description => nil,
                :title => Proc.new {|o| "#{l(:label_contact_name)} #{o.name}"},
                :url => Proc.new {|o| {:controller => 'contacts', :action => 'show', :id => o, :project_id => o.project_id}},
                :author => nil

  acts_as_activity_provider :type => 'contacts',
                            :permission => nil,
                            :timestamp => :updated_at,
                            :author_key => nil,
                            :scope => joins(:project)

  acts_as_searchable :columns => "#{table_name}.name", :date_column => 'created_at'

  scope :visible, lambda {|*args|
    joins(:project).
        where(Project.allowed_to_condition(args.shift || User.current, :view_contacts, *args))}

  # Returns true if the contact can be edited by user, otherwise false
  def editable_by?(usr)
    usr.allowed_to?(:edit_contact, project) || usr.allowed_to?(:delete_contacts, project)
  end
end