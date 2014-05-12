class DocFilter

=begin
Имя *
Отправитель *
Исполнитель *
Статус *
Тип документа *
Входящий номер
Исходящий номер
Отдел отправитель
=end

  attr_accessor :user_id, :sender_id, :executor_id, :state, :doc_type_id,
                :name, :in_num, :out_num, :department, :current_user

  def initialize(params = {}, current_user)
    puts "\n\n\n\n",params,"\n\n\n\n"
    self.current_user = current_user
    options = params || {}
    self.user_id = options[:user_id]
    self.sender_id = options[:sender_id]
    self.executor_id = options[:executor_id]
    self.state = options[:state]
    self.doc_type_id = options[:doc_type_id]

    self.name = options[:name]
    self.in_num = options[:in_num]
    self.out_num = options[:out_num]
    self.department = options[:department]
  end

  def search
    q = Doc.or(
        {responsibles: current_user.id}, {user_id: current_user.id}, {is_public: true}
      ).order_by(:created_at.asc)

    q = q.where(name: /^#{Regexp.escape(name.to_s).gsub(/\\\?/, ".").gsub(/\\\*/, ".*")}/) unless name.blank?
    q = q.where(in_num: /^#{Regexp.escape(in_num.to_s).gsub(/\\\?/, ".").gsub(/\\\*/, ".*")}/) unless in_num.blank?
    q = q.where(out_num: /^#{Regexp.escape(out_num.to_s).gsub(/\\\?/, ".").gsub(/\\\*/, ".*")}/) unless out_num.blank?
    q = q.where(department: /^#{Regexp.escape(department.to_s).gsub(/\\\?/, ".").gsub(/\\\*/, ".*")}/) unless department.blank?

    q = q.where(user_id: user_id) unless user_id.blank?
    q = q.where(doc_type_id: doc_type_id) unless doc_type_id.blank?
    q = q.where(sender_id: sender_id) unless sender_id.blank?
    q = q.where(executor_id: executor_id) unless executor_id.blank?
    q = q.where(state: /^#{state}/) unless state.blank?

    # q = q.where(:c_at.gt => ::Time.utc(register_date_since.year, register_date_since.month, register_date_since.day)) unless register_date_since.blank?
    # q = q.where(:c_at.lt => ::Time.utc(register_date_to.year, register_date_to.month, register_date_to.day).end_of_day()) unless register_date_to.blank?

    return q

  rescue Mongoid::Errors::DocumentNotFound
    render(:status => 404, :layout => false, :nothing => true)
  end

  def q_params
    params = {department_id: @selected_department_id,
              source_id: source_id,
              register_date_since: register_date_since,
              register_date_to: register_date_to,
              executor_id: executor_id,
              notes: notes,
              state: state}
    {issue_filter: params}.with_indifferent_access
  end

end
