class AddMarkDownToRefineryBlogPost < ActiveRecord::Migration
  def change
    add_column :refinery_blog_posts, :markdown, :text
  end
end
