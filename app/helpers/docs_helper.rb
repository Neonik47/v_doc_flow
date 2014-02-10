module DocsHelper
  def event_simple?(event)
    return case event
    when :edit, :to_review, :accept, :to_executed
      true
    else
      false
    end
  end

  def with_change_responsible(event)
    return case event
    when :change_responsible
      true
    else
      false
    end
  end

  def event_path(event)
    return case event
      when :edit
        edit_doc_path
      when :change_responsible
        change_responsible_doc_path
      when :to_review
        to_review_doc_path
      when :reject
        reject_doc_path
      when :to_revision
        to_revision_doc_path
      when :accept
        accept_doc_path
      when :to_execution
        to_execution_doc_path
      when :to_confirmation_of_execution
        to_confirmation_of_execution_doc_path
      when :to_executed
        to_executed_doc_path
      else
        root_path
    end
  end

  def link_to_event(event, doc)
    res = case event
      when :edit
        {u: edit_doc_path(doc)}
      when :change_responsible
        {u: change_responsible_doc_path(doc)}
      when :to_review
        {u: to_review_doc_path(doc)}
      when :reject
        {u: reject_doc_path(doc), c: "btn btn-danger"}
      when :to_revision
        {u: to_revision_doc_path(doc)}
      when :accept
        {u: accept_doc_path(doc), c: "btn btn-success"}
      when :to_execution
        {u: to_execution_doc_path(doc)}
      when :to_confirmation_of_execution
        {u: to_confirmation_of_execution_doc_path(doc)}
      when :to_executed
        {u: to_executed_doc_path(doc), c: "btn btn-success"}
    end

    link_to t(event), res[:u], class: res[:c] || "btn btn-primary"
  end

end
