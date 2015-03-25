class Monologue::Admin::PostsController < Monologue::Admin::BaseController
  before_filter :load_post, only: [:edit, :update]

  def index
    @posts = Monologue::Post.default.includes(:user)
    respond_to {|f| f.html}
  end

  def new
    @post = Monologue::Post.new
    respond_to {|f| f.html}
  end

  ## Preview a post without saving.
  def preview
    # mockup our models for preview.
    @post = Monologue::Post.new post_params
    @post.user_id = monologue_current_user.id
    @post.published_at = Time.zone.now
    # render it exactly as it would display when live.
    respond_to do |f| 
      f.html { render "/monologue/posts/show", layout: Monologue::Config.layout || "/layouts/monologue/application" }
    end
  end

  def create
    respond_to do |f| 
      f.html do
        @post = Monologue::Post.new post_params
        @post.user_id = monologue_current_user.id
        if @post.save
          prepare_flash_and_redirect_to_edit()
        else
          render :new
        end
      end
    end
  end

  def edit
    respond_to {|f| f.html}
  end

  def update
    respond_to do |f| 
      f.html do
        if @post.update(post_params)
          prepare_flash_and_redirect_to_edit()
        else
          render :edit
        end
      end
    end
  end

  def destroy
    respond_to do |f| 
      post = Monologue::Post.find(params[:id])
      f.html do
        if post.destroy
          redirect_to admin_posts_path, notice:  I18n.t("monologue.admin.posts.delete.removed")
        else
          redirect_to admin_posts_path, alert: I18n.t("monologue.admin.posts.delete.failed")
        end
      end
    end
  end

  private
  def load_post
    @post = Monologue::Post.find(params[:id])
  end

  def prepare_flash_and_redirect_to_edit
    if @post.published_in_future? && ActionController::Base.perform_caching
      flash[:warning] = I18n.t("monologue.admin.posts.#{params[:action]}.saved_with_future_date_and_cache")
    else
      flash[:notice] =  I18n.t("monologue.admin.posts.#{params[:action]}.saved")
    end
    redirect_to edit_admin_post_path(@post)
  end

  def post_params
    params.require(:post).permit(:published, :tag_list,:title,:content,:url,:published_at)
  end
end
