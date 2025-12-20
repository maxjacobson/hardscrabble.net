# requires `brew install imagemagick`
# generates opengraph preview images for posts that don't already have one

require "shellwords"

class GeneratePreview
  def initialize(post)
    @post = post
  end

  def write
    return if File.exist?("tmp/#{path}")

    font = ENV["OPENGRAPH_FONT"] || "Helvetica"

    # Color palette
    charcoal = "#000"
    sunset = "#ff6b35"
    yellow_foam = "#fafaf8"

    # Random angle between -60 and 60 degrees for variety
    angle = rand(-60..60)

    cmd = <<~CMD.chomp
      magick \
        -size 1200x630 gradient:"#{sunset}"-"#{yellow_foam}" \
        -rotate #{angle} \
        -crop 1200x630+0+0 +repage \
        \\( -background none -font "#{font}" -fill "#{charcoal}" -size 1100x480 -gravity SouthWest "caption:#{Shellwords.shellescape title}" \\) \
        -gravity center -composite \
        -font "#{font}" -fill "#{sunset}" -pointsize 30 -gravity SouthWest -annotate +30+30 "hardscrabble.net" \
        tmp/#{path}
    CMD

    system(cmd) or raise "Failed for #{slug}"
  end

  def path
    "img/preview/#{date}-#{slug}.png"
  end

  private

  attr_reader :post

  def date
    post.date.strftime("%Y-%m-%d")
  end

  def slug
    post.data.fetch("slug")
  end

  def title
    post.data.fetch("title")
  end
end

def assert_exists!(file, preview_image)
  return if File.exist?(preview_image)

  warn <<~MSG
    [Preview image] #{file} references preview image #{preview_image} but that file does not exist
  MSG

  exit 1
end

Jekyll::Hooks.register :posts, :pre_render do |post|
  if (preview_image = post.data["preview_image"])
    assert_exists!(post.path, preview_image)
  else
    preview = GeneratePreview.new(post)
    preview.write
    post.merge_data!({ "preview_image" => preview.path }, source: "opengraph plugin")
  end
end

Jekyll::Hooks.register :site, :after_init do
  FileUtils.mkdir_p "tmp/img/preview"
end

Jekyll::Hooks.register :posts, :post_write do |post|
  FileUtils.mkdir_p("_site/img/preview")
  path = post.data.fetch("preview_image")
  FileUtils.cp "tmp/#{path}", "_site/#{path}"
end
