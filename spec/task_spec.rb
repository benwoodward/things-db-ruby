require 'spec_helper'

describe Task do
  describe '#tags_sorted_by_importance' do
    xit 'sorts all tags into an array with urg: tags at the front' do
      # imp: tags
      low_importance_tag     = double(title: 'imp:low')
      medium_importance_tag  = double(title: 'imp:medium')
      high_importance_tag    = double(title: 'imp:high')
      asap_importance_tag    = double(title: 'imp:critical')
      random_tag          = double(title: 'randomstring')

      # task = described_class.new(tags: [
      #   low_importance_tag,
      #   medium_importance_tag,
      #   high_importance_tag,
      #   asap_importance_tag,
      #   random_tag
      # ])

      # expect(task.tags_sorted_by_importance).to be_an(Array)
    end
  end
end
