# app/controllers/lottery_events_controller.rb
class LotteryEventsController < ApplicationController
  requires_plugin 'custom-toolbar-modal'
  before_action :ensure_logged_in
  before_action :find_post, only: [:create, :update, :destroy]

  def create
    guardian.ensure_can_edit!(@post)

    @lottery_event = LotteryEvent.new(lottery_event_params)
    @lottery_event.post = @post
    @lottery_event.status = 'active'

    if @lottery_event.save
      # 更新帖子内容，嵌入抽奖信息
      update_post_with_lottery_info(@post, @lottery_event)
      render json: LotteryEventSerializer.new(@lottery_event)
    else
      render json: { errors: @lottery_event.errors }, status: 422
    end
  end

  def update
    guardian.ensure_can_edit!(@post)
    
    if @post.lottery_event.update(lottery_event_params)
      update_post_with_lottery_info(@post, @post.lottery_event)
      render json: LotteryEventSerializer.new(@post.lottery_event)
    else
      render json: { errors: @post.lottery_event.errors }, status: 422
    end
  end

  def draw_winners
    lottery_event = LotteryEvent.find(params[:id])
    guardian.ensure_can_edit!(lottery_event.post)

    unless lottery_event.can_draw?
      return render json: { error: 'Cannot draw winners at this time' }, status: 422
    end

    draw_service = LotteryDrawService.new(lottery_event)
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

  private

  def find_post
    @post = Post.find(params[:post_id])
  end

  def lottery_event_params
    params.require(:lottery_event).permit(
      :activity_name, :prize_description, :prize_image_url, :draw_time,
      :winner_count, :specific_floors, :participation_threshold,
      :backup_strategy, :additional_notes
    )
  end

  def update_post_with_lottery_info(post, lottery_event)
    # 类似 Calendar 插件，将抽奖信息嵌入到帖子内容中
    lottery_markdown = build_lottery_markdown(lottery_event)
    new_raw = insert_or_replace_lottery(post.raw, lottery_markdown)
    
    TextLib.cookAsync(new_raw).then do |cooked|
      post.update!(
        raw: new_raw,
        cooked: cooked.string,
        edit_reason: I18n.t("lottery.post_updated")
      )
    end
  end

  def build_lottery_markdown(lottery_event)
    params = {
      'name' => lottery_event.activity_name,
      'prize' => lottery_event.prize_description,
      'draw-time' => lottery_event.draw_time.iso8601,
      'winner-count' => lottery_event.winner_count,
      'threshold' => lottery_event.participation_threshold,
      'strategy' => lottery_event.backup_strategy
    }

    params['floors'] = lottery_event.specific_floors if lottery_event.specific_floors.present?
    params['image'] = lottery_event.prize_image_url if lottery_event.prize_image_url.present?
    params['notes'] = lottery_event.additional_notes if lottery_event.additional_notes.present?

    markdown_params = params.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
    "[lottery #{markdown_params}]\n[/lottery]"
  end
end
