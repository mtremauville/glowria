# app/controllers/conflicts_controller.rb
class ConflictsController < ApplicationController
  before_action :authenticate_user!

  def index
    all = ConflictAnalyzerService.new(current_user).analyze
    @conflicts_by_severity = all.group_by { |c| c[:severity] }
    @conflict_count        = all.count
  end
end
