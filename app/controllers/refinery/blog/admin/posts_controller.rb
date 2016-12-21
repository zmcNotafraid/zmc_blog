# -*- encoding : utf-8 -*-
module Refinery
  module Blog
    module Admin
      class PostsController < ::Refinery::AdminController
        cache_sweeper Refinery::BlogSweeper

        crudify :'refinery/blog/post',
                :order => 'published_at DESC'

        before_filter :find_all_categories,
                      :only => [:new, :edit, :create, :update]

        before_filter :check_category_ids, :only => :update

        def uncategorized
          @posts = Refinery::Blog::Post.uncategorized.page(params[:page])
        end

        def tags
          if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
            op = '~*'
            wildcard = '.*'
          else
            op = 'LIKE'
            wildcard = '%'
          end

          @tags = Refinery::Blog::Post.tag_counts_on(:tags).where(
              ["tags.name #{op} ?", "#{wildcard}#{params[:term].to_s.downcase}#{wildcard}"]
            ).map { |tag| {:id => tag.id, :value => tag.name}}
          render :json => @tags.flatten
        end

        def preview
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_styles: true,
                                             hard_wrap: true,
                                             autolink: true,
                                             fenced_code_blocks: true,
                                             strikethrough: true,
                                             underline: true,
                                             superscript: true,
                                             tables: true,
                                             footnotes: true,
                                             lax_spacing: true,
                                             space_after_headers: true,
                                             disable_indented_code_blocks: true,
                                             no_intra_emphasis: true
                                            )
          result = markdown.render(params[:md])
          render plain: result
        end

        def new
          @post = ::Refinery::Blog::Post.new(:author => current_refinery_user)
        end

        def edit
          result = HTMLPage.new :contents => @post.body
          @post.body = result.markdown
        end

        def update
          @post.update_attribute :body, params[:post][:body]
          @post.update_attribute :markdown, params[:post][:body]
          if Refinery::Categorization.find_by_blog_post_id(@post.id)
            Refinery::Categorization.find_by_blog_post_id(@post.id).update_attributes(:blog_category_id => params[:post][:category_ids].first)
          else
            Refinery::Categorization.create(:blog_category_id => params[:post][:category_ids].first, :blog_post_id => @post.id)
          end
          redirect_back_or_default(refinery.blog_admin_posts_path)
        end

        def create
          # if the position field exists, set this object as last object, given the conditions of this class.
          if Refinery::Blog::Post.column_names.include?("position")
            params[:post].merge!({
              :position => ((Refinery::Blog::Post.maximum(:position, :conditions => "")||-1) + 1)
            })
          end
          params[:post][:markdown] = params[:post][:body]
          if (@post = Refinery::Blog::Post.create(params[:post])).valid?
            (request.xhr? ? flash.now : flash).notice = t(
              'refinery.crudify.created',
              :what => "'#{@post.title}'"
            )

            unless from_dialog?
              unless params[:continue_editing] =~ /true|on|1/
                redirect_back_or_default(refinery.blog_admin_posts_path)
              else
                unless request.xhr?
                  redirect_to :back
                else
                  render :partial => "/shared/message"
                end
              end
            else
              render :text => "<script>parent.window.location = '#{refinery.blog_admin_posts_url}';</script>"
            end
          else
            unless request.xhr?
              render :action => 'new'
            else
              render :partial => "/refinery/admin/error_messages",
                     :locals => {
                       :object => @post,
                       :include_object_name => true
                     }
            end
          end
        end

      protected
        def find_all_categories
          @categories = Refinery::Blog::Category.find(:all)
        end

        def check_category_ids
          params[:post][:category_ids] ||= []
        end
      end
    end
  end
end
