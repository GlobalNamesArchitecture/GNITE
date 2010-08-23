module GnaclrClassificationsHelper
  def author_line_for_classification(classification)
    raw(classification.authors.map do |author|
      full_name = "#{author['first_name']} #{author['last_name']}"

      if author['email'].present?
        mail_to author['email'], full_name
      else
        full_name
      end
    end.to_sentence)
  end
end
