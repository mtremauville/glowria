# app/controllers/conflicts_controller.rb
class ConflictsController < ApplicationController
  before_action :authenticate_user!

  def index
    service = ConflictAnalyzerService.new(current_user)

    conflicts = service.analyze
    @conflicts_by_severity = conflicts.group_by { |c| c[:severity] }
    @conflict_count        = conflicts.count

    synergies = service.analyze_synergies
    @synergies_by_severity = synergies.group_by { |c| c[:severity] }
    @synergy_count         = synergies.count
  end
end
