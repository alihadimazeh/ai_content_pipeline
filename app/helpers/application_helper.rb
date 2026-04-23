module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true, fenced_code_blocks: true)
    markdown.render(text).html_safe
  end

  FORMAT_HUES = {
    "tweet_thread"     => 200,
    "linkedin_post"    => 260,
    "blog_outline"     => 140,
    "email_newsletter" => 30
  }.freeze

  def format_hue(format)
    FORMAT_HUES[format] || 70
  end

  def time_of_day
    hour = Time.current.hour
    if hour < 12 then "morning"
    elsif hour < 17 then "afternoon"
    else "evening"
    end
  end

  def status_chip(status)
    label = status.humanize
    content_tag(:span, class: "status-chip #{status}") do
      content_tag(:span, "", class: "dot") + label
    end
  end
end
