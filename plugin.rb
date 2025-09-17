# frozen_string_literal: true

# name: custom-toolbar-modal
# about: 为编辑器工具栏添加自定义按钮，支持抽奖活动创建和管理
# meta_topic_id: TODO
# version: 1.0.0
# authors: Your Name
# url: https://github.com/joo2017/custom-toolbar-modal
# required_version: 2.7.0

enabled_site_setting :custom_toolbar_modal_enabled

# 注册 SVG 图标
register_svg_icon "fas-gift" if respond_to?(:register_svg_icon)
register_svg_icon "fas-dice" if respond_to?(:register_svg_icon)

# 注册样式文件
register_asset 'stylesheets/common/lottery.scss'
register_asset 'stylesheets/mobile/lottery.scss', :mobile

after_initialize do
  # 添加路由
  Discourse::Application.routes.append do
    namespace :lottery, defaults: { format: :json } do
      resources :events, only: [:create, :update, :destroy, :show] do
        member do
          post :draw_winners
          post :cancel_event
        end
      end
      resources :winners, only: [:index]
    end
  end

  # 模型定义
  class ::LotteryEvent < ActiveRecord::Base
    belongs_to :post
    has_many :lottery_winners, dependent: :destroy
    has_many :winner_users, through: :lottery_winners, source: :user
    
    has_one :topic, through: :post
    has_one :creator, through: :post, source: :user

    validates :activity_name, presence: true, length: { maximum: 200 }
    validates :prize_description, presence: true, length: { maximum: 1000 }
    validates :draw_time, presence: true
    validates :winner_count, presence: true, numericality: { greater_than: 0 }
    validates :participation_threshold, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :backup_strategy, inclusion: { in: %w[continue cancel] }
    validates :status, inclusion: { in: %w[pending active drawn cancelled] }

    validate :draw_time_must_be_future, on: :create
    validate :specific_floors_format

    scope :active, -> { where(status: 'active') }
    scope :pending_draw, -> { where(status: 'active').where('draw_time <= ?', Time.current) }

    def specific_floor_numbers
      return [] if specific_floors.blank?
      specific_floors.split(',').map(&:strip).map(&:to_i).reject(&:zero?)
    end

    def can_draw?
      status == 'active' && draw_time <= Time.current
    end

    def sufficient_participants?
      topic.posts.count >= participation_threshold
    end

    def is_specific_floor_lottery?
      specific_floors.present? && specific_floor_numbers.any?
    end

    private

    def draw_time_must_be_future
      return unless draw_time.present?
      
      if draw_time <= Time.current
        errors.add(:draw_time, I18n.t('lottery.errors.draw_time_must_be_future'))
      end
    end

    def specific_floors_format
      return if specific_floors.blank?
      
      begin
        floors = specific_floor_numbers
        if floors.empty?
          errors.add(:specific_floors, I18n.t('lottery.errors.invalid_floor_format'))
        elsif floors.any? { |f| f <= 0 }
          errors.add(:specific_floors, I18n.t('lottery.errors.floor_must_be_positive'))
        end
      rescue
        errors.add(:specific_floors, I18n.t('lottery.errors.invalid_floor_format'))
      end
    end
  end

  class ::LotteryWinner < ActiveRecord::Base
    belongs_to :lottery_event
    belongs_to :user

    validates :floor_number, presence: true, numericality: { greater_than: 0 }
    validates :win_type, inclusion: { in: %w[random specific] }
  end

  # 序列化器
  class ::LotteryEventSerializer < ApplicationSerializer
    attributes :id, :activity_name, :prize_description, :prize_image_url,
               :draw_time, :winner_count, :specific_floors, :participation_threshold,
               :backup_strategy, :additional_notes, :status, :created_at

    has_one :creator, serializer: BasicUserSerializer
    has_many :lottery_winners, serializer: :lottery_winner

    def lottery_winners
      object.lottery_winners.includes(:user)
    end
  end

  class ::LotteryWinnerSerializer < ApplicationSerializer
    attributes :id, :floor_number, :win_type, :created_at
    has_one :user, serializer: BasicUserSerializer
  end

  # 控制器
  class ::Lottery::EventsController < ApplicationController
    requires_plugin 'custom-toolbar-modal'
    before_action :ensure_logged_in
    before_action :find_post, only: [:create, :update, :destroy]
    before_action :find_lottery_event, only: [:show, :update, :destroy, :draw_winners, :cancel_event]

    def show
      guardian.ensure_can_see!(@lottery_event.post)
      render json: LotteryEventSerializer.new(@lottery_event)
    end

    def create
      guardian.ensure_can_edit!(@post)

      @lottery_event = LotteryEvent.new(lottery_event_params)
      @lottery_event.post = @post
      @lottery_event.status = 'active'

      if @lottery_event.save
        # 更新帖子内容，嵌入抽奖信息
        Jobs.enqueue(:update_post_with_lottery, post_id: @post.id, lottery_event_id: @lottery_event.id)
        render json: LotteryEventSerializer.new(@lottery_event)
      else
        render json: { errors: @lottery_event.errors }, status: 422
      end
    end

    def update
      guardian.ensure_can_edit!(@lottery_event.post)
      
      if @lottery_event.update(lottery_event_params)
        Jobs.enqueue(:update_post_with_lottery, post_id: @lottery_event.post_id, lottery_event_id: @lottery_event.id)
        render json: LotteryEventSerializer.new(@lottery_event)
      else
        render json: { errors: @lottery_event.errors }, status: 422
      end
    end

    def destroy
      guardian.ensure_can_edit!(@lottery_event.post)
      
      @lottery_event.update!(status: 'cancelled')
      Jobs.enqueue(:remove_lottery_from_post, post_id: @lottery_event.post_id)
      
      render json: { success: true }
    end

    def draw_winners
      guardian.ensure_can_edit!(@lottery_event.post)

      unless @lottery_event.can_draw?
        return render json: { error: I18n.t('lottery.errors.cannot_draw') }, status: 422
      end

      draw_service = LotteryDrawService.new(@lottery_event)
      result = draw_service.execute

      if result[:success]
        render json: { 
          winners: result[:winners].map { |w| LotteryWinnerSerializer.new(w) },
          message: result[:message]
        }
      else
        render json: { error: result[:error] }, status: 422
      end
    end

    def cancel_event
      guardian.ensure_can_edit!(@lottery_event.post)
      
      if @lottery_event.status == 'drawn'
        return render json: { error: I18n.t('lottery.errors.already_drawn') }, status: 422
      end

      @lottery_event.update!(status: 'cancelled')
      render json: { success: true }
    end

    private

    def find_post
      @post = Post.find(params[:post_id])
    end

    def find_lottery_event
      @lottery_event = LotteryEvent.find(params[:id])
    end

    def lottery_event_params
      params.require(:lottery_event).permit(
        :activity_name, :prize_description, :prize_image_url, :draw_time,
        :winner_count, :specific_floors, :participation_threshold,
        :backup_strategy, :additional_notes
      )
    end
  end

  # 抽奖服务类
  class ::LotteryDrawService
    def initialize(lottery_event)
      @lottery_event = lottery_event
      @topic = lottery_event.topic
    end

    def execute
      return { success: false, error: I18n.t('lottery.errors.already_drawn') } if @lottery_event.status == 'drawn'
      
      participants = get_participants
      
      # 检查参与人数是否足够
      if participants.count < @lottery_event.participation_threshold
        return handle_insufficient_participants
      end

      winners = if @lottery_event.is_specific_floor_lottery?
                  draw_specific_floor_winners(participants)
                else
                  draw_random_winners(participants)
                end

      if winners.any?
        @lottery_event.update!(status: 'drawn')
        create_winner_records(winners)
        notify_winners(winners)
        
        { success: true, winners: @lottery_event.lottery_winners.includes(:user), message: I18n.t('lottery.draw_success') }
      else
        { success: false, error: I18n.t('lottery.errors.no_winners') }
      end
    end

    private

    def get_participants
      @topic.posts
            .includes(:user)
            .where('post_number >= ?', @lottery_event.participation_threshold)
            .where('user_id IS NOT NULL')
    end

    def handle_insufficient_participants
      if @lottery_event.backup_strategy == 'cancel'
        @lottery_event.update!(status: 'cancelled')
        { success: false, error: I18n.t('lottery.errors.cancelled_insufficient_participants') }
      else
        # 继续开奖，用现有参与者
        participants = get_participants
        winners = draw_random_winners(participants)
        
        @lottery_event.update!(status: 'drawn')
        create_winner_records(winners)
        
        { success: true, winners: @lottery_event.lottery_winners.includes(:user), 
          message: I18n.t('lottery.draw_success_with_warning') }
      end
    end

    def draw_specific_floor_winners(participants)
      winners = []
      floor_numbers = @lottery_event.specific_floor_numbers

      floor_numbers.each do |floor_num|
        post = participants.find { |p| p.post_number == floor_num }
        if post && post.user
          winners << { user: post.user, floor_number: floor_num, win_type: 'specific' }
        end
      end

      winners
    end

    def draw_random_winners(participants)
      winner_count = [@lottery_event.winner_count, participants.count].min
      selected_posts = participants.to_a.sample(winner_count)
      
      selected_posts.map do |post|
        { user: post.user, floor_number: post.post_number, win_type: 'random' }
      end
    end

    def create_winner_records(winners)
      winners.each do |winner_data|
        LotteryWinner.create!(
          lottery_event: @lottery_event,
          user: winner_data[:user],
          floor_number: winner_data[:floor_number],
          win_type: winner_data[:win_type]
        )
      end
    end

    def notify_winners(winners)
      # 可以在这里实现中奖通知功能
      # 比如发送系统消息或邮件通知
    end
  end

  # 后台任务
  class ::Jobs::UpdatePostWithLottery < ::Jobs::Base
    def execute(args)
      post = Post.find(args[:post_id])
      lottery_event = LotteryEvent.find(args[:lottery_event_id])
      
      lottery_markdown = build_lottery_markdown(lottery_event)
      new_raw = insert_or_replace_lottery(post.raw, lottery_markdown)
      
      cooked = PrettyText.cook(new_raw)
      
      post.revise(
        Discourse.system_user,
        { raw: new_raw, edit_reason: I18n.t("lottery.post_updated") },
        skip_validations: true
      )
    end

    private

    def build_lottery_markdown(lottery_event)
      params = {
        'name' => lottery_event.activity_name,
        'prize' => lottery_event.prize_description,
        'draw-time' => lottery_event.draw_time.iso8601,
        'winner-count' => lottery_event.winner_count.to_s,
        'threshold' => lottery_event.participation_threshold.to_s,
        'strategy' => lottery_event.backup_strategy
      }

      params['floors'] = lottery_event.specific_floors if lottery_event.specific_floors.present?
      params['image'] = lottery_event.prize_image_url if lottery_event.prize_image_url.present?
      params['notes'] = lottery_event.additional_notes if lottery_event.additional_notes.present?

      markdown_params = params.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      "[lottery #{markdown_params}]\n[/lottery]"
    end

    def insert_or_replace_lottery(raw, lottery_markdown)
      # 移除现有的抽奖标记
      cleaned_raw = raw.gsub(/\[lottery[^\]]*\].*?\[\/lottery\]/m, '')
      
      # 在帖子开头添加新的抽奖标记
      "#{lottery_markdown}\n\n#{cleaned_raw.strip}"
    end
  end

  class ::Jobs::RemoveLotteryFromPost < ::Jobs::Base
    def execute(args)
      post = Post.find(args[:post_id])
      
      new_raw = post.raw.gsub(/\[lottery[^\]]*\].*?\[\/lottery\]/m, '').strip
      
      post.revise(
        Discourse.system_user,
        { raw: new_raw, edit_reason: I18n.t("lottery.removed") },
        skip_validations: true
      )
    end
  end

  # 扩展 Post 模型
  add_to_class(:post, :lottery_event) do
    LotteryEvent.find_by(post: self)
  end

  # 帖子钩子
  on(:post_created) do |post|
    # 提取并处理抽奖信息（如果需要从markdown解析）
  end

  on(:post_edited) do |post|
    # 更新抽奖信息（如果需要）
  end

  on(:post_destroyed) do |post|
    if post.lottery_event
      post.lottery_event.update!(status: 'cancelled')
    end
  end
end
