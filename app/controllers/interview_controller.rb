class InterviewController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :list, :edit_interview, :my_interviews, :delete]
  def new
    @interview = Interview.new
  end

  def show
    @interview = Interview.find(params[:id])
    @questions = @interview.questions
  end

  def my_interviews
    @my_applied_interviews = Apply.where(:user_id => current_user.id)
  end

  def create
    #TODO: you should create a function like Interview.parse(param), Question.parse(param), Answer.parse(params) to analyse the parameters to create interview, with questions and answers
    @interview = Interview.new(:title => params[:interview][:title],:start_date => params[:interview][:start_date],:user_id => current_user.id,
                               :due_date => params[:interview][:due_date], :time_test => params[:interview][:time_test])
    @question = Question.new
    if @interview.save
      params[:interview][:questions].each do |key,value|
        @question.create_questions(value,@interview.id)
      end
      redirect_to "/"
    else
      redirect_to '/interview/new'
    end
  end

  def delete
    @inprogress_interview = Interview.where("start_date <= ?",Time.zone.now.to_date)
    @interview = Interview.find(params[:id])
    if @interview.destroy()
      respond_to do |format|
        format.js {
          @return_content = render_to_string(:partial => "/home/body_inprogress_interviews",:locals => {:inprogress_interview => @inprogress_interview})
        }
      end
    end
  end

  def edit
    @interview = Interview.find(params[:id])
    @questions = @interview.questions
  end

  def update
    @question = Question.new
    @interview = Interview.find(params[:interview][:id])
    @interview.update_attributes(:title => params[:interview][:title],:start_date => params[:interview][:start_date],
    :due_date => params[:interview][:due_date], :time_test => params[:interview][:time_test])
    if params[:interview][:questions]
      params[:interview][:questions].each do |key,value|
        @question.create_questions_on_edit(value,)
      end
    end
    if @interview.valid?
      redirect_to :controller => "interview", :action => "show", :id => params[:interview][:id]
    else
      redirect_to :controller => "interview", :action => "edit", :id => params[:interview][:id]
    end
  end
end
