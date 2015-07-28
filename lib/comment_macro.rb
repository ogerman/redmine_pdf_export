Redmine::WikiFormatting::Macros.register do
  desc "Comment macro, displayed only at editing mode"
  macro :_ do |obj, args, text|
    ""
  end

  macro :comment do |obj, args, text|
    ""
  end

end
