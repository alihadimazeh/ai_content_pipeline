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

  FORMAT_ICONS = {
    "tweet_thread"     => '<path d="M22 5.8a8 8 0 0 1-2.3.7 4 4 0 0 0 1.8-2.2 8 8 0 0 1-2.6 1A4 4 0 0 0 12 9a11 11 0 0 1-8-4s-4 9 5 13a12 12 0 0 1-7 2c9 5 20 0 20-11.5 0-.2 0-.5-.1-.7A6 6 0 0 0 22 5.8z"/>',
    "linkedin_post"    => '<rect x="3" y="3" width="18" height="18" rx="3"/><path d="M8 10v7M8 7.5v.01M12 17v-4a2.5 2.5 0 0 1 5 0v4M12 11v6"/>',
    "blog_outline"     => '<path d="M5 3h10l4 4v14H5z"/><path d="M15 3v4h4"/><path d="M9 12h6M9 16h6M9 8h3"/>',
    "email_newsletter" => '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>'
  }.freeze

  def format_icon(format)
    paths = FORMAT_ICONS[format] || ""
    %(<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">#{paths}</svg>).html_safe
  end

  def status_chip(status)
    label = status.humanize
    content_tag(:span, class: "status-chip #{status}") do
      content_tag(:span, "", class: "dot") + label
    end
  end
end
